extends Control

const MIN_SCENE_ZOOM := 0.45
const MAX_SCENE_ZOOM := 1.6
const ZOOM_STEP := 0.08
const PAN_BUTTONS := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]
const SCENE_EDGE_PADDING := Vector2(72, 72)
const DRAG_START_THRESHOLD := 8.0

const SECTIONS := [
	{
		"title": "Basic Rules",
		"subtitle": "Learn the formatting, comments, and command flow expected by the Mini-C parser.",
		"hint": "MISSION HINT: Start simple. Make the line move first, then add waits and conditions.",
		"quick_tip": "QUICK TIP: A clean sequence is easier to debug than a long script with mixed goals.",
		"cards": [
			{"icon": "01", "title": "Command Flow", "body": "Most factory actions end with a semicolon and execute from top to bottom."},
			{"icon": "02", "title": "Comments", "body": "Use # to leave notes that explain why a step exists before you test the mission."},
			{"icon": "03", "title": "Blocks", "body": "Use braces to group loops, condition branches, and machine-safe routines."},
		],
		"code": "# Boot the line\nstart(spawner);\nstart(conveyor);\nwait until (weight(has_value));",
	},
	{
		"title": "Variables",
		"subtitle": "Store values you want to compare, reuse, or update while the line is running.",
		"hint": "MISSION HINT: Save sensor values before making route decisions so your script reads clearly.",
		"quick_tip": "QUICK TIP: Keep variable names short and tied to the job, like box_count or heavy_limit.",
		"cards": [
			{"icon": "01", "title": "Numeric State", "body": "Use int and float values to count boxes, set thresholds, or track process limits."},
			{"icon": "02", "title": "Updating Data", "body": "Mini-C supports standard assignment plus quick updates like += and -= when you need counters."},
			{"icon": "03", "title": "Readable Logic", "body": "Variables help separate machine control from mission logic so your code stays readable."},
		],
		"code": "var int box_count = 0;\nvar float heavy_limit = 5.0;\nbox_count += 1;\nif (weight > heavy_limit) {\n    stop(conveyor);\n}",
	},
	{
		"title": "If / Else",
		"subtitle": "Branch your logic when a sensor detects a special case or when a machine reaches a state.",
		"hint": "MISSION HINT: Check weight, color, or action(done) before deciding which route should activate.",
		"quick_tip": "QUICK TIP: Write the success path first, then use else for the fallback route.",
		"cards": [
			{"icon": "01", "title": "Sensor Checks", "body": "Compare weight, color, or machine state to decide what should happen next."},
			{"icon": "02", "title": "Two Outcomes", "body": "Pair if with else so every box has a clear destination on the factory floor."},
			{"icon": "03", "title": "Safe Timing", "body": "Use condition checks after wait statements so the branch reacts to real machine data."},
		],
		"code": "wait until (weight(has_value));\nif (weight > 5) {\n    stop(conveyor);\n} else {\n    start(conveyor);\n}",
	},
	{
		"title": "Loops",
		"subtitle": "Repeat actions for continuous production lines or for fixed sequences that need multiple steps.",
		"hint": "MISSION HINT: Use loops for ongoing jobs, but make sure the loop has a safe stopping condition.",
		"quick_tip": "QUICK TIP: If a mission feels repetitive, it probably wants repeat or while true.",
		"cards": [
			{"icon": "01", "title": "repeat(n)", "body": "Use repeat when you know the exact number of cycles a machine should perform."},
			{"icon": "02", "title": "while true", "body": "Use a continuous loop for live production lines, especially when boxes keep spawning."},
			{"icon": "03", "title": "Breakouts", "body": "When a mission needs an emergency stop, combine loop logic with condition checks and break."},
		],
		"code": "repeat(3) {\n    rotate(arm(-90));\n}\n\nwhile true {\n    wait until (color(has_value));\n}",
	},
	{
		"title": "Factory Actions",
		"subtitle": "These are the commands that directly control spawners, conveyors, robot arms, and diverters.",
		"hint": "MISSION HINT: Match the command to the hardware. Move the line first, then use the arm when the box is ready.",
		"quick_tip": "QUICK TIP: Start and stop commands are low risk. Rotate, pick, and drop usually need timing support.",
		"cards": [
			{"icon": "01", "title": "Line Control", "body": "Use start(spawner), stop(spawner), start(conveyor), and stop(conveyor) to control flow."},
			{"icon": "02", "title": "Robot Arm", "body": "Use rotate, pick, and drop in a clear order with wait until (action(done)) between arm moves."},
			{"icon": "03", "title": "Routing", "body": "Use diverter actions when the mission needs boxes to split into separate destinations."},
		],
		"code": "start(spawner);\nstart(conveyor);\nrotate(arm(-90));\nwait until (action(done));\npick(box);",
	},
	{
		"title": "Example Code",
		"subtitle": "This sample ties together waits, conditions, and factory commands in a practical mini mission.",
		"hint": "MISSION HINT: Copy this pattern, then replace the branch logic to match your level objective.",
		"quick_tip": "QUICK TIP: Treat example code as a scaffold. Adjust the conditions, not the overall structure first.",
		"cards": [
			{"icon": "01", "title": "Spawn", "body": "Begin by enabling the machine line so a box can enter the mission space."},
			{"icon": "02", "title": "Inspect", "body": "Wait for sensor data before choosing whether the box should continue or be handled."},
			{"icon": "03", "title": "React", "body": "Stop, route, or pick based on the level condition and only continue when the action is complete."},
		],
		"code": "# Sorting mission sample\nstart(spawner);\nstart(conveyor);\nwhile true {\n    wait until (weight(has_value));\n    if (weight > 5) {\n        stop(conveyor);\n        rotate(arm(-90));\n        wait until (action(done));\n        pick(box);\n    } else {\n        start(conveyor);\n    }\n}",
	},
]

