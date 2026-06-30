extends Node
class_name FactoryController

# ==================================================
# CONFIG
# ==================================================
@export var conveyor_path: NodePath
@export var conveyor_paths: Array[NodePath] = []
@export var spawner_path: NodePath
@export var robot_arm_path: NodePath
@export var robot_arm_paths: Array[NodePath] = []
@export var robot_arm_labels: Array[String] = []
@export var cart_path: NodePath
@export var cart_spawner_path: NodePath
@export var cart_dispatcher_mode: bool = false
@export var diverter_gate_path: NodePath
@export var weight_sensor_path: NodePath
@export var color_sensor_path: NodePath

# ==================================================
# SIGNALS
# ==================================================
signal command_emitted(command: String)
signal sensor_updated(data: Dictionary)
signal action_finished(action_name: String)

# ==================================================
# INTERNAL REFERENCES
# ==================================================
var _conveyor: Node
var _conveyors: Array[Node] = []
var _spawner: BoxSpawner
var _robot_arm: RobotArm
var _robot_arms: Array[RobotArm] = []
var _robot_arm_label_map: Dictionary = {} # lower(label) -> RobotArm
var _cart: RodCart
var _cart_spawner: CartSpawner
var _active_cart: RodCart
var _active_cart_returning_home: bool = false
var _active_cart_job_id: int = 0
var _next_cart_job_id: int = 1
var _cart_template_commands: Array[String] = []
var _cart_template_ready: bool = false
var _cart_template_recording: bool = false
var _cart_runtime_swallowing_template: bool = false
var _pending_cart_jobs: Array = []
var _running_cart_jobs: Dictionary = {}
var _dispatched_cart_box_ids: Dictionary = {}
var _diverter_gate: Node
var _weight_sensor: Node
var _color_sensor: Node
var _consumed_sensor_box_ids: Dictionary = {}

# ==================================================
# LIFECYCLE
# ==================================================
func _ready() -> void:
	print("FactoryController ready")

	_resolve_conveyors()
	_resolve_spawner()
	_resolve_robot_arms()
	_resolve_cart()
	_resolve_cart_spawner()
	_resolve_diverter_gate()

	_bind_conveyors()
	_bind_sensors()
	_bind_robot_arms()
	_bind_cart()
	_sync_spawner_with_conveyor()

func _process(_delta: float) -> void:
	if cart_dispatcher_mode:
		_try_start_pending_cart_jobs()

# ==================================================
# RESOLVE NODES
# ==================================================
func _resolve_conveyors() -> void:
	_conveyors.clear()
	_conveyor = null

	# Preferred config: explicit conveyor_paths array.
	if not conveyor_paths.is_empty():
		var idx := 1
		for path in conveyor_paths:
			if path == NodePath():
				push_error("FactoryController: conveyor_paths[%d] is empty" % idx)
				idx += 1
				continue
			var node := get_node_or_null(path)
			if node == null:
				push_error("FactoryController: conveyor_paths[%d] not found: %s" % [idx, str(path)])
				idx += 1
				continue
			if not node.has_method("handle_command"):
				push_error("FactoryController: conveyor_paths[%d] missing handle_command(command: String)" % idx)
				idx += 1
				continue
			_conveyors.append(node)
			idx += 1

		if _conveyors.is_empty():
			push_error("FactoryController: no valid conveyors in conveyor_paths")
			return
		_conveyor = _conveyors[0]
		print("Conveyors resolved from conveyor_paths:", _conveyors.size())
		for i in range(_conveyors.size()):
			print("  conveyor[%d] -> %s" % [i + 1, _conveyors[i].name])
		return

	# Backward compatibility: single conveyor_path.
	if conveyor_path == NodePath():
		print("Conveyor not assigned")
		return

	_conveyor = get_node_or_null(conveyor_path)
	if _conveyor == null:
		push_error("FactoryController: conveyor not found")
		_conveyor = null
		return
	if not _conveyor.has_method("handle_command"):
		push_error("FactoryController: conveyor missing handle_command(command: String)")
		_conveyor = null
		return
	_conveyors.append(_conveyor)

	# Convenience fallback:
	# If this station contains additional conveyors in group "conveyor", include them
	# after the primary conveyor_path so index mapping still starts from conveyor_path.
	# Scope this search to the same parent as the controller so multiple stations in one
	# scene do not accidentally share conveyor commands.
	# Skip this when primary is a multi-segment router (Conveyor3Way).
	if not (_conveyor is Conveyor3Way):
		var station_root := get_parent()
		if station_root != null:
			for child in station_root.get_children():
				if child == null or child == _conveyor:
					continue
				if not child.is_in_group("conveyor"):
					continue
				if not child.has_method("handle_command"):
					continue
				if _conveyors.has(child):
					continue
				_conveyors.append(child)

	print("Conveyor resolved")
	for i in range(_conveyors.size()):
		print("  conveyor[%d] -> %s" % [i + 1, _conveyors[i].name])

