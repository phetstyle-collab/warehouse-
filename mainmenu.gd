extends Control

@onready var start_button: Button = $SafeMargin/OverlayShell/ShellMargin/LayoutRow/MenuColumn/MenuPanel/MenuMargin/MenuVBox/ButtonsVBox/StartButton
@onready var level_select_button: Button = $SafeMargin/OverlayShell/ShellMargin/LayoutRow/MenuColumn/MenuPanel/MenuMargin/MenuVBox/ButtonsVBox/LevelSelectButton
@onready var how_to_play_button: Button = $SafeMargin/OverlayShell/ShellMargin/LayoutRow/MenuColumn/MenuPanel/MenuMargin/MenuVBox/ButtonsVBox/HowToPlayButton
@onready var tutorial_button: Button = $SafeMargin/OverlayShell/ShellMargin/LayoutRow/MenuColumn/MenuPanel/MenuMargin/MenuVBox/ButtonsVBox/TutorialButton
@onready var quit_button: Button = $SafeMargin/OverlayShell/ShellMargin/LayoutRow/MenuColumn/MenuPanel/MenuMargin/MenuVBox/ButtonsVBox/QuitButton
@onready var system_status_label: Label = $SafeMargin/OverlayShell/ShellMargin/LayoutRow/MenuColumn/MenuPanel/MenuMargin/MenuVBox/SystemPanel/SystemMargin/SystemVBox/SystemStatus

func _ready() -> void:
	if not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
	if not level_select_button.pressed.is_connected(_on_level_select_button_pressed):
		level_select_button.pressed.connect(_on_level_select_button_pressed)
	if not how_to_play_button.pressed.is_connected(_on_how_to_play_button_pressed):
		how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	if not tutorial_button.pressed.is_connected(_on_tutorial_button_pressed):
		tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	if not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://how_to_play.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial_select.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