@onready var tutorial_badge: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/TopBar/TopBarMargin/TopBarVBox/TitleRow/TutorialBadge
@onready var scene_root: Control = $SafeMargin
@onready var main_shell: PanelContainer = $SafeMargin/MainShell
@onready var hint_strip: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/TopBar/TopBarMargin/TopBarVBox/HintStrip
@onready var quick_tip_label: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/QuickTipPanel/QuickTipMargin/QuickTipLabel
@onready var section_title: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/SectionTitle
@onready var section_subtitle: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/SectionSubtitle
@onready var footer_tip: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/BottomBar/FooterTip
@onready var menu_button: Button = $SafeMargin/MainShell/ShellMargin/ShellVBox/BottomBar/MenuButton
@onready var next_button: Button = $SafeMargin/MainShell/ShellMargin/ShellVBox/BottomBar/NextButton
@onready var code_text: RichTextLabel = $SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CodePanel/CodeMargin/CodeVBox/CodeBlock/CodeText
@onready var line_numbers: Label = $SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CodePanel/CodeMargin/CodeVBox/CodeBlock/LineNumbers

var _nav_buttons: Array[Button] = []
var _card_icons: Array[Label] = []
var _card_titles: Array[Label] = []
var _card_bodies: Array[Label] = []
var _current_index := 0
var _scene_zoom := 1.0
var _scene_base_size := Vector2.ZERO
var _scene_position := Vector2.ZERO
var _is_panning := false
var _last_mouse_position := Vector2.ZERO
var _active_pan_button := -1
var _pending_left_pan := false
var _left_press_position := Vector2.ZERO

func _ready() -> void:
	_nav_buttons = [
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/NavButtons/BasicRulesButton,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/NavButtons/VariablesButton,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/NavButtons/IfElseButton,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/NavButtons/LoopsButton,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/NavButtons/FactoryActionsButton,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/SidebarPanel/SidebarMargin/SidebarVBox/NavButtons/ExampleCodeButton,
	]
	_card_icons = [
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card1/Margin/VBox/Icon,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card2/Margin/VBox/Icon,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card3/Margin/VBox/Icon,
	]
	_card_titles = [
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card1/Margin/VBox/Title,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card2/Margin/VBox/Title,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card3/Margin/VBox/Title,
	]
	_card_bodies = [
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card1/Margin/VBox/Body,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card2/Margin/VBox/Body,
		$SafeMargin/MainShell/ShellMargin/ShellVBox/ContentRow/ContentPanel/ContentMargin/ContentVBox/CardsGrid/Card3/Margin/VBox/Body,
	]

	for idx in range(_nav_buttons.size()):
		var button := _nav_buttons[idx]
		if not button.pressed.is_connected(_on_nav_button_pressed.bind(idx)):
			button.pressed.connect(_on_nav_button_pressed.bind(idx))

	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)
	if menu_button != null and not menu_button.pressed.is_connected(_on_menu_button_pressed):
		menu_button.pressed.connect(_on_menu_button_pressed)

	_refresh_view()
	call_deferred("_setup_scene_camera")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("_update_scene_bounds")