func _resolve_spawner() -> void:
	if spawner_path == NodePath():
		print("Spawner not assigned")
		return

	_spawner = get_node_or_null(spawner_path)
	if _spawner == null or not (_spawner is BoxSpawner):
		push_error("FactoryController: spawner not found or wrong type")
		_spawner = null
		return

	print("Spawner resolved")

func _resolve_robot_arms() -> void:
	_robot_arm = null
	_robot_arms.clear()
	_robot_arm_label_map.clear()

	if not robot_arm_paths.is_empty():
		var idx := 1
		for path in robot_arm_paths:
			if path == NodePath():
				push_error("FactoryController: robot_arm_paths[%d] is empty" % idx)
				idx += 1
				continue
			var node := get_node_or_null(path)
			if node == null or not (node is RobotArm):
				push_error("FactoryController: robot_arm_paths[%d] not found or wrong type: %s" % [idx, str(path)])
				idx += 1
				continue
			_robot_arms.append(node as RobotArm)
			idx += 1
	elif robot_arm_path != NodePath():
		var primary := get_node_or_null(robot_arm_path)
		if primary == null or not (primary is RobotArm):
			push_error("FactoryController: RobotArm not found or wrong type")
		else:
			_robot_arms.append(primary as RobotArm)

	# Fallback discover: include other RobotArm siblings in this scene for multi-arm levels.
	var parent_node := get_parent()
	if parent_node != null:
		for child in parent_node.get_children():
			if not (child is RobotArm):
				continue
			var arm_child := child as RobotArm
			if _robot_arms.has(arm_child):
				continue
			_robot_arms.append(arm_child)

	if _robot_arms.is_empty():
		print("RobotArm not assigned")
		return

	_robot_arm = _robot_arms[0]
	for i in range(_robot_arms.size()):
		var arm := _robot_arms[i]
		var label := ""
		if i < robot_arm_labels.size():
			label = str(robot_arm_labels[i]).strip_edges()
		if label == "":
			label = "arm_%d" % [i + 1]
		_robot_arm_label_map[label.to_lower()] = arm
		# Also allow direct node name usage.
		_robot_arm_label_map[str(arm.name).to_lower()] = arm

	print("RobotArms resolved:", _robot_arms.size())
	for i in range(_robot_arms.size()):
		print("  robot_arm[%d] -> %s" % [i + 1, _robot_arms[i].name])

func _resolve_cart() -> void:
	_cart = null
	if cart_path != NodePath():
		var configured := get_node_or_null(cart_path)
		if configured is RodCart:
			_cart = configured as RodCart
		else:
			push_error("FactoryController: cart_path not found or wrong type")

	if _cart == null:
		var parent_node := get_parent()
		if parent_node != null:
			for child in parent_node.get_children():
				if child is RodCart:
					_cart = child as RodCart
					break

	if _cart != null:
		print("RodCart resolved:", _cart.name)

