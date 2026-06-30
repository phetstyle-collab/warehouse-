extends Control

const MIN_SCENE_ZOOM := 0.45
const MAX_SCENE_ZOOM := 1.6
const ZOOM_STEP := 0.08
const PAN_BUTTONS := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]
const SCENE_EDGE_PADDING := Vector2(72, 72)
const DRAG_START_THRESHOLD := 8.0

const LEVELS := [
	{
		"id": 1,
		"title": "Conveyor Basics",
		"skill": "startup logic",
		"topic": "sequence",
		"scene": "res://Test.tscn",
		"goal": "Activate the spawner and conveyor so your first box travels safely down the line.",
		"concepts": "start(spawner), start(conveyor), command sequence",
		"difficulty": "Easy",
		"stars": 3,
	},
	{
		"id": 2,
		"title": "Color Sorting",
		"skill": "sensor reading",
		"topic": "sensor",
		"scene": "res://test_2.tscn",
		"goal": "Read a color sensor and stop the line once the target box arrives for inspection.",
		"concepts": "wait until, sensor state, stop(conveyor)",
		"difficulty": "Easy",
		"stars": 2,
	},
	{
		"id": 3,
		"title": "Weight Detection",
		"skill": "condition logic",
		"topic": "if / else",
		"scene": "res://test_3.tscn",
		"goal": "Use weight data to decide how the factory should react to incoming boxes.",
		"concepts": "if / else, comparisons, sensor values",
		"difficulty": "Normal",
		"stars": 0,
	},
	{
		"id": 4,
		"title": "Loop Control",
		"skill": "while loop",
		"topic": "loop flow",
		"scene": "res://test_4.tscn",
		"goal": "Keep the production line running with a controlled loop and safe action timing.",
		"concepts": "while true, repeat, action(done)",
		"difficulty": "Normal",
		"stars": 0,
	},
	{
		"id": 5,
		"title": "Robot Arm Pick",
		"skill": "automation",
		"topic": "robot arm",
		"scene": "res://test_6.tscn",
		"goal": "Move a box with a robot arm and return the line to service without losing flow.",
		"concepts": "rotate, pick(box), drop(box), wait until",
		"difficulty": "Hard",
		"stars": 0,
	},
	{
		"id": 6,
		"title": "Final Factory Test",
		"skill": "integrated challenge",
		"topic": "full system",
		"scene": "res://test_5.tscn",
		"goal": "Combine sensors, conditions, and automation rules to complete the final integrated test.",
		"concepts": "logic chaining, sensor routing, multi-step automation",
		"difficulty": "Hard",
		"stars": 0,
	},
]

@onready var progress_badge: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/TitleRow/ProgressBox/ProgressBadge
@onready var stars_badge: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/TitleRow/ProgressBox/StarsBadge
@onready var scene_root: Control = $SafeMargin
@onready var mission_name: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/MissionName
@onready var mission_status: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/MissionStatus
@onready var goal_body: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/GoalBody
@onready var concepts_body: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/ConceptsBody
@onready var difficulty_body: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/DifficultyBody
@onready var reward_body: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/RewardBody
@onready var start_button: Button = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/StartButton
@onready var back_button: Button = $SafeMargin/Shell/ShellMargin/ShellVBox/FooterRow/BackButton
@onready var footer_hint: Label = $SafeMargin/Shell/ShellMargin/ShellVBox/FooterRow/FooterHint

var _card_buttons: Array[Button] = []
var _selected_index: int = 0
var _scene_zoom: float = 1.0
var _scene_base_size: Vector2 = Vector2.ZERO
var _scene_position: Vector2 = Vector2.ZERO
var _is_panning: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO
var _active_pan_button: int = -1
var _pending_left_pan: bool = false
var _left_press_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_card_buttons = [
		$SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/ScrollContainer/LevelCards/LevelCard1,
		$SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/ScrollContainer/LevelCards/LevelCard2,
		$SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/ScrollContainer/LevelCards/LevelCard3,
		$SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/ScrollContainer/LevelCards/LevelCard4,
		$SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/ScrollContainer/LevelCards/LevelCard5,
		$SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/ScrollContainer/LevelCards/LevelCard6,
	]

	for idx in range(_card_buttons.size()):
		var button: Button = _card_buttons[idx]
		if not button.pressed.is_connected(_on_level_card_pressed.bind(idx)):
			button.pressed.connect(_on_level_card_pressed.bind(idx))

	if not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
	if not back_button.pressed.is_connected(_on_back_button_pressed):
		back_button.pressed.connect(_on_back_button_pressed)

	_populate_cards()
	_selected_index = 0
	_refresh_screen()
	call_deferred("_setup_scene_camera")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("_update_scene_bounds")

