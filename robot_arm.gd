extends Node2D
class_name RobotArm

enum ClickMoveDirection {
	RIGHT,
	LEFT,
	UP,
	FORWARD,
	BACKWARD,
	CUSTOM,
}

@export var rotation_speed_deg: float = 120.0
@export var drop_snap_distance: float = 220.0
@export var drop_target_conveyor_path: NodePath
@export var manual_move_speed: float = 180.0
@export var allow_click_control: bool = false
@export var allow_keyboard_control: bool = false
@export var click_move_enabled: bool = true
@export var click_move_speed: float = 140.0
@export var click_move_direction: ClickMoveDirection = ClickMoveDirection.RIGHT
@export var click_move_distance: float = 120.0
@export var click_move_custom_offset: Vector2 = Vector2(120, 0)
@export var click_move_use_l_path: bool = true
@export var click_move_l_horizontal: float = 120.0
@export var click_move_l_vertical: float = 120.0
@export var click_move_return_to_start: bool = true
@export var move_target_path: NodePath
@export var move_target_axis_aligned: bool = true
@export var move_target_x_first: bool = true
@export var path_follow_path: NodePath
@export var path_follow_paths: Array[NodePath] = []
@export var path_names: Array[String] = []
@export var path_move_speed: float = 140.0
@export var grip_animation_speed: float = 1.0

@onready var pivot: Node2D = $ArmPivot
@onready var arm_sprite: AnimatedSprite2D = $ArmPivot/ArmSprite
@onready var attach_point: Marker2D = $ArmPivot/AttachPoint
@onready var grab_area: Area2D = $ArmPivot/GrabArea
@onready var select_area: Area2D = $DetectArea
@onready var drop_target_conveyor: Conveyor = get_node_or_null(drop_target_conveyor_path)
@onready var move_target: Node2D = get_node_or_null(move_target_path) as Node2D
@onready var path_follow: PathFollow2D = _resolve_path_follow()

signal action_finished(action_name: String)

var held_box: Box = null
var _candidates: Array[Box] = []

var rotating: bool = false
var target_angle: float = 0.0
var moving_to_click_target: bool = false
var click_target_position: Vector2 = Vector2.ZERO
var click_move_targets: Array[Vector2] = []
var moving_on_path: bool = false
var _path_map: Dictionary = {}

static var selected_arm: RobotArm = null

func _ready() -> void:
	print("RobotArm ready")
	z_as_relative = false
	z_index = 60
	_set_grip_open_default()

	if grab_area == null:
		push_error("RobotArm: GrabArea not found")
		return

	grab_area.monitoring = true
	grab_area.monitorable = true
	grab_area.body_entered.connect(_on_body_entered)
	grab_area.body_exited.connect(_on_body_exited)

	_build_path_map()

	if allow_click_control and select_area != null:
		select_area.input_pickable = true
		select_area.input_event.connect(_on_select_area_input_event)
	elif select_area != null:
		select_area.input_pickable = false

	print("GrabArea connected")

func _process(delta: float) -> void:
	_process_path_move(delta)
	_process_click_move(delta)
	_process_manual_move(delta)

	if rotating:
		var current: float = rad_to_deg(pivot.rotation)
		var diff: float = target_angle - current

		if abs(diff) < 1.0:
			pivot.rotation = deg_to_rad(target_angle)
			rotating = false
			print("Arm reached angle:", target_angle)
			action_finished.emit("ROTATE_ARM")
			return

		var step: float = rotation_speed_deg * delta * sign(diff)
		pivot.rotation += deg_to_rad(step)

func rotate_to(angle_deg: float) -> void:
	target_angle = angle_deg
	rotating = true
	print("Rotate arm to:", angle_deg)

func rotate_by(delta_deg: float) -> void:
	var current_deg: float = rad_to_deg(pivot.rotation)
	rotate_to(current_deg + delta_deg)