func _resolve_cart_spawner() -> void:
	_cart_spawner = null
	if cart_spawner_path != NodePath():
		var configured := get_node_or_null(cart_spawner_path)
		if configured is CartSpawner:
			_cart_spawner = configured as CartSpawner
		else:
			push_error("FactoryController: cart_spawner_path not found or wrong type")

	if _cart_spawner == null:
		var parent_node := get_parent()
		if parent_node != null:
			for child in parent_node.get_children():
				if child is CartSpawner:
					_cart_spawner = child as CartSpawner
					break

	if _cart_spawner != null:
		print("CartSpawner resolved:", _cart_spawner.name)

func _resolve_diverter_gate() -> void:
	if diverter_gate_path == NodePath():
		return

	_diverter_gate = get_node_or_null(diverter_gate_path)
	if _diverter_gate == null:
		push_error("FactoryController: DiverterGate not found")
		return
	if not _diverter_gate.has_method("handle_command"):
		push_error("FactoryController: DiverterGate missing handle_command(command: String)")
		_diverter_gate = null
		return

	print("DiverterGate resolved")

# ==================================================
# BINDINGS
# ==================================================
func _bind_conveyors() -> void:
	# Conveyor commands are routed explicitly in _dispatch_conveyor_command()
	# so we do not auto-connect command_emitted -> handle_command here.
	print("FactoryController -> Conveyors bound:", _conveyors.size())

func _bind_sensors() -> void:
	if weight_sensor_path != NodePath():
		_weight_sensor = get_node_or_null(weight_sensor_path)
		if _weight_sensor and _weight_sensor.has_signal("box_detected"):
			_weight_sensor.box_detected.connect(_on_weight_detected)
			print("WeightSensor bound")

	if color_sensor_path != NodePath():
		_color_sensor = get_node_or_null(color_sensor_path)
		if _color_sensor and _color_sensor.has_signal("box_detected"):
			_color_sensor.box_detected.connect(_on_color_detected)
			print("ColorSensor bound")

func _bind_robot_arms() -> void:
	if _robot_arms.is_empty():
		return
	for arm in _robot_arms:
		if arm == null:
			continue
		if arm.has_signal("action_finished"):
			if not arm.action_finished.is_connected(_on_robot_arm_action_finished):
				arm.action_finished.connect(_on_robot_arm_action_finished)
	print("RobotArm -> FactoryController (action_finished):", _robot_arms.size())

func _bind_cart() -> void:
	if _cart != null:
		_connect_cart(_cart)
		print("RodCart -> FactoryController (action_finished):", _cart.name)

func _connect_cart(cart: RodCart) -> void:
	if cart == null:
		return
	if not cart.has_signal("action_finished"):
		return
	var cb := Callable(self, "_on_cart_action_finished").bind(cart)
	if not cart.action_finished.is_connected(cb):
		cart.action_finished.connect(cb)
	if cart.has_signal("action_failed"):
		var fail_cb := Callable(self, "_on_cart_action_failed").bind(cart)
		if not cart.action_failed.is_connected(fail_cb):
			cart.action_failed.connect(fail_cb)

func _sync_spawner_with_conveyor() -> void:
	if _spawner == null:
		return
	if not _spawner.has_method("set_conveyor_running"):
		return
	var is_running := _get_conveyor_running()
	_spawner.set_conveyor_running(is_running)

func _get_conveyor_running() -> bool:
	for conveyor in _conveyors:
		if conveyor == null:
			continue
		if conveyor.has_method("is_running"):
			var state: Variant = conveyor.call("is_running")
			if typeof(state) == TYPE_BOOL and state:
				return true
		var state_prop = conveyor.get("running")
		if typeof(state_prop) == TYPE_BOOL and state_prop:
			return true
	return false

