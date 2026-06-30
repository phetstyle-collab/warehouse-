extends Node2D

var _code_button: Button = null
var _code_panel: Control = null
var _code_panels_by_button: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TooltipManager.setup($CanvasLayer/HoverNameLabel)
	CodePanelToggle.setup(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _bind_code_panel() -> void:
	_code_panels_by_button.clear()
	for button_name in ["code1", "code2", "code3", "Button"]:
		var button := get_node_or_null(button_name)
		if not (button is Button):
			continue
		var panel := button.get_node_or_null("Control")
		if not (panel is Control):
			continue
		panel.visible = false
		_code_panels_by_button[button] = panel
		if not button.pressed.is_connected(_on_any_code_button_pressed):
			button.pressed.connect(_on_any_code_button_pressed.bind(button))

	if _code_panels_by_button.has(get_node_or_null("code1")):
		_code_button = get_node_or_null("code1")
		_code_panel = _code_panels_by_button[_code_button]
	elif _code_panels_by_button.has(get_node_or_null("Button")):
		_code_button = get_node_or_null("Button")
		_code_panel = _code_panels_by_button[_code_button]

func _on_any_code_button_pressed(button: Button) -> void:
	if not _code_panels_by_button.has(button):
		return
	var panel: Control = _code_panels_by_button[button]
	panel.visible = not panel.visible

func _load_demo_script() -> void:
	var editor := get_node_or_null("Control/VBoxContainer/TextEdit")
	if editor == null and _code_panel != null:
		editor = _code_panel.get_node_or_null("VBoxContainer/TextEdit")
	if editor == null:
		return
	if not (editor is TextEdit):
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
