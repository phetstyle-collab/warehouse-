extends ScrollContainer

@export var scroll_speed := 40

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_vertical -= scroll_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_vertical += scroll_speed
