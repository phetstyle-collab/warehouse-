extends Node2D
class_name DiverterGateCloseOpen

signal gate_state_changed(is_open: bool)

@onready var paddle: StaticBody2D = $Paddle
@onready var gate_visual: Node2D = _resolve_gate_visual()

@export var open_angle_deg: float = -90.0
@export var close_angle_deg: float = 0.0
@export var rotate_speed: float = 12.0

var _target_angle: float = 0.0
var _is_open: bool = false

func _ready() -> void:
	close_gate()

func handle_command(command: String) -> void:
	var cmd := str(command).strip_edges().to_upper()
	match cmd:
		# Open aliases
		"OPEN", "DIVERTER_OPEN", "SET_DIVERTER_OPEN":
			open_gate()
		# Close aliases
		"CLOSE", "DIVERTER_CLOSE", "SET_DIVERTER_CLOSE", "DIVERTER_LEFT", "DIVERTER_RIGHT", "SET_DIVERTER_LEFT", "SET_DIVERTER_RIGHT":
			close_gate()

func open_gate() -> void:
	_is_open = true
	_target_angle = open_angle_deg
	gate_state_changed.emit(true)

func close_gate() -> void:
	_is_open = false
	_target_angle = close_angle_deg
	gate_state_changed.emit(false)

func is_open() -> bool:
	return _is_open

func _physics_process(delta: float) -> void:
	if paddle == null:
		return
	var current := paddle.rotation_degrees
	var next: float = lerp(current, _target_angle, 1.0 - exp(-rotate_speed * delta))
	paddle.rotation_degrees = next
	if gate_visual != null:
		gate_visual.rotation_degrees = next

func _resolve_gate_visual() -> Node2D:
	var candidates := ["GateDiver", "gatediver", "Sprite2D"]
	for child_name in candidates:
		var node := get_node_or_null(child_name)
		if node is Node2D:
			return node as Node2D
	return null
