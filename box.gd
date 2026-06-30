extends CharacterBody2D
class_name Box

var box_id: int = -1
var box_color: Color = Color.WHITE
var weight_kg: int = 0
var box_size: String = "M"

var on_conveyor: bool = false
var held_by_robot: bool = false
var _conveyor_contact_count: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_area: Area2D = $HitArea
@onready var hit_shape_node: CollisionShape2D = $HitArea/CollisionShape2D
@onready var body_shape_node: CollisionShape2D = $CollisionShape2D

var _base_sprite_scale: Vector2 = Vector2.ONE
var _base_hit_size: Vector2 = Vector2.ZERO
var _base_body_size: Vector2 = Vector2.ZERO

const SIZE_SCALE := {
	"S": 0.95,
	"M": 1.0,
	"L": 1.2,
	"XL": 1.4,
	"XXL": 1.6,
}

const DEFAULT_Z_INDEX := 55
const CONVEYOR_Z_INDEX := 50
const HELD_Z_INDEX := 70

func _ready() -> void:
	add_to_group("box")
	set_collision_layer(1)
	set_collision_mask(1)
	z_as_relative = false
	_update_z_index()
	_capture_base_shapes()
	_update_visual()

func _physics_process(_delta: float) -> void:
	if held_by_robot:
		return
	move_and_slide()

func apply_data(id: int, color: Color, weight: int, size: String = "M") -> void:
	box_id = id
	box_color = color
	weight_kg = weight
	box_size = size.to_upper()
	_update_visual()

func _update_visual() -> void:
	if sprite:
		sprite.modulate = box_color
	_apply_size_profile()

func set_on_conveyor(value: bool) -> void:
	if value:
		_conveyor_contact_count += 1
	else:
		_conveyor_contact_count = max(0, _conveyor_contact_count - 1)
	on_conveyor = _conveyor_contact_count > 0
	_update_z_index()

func grab() -> void:
	held_by_robot = true
	on_conveyor = false
	_conveyor_contact_count = 0
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
	_update_z_index()

func release() -> void:
	held_by_robot = false
	set_physics_process(true)
	set_collision_layer(1)
	set_collision_mask(1)
	_update_z_index()

func _to_string() -> String:
	return "[Box id=%d weight=%d size=%s]" % [box_id, weight_kg, box_size]

func _capture_base_shapes() -> void:
	if sprite != null:
		_base_sprite_scale = sprite.scale

	if hit_shape_node != null and hit_shape_node.shape is RectangleShape2D:
		var hit_rect := hit_shape_node.shape as RectangleShape2D
		# Ensure each spawned box edits its own shape resource.
		hit_shape_node.shape = hit_rect.duplicate()
		_base_hit_size = (hit_shape_node.shape as RectangleShape2D).size

	if body_shape_node != null and body_shape_node.shape is RectangleShape2D:
		var body_rect := body_shape_node.shape as RectangleShape2D
		body_shape_node.shape = body_rect.duplicate()
		_base_body_size = (body_shape_node.shape as RectangleShape2D).size

func _apply_size_profile() -> void:
	var key := box_size.to_upper()
	if not SIZE_SCALE.has(key):
		key = "M"
	var factor: float = float(SIZE_SCALE[key])

	if sprite != null:
		sprite.scale = _base_sprite_scale * factor

	if hit_shape_node != null and hit_shape_node.shape is RectangleShape2D:
		var hit_rect := hit_shape_node.shape as RectangleShape2D
		hit_rect.size = _base_hit_size * factor

	if body_shape_node != null and body_shape_node.shape is RectangleShape2D:
		var body_rect := body_shape_node.shape as RectangleShape2D
		body_rect.size = _base_body_size * factor

func _update_z_index() -> void:
	if held_by_robot:
		z_index = HELD_Z_INDEX
	elif on_conveyor:
		z_index = CONVEYOR_Z_INDEX
	else:
		z_index = DEFAULT_Z_INDEX
