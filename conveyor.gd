extends Node2D
class_name Conveyor

@export var speed: float = 100.0
@export var direction: Vector2 = Vector2.DOWN
@export var drive_delay: float = 0.0

@onready var belt_area: Area2D = $BeltArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var boxes_on_belt: Array[Node2D] = []
var _world_direction: Vector2 = Vector2.DOWN
var running: bool = false
var _box_entered_at: Dictionary = {}

signal START_CONVEYOR
signal STOP_CONVEYOR

func _ready() -> void:
	add_to_group("conveyor")
	direction = direction.normalized()
	_world_direction = direction.rotated(global_rotation).normalized()
	belt_area.area_entered.connect(_on_area_entered)
	belt_area.area_exited.connect(_on_area_exited)

	if anim:
		anim.stop()
		anim.frame = 0
	else:
		push_error("Conveyor: Missing AnimatedSprite2D node.")

func _physics_process(_delta: float) -> void:
	if not running:
		return
	for box in boxes_on_belt:
		if not is_instance_valid(box):
			continue
		if box is Box:
			if _is_box_on_running_conveyor_right(box as Box):
				continue
			if not _is_box_drive_ready(box as Box):
				continue
			(box as Box).velocity = _world_direction * speed

func _on_area_entered(area: Area2D) -> void:
	var box: Node = area.get_parent()
	if box is Box:
		if not boxes_on_belt.has(box):
			boxes_on_belt.append(box)
			(box as Box).set_on_conveyor(true)
			_box_entered_at[box] = Time.get_ticks_msec()
		if running and _is_box_drive_ready(box as Box):
			if _is_box_on_running_conveyor_right(box as Box):
				return
			(box as Box).velocity = _world_direction * speed

func _on_area_exited(area: Area2D) -> void:
	var box: Node = area.get_parent()
	if box is Box:
		boxes_on_belt.erase(box)
		_box_entered_at.erase(box)
		(box as Box).set_on_conveyor(false)
		if not _is_box_on_any_running_conveyor(box as Box):
			(box as Box).velocity = Vector2.ZERO

func start() -> void:
	if running:
		return
	running = true
	if anim:
		anim.play("run")
	for box in boxes_on_belt:
		if box is Box:
			if _is_box_on_running_conveyor_right(box as Box):
				continue
			if not _is_box_drive_ready(box as Box):
				continue
			(box as Box).velocity = _world_direction * speed
	START_CONVEYOR.emit()

func stop() -> void:
	if not running:
		return
	running = false
	if anim:
		anim.stop()
	for box in boxes_on_belt:
		if box is Box and not _is_box_on_any_running_conveyor(box as Box):
			(box as Box).velocity = Vector2.ZERO
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

func place_box_on_belt(box: Box) -> void:
	if box == null or not is_instance_valid(box):
		return
	if not is_point_inside_belt(box.global_position):
		if boxes_on_belt.has(box):
			boxes_on_belt.erase(box)
			box.set_on_conveyor(false)
		if not _is_box_on_any_running_conveyor(box):
			box.velocity = Vector2.ZERO
		return
	if not boxes_on_belt.has(box):
		boxes_on_belt.append(box)
		box.set_on_conveyor(true)
		_box_entered_at[box] = Time.get_ticks_msec()
	if running:
		if not _is_box_on_running_conveyor_right(box) and _is_box_drive_ready(box):
			box.velocity = _world_direction * speed
	else:
		box.velocity = Vector2.ZERO

func get_closest_point_on_belt(world_point: Vector2) -> Vector2:
	var collision_shape := _get_belt_collision_shape()
	if collision_shape == null:
		return belt_area.global_position

	var rect_shape := collision_shape.shape as RectangleShape2D
	var half_size := rect_shape.size * 0.5
	var local_point := collision_shape.to_local(world_point)
	var clamped_local := Vector2(
		clamp(local_point.x, -half_size.x, half_size.x),
		clamp(local_point.y, -half_size.y, half_size.y)
	)

	return collision_shape.to_global(clamped_local)

func distance_to_belt(world_point: Vector2) -> float:
	return world_point.distance_to(get_closest_point_on_belt(world_point))

func is_point_inside_belt(world_point: Vector2) -> bool:
	var collision_shape := _get_belt_collision_shape()
	if collision_shape == null:
		return false

	var rect_shape := collision_shape.shape as RectangleShape2D
	var half_size := rect_shape.size * 0.5
	var local_point := collision_shape.to_local(world_point)
	return abs(local_point.x) <= half_size.x and abs(local_point.y) <= half_size.y

func _get_belt_collision_shape() -> CollisionShape2D:
	var shape_node := belt_area.get_node_or_null("CollisionShape2D")
	if shape_node == null:
		return null
	if not (shape_node is CollisionShape2D):
		return null

	var collision_shape := shape_node as CollisionShape2D
	if not (collision_shape.shape is RectangleShape2D):
		return null
	return collision_shape

func _is_box_drive_ready(box: Box) -> bool:
	if drive_delay <= 0.0:
		return true
	if not _box_entered_at.has(box):
		_box_entered_at[box] = Time.get_ticks_msec()
		return false
	var elapsed := float(Time.get_ticks_msec() - int(_box_entered_at[box])) / 1000.0
	return elapsed >= drive_delay

func _on_factory_controller_command_emitted(command: String) -> void:
	handle_command(command)

func _is_box_on_any_running_conveyor(box: Box) -> bool:
	var tree := get_tree()
	if tree == null:
		return false
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
			if conv_right.is_running() and conv_right.boxes_on_belt.has(box):
				return true
	return false

func _is_box_on_running_conveyor_right(box: Box) -> bool:
	var station_root := get_parent()
	if station_root == null:
		return false
	for node in station_root.get_children():
		if node is ConveyorRight:
			var conv_right := node as ConveyorRight
			if conv_right.is_running() and conv_right.boxes_on_belt.has(box):
				return true
	return false
