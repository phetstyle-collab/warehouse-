extends Node2D
class_name ConveyorRight

@export var speed: float = 100.0
@export var start_delay: float = 0.0
@export var diverter_gate_path: NodePath
@export var debug_print: bool = true

@onready var belt_area: Area2D = (get_node_or_null("BeltArea") if has_node("BeltArea") else get_node_or_null("beltarea")) as Area2D
@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var boxes_on_belt: Array[Node2D] = []
var _world_direction: Vector2 = Vector2.RIGHT
var running: bool = false
var _diverter_gate: Node = null
var _drive_enabled: bool = false
var _delay_token: int = 0

signal START_CONVEYOR
signal STOP_CONVEYOR

func _ready() -> void:
	add_to_group("conveyor")
	_world_direction = Vector2.RIGHT.rotated(global_rotation).normalized()
	_debug("ready running=%s speed=%s direction=%s" % [running, speed, _world_direction])

	if belt_area == null:
		push_error("ConveyorRight: missing BeltArea/beltarea node")
		return
	if anim != null:
		anim.stop()
		anim.frame = 0

	belt_area.area_entered.connect(_on_area_entered)
	belt_area.area_exited.connect(_on_area_exited)
	_debug("belt_area bound: %s" % belt_area.name)
	_bind_diverter_gate()

func _physics_process(_delta: float) -> void:
	if not running or not _drive_enabled:
		return
	for box in boxes_on_belt:
		if not is_instance_valid(box):
			continue
		if box is Box:
			(box as Box).velocity = _world_direction * speed

func _on_area_entered(area: Area2D) -> void:
	var box: Node = area.get_parent()
	_debug("area entered=%s parent=%s running=%s box_pos=%s" % [area.name, box.name if box != null else "<none>", running, (box as Node2D).global_position if box is Node2D else Vector2.ZERO])
	if box is Box:
		if not boxes_on_belt.has(box):
			boxes_on_belt.append(box)
			(box as Box).set_on_conveyor(true)
			_debug("box added id=%s total=%d" % [(box as Box).box_id, boxes_on_belt.size()])
		if running:
			_apply_velocity_after_delay(box as Box, "enter")

func _on_area_exited(area: Area2D) -> void:
	var box: Node = area.get_parent()
	_debug("area exited=%s parent=%s" % [area.name, box.name if box != null else "<none>"])
	if box is Box:
		boxes_on_belt.erase(box)
		(box as Box).set_on_conveyor(false)
		_debug("box removed id=%s total=%d" % [(box as Box).box_id, boxes_on_belt.size()])
		if not _is_box_on_any_running_conveyor(box as Box):
			(box as Box).velocity = Vector2.ZERO
			_debug("box velocity stopped on exit id=%s" % [(box as Box).box_id])

func start() -> void:
	if running:
		_debug("start ignored already running")
		return
	running = true
	_drive_enabled = false
	if anim != null:
		anim.play("run")
	_debug("start running=true boxes=%d global=%s" % [boxes_on_belt.size(), global_position])
	_enable_drive_after_delay()
	START_CONVEYOR.emit()

func stop() -> void:
	if not running:
		_debug("stop ignored not running")
		return
	running = false
	_drive_enabled = false
	_delay_token += 1
	if anim != null:
		anim.stop()
	_debug("stop running=false boxes=%d" % [boxes_on_belt.size()])
	for box in boxes_on_belt:
		if box is Box and not _is_box_on_any_running_conveyor(box as Box):
			(box as Box).velocity = Vector2.ZERO
			_debug("box velocity stopped on stop id=%s" % [(box as Box).box_id])
	STOP_CONVEYOR.emit()

func handle_command(command: String) -> void:
	if command.begins_with("START_CONVEYOR"):
		start()
		return
	if command.begins_with("STOP_CONVEYOR"):
		stop()
		return
	print("Unknown command:", command)

func is_running() -> bool:
	return running

func _bind_diverter_gate() -> void:
	if diverter_gate_path != NodePath():
		_diverter_gate = get_node_or_null(diverter_gate_path)
		_debug("resolve diverter by path=%s found=%s" % [str(diverter_gate_path), _diverter_gate != null])
	if _diverter_gate == null:
		var parent_node := get_parent()
		if parent_node != null:
			_diverter_gate = parent_node.get_node_or_null("Divertergatecloseopen")
			_debug("resolve diverter by sibling found=%s" % [_diverter_gate != null])
	if _diverter_gate == null:
		_debug("diverter not found")
		return

	if _diverter_gate.has_method("is_open"):
		var state: Variant = _diverter_gate.call("is_open")
		if typeof(state) == TYPE_BOOL:
			_debug("initial diverter open=%s" % [state])
			if state:
				start()
			else:
				stop()

	if _diverter_gate.has_signal("gate_state_changed"):
		var cb := Callable(self, "_on_gate_state_changed")
		if not _diverter_gate.gate_state_changed.is_connected(cb):
			_diverter_gate.gate_state_changed.connect(cb)
			_debug("connected gate_state_changed")

func _on_gate_state_changed(is_open: bool) -> void:
	_debug("diverter changed open=%s" % [is_open])
	if is_open:
		start()
	else:
		stop()

func _enable_drive_after_delay() -> void:
	_delay_token += 1
	var token := _delay_token
	if start_delay > 0.0:
		_debug("waiting %.2fs before drive" % [start_delay])
		await get_tree().create_timer(start_delay).timeout
	if token != _delay_token or not running:
		return
	_drive_enabled = true
	for box in boxes_on_belt:
		if box is Box:
			(box as Box).velocity = _world_direction * speed
			_debug("box velocity applied after delay id=%s velocity=%s" % [(box as Box).box_id, (box as Box).velocity])

func _apply_velocity_after_delay(box: Box, reason: String) -> void:
	var token := _delay_token
	if start_delay > 0.0 and not _drive_enabled:
		await get_tree().create_timer(start_delay).timeout
	if token != _delay_token or not running or not boxes_on_belt.has(box):
		return
	box.velocity = _world_direction * speed
	_debug("box velocity applied on %s id=%s velocity=%s" % [reason, box.box_id, box.velocity])

func _is_box_on_any_running_conveyor(box: Box) -> bool:
	var station_root := get_parent()
	if station_root == null:
		return false
	for node in station_root.get_children():
		if node is Conveyor:
			var conv := node as Conveyor
			if conv.running and conv.boxes_on_belt.has(box):
				return true
		if node is ConveyorRight:
			var conv_right := node as ConveyorRight
			if conv_right.running and conv_right.boxes_on_belt.has(box):
				return true
	return false

func _debug(message: String) -> void:
	if debug_print:
		print("[ConveyorRight:%s] %s" % [name, message])