func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	if _pending_left_pan and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if mouse_position.distance_to(_left_press_position) >= DRAG_START_THRESHOLD:
			_pending_left_pan = false
			_is_panning = true
			_active_pan_button = MOUSE_BUTTON_LEFT
			_last_mouse_position = mouse_position

	if _is_panning and _active_pan_button != -1:
		if not Input.is_mouse_button_pressed(_active_pan_button):
			_stop_panning()
			return

		var delta: Vector2 = mouse_position - _last_mouse_position
		if delta != Vector2.ZERO:
			_scene_position += delta
			_last_mouse_position = mouse_position
			_refresh_scene_transform()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index in PAN_BUTTONS:
			if mouse_event.button_index == MOUSE_BUTTON_LEFT:
				if mouse_event.pressed:
					_pending_left_pan = true
					_left_press_position = mouse_event.position
					_last_mouse_position = mouse_event.position
				else:
					_pending_left_pan = false
					if _active_pan_button == MOUSE_BUTTON_LEFT:
						_stop_panning()
			else:
				if mouse_event.pressed:
					_is_panning = true
					_active_pan_button = mouse_event.button_index
					_last_mouse_position = mouse_event.position
				elif _active_pan_button == mouse_event.button_index:
					_stop_panning()
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_scene(ZOOM_STEP, mouse_event.position)
			return
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_scene(-ZOOM_STEP, mouse_event.position)
			return

func _populate_cards() -> void:
	for idx in range(LEVELS.size()):
		var button: Button = _card_buttons[idx]
		var data: Dictionary = LEVELS[idx]
		var title_label: Label = button.get_node("Margin/CardRow/TextBox/Title") as Label
		var skill_label: Label = button.get_node("Margin/CardRow/TextBox/Skill") as Label
		var level_tag: Label = button.get_node("Margin/CardRow/LevelTag") as Label
		title_label.text = str(data.get("title", "Mission"))
		skill_label.text = "Skill: %s  |  Topic: %s" % [
			str(data.get("skill", "logic")),
			str(data.get("topic", "automation")),
		]
		level_tag.text = "LV %02d" % int(data.get("id", idx + 1))

func _refresh_screen() -> void:
	progress_badge.text = "OPEN ACCESS %d/%d" % [LEVELS.size(), LEVELS.size()]
	stars_badge.text = "NO SAVE DATA"
	footer_hint.text = "All training missions are open for now. Unlock progress and user save data can be added later."

	for idx in range(_card_buttons.size()):
		_style_level_card(_card_buttons[idx], LEVELS[idx], idx)

	_update_detail_panel(LEVELS[_selected_index])

func _style_level_card(button: Button, data: Dictionary, idx: int) -> void:
	var title_label: Label = button.get_node("Margin/CardRow/TextBox/Title") as Label
	var skill_label: Label = button.get_node("Margin/CardRow/TextBox/Skill") as Label
	var status_label: Label = button.get_node("Margin/CardRow/Status") as Label
	var level_tag: Label = button.get_node("Margin/CardRow/LevelTag") as Label

	var level_id: int = int(data.get("id", idx + 1))
	var is_selected: bool = idx == _selected_index
	var is_open: bool = true

	var panel_style: StyleBoxFlat = _make_card_style(is_selected, is_open)
	button.add_theme_stylebox_override("normal", panel_style)
	button.add_theme_stylebox_override("hover", _make_card_style(true, is_open))
	button.add_theme_stylebox_override("pressed", _make_card_style(true, is_open))
	button.disabled = false

	title_label.add_theme_color_override("font_color", Color8(244, 247, 255))
	skill_label.add_theme_color_override("font_color", Color8(197, 218, 247))
	level_tag.add_theme_color_override("font_color", Color8(255, 205, 97))
	status_label.add_theme_color_override("font_color", _status_color(is_selected))
	status_label.text = _status_text(is_selected)

