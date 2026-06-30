extends RefCounted
class_name MiniCRuntime

signal action_executed(action: String)
signal execution_finished()
signal line_executing(line: int)

# =================================================
# STATE
# =================================================
var _controller

# program execution
var _current_program: ProgramNode = null
var _resume_ip: int = 0

# WAIT gate
var _waiting: bool = false
var _wait_program: ProgramNode = null
var _wait_resume_ip: int = -1
var _wait_node: WaitUntilNode = null
var _pending_clear_sensor: String = ""
var _sensor_latch: Dictionary = {} # sensor_name -> bool (true = already consumed)
var _action_done_latch: bool = false

# Command aliases: name -> action string (e.g. "sp" -> "START_SPAWNER")
var _aliases: Dictionary = {}
var _number_vars: Dictionary = {}
var _number_var_types: Dictionary = {}

# Function table: name -> {body: ProgramNode, params: Array[String]}
var _functions: Dictionary = {}

# Flow control gate (prevents ProgramNode fallthrough when a statement manages flow)
var _flow_controlled: bool = false
var _flow_control_program: ProgramNode = null

# Loop stack for WHILE bodies (each item: {body, outer_program, outer_ip})
var _loop_stack: Array = []

# BREAK flag
var _breaking: bool = false

# Return stack for IF bodies (each item: {body, return_program, return_ip})
var _return_stack: Array = []

# Step budget to avoid infinite tight loops in one frame
const MAX_STEPS_PER_FRAME: int = 200
const STEP_DELAY_SECONDS: float = 0.2
var _last_frame: int = -1
var _steps_this_frame: int = 0
var _finished_emitted: bool = false
var _step_delay_token: int = 0


# =================================================
# ENTRY
# =================================================
func execute(program: ProgramNode, controller) -> void:
	if _controller != null and _controller.has_signal("action_finished"):
		if _controller.action_finished.is_connected(_on_action_done):
			_controller.action_finished.disconnect(_on_action_done)

	_controller = controller
	_current_program = program
	_resume_ip = 0

	_waiting = false
	_wait_program = null
	_wait_resume_ip = -1
	_wait_node = null
	_pending_clear_sensor = ""
	_sensor_latch.clear()
	_action_done_latch = false

	if _controller != null and _controller.has_signal("action_finished"):
		if not _controller.action_finished.is_connected(_on_action_done):
			_controller.action_finished.connect(_on_action_done)

	_breaking = false
	_flow_controlled = false
	_aliases.clear()
	_number_vars.clear()
	_number_var_types.clear()
	_functions.clear()
	# Important when the runtime instance is reused between runs (e.g. in the
	# playground): stale loop/return stacks will corrupt control flow (REPEAT/WHILE
	# may "finish" after one iteration).
	_loop_stack.clear()
	_return_stack.clear()
	_last_frame = -1
	_steps_this_frame = 0
	_finished_emitted = false
	_step_delay_token += 1

	_register_functions(program)

	print("MiniCRuntime START")
	call_deferred("_step")


func notify_execution_finished() -> void:
	if _finished_emitted:
		return
	_finished_emitted = true
	execution_finished.emit()


func notify_line_executing(line: int) -> void:
	if line < 0:
		return
	line_executing.emit(line)


func _register_functions(program: ProgramNode) -> void:
	# Pre-register all function definitions so CALL can be used before the FUNC
	# appears in the source, and so definitions inside nested blocks work.
	if program == null:
		return
	for stmt in program.statements:
		if stmt == null:
			continue
		if stmt is FuncDefNode:
			register_function(stmt.name, stmt.body, stmt.params)
			continue
		if stmt is WhileNode:
			_register_functions(stmt.body)
			continue
		if stmt is RepeatNode:
			_register_functions(stmt.body)
			continue
		if stmt is ConditionNode:
			if stmt.then_body != null:
				_register_functions(stmt.then_body)
			if stmt.else_body != null:
				_register_functions(stmt.else_body)
			continue


