extends Node2D

@onready var code_panel: Control = null  # layout handled by SplitScreenSetup (game_split_screen.gd)

func _ready() -> void:
	TooltipManager.setup($CanvasLayer/HoverNameLabel)
	call_deferred("_force_show_code_panel")


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _force_show_code_panel() -> void:
	if code_panel == null:
		return

	await get_tree().process_frame

	code_panel.visible = true
	code_panel.z_as_relative = false
	code_panel.z_index = 500
	code_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	code_panel.global_position = Vector2(900, 82)
	code_panel.size = Vector2(340, 608)
	code_panel.custom_minimum_size = Vector2(340, 608)

	if code_panel.has_method("_apply_playground_layout"):
		code_panel.call("_apply_playground_layout")

	code_panel.visible = true
	code_panel.global_position = Vector2(900, 82)
	code_panel.size = Vector2(340, 608)