func _update_detail_panel(data: Dictionary) -> void:
	var level_id: int = int(data.get("id", 1))
	var stars: int = int(data.get("stars", 0))

	mission_name.text = "MISSION %02d | %s" % [level_id, str(data.get("title", "Mission"))]
	goal_body.text = str(data.get("goal", ""))
	concepts_body.text = str(data.get("concepts", ""))
	difficulty_body.text = str(data.get("difficulty", ""))
	reward_body.text = "Topic: %s  |  Best Result: %s" % [
		str(data.get("topic", "logic")),
		_stars_text(stars),
	]

	mission_status.text = "OPEN TRAINING MISSION"

	var badge_style: StyleBoxFlat = _make_progress_style()
	mission_status.add_theme_stylebox_override("normal", badge_style)
	mission_status.add_theme_color_override("font_color", Color8(18, 24, 34))

	start_button.disabled = false
	start_button.text = "START MISSION"
	start_button.add_theme_stylebox_override("normal", _make_start_style(true))
	start_button.add_theme_stylebox_override("hover", _make_start_style(true))
	start_button.add_theme_stylebox_override("pressed", _make_start_style(true))
	start_button.add_theme_color_override("font_color", Color8(13, 18, 28))

func _on_level_card_pressed(index: int) -> void:
	_selected_index = int(clampi(index, 0, LEVELS.size() - 1))
	_refresh_screen()

func _on_start_button_pressed() -> void:
	var data: Dictionary = LEVELS[_selected_index]
	get_tree().change_scene_to_file(str(data.get("scene", "res://Test.tscn")))

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _status_text(is_selected: bool) -> String:
	if is_selected:
		return "CURRENT"
	return "OPEN"

func _status_color(is_selected: bool) -> Color:
	if is_selected:
		return Color8(255, 206, 99)
	return Color8(119, 214, 245)

func _stars_text(stars: int) -> String:
	return "%d/3 STARS" % clampi(stars, 0, 3)

