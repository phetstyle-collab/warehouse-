extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TooltipManager.setup($CanvasLayer/HoverNameLabel)
	CodePanelToggle.setup(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