# =================================================
# CORE STEP
# =================================================
func _step() -> void:
	if _waiting:
		print("Runtime waiting (gate closed)")
		return

	if _current_program == null:
		print("Runtime: no program")
		return

	# Throttle to avoid blocking the main thread on infinite loops.
	var frame := Engine.get_process_frames()
	if frame != _last_frame:
		_last_frame = frame
		_steps_this_frame = 0
	_steps_this_frame += 1
	if _steps_this_frame > MAX_STEPS_PER_FRAME:
		call_deferred("_step")
		return

	var p := _current_program
	var ip := _resume_ip

	_current_program = null
	_resume_ip = 0

	print("Runtime step -> ProgramNode ip =", ip)
	p.execute_from(self, ip)


# =================================================
# PROGRAM CONTINUATION
# =================================================
func save_execution_state(program: ProgramNode, ip: int) -> void:
	print("Runtime save state ip =", ip)
	_current_program = program
	_resume_ip = ip
	_schedule_next_step()


func _schedule_next_step() -> void:
	_step_delay_token += 1
	var token := _step_delay_token
	if STEP_DELAY_SECONDS <= 0.0 or _controller == null or not _controller.has_method("get_tree"):
		call_deferred("_step")
		return
	var tree: SceneTree = _controller.get_tree()
	if tree == null:
		call_deferred("_step")
		return
	await tree.create_timer(STEP_DELAY_SECONDS).timeout
	if token != _step_delay_token:
		return
	call_deferred("_step")


# =================================================
# WAIT API
# =================================================
func enter_wait(
	program: ProgramNode,
	resume_ip: int,
	node: WaitUntilNode
) -> void:
	print("ENTER WAIT resume_ip =", resume_ip)

	_waiting = true
	_wait_program = program
	_wait_resume_ip = resume_ip
	_wait_node = node

	# connect signals
	if node.wait_type == WaitUntilNode.WaitType.SENSOR_CONDITION:
		# Level stations are allowed to react to an object that is already on
		# the sensor. Requiring a fresh edge makes cart jobs miss boxes that
		# arrived while the cart was still executing the previous route.
		if node.condition != null and node.condition.evaluate(self):
			print("WAIT condition already satisfied")
			_complete_wait_immediately()
			return
		if not _controller.sensor_updated.is_connected(_on_sensor):
			_controller.sensor_updated.connect(_on_sensor)

	if node.wait_type == WaitUntilNode.WaitType.ACTION_DONE:
		if _action_done_latch:
			_action_done_latch = false
			print("WAIT action already completed")
			_complete_wait_immediately()
			return


func is_waiting() -> bool:
	return _waiting

func block_fallthrough(program: ProgramNode) -> void:
	_flow_controlled = true
	_flow_control_program = program

func consume_flow_controlled(program: ProgramNode) -> bool:
	if _flow_controlled and _flow_control_program == program:
		_flow_controlled = false
		_flow_control_program = null
		return true
	return false

func trigger_break() -> void:
	_breaking = true

func is_breaking() -> bool:
	return _breaking

func clear_break() -> void:
	_breaking = false

func push_loop(body: ProgramNode, outer_program: ProgramNode, outer_ip: int, loop_owner = null) -> void:
	_loop_stack.append({
		"body": body,
		"outer_program": outer_program,
		"outer_ip": outer_ip,
		"return_stack_size": _return_stack.size(),
		"loop_owner": loop_owner
	})

func pop_loop_for_body(body: ProgramNode):
	if _loop_stack.is_empty():
		return null
	var last = _loop_stack[_loop_stack.size() - 1]
	if last.get("body") == body:
		_loop_stack.pop_back()
		return last
	return null

func _trim_return_stack(target_size: int) -> void:
	while _return_stack.size() > target_size:
		_return_stack.pop_back()

func pop_nearest_loop_for_break():
	if _loop_stack.is_empty():
		return null
	var last = _loop_stack[_loop_stack.size() - 1]
	_loop_stack.pop_back()
	var target_size := int(last.get("return_stack_size", 0))
	_trim_return_stack(target_size)
	return last

func push_return(body: ProgramNode, return_program: ProgramNode, return_ip: int, scope_restore: Dictionary = {}) -> void:
	_return_stack.append({
		"body": body,
		"return_program": return_program,
		"return_ip": return_ip,
		"scope_restore": scope_restore.duplicate(true),
	})

func pop_return_for_body(body: ProgramNode):
	if _return_stack.is_empty():
		return null
	var last = _return_stack[_return_stack.size() - 1]
	if last.get("body") == body:
		_return_stack.pop_back()
		return last
	return null


