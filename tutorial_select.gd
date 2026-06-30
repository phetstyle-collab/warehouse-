extends Control

## Tutorial Select Screen
## แสดงรายการด่าน Tutorial ทั้ง 4 ด่าน แยกออกจาก Level Select ของด่านจริง

const MIN_SCENE_ZOOM := 0.45
const MAX_SCENE_ZOOM := 1.6
const ZOOM_STEP := 0.08
const PAN_BUTTONS := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]
const SCENE_EDGE_PADDING := Vector2(72, 72)
const DRAG_START_THRESHOLD := 8.0

const TUTORIALS := [

	{
		"id": 1,
		"title": "คำสั่งพื้นฐาน",
		"subtitle": "Basic Commands",
		"skill": "syntax พื้นฐาน",
		"topic": "start / stop",
		"scene": "res://tutorial_1.tscn",
		"goal": "เรียนรู้การพิมพ์คำสั่ง start(spawner); และ start(conveyor); โดยพิมพ์ตามเงาที่แสดงในหน้าจอ แล้วกด RUN เพื่อดูผลลัพธ์",
		"concepts": "start(spawner), start(conveyor), การลงท้ายด้วย ;",
		"difficulty": "เริ่มต้น",
		"ghost_code": "start(spawner);\nstart(conveyor);",
	},
	{
		"id": 2,
		"title": "รอให้เซนเซอร์ทำงาน",
		"subtitle": "Wait & Sensor",
		"skill": "การรอเหตุการณ์",
		"topic": "wait until",
		"scene": "res://tutorial_2.tscn",
		"goal": "เรียนรู้การใช้ wait until เพื่อรอให้เซนเซอร์น้ำหนักตรวจพบกล่องก่อนหยุดสายพาน",
		"concepts": "wait until (weight(has_value)), stop(conveyor)",
		"difficulty": "เริ่มต้น",
		"ghost_code": "start(spawner);\nstart(conveyor);\nwait until (weight(has_value));\nstop(conveyor);",
	},
	{
		"id": 3,
		"title": "ตัดสินใจด้วย If / Else",
		"subtitle": "Conditionals",
		"skill": "การเขียนเงื่อนไข",
		"topic": "if / else",
		"scene": "res://tutorial_3.tscn",
		"goal": "เรียนรู้การตัดสินใจว่าจะทำอะไรถ้ากล่องหนักเกิน 5 และทำอะไรถ้าเบากว่า",
		"concepts": "if (weight > 5) { ... } else { ... }",
		"difficulty": "ปานกลาง",
		"ghost_code": "start(spawner);\nstart(conveyor);\nwait until (weight(has_value));\nif (weight > 5) {\n    stop(conveyor);\n} else {\n    start(conveyor);\n}",
	},
	{
		"id": 4,
		"title": "วนซ้ำอัตโนมัติ",
		"subtitle": "While Loop",
		"skill": "การวนซ้ำ",
		"topic": "while loop",
		"scene": "res://tutorial_4.tscn",
		"goal": "เรียนรู้การให้โปรแกรมทำงานวนซ้ำตลอดไปโดยอัตโนมัติ ด้วย while true { ... }",
		"concepts": "while true { ... }, การวนซ้ำไม่สิ้นสุด",
		"difficulty": "ปานกลาง",
		"ghost_code": "while true {\n    start(spawner);\n    start(conveyor);\n    wait until (weight(has_value));\n    stop(conveyor);\n}",
	},
]

@onready var progress_badge: Label        = $SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/TitleRow/ProgressBox/ProgressBadge
@onready var stars_badge: Label           = $SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/TitleRow/ProgressBox/StarsBadge
@onready var mission_name: Label          = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/MissionName
@onready var mission_status: Label        = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/MissionStatus
@onready var goal_body: Label             = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/GoalBody
@onready var concepts_body: Label         = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/ConceptsBody
@onready var difficulty_body: Label       = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/DifficultyBody
@onready var reward_body: Label           = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/ObjectivePanel/ObjectiveMargin/ObjectiveVBox/RewardBody
@onready var start_button: Button         = $SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/StartButton
@onready var back_button: Button          = $SafeMargin/Shell/ShellMargin/ShellVBox/FooterRow/BackButton
@onready var footer_hint: Label           = $SafeMargin/Shell/ShellMargin/ShellVBox/FooterRow/FooterHint
@onready var scene_root: Control          = $SafeMargin

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

	# ซ่อน card ที่เกิน TUTORIALS.size()
	for idx in range(_card_buttons.size()):
		if idx < TUTORIALS.size():
			_card_buttons[idx].visible = true
			if not _card_buttons[idx].pressed.is_connected(_on_card_pressed.bind(idx)):
				_card_buttons[idx].pressed.connect(_on_card_pressed.bind(idx))
		else:
			_card_buttons[idx].visible = false

	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)
	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)

	_apply_tutorial_theme()
	_populate_cards()
	_selected_index = 0
	_refresh_screen()
	call_deferred("_setup_scene_camera")

