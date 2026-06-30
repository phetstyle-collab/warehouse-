extends Area2D

@export var display_name := "robotarm"
@export var hover_priority := 10

func _ready() -> void:
	set_meta("hover_text", display_name)
	set_meta("hover_priority", hover_priority)
	add_to_group("hoverable")