# =================================================
# WAIT HANDLERS
# =================================================
func _on_sensor(data) -> void:
	if not _waiting or _wait_node == null:
		return

	print("WAIT evaluate sensor")
	var updated_type := ""
	if typeof(data) == TYPE_DICTIONARY and data.has("type"):
		updated_type = String(data["type"]).to_lower()

	# If waiting on a specific sensor, ignore updates from other sensors.
	if _wait_node.condition != null and _wait_node.condition is ComparisonNode:
		var target_sensor: String = _normalize_sensor_name(_wait_node.condition.sensor)
		if target_sensor != "__const__" and updated_type != "" and target_sensor != updated_type:
			return

	# Allow HAS_VALUE waits only on fresh updates.
	if _wait_node.condition != null and _wait_node.condition is ComparisonNode:
		if _wait_node.condition.value == ComparisonNode.HAS_VALUE:
			var sensor_name: String = _normalize_sensor_name(_wait_node.condition.sensor)
			if sensor_name != "" and (updated_type == "" or sensor_name == updated_type):
				_sensor_latch[sensor_name] = false
	if not _wait_node.condition.evaluate(self):
		return

	print("WAIT condition satisfied")
	# Latch HAS_VALUE so the next wait requires a new update.
	if _wait_node.condition != null and _wait_node.condition is ComparisonNode:
		if _wait_node.condition.value == ComparisonNode.HAS_VALUE:
			var sensor_name: String = _normalize_sensor_name(_wait_node.condition.sensor)
			if sensor_name != "":
				_sensor_latch[sensor_name] = true
	_exit_wait()


func _on_action_done(_action) -> void:
	if not _waiting:
		_action_done_latch = true
		return
	if _wait_node == null or _wait_node.wait_type != WaitUntilNode.WaitType.ACTION_DONE:
		_action_done_latch = true
		return

	print("WAIT action done")
	_action_done_latch = false
	_exit_wait()


# =================================================
# IMMEDIATE WAIT COMPLETION
# =================================================
func _complete_wait_immediately() -> void:
	# This path is used while WaitUntilNode.execute() is still on the stack.
	# Do not call _exit_wait(), because that schedules a deferred resume while
	# ProgramNode will already fall through to the next statement.
	if _wait_node != null and _wait_node.wait_type == WaitUntilNode.WaitType.SENSOR_CONDITION:
		if _wait_node.condition != null and _wait_node.condition.sensor != "__const__":
			_pending_clear_sensor = _normalize_sensor_name(_wait_node.condition.sensor)

	_waiting = false
	_wait_program = null
	_wait_resume_ip = -1
	_wait_node = null


# =================================================
# EXIT WAIT
# =================================================
func _exit_wait() -> void:
	print("EXIT WAIT -> resume ip =", _wait_resume_ip)

	_waiting = false

	# Mark sensor for clearing after the next statement executes (so IF can read it).
	if _wait_node != null and _wait_node.wait_type == WaitUntilNode.WaitType.SENSOR_CONDITION:
		if _wait_node.condition != null and _wait_node.condition.sensor != "__const__":
			_pending_clear_sensor = _normalize_sensor_name(_wait_node.condition.sensor)

	# disconnect signals
	if _controller.sensor_updated.is_connected(_on_sensor):
		_controller.sensor_updated.disconnect(_on_sensor)

	var p := _wait_program
	var ip := _wait_resume_ip

	_wait_program = null
	_wait_resume_ip = -1
	_wait_node = null

	call_deferred("_resume_program", p, ip)


func _resume_program(program: ProgramNode, ip: int) -> void:
	_current_program = program
	_resume_ip = ip
	call_deferred("_step")


# =================================================
# WORLD API
# =================================================
func execute_action(action: String) -> void:
	var normalized_action := _normalize_runtime_action(_resolve_action_vars(action))
	print("Action:", normalized_action)
	_action_done_latch = false
	_controller.execute_action(normalized_action)
	action_executed.emit(normalized_action)

func set_alias(name: String, action: String) -> void:
	_aliases[name] = action

func resolve_action(action_or_alias: String) -> String:
	var key := str(action_or_alias).strip_edges()
	if _aliases.has(key):
		return str(_aliases[key])
	return key