func _process(_delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()

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

		var delta := mouse_position - _last_mouse_position
		if delta != Vector2.ZERO:
			_scene_position += delta
			_last_mouse_position = mouse_position
			_refresh_scene_transform()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
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

func _on_nav_button_pressed(index: int) -> void:
	_current_index = clampi(index, 0, SECTIONS.size() - 1)
	_refresh_view()

func _on_next_button_pressed() -> void:
	_current_index += 1
	if _current_index >= SECTIONS.size():
		_current_index = 0
	_refresh_view()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _refresh_view() -> void:
	var section: Dictionary = SECTIONS[_current_index]
	tutorial_badge.text = "TUTORIAL %d/%d" % [_current_index + 1, SECTIONS.size()]
	hint_strip.text = str(section.get("hint", ""))
	quick_tip_label.text = str(section.get("quick_tip", ""))
	section_title.text = str(section.get("title", ""))
	section_subtitle.text = str(section.get("subtitle", ""))
	footer_tip.text = "TIP: %s" % str(section.get("quick_tip", "")).replace("QUICK TIP: ", "")
	_update_cards(section.get("cards", []))
	_update_code_block(str(section.get("code", "")))
	_style_nav_buttons()
	next_button.text = "RESTART PATH" if _current_index == SECTIONS.size() - 1 else "NEXT LESSON"

func _update_cards(cards: Array) -> void:
	for idx in range(_card_titles.size()):
		var card_data: Dictionary = {}
		if idx < cards.size():
			card_data = cards[idx]
		_card_icons[idx].text = str(card_data.get("icon", "--"))
		_card_titles[idx].text = str(card_data.get("title", ""))
		_card_bodies[idx].text = str(card_data.get("body", ""))

func _update_code_block(source: String) -> void:
	code_text.text = "[code]%s[/code]" % source
	var lines := source.split("\n")
	var numbers: Array[String] = []
	for idx in range(lines.size()):
		numbers.append(str(idx + 1))
	line_numbers.text = "\n".join(numbers)

func _style_nav_buttons() -> void:
	for idx in range(_nav_buttons.size()):
		var button := _nav_buttons[idx]
		var is_active := idx == _current_index
		button.modulate = Color(1, 1, 1, 1)
		button.add_theme_color_override("font_color", Color8(17, 21, 29) if is_active else Color8(244, 247, 255))
		button.add_theme_stylebox_override("normal", _make_nav_style(is_active))
		button.add_theme_stylebox_override("hover", _make_nav_style(true))
		button.add_theme_stylebox_override("pressed", _make_nav_style(true))

func _make_nav_style(is_active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color8(237, 171, 65) if is_active else Color8(30, 40, 57)
	style.border_color = Color8(255, 218, 122) if is_active else Color8(92, 117, 157)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_color = Color(0, 0, 0, 0.18)
	style.shadow_size = 8
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12
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
	var previous_scale := scene_root.scale
	scene_root.scale = Vector2.ONE
	var viewport_size := get_viewport_rect().size
	var content_rect := _measure_scene_content_rect()
	var shell_margin := SCENE_EDGE_PADDING
	_scene_base_size = Vector2(
		maxf(viewport_size.x + shell_margin.x * 2.0, content_rect.size.x + shell_margin.x * 2.0),
		maxf(viewport_size.y + shell_margin.y * 2.0, content_rect.size.y + shell_margin.y * 2.0)
	)
	scene_root.custom_minimum_size = _scene_base_size
	scene_root.size = _scene_base_size
	scene_root.scale = previous_scale
	_refresh_scene_transform()

func _zoom_scene(delta: float, focus_point: Vector2) -> void:
	var previous_zoom := _scene_zoom
	_scene_zoom = clampf(_scene_zoom + delta, MIN_SCENE_ZOOM, MAX_SCENE_ZOOM)
	if is_equal_approx(previous_zoom, _scene_zoom):
		return

	var local_focus := (focus_point - _scene_position) / previous_zoom
	_scene_position = focus_point - local_focus * _scene_zoom
	_refresh_scene_transform()

func _refresh_scene_transform() -> void:
	if scene_root == null:
		return
	if _scene_base_size == Vector2.ZERO:
		return

	scene_root.scale = Vector2(_scene_zoom, _scene_zoom)
	var scaled_size := _scene_base_size * _scene_zoom
	_scene_position = _clamp_scene_position(_scene_position, scaled_size)
	scene_root.position = _scene_position

func _clamp_scene_position(target_position: Vector2, scaled_size: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	var result := target_position

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
	var viewport_size := get_viewport_rect().size
	return Vector2(
		(viewport_size.x - scaled_size.x) * 0.5,
		(viewport_size.y - scaled_size.y) * 0.5
	)

func _get_fit_zoom() -> float:
	if _scene_base_size == Vector2.ZERO:
		return 1.0
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return 1.0
	var fit_zoom := minf(viewport_size.x / _scene_base_size.x, viewport_size.y / _scene_base_size.y)
	return clampf(fit_zoom, MIN_SCENE_ZOOM, MAX_SCENE_ZOOM)

func _measure_scene_content_rect() -> Rect2:
	if scene_root == null:
		return Rect2(Vector2.ZERO, get_viewport_rect().size)

	var content_rect := Rect2(Vector2.ZERO, Vector2.ZERO)
	var has_content := false
	for child in scene_root.get_children():
		if child is Control and (child as Control).visible:
			var child_rect := _collect_control_rect(child as Control, Vector2.ZERO)
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
	var control_size := control.size
	if control_size.x <= 0.0 or control_size.y <= 0.0:
		control_size = control.get_combined_minimum_size()
	var current_rect := Rect2(parent_offset + control.position, control_size)

	for child in control.get_children():
		if child is Control and (child as Control).visible:
			current_rect = current_rect.merge(
				_collect_control_rect(child as Control, parent_offset + control.position)
			)

	return current_rect

func _stop_panning() -> void:
	_is_panning = false
	_active_pan_button = -1