# ==================================================
# COMMAND API (Mini-C entry)
# ==================================================
func send_command(command: String) -> void:
	print("FactoryController received:", command)

	# RobotArm commands
	if command.begins_with("ROTATE_ARM"):
		_handle_rotate_arm(command)
		return

	if command.begins_with("PICK_BOX"):
		_handle_pick_box(command)
		return

	if command.begins_with("DROP_BOX"):
		_handle_drop_box(command)
		return

	if command == "ROD_PICK_BOX":
		if cart_dispatcher_mode:
			_handle_cart_dispatcher_command(command)
			return
		_handle_rod_pick_box()
		return

	if command == "ROD_DROP_BOX":
		if cart_dispatcher_mode:
			_handle_cart_dispatcher_command(command)
			return
		_handle_rod_drop_box()
		return

	if command.begins_with("ROD_MOVE_PATH"):
		if cart_dispatcher_mode:
			_handle_cart_dispatcher_command(command)
			return
		_handle_rod_move_path(command)
		return

	if command.begins_with("ROBOT_MOVE_PATH"):
		_handle_robot_move_path(command)
		return

	if command.begins_with("MOVE_PATH"):
		if cart_dispatcher_mode:
			_handle_cart_dispatcher_command(command)
			return
		_handle_rod_move_path(command)
		return

	# Diverter commands
	if (
		command == "DIVERTER_LEFT"
		or command == "DIVERTER_RIGHT"
		or command == "DIVERTER_OPEN"
		or command == "DIVERTER_CLOSE"
		or command == "SET_DIVERTER_LEFT"
		or command == "SET_DIVERTER_RIGHT"
		or command == "SET_DIVERTER_OPEN"
		or command == "SET_DIVERTER_CLOSE"
	):
		if _diverter_gate:
			_diverter_gate.call("handle_command", command)
		return

	# Spawner commands
	if command == "START_SPAWNER" or command == "STOP_SPAWNER":
		if _spawner:
			print("Forward to BoxSpawner:", command)
			_spawner.handle_command(command)
		return

	# Conveyor commands (supports optional index, e.g. START_CONVEYOR 2)
	if command.begins_with("START_CONVEYOR") or command.begins_with("STOP_CONVEYOR"):
		_dispatch_conveyor_command(command)
		if _spawner and _spawner.has_method("set_conveyor_running"):
			_spawner.set_conveyor_running(_get_conveyor_running())
		return

	command_emitted.emit(command)

func _handle_rotate_arm(command: String) -> void:
	if _robot_arms.is_empty():
		return

	var parts := command.split(" ", false)
	if parts.size() < 2:
		push_error("ROTATE_ARM missing angle")
		return

	var target_arm: RobotArm = _robot_arm
	var angle_text := ""
	if parts.size() == 2:
		angle_text = str(parts[1]).strip_edges()
	else:
		var label := str(parts[1]).strip_edges().to_lower()
		angle_text = str(parts[2]).strip_edges()
		target_arm = _resolve_robot_arm_by_label(label)
		if target_arm == null:
			push_error("FactoryController: unknown robot arm label '%s'" % label)
			return

	if not angle_text.is_valid_int() and not angle_text.is_valid_float():
		push_error("ROTATE_ARM invalid angle: %s" % angle_text)
		return

	var angle := float(angle_text)
	if target_arm.has_method("rotate_by"):
		target_arm.call("rotate_by", angle)
	else:
		target_arm.rotate_to(angle)

func _resolve_robot_arm_by_label(label: String) -> RobotArm:
	var key := str(label).strip_edges().to_lower()
	if key == "":
		return _robot_arm
	if _robot_arm_label_map.has(key):
		var value: Variant = _robot_arm_label_map[key]
		if value is RobotArm:
			return value as RobotArm
	return null

func _handle_pick_box(command: String) -> void:
	var target_arm := _resolve_target_arm_from_command(command, "PICK_BOX")
	if target_arm == null:
		return
	target_arm.pick()

func _handle_drop_box(command: String) -> void:
	var target_arm := _resolve_target_arm_from_command(command, "DROP_BOX")
	if target_arm == null:
		return
	target_arm.drop()