func register_function(name: String, body: ProgramNode, params: Array = []) -> void:
	var key := str(name).strip_edges()
	if key == "":
		return
	var normalized_params: Array[String] = []
	for p in params:
		normalized_params.append(str(p).strip_edges().to_lower())
	_functions[key] = {
		"body": body,
		"params": normalized_params,
	}

func get_function_body(name: String) -> ProgramNode:
	var sig := get_function_signature(name)
	return sig.get("body", null)

func get_function_signature(name: String) -> Dictionary:
	var key := str(name).strip_edges()
	if _functions.has(key):
		var sig = _functions[key]
		if sig is Dictionary:
			return (sig as Dictionary).duplicate(true)
	return {}

func push_function_scope(param_names: Array, arg_exprs: Array) -> Dictionary:
	var restore := {
		"names": [],
		"had_value": {},
		"values": {},
		"had_type": {},
		"types": {},
	}
	for i in range(param_names.size()):
		var key := str(param_names[i]).strip_edges().to_lower()
		if key == "":
			continue
		restore["names"].append(key)
		restore["had_value"][key] = _number_vars.has(key)
		if _number_vars.has(key):
			restore["values"][key] = _number_vars[key]
		restore["had_type"][key] = _number_var_types.has(key)
		if _number_var_types.has(key):
			restore["types"][key] = _number_var_types[key]

		var expr := ""
		if i < arg_exprs.size():
			expr = str(arg_exprs[i]).strip_edges()
		_number_vars[key] = _eval_call_arg(expr)
	return restore

func pop_function_scope(restore: Dictionary) -> void:
	if restore.is_empty():
		return
	var names: Array = restore.get("names", [])
	var had_value: Dictionary = restore.get("had_value", {})
	var values: Dictionary = restore.get("values", {})
	var had_type: Dictionary = restore.get("had_type", {})
	var types: Dictionary = restore.get("types", {})
	for n in names:
		var key := str(n)
		if bool(had_value.get(key, false)):
			_number_vars[key] = values.get(key, null)
		else:
			_number_vars.erase(key)
		if bool(had_type.get(key, false)):
			_number_var_types[key] = str(types.get(key, ""))
		else:
			_number_var_types.erase(key)

func _eval_call_arg(expr: String):
	var e := str(expr).strip_edges()
	if e == "":
		return 0
	if e.is_valid_int():
		return int(e)
	if e.is_valid_float():
		return float(e)
	if _is_identifier_token(e):
		var key := e.to_lower()
		if _number_vars.has(key):
			return _number_vars[key]
		return key
	return eval_numeric_expr(e)


func get_sensor_state(name: String):
	return _controller.get_sensor_state(name)

func set_number_var(name: String, value) -> void:
	var key := str(name).strip_edges().to_lower()
	if key == "":
		return
	var value_type := str(_number_var_types.get(key, ""))
	var normalized = _coerce_number_value(value, value_type)
	_number_vars[key] = normalized
	action_executed.emit("VAR %s = %s" % [key, str(normalized)])

func declare_number_var(name: String, value, declared_type: String) -> void:
	var key := str(name).strip_edges().to_lower()
	if key == "":
		return
	var t := str(declared_type).strip_edges().to_lower()
	if t in ["int", "float"]:
		_number_var_types[key] = t
	set_number_var(key, value)

func has_number_var(name: String) -> bool:
	var key := str(name).strip_edges().to_lower()
	return _number_vars.has(key)

func get_number_var(name: String):
	var key := str(name).strip_edges().to_lower()
	return _number_vars.get(key, null)

func eval_numeric_expr(expr: String):
	var source := str(expr).strip_edges()
	if source == "":
		return 0.0

	var names := _extract_identifiers(source)
	var values: Array = []
	for var_name in names:
		values.append(get_number_var(var_name))

	var evaluator := Expression.new()
	var err := evaluator.parse(source, names)
	if err != OK:
		push_error("Numeric expression parse failed: " + source)
		return 0.0

	var result = evaluator.execute(values, self, true)
	if evaluator.has_execute_failed():
		push_error("Numeric expression execute failed: " + source)
		return 0.0
	return result

func idiv(a, b) -> int:
	var divisor := float(b)
	if is_zero_approx(divisor):
		push_error("idiv divide by zero")
		return 0
	return int(floor(float(a) / divisor))

