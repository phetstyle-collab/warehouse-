extends CharacterBody2D
class_name RodCart

signal action_finished(action_name: String)
signal action_failed(action_name: String)

@export var open_texture: Texture2D
@export var open_alt_texture: Texture2D
@export var mid_texture: Texture2D
@export var closed_texture: Texture2D
@export var path_follow_paths: Array[NodePath] = []
@export var path_names: Array[String] = []
@export var path_move_speed: float = 180.0
@export var rotate_with_path: bool = true
@export var path_rotation_offset_deg: float = 0.0
@export var right_rotation_deg: float = 90.0
@export var left_rotation_deg: float = -90.0
@export var up_rotation_deg: float = -180.0
@export var down_rotation_deg: float = 180.0
@export var target_visual_height: float = 100.0
@export var drop_snap_distance: float = 220.0
@export var drop_target_conveyor_path: NodePath
@export var path_start_delay: float = 0.5
@export var path_entry_speed: float = 220.0
@export var path_entry_snap_distance: float = 4.0
@export var grab_offset: Vector2 = Vector2(0, -38)
@export var grab_fallback_radius: float = 90.0
@export var grip_frame_delay: float = 0.08
@export var wheel_frame_interval: float = 0.08

@onready var sprite: Sprite2D = $Sprite2D
@onready var carry_point: Marker2D = $Marker2D
@onready var grab_area: Area2D = $Area2D
@onready var drop_target_conveyor: Conveyor = get_node_or_null(drop_target_conveyor_path)
@onready var wheel_root: Node2D = get_node_or_null("WheelRoot") as Node2D

var held_box: Box = null
var _candidates: Array[Box] = []
var _path_map: Dictionary = {}
var _path_follow: PathFollow2D = null
var _runtime_path_follow: PathFollow2D = null
var _moving_on_path: bool = false
var _moving_to_path_start: bool = false
var _last_path_position: Vector2 = Vector2.ZERO
var _path_start_position: Vector2 = Vector2.ZERO
var _path_start_token: int = 0
var _visual_rotation_rad: float = 0.0
var _wheel_sprites: Array[Sprite2D] = []
var _wheel_textures: Array[Texture2D] = []
var _wheel_frame_time: float = 0.0
var _wheel_frame_index: int = 0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	z_as_relative = false
	z_index = 65
	_collect_wheel_sprites()
	_apply_grab_transform()
	_set_open_visual()

	if grab_area != null:
		grab_area.monitoring = true
		grab_area.monitorable = true
		if not grab_area.body_entered.is_connected(_on_body_entered):
			grab_area.body_entered.connect(_on_body_entered)
		if not grab_area.body_exited.is_connected(_on_body_exited):
			grab_area.body_exited.connect(_on_body_exited)
	_build_path_map()


func _process(delta: float) -> void:
	_process_path_entry_move(delta)
	_process_path_move(delta)
	_process_wheel_animation(delta)


func pick() -> void:
	if held_box != null:
		print("RodCart: already holding box")
		action_finished.emit("CART_PICK")
		return
	_refresh_grab_candidates()
	if _candidates.is_empty():
		var nearest := _find_nearest_box_to_grab()
		if nearest != null:
			_candidates.append(nearest)
		else:
			print("RodCart: no box in grab area")
			action_failed.emit("CART_PICK")
			return

	var box := _candidates[0]
	if box == null or not is_instance_valid(box):
		_candidates.remove_at(0)
		pick()
		return

	held_box = box
	held_box.grab()
	held_box.get_parent().remove_child(held_box)
	carry_point.add_child(held_box)
	held_box.position = Vector2.ZERO

	await _play_grip_close()
	action_finished.emit("CART_PICK")


func drop() -> void:
	if held_box == null:
		print("RodCart: no box to drop")
		action_failed.emit("CART_DROP")
		return

	var box := held_box
	held_box = null

	carry_point.remove_child(box)
	get_parent().add_child(box)
	box.global_position = carry_point.global_position
	box.release()
	_snap_dropped_box_to_nearest_conveyor(box)

	await _play_grip_open()
	action_finished.emit("CART_DROP")


func move_path(path_name: String) -> void:
	_build_path_map()
	var key := path_name.strip_edges().to_lower()
	if not _path_map.has(key):
		print("RodCart path not found: %s available=%s parent=%s" % [path_name, str(_path_map.keys()), get_parent().name if get_parent() != null else "<none>"])
		action_failed.emit("MOVE_PATH")
		return
	var selected_path := _path_map[key] as PathFollow2D
	print("RodCart path selected: %s -> %s cart=%s parent=%s" % [path_name, selected_path.get_path(), name, get_parent().name if get_parent() != null else "<none>"])
	_start_path_move_after_delay(selected_path)