func pick() -> void:
	if held_box != null:
		print("Already holding box")
		return

	_refresh_grab_candidates()
	if _candidates.is_empty():
		print("No box in grab area")
		await _play_grip_animation("close")
		return

	var box: Box = _candidates[0]
	await _play_grip_animation("close")
	if box == null or not is_instance_valid(box):
		print("Box disappeared before pick")
		return
	held_box = box
	held_box.grab()

	held_box.get_parent().remove_child(held_box)
	attach_point.add_child(held_box)
	held_box.position = Vector2.ZERO

	print("Picked box:", held_box)
	action_finished.emit("PICK_BOX")

func drop() -> void:
	if held_box == null:
		print("No box to drop")
		await _play_grip_animation("open")
		return

	var box: Box = held_box
	held_box = null

	await _play_grip_animation("open")
	attach_point.remove_child(box)
	get_parent().add_child(box)
	box.global_position = attach_point.global_position
	box.release()
	_snap_dropped_box_to_nearest_conveyor(box)

	print("Dropped box:", box)
	action_finished.emit("DROP_BOX")

func _snap_dropped_box_to_nearest_conveyor(box: Box) -> void:
	if box == null or not is_instance_valid(box):
		return
	if drop_target_conveyor != null:
		drop_target_conveyor.place_box_on_belt(box)
		return
	var tree := get_tree()
	if tree == null:
		return

	var nearest: Conveyor = null
	var nearest_distance := drop_snap_distance
	for node in tree.get_nodes_in_group("conveyor"):
		if not (node is Conveyor):
			continue
		var conveyor := node as Conveyor
		var distance := conveyor.distance_to_belt(box.global_position)
		if distance > nearest_distance:
			continue
		nearest = conveyor
		nearest_distance = distance

	if nearest != null:
		nearest.place_box_on_belt(box)

func _play_grip_animation(animation_name: String) -> void:
	if arm_sprite == null or arm_sprite.sprite_frames == null:
		print("RobotArm grip animation skipped: missing AnimatedSprite2D")
		return
	if not arm_sprite.sprite_frames.has_animation(animation_name):
		print("RobotArm grip animation missing:", animation_name)
		return
	arm_sprite.speed_scale = grip_animation_speed
	arm_sprite.play(animation_name)
	print("RobotArm grip animation:", animation_name)
	await arm_sprite.animation_finished

func _set_grip_open_default() -> void:
	if arm_sprite == null or arm_sprite.sprite_frames == null:
		return
	arm_sprite.animation = &"close"
	arm_sprite.frame = 0

func _refresh_grab_candidates() -> void:
	if grab_area == null:
		return
	_candidates = _candidates.filter(func(box: Box) -> bool:
		return box != null and is_instance_valid(box) and not box.held_by_robot
	)
	for body in grab_area.get_overlapping_bodies():
		if body is Box and not (body as Box).held_by_robot:
			var box := body as Box
			if box not in _candidates:
				_candidates.append(box)
	for area in grab_area.get_overlapping_areas():
		var parent := area.get_parent()
		if parent is Box and not (parent as Box).held_by_robot:
			var box := parent as Box
			if box not in _candidates:
				_candidates.append(box)
	print("RobotArm grab candidates:", _candidates.size())

func _on_body_entered(body: Node) -> void:
	if body is Box and not body.held_by_robot:
		if body not in _candidates:
			_candidates.append(body)
			print("Box entered grab area")

func _on_body_exited(body: Node) -> void:
	if body is Box:
		_candidates.erase(body)
		print("Box exited grab area")

func _on_select_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			selected_arm = self
			if click_move_enabled:
				_start_click_move()
			print("RobotArm selected:", name)

func _process_click_move(delta: float) -> void:
	if moving_on_path or not moving_to_click_target:
		return
	global_position = global_position.move_toward(click_target_position, click_move_speed * delta)
	if global_position.distance_to(click_target_position) <= 1.0:
		global_position = click_target_position
		_start_next_click_move_target()

func _process_manual_move(delta: float) -> void:
	if not allow_keyboard_control:
		return
	if selected_arm != self:
		return
	if _is_text_input_focused():
		return

	var move_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		move_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		move_dir.y += 1.0
	if Input.is_key_pressed(KEY_A):
		move_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		move_dir.x += 1.0

	if move_dir == Vector2.ZERO:
		return
	moving_on_path = false
	moving_to_click_target = false
	click_move_targets.clear()
	global_position += move_dir.normalized() * manual_move_speed * delta