func _coerce_number_value(value, value_type: String):
	if value_type == "int":
		if typeof(value) == TYPE_INT:
			return value
		if typeof(value) == TYPE_FLOAT:
			return int(value)
		if typeof(value) == TYPE_STRING:
			var s := str(value).strip_edges()
			if s.is_valid_int():
				return int(s)
			if s.is_valid_float():
				return int(float(s))
		return 0
	if value_type == "float":
		if typeof(value) == TYPE_FLOAT:
			return value
		if typeof(value) == TYPE_INT:
			return float(value)
		if typeof(value) == TYPE_STRING:
			var s2 := str(value).strip_edges()
			if s2.is_valid_float():
				return float(s2)
			if s2.is_valid_int():
				return float(int(s2))
		return 0.0
	return value

func consume_pending_clear() -> void:
	if _pending_clear_sensor == "":
		return
	if _controller.has_method("clear_sensor"):
		_controller.clear_sensor(_pending_clear_sensor)
	_pending_clear_sensor = ""

static func _normalize_sensor_name(sensor_name: String) -> String:
	var key := str(sensor_name).strip_edges()
	if key == "__const__":
		return key
	return key.to_lower()

static func _normalize_runtime_action(action: String) -> String:
	var src := str(action).strip_edges()
	if src == "":
		return src

	var open_idx := src.find("(")
	var close_idx := src.rfind(")")
	if open_idx <= 0 or close_idx < 0 or close_idx != src.length() - 1:
		return src

	var head := src.substr(0, open_idx).strip_edges().to_upper()
	var arg := src.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
	if arg == "":
		return head

	if head == "START_CONVEYOR" or head == "STOP_CONVEYOR" or head == "ROTATE_ARM" or head == "MOVE_PATH" or head == "ROD_MOVE_PATH" or head == "ROBOT_MOVE_PATH":
		return head + " " + arg
	return src

static func _extract_identifiers(source: String) -> PackedStringArray:
	var out := PackedStringArray()
	var re := RegEx.new()
	var err := re.compile("[A-Za-z_][A-Za-z0-9_]*")
	if err != OK:
		return out
	var builtin_funcs := {
		"idiv": true,
	}
	var seen: Dictionary = {}
	for m in re.search_all(source):
		var name := str(m.get_string()).to_lower()
		if builtin_funcs.has(name):
			continue
		if not seen.has(name):
			out.append(name)
			seen[name] = true
	return out

func _resolve_action_vars(action_text: String) -> String:
	var parts := str(action_text).split(" ", false)
	if parts.is_empty():
		return str(action_text)
	var op := str(parts[0]).to_upper()
	if op in ["START_TARGET", "STOP_TARGET"] and parts.size() >= 2:
		var target := str(_resolve_token_var(parts[1])).strip_edges().to_lower()
		if target == "spawner":
			return ("START_SPAWNER" if op == "START_TARGET" else "STOP_SPAWNER")
		if target == "conveyor":
			return ("START_CONVEYOR" if op == "START_TARGET" else "STOP_CONVEYOR")
		return str(action_text)
	if op in ["START_CONVEYOR", "STOP_CONVEYOR"] and parts.size() >= 2:
		parts[1] = str(_resolve_token_var(parts[1]))
		return " ".join(parts)
	if op == "ROTATE_ARM":
		if parts.size() == 2:
			parts[1] = str(_resolve_token_var(parts[1]))
		elif parts.size() >= 3:
			parts[2] = str(_resolve_token_var(parts[2]))
		return " ".join(parts)
	if op == "MOVE_PATH" or op == "ROD_MOVE_PATH" or op == "ROBOT_MOVE_PATH":
		if parts.size() >= 2:
			parts[1] = str(_resolve_token_var(parts[1]))
		return " ".join(parts)
	return str(action_text)

func _resolve_token_var(token: String):
	var t := str(token).strip_edges()
	if t == "":
		return t
	if not _is_identifier_token(t):
		return t
	var key := t.to_lower()
	if _number_vars.has(key):
		return _number_vars[key]
	return t

static func _is_identifier_token(name: String) -> bool:
	var s := str(name).strip_edges()
	if s == "":
		return false
	var re := RegEx.new()
	if re.compile("^[A-Za-z_][A-Za-z0-9_]*$") != OK:
		return false
	return re.search(s) != null