func _start_path_move_after_delay(selected_path: PathFollow2D) -> void:
	_path_start_token += 1
	var token := _path_start_token
	if path_start_delay > 0.0:
		print("RodCart path delay %.2fs before move: %s" % [path_start_delay, name])
		await get_tree().create_timer(path_start_delay).timeout
	if token != _path_start_token:
		return
	_start_path_move(selected_path)


func _start_path_move(selected_path: PathFollow2D) -> void:
	if selected_path == null:
		action_failed.emit("MOVE_PATH")
		return
	if selected_path.get_parent() == null:
		print("RodCart selected PathFollow2D has no parent:", selected_path.name)
		action_failed.emit("MOVE_PATH")
		return

	_clear_runtime_path_follow()
	var path_parent := selected_path.get_parent()
	var runtime_follow := PathFollow2D.new()
	runtime_follow.name = "%s_RuntimeFollow" % name
	runtime_follow.loop = false
	runtime_follow.rotates = false
	path_parent.add_child(runtime_follow)
	_runtime_path_follow = runtime_follow
	_path_follow = runtime_follow
	_path_follow.progress = 0.0
	_path_follow.loop = false
	_path_follow.rotates = false
	_path_start_position = _path_follow.global_position
	_last_path_position = global_position

	if global_position.distance_to(_path_start_position) > path_entry_snap_distance:
		_moving_to_path_start = true
		_moving_on_path = false
		print("RodCart path entry move: cart=%s from=%s to=%s" % [name, str(global_position), str(_path_start_position)])
	else:
		global_position = _path_start_position
		_begin_follow_path()


func _process_path_entry_move(delta: float) -> void:
	if not _moving_to_path_start:
		return
	var to_start := _path_start_position - global_position
	var distance := to_start.length()
	if distance <= max(path_entry_snap_distance, path_entry_speed * delta):
		global_position = _path_start_position
		_moving_to_path_start = false
		_begin_follow_path()
		return
	var step := to_start.normalized() * path_entry_speed * delta
	if rotate_with_path:
		_apply_visual_direction(step)
	global_position += step
	_last_path_position = global_position


func _begin_follow_path() -> void:
	if _path_follow == null:
		action_failed.emit("MOVE_PATH")
		return
	_path_follow.progress = 0.0
	_last_path_position = _path_follow.global_position
	global_position = _last_path_position
	_moving_on_path = true
	print("RodCart path move started: cart=%s from=%s progress=%s" % [name, str(global_position), str(_path_follow.progress)])


func _process_path_move(delta: float) -> void:
	if not _moving_on_path or _path_follow == null:
		return
	_path_follow.progress += path_move_speed * delta
	var next_position := _path_follow.global_position
	if rotate_with_path:
		var move_delta := next_position - _last_path_position
		if move_delta.length() > 0.1:
			_apply_visual_direction(move_delta)
	global_position = next_position
	_last_path_position = next_position
	if _path_follow.progress_ratio >= 1.0:
		_moving_on_path = false
		print("RodCart path move finished: cart=%s at=%s" % [name, str(global_position)])
		_clear_runtime_path_follow()
		action_finished.emit("MOVE_PATH")


func _clear_runtime_path_follow() -> void:
	if _runtime_path_follow != null and is_instance_valid(_runtime_path_follow):
		_runtime_path_follow.queue_free()
	_runtime_path_follow = null
	_path_follow = null
	_moving_on_path = false
	_moving_to_path_start = false


func _build_path_map() -> void:
	_path_map.clear()
	for i in range(path_follow_paths.size()):
		var follow := _resolve_path_follow(path_follow_paths[i])
		if follow == null:
			continue
		var label := str(i + 1)
		if i < path_names.size() and str(path_names[i]).strip_edges() != "":
			label = str(path_names[i]).strip_edges()
		_path_map[label.to_lower()] = follow
	_add_sibling_path_fallback("A", "PathA")
	_add_sibling_path_fallback("B", "PathB")
	_add_sibling_path_fallback("PICK", "PathHome")
	_add_sibling_path_fallback("HOME", "Pattohome")


func _resolve_path_follow(path: NodePath) -> PathFollow2D:
	if path == NodePath():
		return null
	var follow := get_node_or_null(path) as PathFollow2D
	if follow != null:
		return follow

	# Spawned carts may be reparented later. Resolve ../PathX relative to the
	# nearest ancestor that actually owns the station paths instead of only the
	# cart's current parent.
	var text := str(path)
	var parts := text.split("/", false)
	var path_node_name := ""
	if parts.size() >= 2:
		path_node_name = str(parts[parts.size() - 2])
	if path_node_name == "":
		return null
	return _find_path_follow_in_ancestors(path_node_name)


func _add_sibling_path_fallback(label: String, path_node_name: String) -> void:
	var key := label.strip_edges().to_lower()
	if _path_map.has(key):
		return
	var follow := _find_path_follow_in_ancestors(path_node_name)
	if follow != null:
		_path_map[key] = follow