func _make_card_style(is_selected: bool, is_open: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_right = 20
	style.corner_radius_bottom_left = 20
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.shadow_color = Color(0, 0, 0, 0.18)
	style.shadow_size = 8
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12

	if is_selected and is_open:
		style.bg_color = Color8(82, 61, 20)
		style.border_color = Color8(246, 187, 71)
	elif is_open:
		style.bg_color = Color8(36, 47, 68)
		style.border_color = Color8(86, 118, 172)
	else:
		style.bg_color = Color8(27, 31, 40)
		style.border_color = Color8(64, 70, 84)

	return style

func _make_progress_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	style.bg_color = Color8(236, 171, 65)
	return style

func _make_start_style(is_available: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.shadow_color = Color(0, 0, 0, 0.22)
	style.shadow_size = 10
	if is_available:
		style.bg_color = Color8(236, 171, 65)
		style.border_color = Color8(255, 214, 113)
	else:
		style.bg_color = Color8(61, 66, 78)
		style.border_color = Color8(92, 98, 116)
	return style

func _setup_scene_camera() -> void:
	scene_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene_root.anchor_right = 0.0
	scene_root.anchor_bottom = 0.0
	_update_scene_bounds()
	_scene_zoom = _get_fit_zoom()
	_scene_position = _centered_scene_position(_scene_base_size * _scene_zoom)
	_refresh_scene_transform()

func _update_scene_bounds() -> void:
	await get_tree().process_frame
	var previous_scale: Vector2 = scene_root.scale
	scene_root.scale = Vector2.ONE
	var viewport_size: Vector2 = get_viewport_rect().size
	var content_rect: Rect2 = _measure_scene_content_rect()
	var shell_margin: Vector2 = SCENE_EDGE_PADDING
	_scene_base_size = Vector2(
		maxf(viewport_size.x + shell_margin.x * 2.0, content_rect.size.x + shell_margin.x * 2.0),
		maxf(viewport_size.y + shell_margin.y * 2.0, content_rect.size.y + shell_margin.y * 2.0)
	)
	scene_root.custom_minimum_size = _scene_base_size
	scene_root.size = _scene_base_size
	scene_root.scale = previous_scale
	_refresh_scene_transform()

func _zoom_scene(delta: float, focus_point: Vector2) -> void:
	var previous_zoom: float = _scene_zoom
	_scene_zoom = clampf(_scene_zoom + delta, MIN_SCENE_ZOOM, MAX_SCENE_ZOOM)
	if is_equal_approx(previous_zoom, _scene_zoom):
		return

	var local_focus: Vector2 = (focus_point - _scene_position) / previous_zoom
	_scene_position = focus_point - local_focus * _scene_zoom
	_refresh_scene_transform()

func _refresh_scene_transform() -> void:
	if scene_root == null:
		return
	if _scene_base_size == Vector2.ZERO:
		return

	scene_root.scale = Vector2(_scene_zoom, _scene_zoom)
	var scaled_size: Vector2 = _scene_base_size * _scene_zoom
	_scene_position = _clamp_scene_position(_scene_position, scaled_size)
	scene_root.position = _scene_position

func _clamp_scene_position(target_position: Vector2, scaled_size: Vector2) -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	var result: Vector2 = target_position

	if scaled_size.x <= viewport_size.x:
		result.x = (viewport_size.x - scaled_size.x) * 0.5
	else:
		result.x = clampf(result.x, viewport_size.x - scaled_size.x, 0.0)

	if scaled_size.y <= viewport_size.y:
		result.y = (viewport_size.y - scaled_size.y) * 0.5
	else:
		result.y = clampf(result.y, viewport_size.y - scaled_size.y, 0.0)

	return result

func _centered_scene_position(scaled_size: Vector2) -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	return Vector2(
		(viewport_size.x - scaled_size.x) * 0.5,
		(viewport_size.y - scaled_size.y) * 0.5
	)

func _get_fit_zoom() -> float:
	if _scene_base_size == Vector2.ZERO:
		return 1.0
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return 1.0
	var fit_zoom: float = minf(viewport_size.x / _scene_base_size.x, viewport_size.y / _scene_base_size.y)
	return clampf(fit_zoom, MIN_SCENE_ZOOM, MAX_SCENE_ZOOM)

func _measure_scene_content_rect() -> Rect2:
	if scene_root == null:
		return Rect2(Vector2.ZERO, get_viewport_rect().size)

	var content_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	var has_content: bool = false
	for child in scene_root.get_children():
		if child is Control and (child as Control).visible:
			var child_rect: Rect2 = _collect_control_rect(child as Control, Vector2.ZERO)
			if not has_content:
				content_rect = child_rect
				has_content = true
			else:
				content_rect = content_rect.merge(child_rect)

	if not has_content:
		return Rect2(Vector2.ZERO, get_viewport_rect().size)

	var padded_position := Vector2(
		minf(content_rect.position.x, 0.0) - SCENE_EDGE_PADDING.x,
		minf(content_rect.position.y, 0.0) - SCENE_EDGE_PADDING.y
	)
	var padded_end := Vector2(
		content_rect.end.x + SCENE_EDGE_PADDING.x,
		content_rect.end.y + SCENE_EDGE_PADDING.y
	)
	return Rect2(padded_position, padded_end - padded_position)

func _collect_control_rect(control: Control, parent_offset: Vector2) -> Rect2:
	var control_size: Vector2 = control.size
	if control_size.x <= 0.0 or control_size.y <= 0.0:
		control_size = control.get_combined_minimum_size()
	var current_rect: Rect2 = Rect2(parent_offset + control.position, control_size)

	for child in control.get_children():
		if child is Control and (child as Control).visible:
			current_rect = current_rect.merge(
				_collect_control_rect(child as Control, parent_offset + control.position)
			)

	return current_rect

func _stop_panning() -> void:
	_is_panning = false
	_active_pan_button = -1