func _handle_rod_pick_box() -> void:
	var cart := _get_active_or_ready_cart()
	if cart == null:
		push_error("FactoryController: ROD_PICK_BOX requested but RodCart is not assigned")
		action_finished.emit("CART_PICK")
		return
	cart.pick()

func _handle_rod_drop_box() -> void:
	var cart := _get_active_or_ready_cart()
	if cart == null:
		push_error("FactoryController: ROD_DROP_BOX requested but RodCart is not assigned")
		action_finished.emit("CART_DROP")
		return
	cart.drop()

func _handle_rod_move_path(command: String) -> void:
	var parts := command.split(" ", false)
	if parts.size() < 2:
		push_error("ROD_MOVE_PATH missing path name")
		return
	var path_name := str(parts[1]).strip_edges()
	var cart := _get_active_or_ready_cart()
	if cart != null and cart.has_method("move_path"):
		_active_cart_returning_home = path_name.strip_edges().to_lower() == "home"
		cart.call("move_path", path_name)
		return
	push_error("FactoryController: RodCart not assigned for path '%s'" % path_name)
	action_finished.emit("MOVE_PATH")

func _handle_cart_dispatcher_command(command: String) -> void:
	var normalized := _normalize_cart_command_for_template(command)
	var starts_job := _is_cart_job_start(normalized)
	var ends_job := _is_cart_job_end(normalized)

	if _cart_template_ready:
		if starts_job:
			if _should_dispatch_cart_job_for_current_trigger():
				_enqueue_cart_job(_cart_template_commands.duplicate())
				_cart_runtime_swallowing_template = true
				print("CartDispatcher queued template job commands=%d" % _cart_template_commands.size())
			else:
				print("CartDispatcher skip duplicate trigger for same box")
		if _cart_runtime_swallowing_template and ends_job:
			_cart_runtime_swallowing_template = false
		_emit_synthetic_cart_action_done(normalized)
		return

	if starts_job and not _cart_template_recording:
		_cart_template_commands.clear()
		_cart_template_recording = true
		print("CartDispatcher recording template")

	if _cart_template_recording:
		_cart_template_commands.append(normalized)
		if ends_job:
			_cart_template_recording = false
			_cart_template_ready = true
			if _should_dispatch_cart_job_for_current_trigger():
				_enqueue_cart_job(_cart_template_commands.duplicate())
			print("CartDispatcher template ready commands=%d" % _cart_template_commands.size())

	_emit_synthetic_cart_action_done(normalized)

func _normalize_cart_command_for_template(command: String) -> String:
	var parts := command.split(" ", false)
	if parts.is_empty():
		return command.strip_edges().to_upper()
	var head := str(parts[0]).strip_edges().to_upper()
	if head == "MOVE_PATH":
		head = "ROD_MOVE_PATH"
	if parts.size() >= 2:
		return "%s %s" % [head, str(parts[1]).strip_edges().to_upper()]
	return head

func _is_cart_job_start(command: String) -> bool:
	var parts := command.split(" ", false)
	return parts.size() >= 2 and str(parts[0]).to_upper() == "ROD_MOVE_PATH" and str(parts[1]).to_lower() == "pick"

func _is_cart_job_end(command: String) -> bool:
	var parts := command.split(" ", false)
	return parts.size() >= 2 and str(parts[0]).to_upper() == "ROD_MOVE_PATH" and str(parts[1]).to_lower() == "home"

func _should_dispatch_cart_job_for_current_trigger() -> bool:
	var box_id := _get_weight_sensor_box_id()
	if box_id < 0:
		return true
	if _dispatched_cart_box_ids.has(box_id):
		return false
	_dispatched_cart_box_ids[box_id] = true
	print("CartDispatcher trigger accepted box_id=", box_id)
	return true