func _start_click_move() -> void:
	if path_follow != null:
		_start_path_move(path_follow)
		return

	click_move_targets.clear()
	if move_target != null:
		_append_move_target_path(global_position, move_target.global_position)
		_start_next_click_move_target()
		return

	var start_pos := global_position
	if click_move_use_l_path:
		var right_pos := start_pos + Vector2(click_move_l_horizontal, 0)
		var up_pos := start_pos + Vector2(click_move_l_horizontal, -click_move_l_vertical)
		var left_pos := start_pos + Vector2(0, -click_move_l_vertical)
		click_move_targets.append(right_pos)
		click_move_targets.append(up_pos)
		click_move_targets.append(left_pos)
		if click_move_return_to_start:
			click_move_targets.append(start_pos)
	else:
		click_move_targets.append(start_pos + _get_click_move_offset())
	_start_next_click_move_target()

func _append_move_target_path(from_position: Vector2, to_position: Vector2) -> void:
	if not move_target_axis_aligned:
		click_move_targets.append(to_position)
		return

	var corner := Vector2(to_position.x, from_position.y) if move_target_x_first else Vector2(from_position.x, to_position.y)
	if from_position.distance_to(corner) > 1.0:
		click_move_targets.append(corner)
	if corner.distance_to(to_position) > 1.0:
		click_move_targets.append(to_position)

func _start_next_click_move_target() -> void:
	if click_move_targets.is_empty():
		moving_to_click_target = false
		print("RobotArm reached move target:", name)
		return
	click_target_position = click_move_targets.pop_front()
	moving_to_click_target = true
	print("RobotArm move target:", click_target_position)

func _get_click_move_offset() -> Vector2:
	match click_move_direction:
		ClickMoveDirection.RIGHT:
			return Vector2(click_move_distance, 0)
		ClickMoveDirection.LEFT:
			return Vector2(-click_move_distance, 0)
		ClickMoveDirection.UP:
			return Vector2(0, -click_move_distance)
		ClickMoveDirection.FORWARD:
			return Vector2(0, -click_move_distance)
		ClickMoveDirection.BACKWARD:
			return Vector2(0, click_move_distance)
		ClickMoveDirection.CUSTOM:
			return click_move_custom_offset
	return Vector2.ZERO

func move_path(path_name: String) -> void:
	print("RobotArm movement disabled. Path command ignored:", path_name)

func move_path_index(index: int) -> void:
	print("RobotArm movement disabled. Path index ignored:", index)

func _start_path_move(selected_path: PathFollow2D) -> void:
	if selected_path == null:
		return
	path_follow = selected_path
	click_move_targets.clear()
	moving_to_click_target = false
	path_follow.progress = 0.0
	path_follow.loop = false
	path_follow.rotates = false
	moving_on_path = true
	print("RobotArm path move started:", name)

func _process_path_move(_delta: float) -> void:
	return

func _resolve_path_follow() -> PathFollow2D:
	var from_path := get_node_or_null(path_follow_path) as PathFollow2D
	if from_path != null:
		return from_path
	var parent_node := get_parent()
	if parent_node is PathFollow2D:
		return parent_node as PathFollow2D
	return null

func _build_path_map() -> void:
	_path_map.clear()
	for i in range(path_follow_paths.size()):
		var follow := get_node_or_null(path_follow_paths[i]) as PathFollow2D
		if follow == null:
			continue
		var label := str(i + 1)
		if i < path_names.size() and str(path_names[i]).strip_edges() != "":
			label = str(path_names[i]).strip_edges()
		_path_map[label.to_lower()] = follow

func _is_text_input_focused() -> bool:
	var viewport := get_viewport()
	if viewport == null:
		return false
	var focus_owner := viewport.gui_get_focus_owner()
	return focus_owner is TextEdit or focus_owner is LineEdit
