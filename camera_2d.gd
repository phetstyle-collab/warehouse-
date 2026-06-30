extends Camera2D

@export var drag_speed: float = 1.0
@export var keyboard_speed: float = 520.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var default_zoom: float = 0.75
@export var allow_keyboard_move: bool = false
@export var allow_mouse_zoom: bool = false

var is_dragging := false
var last_mouse_position := Vector2.ZERO
var reset_position := Vector2.ZERO
var reset_zoom := Vector2.ONE


func _ready() -> void:
	reset_position = position
	zoom = Vector2(default_zoom, default_zoom)
	reset_zoom = zoom
	make_current()


func _process(delta: float) -> void:
	if not allow_keyboard_move:
		return
	if _is_typing_in_text_control():
		return

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	if direction != Vector2.ZERO:
		position += direction.normalized() * keyboard_speed * delta / zoom.x


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if _is_typing_in_text_control():
			return
		if event.keycode == KEY_HOME:
			position = reset_position
			zoom = reset_zoom
			return

	# คลิกกลางหรือคลิกขวาค้างไว้เพื่อลากกล้อง
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
			last_mouse_position = event.position

		if allow_mouse_zoom and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(-zoom_speed, event.position)

		if allow_mouse_zoom and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(zoom_speed, event.position)

	if event is InputEventMouseMotion and is_dragging:
		var mouse_delta: Vector2 = event.position - last_mouse_position
		position -= mouse_delta * zoom * drag_speed
		last_mouse_position = event.position


func zoom_camera(amount: float, _mouse_position: Vector2) -> void:
	var new_zoom_value: float = clampf(
		zoom.x + amount,
		min_zoom,
		max_zoom
	)

	var mouse_before_zoom: Vector2 = get_global_mouse_position()
	zoom = Vector2(new_zoom_value, new_zoom_value)
	var mouse_after_zoom: Vector2 = get_global_mouse_position()

	position += mouse_before_zoom - mouse_after_zoom


func _is_typing_in_text_control() -> bool:
	var focused: Control = get_viewport().gui_get_focus_owner()
	return focused is TextEdit or focused is LineEdit