func _emit_synthetic_cart_action_done(command: String) -> void:
	var parts := command.split(" ", false)
	var op := str(parts[0]).to_upper() if not parts.is_empty() else command.to_upper()
	match op:
		"ROD_PICK_BOX":
			action_finished.emit("CART_PICK")
		"ROD_DROP_BOX":
			action_finished.emit("CART_DROP")
		"ROD_MOVE_PATH":
			action_finished.emit("MOVE_PATH")
		_:
			action_finished.emit(op)

func _enqueue_cart_job(commands: Array) -> void:
	if commands.is_empty():
		return
	_pending_cart_jobs.append(commands.duplicate())
	_try_start_pending_cart_jobs()

func _try_start_pending_cart_jobs() -> void:
	if _pending_cart_jobs.is_empty():
		return
	if _cart_spawner == null or not _cart_spawner.has_method("get_ready_cart"):
		return
	var remaining: Array = []
	for commands in _pending_cart_jobs:
		var cart := _cart_spawner.call("get_ready_cart") as RodCart
		if cart == null:
			remaining.append(commands)
			continue
		_start_cart_job(cart, commands)
	_pending_cart_jobs = remaining

func _start_cart_job(cart: RodCart, commands: Array) -> void:
	if cart == null or not is_instance_valid(cart):
		return
	var job_id := _next_cart_job_id
	_next_cart_job_id += 1
	cart.set_meta("cart_job_id", job_id)
	cart.set_meta("cart_state", "running")
	_running_cart_jobs[cart.get_instance_id()] = job_id
	_connect_cart(cart)
	print("CartDispatcher start job=%d cart=%s commands=%d" % [job_id, cart.name, commands.size()])
	call_deferred("_run_cart_job", cart, commands.duplicate(), job_id)

func _run_cart_job(cart: RodCart, commands: Array, job_id: int) -> void:
	for command in commands:
		if cart == null or not is_instance_valid(cart):
			return
		print("CartDispatcher job=%d cart=%s execute=%s" % [job_id, cart.name, str(command)])
		await _execute_and_wait_cart_job_command(cart, str(command))
	if cart != null and is_instance_valid(cart):
		print("CartDispatcher complete job=%d cart=%s" % [job_id, cart.name])
		_running_cart_jobs.erase(cart.get_instance_id())
		if _cart_spawner != null and _cart_spawner.has_method("complete_cart"):
			_cart_spawner.call("complete_cart", cart)

func _execute_and_wait_cart_job_command(cart: RodCart, command: String) -> void:
	if cart == null or not is_instance_valid(cart):
		return
	var state := {"done": false}
	var finish_cb := func(_action_name: String) -> void:
		state["done"] = true
	var fail_cb := func(_action_name: String) -> void:
		state["done"] = true
	cart.action_finished.connect(finish_cb)
	if cart.has_signal("action_failed"):
		cart.action_failed.connect(fail_cb)

	var parts := command.split(" ", false)
	var op := str(parts[0]).to_upper() if not parts.is_empty() else command.to_upper()
	match op:
		"ROD_MOVE_PATH":
			if parts.size() >= 2:
				cart.move_path(str(parts[1]))
		"ROD_PICK_BOX":
			cart.pick()
		"ROD_DROP_BOX":
			cart.drop()
		_:
			state["done"] = true

	while not bool(state["done"]):
		await get_tree().process_frame
	if cart != null and is_instance_valid(cart):
		if cart.action_finished.is_connected(finish_cb):
			cart.action_finished.disconnect(finish_cb)
		if cart.has_signal("action_failed") and cart.action_failed.is_connected(fail_cb):
			cart.action_failed.disconnect(fail_cb)