## ปรับสี/theme ของหน้าจอให้เป็นสีฟ้า (Tutorial) แทนสีเหลืองทอง (Mission)
func _apply_tutorial_theme() -> void:
	# Header title
	var header_title := get_node_or_null(
		"SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/TitleRow/TitleBox/Title"
	) as Label
	if header_title != null:
		header_title.text = "TUTORIAL SELECT"
		header_title.add_theme_color_override("font_color", Color8(100, 220, 255))

	var header_sub := get_node_or_null(
		"SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/TitleRow/TitleBox/Subtitle"
	) as Label
	if header_sub != null:
		header_sub.text = "SYNTAX TRAINING PROGRAM"
		header_sub.add_theme_color_override("font_color", Color8(100, 220, 255))

	var header_desc := get_node_or_null(
		"SafeMargin/Shell/ShellMargin/ShellVBox/HeaderPanel/HeaderMargin/HeaderVBox/Description"
	) as Label
	if header_desc != null:
		header_desc.text = "เลือกบทเรียน Tutorial เพื่อฝึกพิมพ์ MiniC Syntax ก่อนไปลุยด่านจริง"

	var board_title := get_node_or_null(
		"SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/MissionsPanel/MissionsMargin/MissionsVBox/MissionsHeader/BoardTitle"
	) as Label
	if board_title != null:
		board_title.text = "TUTORIAL BOARD"
		board_title.add_theme_color_override("font_color", Color8(100, 220, 255))

	var detail_title := get_node_or_null(
		"SafeMargin/Shell/ShellMargin/ShellVBox/ContentRow/DetailPanel/DetailMargin/DetailVBox/DetailTitle"
	) as Label
	if detail_title != null:
		detail_title.text = "TUTORIAL DETAIL"
		detail_title.add_theme_color_override("font_color", Color8(100, 220, 255))

func _populate_cards() -> void:
	for idx in range(TUTORIALS.size()):
		var button: Button = _card_buttons[idx]
		var data: Dictionary = TUTORIALS[idx]
		var title_label: Label = button.get_node("Margin/CardRow/TextBox/Title") as Label
		var skill_label: Label = button.get_node("Margin/CardRow/TextBox/Skill") as Label
		var level_tag: Label   = button.get_node("Margin/CardRow/LevelTag") as Label
		title_label.text = "%s — %s" % [str(data.get("title", "")), str(data.get("subtitle", ""))]
		skill_label.text = "Skill: %s  |  Topic: %s" % [
			str(data.get("skill", "")),
			str(data.get("topic", "")),
		]
		level_tag.text = "T%02d" % int(data.get("id", idx + 1))
		level_tag.add_theme_color_override("font_color", Color8(100, 220, 255))

func _refresh_screen() -> void:
	progress_badge.text = "TUTORIAL %d/%d" % [_selected_index + 1, TUTORIALS.size()]
	progress_badge.add_theme_color_override("font_color", Color8(18, 24, 34))
	stars_badge.text = "SYNTAX TRAINING"
	stars_badge.add_theme_color_override("font_color", Color8(18, 24, 34))
	footer_hint.text = "เลือก Tutorial เพื่อฝึก Syntax — ไม่มีการผ่าน/ตก สามารถลองซ้ำได้เสมอ"

	for idx in range(TUTORIALS.size()):
		_style_tutorial_card(_card_buttons[idx], TUTORIALS[idx], idx)

	_update_detail_panel(TUTORIALS[_selected_index])

