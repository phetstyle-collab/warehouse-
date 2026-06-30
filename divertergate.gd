extends Node2D
class_name DiverterGate

enum Mode {
	OPEN,
	CLOSE_LEFT,
	CLOSE_RIGHT
}

@onready var paddle: StaticBody2D = $Paddle
@onready var gate_diver_visual: Node2D = _resolve_gate_diver_visual()

@export var open_angle_deg: float = 0.0
@export var close_left_angle_deg: float = 35.0
@export var close_right_angle_deg: float = -35.0
@export var rotate_speed: float = 12.0

var _target_angle: float = 0.0
var _mode: Mode = Mode.OPEN

func _ready() -> void:
	set_mode(Mode.OPEN)

func handle_command(command: String) -> void:
	var cmd := str(command).strip_edges().to_upper()
	match cmd:
		"DIVERTER_LEFT", "SET_DIVERTER_LEFT":
			# close right side so box is guided left.
			set_mode(Mode.CLOSE_RIGHT)
		"DIVERTER_RIGHT", "SET_DIVERTER_RIGHT":
			# close left side so box is guided right.
			set_mode(Mode.CLOSE_LEFT)
		"DIVERTER_OPEN", "SET_DIVERTER_OPEN":
			set_mode(Mode.OPEN)
		"DIVERTER_CLOSE", "SET_DIVERTER_CLOSE":
			# Backward-compatible default close direction for 2-state commands.
			set_mode(Mode.CLOSE_LEFT)

func set_mode(mode: Mode) -> void:
	_mode = mode
	match mode:
		Mode.OPEN:
			_target_angle = open_angle_deg
		Mode.CLOSE_LEFT:
			_target_angle = close_left_angle_deg
		Mode.CLOSE_RIGHT:
			_target_angle = close_right_angle_deg

func _physics_process(delta: float) -> void:
	var current := paddle.rotation_degrees
	var next: float = lerp(current, _target_angle, 1.0 - exp(-rotate_speed * delta))
	paddle.rotation_degrees = next
	if gate_diver_visual != null:
		gate_diver_visual.rotation_degrees = next

func _resolve_gate_diver_visual() -> Node2D:
	var candidates := [
		"GateDiver",
		"gatediver",
		"Sprite2D",
	]
	for child_name in candidates:
		var node := get_node_or_null(child_name)
		if node is Node2D:
			return node as Node2D
	return null