func _get_active_or_ready_cart() -> RodCart:
	if _active_cart != null and is_instance_valid(_active_cart):
		if _active_cart.get_meta("cart_state", "ready") == "done":
			_active_cart = null
		else:
			_connect_cart(_active_cart)
			print("FactoryController using active cart job=%d cart=%s" % [_active_cart_job_id, _active_cart.name])
			return _active_cart
	if _cart_spawner != null and _cart_spawner.has_method("get_ready_cart"):
		var cart := _cart_spawner.call("get_ready_cart") as RodCart
		if cart != null:
			_active_cart = cart
			_active_cart_job_id = _next_cart_job_id
			_next_cart_job_id += 1
			_active_cart.set_meta("cart_job_id", _active_cart_job_id)
			_connect_cart(_active_cart)
			print("FactoryController selected cart job=%d cart=%s" % [_active_cart_job_id, _active_cart.name])
			return _active_cart
	if _cart_spawner != null:
		return null
	if _cart != null and is_instance_valid(_cart):
		_active_cart = _cart
		_active_cart_job_id = _next_cart_job_id
		_next_cart_job_id += 1
		_active_cart.set_meta("cart_job_id", _active_cart_job_id)
		_connect_cart(_active_cart)
		return _active_cart
	return null

func _handle_robot_move_path(command: String) -> void:
	var parts := command.split(" ", false)
	if parts.size() < 2:
		push_error("ROBOT_MOVE_PATH missing path name")
		return
	var path_name := str(parts[1]).strip_edges()
	if _robot_arms.is_empty():
		return
	var target_arm: RobotArm = _robot_arm
	if parts.size() >= 3:
		target_arm = _resolve_robot_arm_by_label(str(parts[1]))
		path_name = str(parts[2]).strip_edges()
	if target_arm == null:
		push_error("FactoryController: MOVE_PATH target arm not found")
		return
	if target_arm.has_method("move_path"):
		target_arm.call("move_path", path_name)

func _resolve_target_arm_from_command(command: String, opcode: String) -> RobotArm:
	if _robot_arms.is_empty():
		return null
	var parts := command.split(" ", false)
	if parts.is_empty():
		return null
	if str(parts[0]).strip_edges().to_upper() != opcode:
		return null
	if parts.size() == 1:
		return _robot_arm
	var label := str(parts[1]).strip_edges().to_lower()
	var arm := _resolve_robot_arm_by_label(label)
	if arm == null:
		push_error("FactoryController: unknown robot arm label '%s' for %s" % [label, opcode])
	return arm

# ==================================================
# ACTION CALLBACK
# ==================================================
func _on_robot_arm_action_finished(_raw_action: String) -> void:
	var action := str(_raw_action).strip_edges().to_upper()
	if action == "":
		action = "ROTATE_ARM"
	print("Factory action finished:", action)
	action_finished.emit(action)

func _on_cart_action_finished(_raw_action: String, cart: RodCart) -> void:
	var action := str(_raw_action).strip_edges().to_upper()
	if action == "":
		action = "MOVE_PATH"
	if cart_dispatcher_mode and cart != null and _running_cart_jobs.has(cart.get_instance_id()):
		print("Factory cart background action finished: job=%s cart=%s action=%s" % [str(_running_cart_jobs[cart.get_instance_id()]), cart.name, action])
		return
	print("Factory cart action finished:", action)
	action_finished.emit(action)
	if cart == _active_cart and action == "MOVE_PATH" and _active_cart_returning_home:
		print("FactoryController completed cart job=%d cart=%s" % [_active_cart_job_id, cart.name])
		_active_cart_returning_home = false
		if _cart_spawner != null and _cart_spawner.has_method("complete_cart"):
			_cart_spawner.call("complete_cart", cart)
		_active_cart = null
		_active_cart_job_id = 0

func _on_cart_action_failed(_raw_action: String, cart: RodCart) -> void:
	var action := str(_raw_action).strip_edges().to_upper()
	if cart_dispatcher_mode and cart != null and _running_cart_jobs.has(cart.get_instance_id()):
		print("Factory cart background action failed: job=%s cart=%s action=%s" % [str(_running_cart_jobs[cart.get_instance_id()]), cart.name, action])
		return
	print("Factory cart action failed: %s cart=%s" % [action, cart.name if cart != null else "<none>"])
	action_finished.emit(action)

