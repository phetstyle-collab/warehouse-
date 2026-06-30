extends Node2D
class_name SizeSensor

signal box_detected(data: Dictionary)

@export var detect_delay: float = 0.5
@export var frame_idle: int = 0
@export var frame_found: int = 1

@onready var detect_area: Area2D = $DetectArea
@onready var display: Label = $DisplayRoot/Display
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var has_value: bool = false
var value: String = ""
var target_size: String = ""
var target_is_set: bool = false
var found_target: bool = false

func _ready() -> void:
	display.text = "---"
	display.modulate = Color.WHITE
	detect_area.area_entered.connect(_on_area_entered)
	detect_area.area_exited.connect(_on_area_exited)
	if anim:
		anim.stop()
		anim.speed_scale = 0.0
		anim.frame = frame_idle

func _on_area_entered(area: Area2D) -> void:
	var box := area.get_parent()
	if box is Box:
		_read_size(box as Box)

func _on_area_exited(area: Area2D) -> void:
	var box := area.get_parent()
	if box is Box:
		_clear()

func _read_size(box: Box) -> void:
	var size_value := str(box.box_size).to_upper()
	display.text = size_value
	display.modulate = Color.WHITE
	has_value = size_value != ""
	value = size_value

	box_detected.emit({
		"sensor": "SizeSensor",
		"box_id": box.box_id,
		"size": value,
	})

	if detect_delay > 0.0:
		await get_tree().create_timer(detect_delay).timeout
	if target_is_set and not found_target and _is_target(value):
		_set_frame(frame_found)
		found_target = true

func _clear() -> void:
	display.text = "---"
	display.modulate = Color.WHITE
	has_value = false
	value = ""
	_set_frame(frame_idle)

func set_target_from_if(size_name: String) -> void:
	target_size = str(size_name).to_upper()
	target_is_set = target_size != ""
	found_target = false
	_set_frame(frame_idle)

func _is_target(size_name: String) -> bool:
	if not target_is_set:
		return false
	return str(size_name).to_upper() == target_size

func _set_frame(idx: int) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	anim.stop()
	anim.speed_scale = 0.0
	anim.frame = idx
