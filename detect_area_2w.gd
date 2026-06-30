extends Area2D

@export var display_name := "weightsensor"
@export var hover_priority := 10  # ใครมากกว่า = ชนะ

func _ready() -> void:
	# ให้ TooltipManager อ่านข้อมูลจาก meta
	set_meta("hover_text", display_name)
	set_meta("hover_priority", hover_priority)
	add_to_group("hoverable")
