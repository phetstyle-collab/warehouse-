extends Node2D
class_name Conveyor3Way

@export var main_conveyor_path: NodePath = NodePath("Conveyor")
@export var left_conveyor_path: NodePath = NodePath("Conveyor2")
@export var right_conveyor_path: NodePath = NodePath("Conveyor3")

signal START_CONVEYOR
signal STOP_CONVEYOR

var running: bool = false
var _segments: Array[Node] = []

func _ready() -> void:
	_resolve_segments()

func handle_command(command: String) -> void:
	if command.begins_with("START_CONVEYOR"):
		_route_conveyor_command(command, "START_CONVEYOR", true)
		return
	if command.begins_with("STOP_CONVEYOR"):
		_route_conveyor_command(command, "STOP_CONVEYOR", false)
		return

func start() -> void:
	for segment in _segments:
		if is_instance_valid(segment) and segment.has_method("start"):
			segment.call("start")
	_refresh_running_state()
	START_CONVEYOR.emit()

func stop() -> void:
	for segment in _segments:
		if is_instance_valid(segment) and segment.has_method("stop"):
			segment.call("stop")
	_refresh_running_state()
	STOP_CONVEYOR.emit()

func is_running() -> bool:
	return running

func _start_segment(index: int) -> void:
	var segment := _get_segment(index)
	if segment == null:
		push_error("Conveyor3Way: invalid segment index %d" % index)
		return
	segment.call("start")
	_refresh_running_state()
	START_CONVEYOR.emit()

func _stop_segment(index: int) -> void:
	var segment := _get_segment(index)
	if segment == null:
		push_error("Conveyor3Way: invalid segment index %d" % index)
		return
	segment.call("stop")
	_refresh_running_state()
	STOP_CONVEYOR.emit()

func _resolve_segments() -> void:
	_segments.clear()
	_add_segment(main_conveyor_path)
	_add_segment(left_conveyor_path)
	_add_segment(right_conveyor_path)
	_refresh_running_state()
	if _segments.is_empty():
		push_error("Conveyor3Way: no conveyor segments found")

func _add_segment(path: NodePath) -> void:
	if path == NodePath():
		return
	var node := get_node_or_null(path)
	if node == null:
		push_error("Conveyor3Way: missing segment at path %s" % [str(path)])
		return
	if not node.has_method("start") or not node.has_method("stop"):
		push_error("Conveyor3Way: segment must have start()/stop() at path %s" % [str(path)])
		return
	_segments.append(node)

func _extract_index(command: String, opcode: String) -> int:
	var rest := command.substr(opcode.length()).strip_edges()
	if rest == "":
		return -1
	if not rest.is_valid_int():
		return -2
	return int(rest)

func _route_conveyor_command(command: String, opcode: String, is_start: bool) -> void:
	var index := _extract_index(command, opcode)
	if index == -1:
		if is_start:
			start()
		else:
			stop()
		return
	if index == -2:
		push_error("Conveyor3Way: invalid segment index format in command '%s'" % command)
		return
	if is_start:
		_start_segment(index)
	else:
		_stop_segment(index)

func _get_segment(index: int) -> Node:
	if index < 1 or index > _segments.size():
		return null
	return _segments[index - 1]

func _refresh_running_state() -> void:
	running = false
	for segment in _segments:
		if not is_instance_valid(segment):
			continue
		var state := false
		if segment.has_method("is_running"):
			var state_variant: Variant = segment.call("is_running")
			if typeof(state_variant) == TYPE_BOOL:
				state = state_variant
		else:
			var state_prop: Variant = segment.get("running")
			if typeof(state_prop) == TYPE_BOOL:
				state = state_prop
		if state:
			running = true
			return