func _style_tutorial_card(button: Button, data: Dictionary, idx: int) -> void:
	var title_label: Label  = button.get_node("Margin/CardRow/TextBox/Title") as Label
	var skill_label: Label  = button.get_node("Margin/CardRow/TextBox/Skill") as Label
	var status_label: Label = button.get_node("Margin/CardRow/Status") as Label
	var level_tag: Label    = button.get_node("Margin/CardRow/LevelTag") as Label

	var is_selected: bool = idx == _selected_index

	# สี card
	var bg_col := Color8(42, 60, 90) if not is_selected else Color8(22, 60, 90)
	var border_col := Color8(40, 130, 200) if is_selected else Color8(60, 90, 130)
	var style := StyleBoxFlat.new()
	style.bg_color = bg_col
	style.border_color = border_col
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", _make_hover_style())
	button.add_theme_stylebox_override("pressed", _make_hover_style())
	button.disabled = false

	title_label.add_theme_color_override("font_color", Color8(220, 240, 255))
	skill_label.add_theme_color_override("font_color", Color8(140, 200, 240))
	level_tag.add_theme_color_override("font_color", Color8(100, 220, 255))
	status_label.add_theme_color_override("font_color", Color8(100, 220, 255) if is_selected else Color8(90, 150, 190))
	status_label.text = "SELECTED" if is_selected else "OPEN"

func _make_hover_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color8(30, 75, 115)
	s.border_color = Color8(64, 200, 255)
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left = 14
	s.corner_radius_top_right = 14
	s.corner_radius_bottom_right = 14
	s.corner_radius_bottom_left = 14
	return s

func _update_detail_panel(data: Dictionary) -> void:
	var level_id: int = int(data.get("id", 1))
	mission_name.text = "TUTORIAL %02d | %s" % [level_id, str(data.get("title", "Tutorial"))]
	mission_name.add_theme_color_override("font_color", Color8(100, 220, 255))

	goal_body.text = str(data.get("goal", ""))
	concepts_body.text = str(data.get("concepts", ""))
	difficulty_body.text = str(data.get("difficulty", ""))
	reward_body.text = "Topic: %s  |  Ghost Code: พิมพ์ตามเงาที่ปรากฏในหน้าจอ" % str(data.get("topic", ""))

	mission_status.text = "OPEN TUTORIAL"
	# สี badge เป็นฟ้า
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color8(30, 110, 175)
	badge_style.corner_radius_top_left = 12
	badge_style.corner_radius_top_right = 12
	badge_style.corner_radius_bottom_right = 12
	badge_style.corner_radius_bottom_left = 12
	mission_status.add_theme_stylebox_override("normal", badge_style)
	mission_status.add_theme_color_override("font_color", Color8(220, 245, 255))

	start_button.disabled = false
	start_button.text = "START TUTORIAL"
	# สี start button เป็นฟ้า
	var start_style := StyleBoxFlat.new()
	start_style.bg_color = Color8(30, 120, 200)
	start_style.border_color = Color8(80, 180, 255)
	start_style.border_width_left = 2
	start_style.border_width_top = 2
	start_style.border_width_right = 2
	start_style.border_width_bottom = 2
	start_style.corner_radius_top_left = 18
	start_style.corner_radius_top_right = 18
	start_style.corner_radius_bottom_right = 18
	start_style.corner_radius_bottom_left = 18
	start_button.add_theme_stylebox_override("normal", start_style)
	start_button.add_theme_stylebox_override("hover", start_style)
	start_button.add_theme_stylebox_override("pressed", start_style)
	start_button.add_theme_color_override("font_color", Color8(220, 245, 255))

func _on_card_pressed(index: int) -> void:
	_selected_index = int(clampi(index, 0, TUTORIALS.size() - 1))
	_refresh_screen()

func _on_start_pressed() -> void:
	var data: Dictionary = TUTORIALS[_selected_index]
	get_tree().change_scene_to_file(str(data.get("scene", "res://tutorial_1.tscn")))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

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

func _setup_scene_camera() -> void:
	scene_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene_root.anchor_right = 0.0
	scene_root.anchor_bottom = 0.0
	_update_scene_bounds()
	_scene_zoom = MIN_SCENE_ZOOM
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
