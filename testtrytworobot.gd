extends Node2D

func _ready() -> void:
	var hover := get_node_or_null("CanvasLayer/HoverNameLabel")
	var tooltip_manager := get_node_or_null("/root/TooltipManager")
	if hover != null and tooltip_manager != null and tooltip_manager.has_method("setup"):
		tooltip_manager.call("setup", hover)
	CodePanelToggle.setup(self)

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _load_demo_script() -> void:
	var editor := get_node_or_null("Control/VBoxContainer/TextEdit")
	if editor == null or not (editor is TextEdit):
		return
	var text_edit := editor as TextEdit
	if text_edit.text.strip_edges() != "":
		return

	var path := "res://testtrytworobot_demo.minic"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	text_edit.text = file.get_as_text()