func _find_path_follow_in_ancestors(path_node_name: String) -> PathFollow2D:
	var node: Node = get_parent()
	while node != null:
		var follow := node.get_node_or_null("%s/PathFollow2D" % path_node_name) as PathFollow2D
		if follow != null:
			return follow
		node = node.get_parent()
	return null


func _rotation_degrees_for_direction(direction: Vector2) -> float:
	if abs(direction.x) >= abs(direction.y):
		if direction.x >= 0.0:
			return right_rotation_deg
		return left_rotation_deg
	if direction.y >= 0.0:
		return down_rotation_deg
	return up_rotation_deg


func _apply_visual_direction(direction: Vector2) -> void:
	if sprite == null:
		return
	_visual_rotation_rad = deg_to_rad(_rotation_degrees_for_direction(direction) + path_rotation_offset_deg)
	sprite.rotation = _visual_rotation_rad
	_apply_grab_transform()
	_apply_wheel_root_transform()


func _set_open_visual() -> void:
	if sprite != null and open_texture != null:
		sprite.texture = open_texture
		_apply_visual_size()
		_apply_grab_transform()


func _set_closed_visual() -> void:
	if sprite != null and closed_texture != null:
		sprite.texture = closed_texture
		_apply_visual_size()
		_apply_grab_transform()


func _play_grip_close() -> void:
	await _play_grip_frames([open_texture, open_alt_texture, mid_texture, closed_texture])


func _play_grip_open() -> void:
	await _play_grip_frames([closed_texture, mid_texture, open_alt_texture, open_texture])


func _play_grip_frames(frames: Array[Texture2D]) -> void:
	for texture in frames:
		if texture == null:
			continue
		if sprite != null:
			sprite.texture = texture
			_apply_visual_size()
			_apply_grab_transform()
		if grip_frame_delay > 0.0:
			await get_tree().create_timer(grip_frame_delay).timeout


func _apply_grab_transform() -> void:
	var rotated_offset := grab_offset.rotated(_visual_rotation_rad)
	if carry_point != null:
		carry_point.position = rotated_offset
		carry_point.rotation = _visual_rotation_rad
	if grab_area != null:
		grab_area.position = rotated_offset
		grab_area.rotation = _visual_rotation_rad


func _apply_wheel_root_transform() -> void:
	if wheel_root != null:
		wheel_root.rotation = _visual_rotation_rad


func _collect_wheel_sprites() -> void:
	_wheel_sprites.clear()
	_wheel_textures.clear()
	if wheel_root == null:
		return
	for child in wheel_root.get_children():
		if child is Sprite2D:
			var wheel := child as Sprite2D
			_wheel_sprites.append(wheel)
			if wheel.texture != null and wheel.texture not in _wheel_textures:
				_wheel_textures.append(wheel.texture)


func _process_wheel_animation(delta: float) -> void:
	if not _moving_on_path:
		return
	if _wheel_textures.size() < 2:
		return
	_wheel_frame_time += delta
	if _wheel_frame_time < wheel_frame_interval:
		return
	_wheel_frame_time = 0.0
	_wheel_frame_index = (_wheel_frame_index + 1) % _wheel_textures.size()
	for wheel in _wheel_sprites:
		if wheel != null:
			wheel.texture = _wheel_textures[_wheel_frame_index]


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


func _apply_visual_size() -> void:
	if sprite == null or sprite.texture == null:
		return
	var texture_size := sprite.texture.get_size()
	if texture_size.y <= 0.0:
		return
	var uniform_scale := target_visual_height / texture_size.y
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	for wheel in _wheel_sprites:
		if wheel != null:
			var x_sign := -1.0 if wheel.name.ends_with("R") else 1.0
			wheel.scale = Vector2(uniform_scale * x_sign, uniform_scale)


func _on_body_entered(body: Node) -> void:
	if body is Box and not body.held_by_robot:
		var box := body as Box
		if box not in _candidates:
			_candidates.append(box)
			print("RodCart: box entered grab area")


func _on_body_exited(body: Node) -> void:
	if body is Box:
		_candidates.erase(body)
		print("RodCart: box exited grab area")


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
	print("RodCart grab candidates:", _candidates.size())


func _find_nearest_box_to_grab() -> Box:
	var tree := get_tree()
	if tree == null:
		return null
	var grab_position := carry_point.global_position if carry_point != null else global_position
	var nearest: Box = null
	var nearest_distance := grab_fallback_radius
	for node in tree.get_nodes_in_group("box"):
		if not (node is Box):
			continue
		var box := node as Box
		if box.held_by_robot:
			continue
		var distance := box.global_position.distance_to(grab_position)
		if distance <= nearest_distance:
			nearest = box
			nearest_distance = distance
	if nearest != null:
		print("RodCart fallback grab box id=%s distance=%.2f" % [nearest.box_id, nearest_distance])
	return nearest
