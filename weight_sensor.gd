extends Node2D
class_name WeightSensor

signal box_detected(data: Dictionary)

@export var tolerance: float = 0.0
@export var detect_delay: float = 0.5

@export var frame_idle: int = 0
@export var frame_found: int = 1

@onready var display: Label = $DisplayRoot/Display
@onready var display_panel: Panel = $DisplayRoot/DisplayPanel
@onready var detect_area: Area2D = $DetectArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var has_value: bool = false
var value: float = 0.0
var _current_box: Box = null

# target ที่ถูก set จาก IF ในหลังบ้าน
var target_weight: float = 0.0
var target_is_set: bool = false
var found_target: bool = false

func _ready():
	_apply_display_theme()
	_clear()

	detect_area.area_entered.connect(_on_area_entered)
	detect_area.area_exited.connect(_on_area_exited)

	if anim:
		anim.stop()
		anim.speed_scale = 0.0
		anim.frame = frame_idle

func _physics_process(_delta: float) -> void:
	_refresh_detection()

func _on_area_entered(area: Area2D):
	var box := area.get_parent()
	if box is Box and not (box as Box).held_by_robot:
		_read_weight(box as Box)

func _on_area_exited(area: Area2D):
	var box := area.get_parent()
	if box is Box:
		call_deferred("_refresh_detection")

func _refresh_detection() -> void:
	var box := _find_detected_box()
	if box == null:
		if has_value:
			_clear()
		return
	if box != _current_box or not has_value or not is_equal_approx(value, float(box.weight_kg)):
		_read_weight(box)

func _find_detected_box() -> Box:
	if detect_area == null:
		return null
	for area in detect_area.get_overlapping_areas():
		var parent := area.get_parent()
		if parent is Box and not (parent as Box).held_by_robot:
			return parent as Box
	for body in detect_area.get_overlapping_bodies():
		if body is Box and not (body as Box).held_by_robot:
			return body as Box
	return null

func _read_weight(box: Box) -> void:
	_current_box = box
	var w := float(box.weight_kg)

	display.text = "WEIGHT: %s kg" % _format_weight(w)
	display.modulate = Color8(255, 235, 150)

	has_value = true
	value = w

	var data := {
		"sensor": "WeightSensor",
		"box_id": box.box_id,
		"weight": w
	}
	box_detected.emit(data)

	if detect_delay > 0.0:
		await get_tree().create_timer(detect_delay).timeout

	# ✅ เปลี่ยนเฟรมเฉพาะตอนที่หลังบ้าน set target มาแล้ว
	if target_is_set and not found_target and _is_target(w):
		_set_frame(frame_found)
		found_target = true

func _clear() -> void:
	_current_box = null
	display.text = "WEIGHT: ---"
	display.modulate = Color8(232, 240, 255)
	has_value = false
	value = 0.0
	_set_frame(frame_idle)

func _format_weight(w: float) -> String:
	if is_equal_approx(w, round(w)):
		return str(int(round(w)))
	return "%.1f" % w

func get_current_box_id() -> int:
	if _current_box == null or not is_instance_valid(_current_box):
		return -1
	return int(_current_box.box_id)

func _apply_display_theme() -> void:
	if display_panel != null:
		display_panel.add_theme_stylebox_override("panel", _make_display_style(Color(0.07, 0.055, 0.02, 0.9), Color8(255, 199, 87)))
	if display != null:
		display.add_theme_font_size_override("font_size", 13)
		display.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		display.add_theme_constant_override("outline_size", 3)
		display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _make_display_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	return style

# ✅ หลังบ้านเรียกตอนเจอ IF weight == X
func set_target_from_if(x: float) -> void:
	target_weight = x
	target_is_set = true
	found_target = false
	_set_frame(frame_idle)

func _is_target(w: float) -> bool:
	var min_w = target_weight - tolerance
	var max_w = target_weight + tolerance
	return w >= min_w and w <= max_w

func _set_frame(idx: int) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	anim.stop()
	anim.speed_scale = 0.0
	anim.frame = idx