# ==================================================
# SENSOR INPUT
# ==================================================
func _on_weight_detected(data: Dictionary) -> void:
	var box_id := int(data.get("box_id", -1))
	if box_id >= 0 and _consumed_sensor_box_ids.get("weight", -999999) != box_id:
		_consumed_sensor_box_ids.erase("weight")
	sensor_updated.emit({
		"type": "weight",
		"box_id": box_id,
		"value": data.get("weight", -1)
	})

func _on_color_detected(data: Dictionary) -> void:
	sensor_updated.emit({
		"type": "color",
		"box_id": data.get("box_id", -1),
		"value": data.get("color", "")
	})

func get_sensor_state(sensor_name: String):
	var key := str(sensor_name).strip_edges().to_lower()
	if key == "weight" and _weight_sensor != null:
		var has_weight = _weight_sensor.get("has_value")
		if typeof(has_weight) == TYPE_BOOL and bool(has_weight):
			var box_id := _get_weight_sensor_box_id()
			if box_id >= 0 and int(_consumed_sensor_box_ids.get("weight", -999999)) == box_id:
				return null
			return _weight_sensor.get("value")
		return null
	if key == "color" and _color_sensor != null:
		var has_color = _color_sensor.get("has_value")
		if typeof(has_color) == TYPE_BOOL and bool(has_color):
			return _color_sensor.get("current_color")
		return null
	return null

func clear_sensor(sensor_name: String) -> void:
	var key := str(sensor_name).strip_edges().to_lower()
	if key == "weight" and _weight_sensor != null:
		var box_id := _get_weight_sensor_box_id()
		if box_id >= 0:
			_consumed_sensor_box_ids["weight"] = box_id
			print("FactoryController consumed weight sensor box_id=", box_id)

func _get_weight_sensor_box_id() -> int:
	if _weight_sensor == null:
		return -1
	if _weight_sensor.has_method("get_current_box_id"):
		return int(_weight_sensor.call("get_current_box_id"))
	var box = _weight_sensor.get("_current_box")
	if box is Box:
		return int((box as Box).box_id)
	return -1

func _dispatch_conveyor_command(command: String) -> void:
	# Keep signal for observers/loggers.
	command_emitted.emit(command)
	var completed_action := command.split(" ", false)[0].strip_edges().to_upper()

	if _conveyors.is_empty():
		action_finished.emit(completed_action)
		return

	# With one conveyor node (e.g. Conveyor3Way), forward full command (with index if any).
	if _conveyors.size() == 1:
		var only := _conveyors[0]
		if only != null and only.has_method("handle_command"):
			only.call("handle_command", command)
		action_finished.emit(completed_action)
		return

	# Multi-conveyor mode:
	# - no index -> broadcast to all conveyors
	# - index n  -> route to conveyor_paths[n-1]
	var idx := _extract_conveyor_index(command)
	if idx == -2:
		push_error("FactoryController: invalid conveyor index format in command '%s'" % command)
		return
	if idx == -1:
		for conv in _conveyors:
			if conv != null and conv.has_method("handle_command"):
				conv.call("handle_command", command)
		action_finished.emit(completed_action)
		return
	if idx < 1 or idx > _conveyors.size():
		push_error("FactoryController: conveyor index out of range (%d), total=%d" % [idx, _conveyors.size()])
		return

	var target := _conveyors[idx - 1]
	if target != null and target.has_method("handle_command"):
		target.call("handle_command", command)
	action_finished.emit(completed_action)

func _extract_conveyor_index(command: String) -> int:
	var trimmed := command.strip_edges()
	var parts := trimmed.split(" ", false)
	if parts.size() <= 1:
		return -1
	var idx_text := str(parts[1]).strip_edges()
	if idx_text == "":
		return -1
	if not idx_text.is_valid_int():
		return -2
	return int(idx_text)
