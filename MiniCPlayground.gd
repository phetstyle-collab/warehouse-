extends Control
class_name MiniCPlayground

# ==================================================
# UI NODES
# ==================================================
@onready var code_editor: TextEdit = $PlaygroundScroll/VBoxContainer/TextEdit
@onready var run_button: Button = $PlaygroundScroll/VBoxContainer/HBoxContainer/Button
@onready var reset_button: Button = $PlaygroundScroll/VBoxContainer/HBoxContainer/ResetButton
var summit_button: Button
@onready var output: RichTextLabel = $PlaygroundScroll/VBoxContainer/RichTextLabel
@onready var debug_log: RichTextLabel = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/ScrollContainer/RichTextLabel
@onready var playground_box: VBoxContainer = $PlaygroundScroll/VBoxContainer
@onready var playground_title_label: Label = $PlaygroundScroll/VBoxContainer/HeaderRow/Label
@onready var playground_subtitle_label: Label = $PlaygroundScroll/VBoxContainer/HeaderSubtitle
@onready var zoom_controls: HBoxContainer = $PlaygroundScroll/VBoxContainer/HeaderRow/HeaderActions/ZoomControls
@onready var zoom_out_button: Button = $PlaygroundScroll/VBoxContainer/HeaderRow/HeaderActions/ZoomControls/ZoomOutButton
@onready var zoom_label: Label = $PlaygroundScroll/VBoxContainer/HeaderRow/HeaderActions/ZoomControls/ZoomLabel
@onready var zoom_in_button: Button = $PlaygroundScroll/VBoxContainer/HeaderRow/HeaderActions/ZoomControls/ZoomInButton
@onready var panel_expand_button: Button = $PlaygroundScroll/VBoxContainer/HeaderRow/HeaderActions/PanelExpandButton
@onready var station_shell: PanelContainer = $PlaygroundScroll/VBoxContainer/StationShell
@onready var station_header_title: Label = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationHeaderRow/StationHeaderTitle
@onready var station_status_badge: Label = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationHeaderRow/StationStatusBadge
@onready var station_tabs_scroll: ScrollContainer = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationTabsScroll
@onready var station_tabs: HBoxContainer = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationTabsScroll/StationTabs
@onready var station_context_label: Label = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationMetaRow/StationInfoBox/StationContextLabel
@onready var station_role_label: Label = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationMetaRow/StationInfoBox/StationRoleLabel
@onready var station_signal_label: Label = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationMetaRow/StationSignalBox/StationSignalLabel
@onready var station_code_hint_label: Label = $PlaygroundScroll/VBoxContainer/StationShell/StationMargin/StationVBox/StationMetaRow/StationSignalBox/StationCodeHintLabel
@onready var debug_console_panel: PanelContainer = $PlaygroundScroll/VBoxContainer/DebugConsolePanel
@onready var debug_console_title: Label = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/ConsoleTitle
@onready var mission_tab_button: Button = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/ConsoleTabs/MissionTabButton
@onready var output_tab_button: Button = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/ConsoleTabs/OutputTabButton
@onready var errors_tab_button: Button = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/ConsoleTabs/ErrorsTabButton
@onready var hints_tab_button: Button = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/ConsoleTabs/HintsTabButton
@onready var feedback_panel: PanelContainer = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel
@onready var progress_title_label: Label = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel/FeedbackMargin/FeedbackBox/ProgressTitle
@onready var progress_meta_label: Label = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel/FeedbackMargin/FeedbackBox/ProgressMeta
@onready var progress_bar_mini: ProgressBar = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel/FeedbackMargin/FeedbackBox/ProgressBarMini
@onready var progress_stars_label: Label = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel/FeedbackMargin/FeedbackBox/ProgressStars
@onready var feedback_status_label: Label = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel/FeedbackMargin/FeedbackBox/FeedbackStatus
@onready var feedback_detail_label: Label = $PlaygroundScroll/VBoxContainer/DebugConsolePanel/ConsoleBox/PlayerFeedbackPanel/FeedbackMargin/FeedbackBox/FeedbackDetail
@onready var level_header_card: PanelContainer = $HUDLayer/LevelHeaderCard
@onready var level_badge_label: Label = $HUDLayer/LevelHeaderCard/HeaderMargin/HeaderBox/HeaderTopRow/LevelBadge
@onready var lesson_label: Label = $HUDLayer/LevelHeaderCard/HeaderMargin/HeaderBox/HeaderTopRow/LessonLabel
@onready var level_header_title_label: Label = $HUDLayer/LevelHeaderCard/HeaderMargin/HeaderBox/TitleLabel
@onready var progress_label: Label = $HUDLayer/LevelHeaderCard/HeaderMargin/HeaderBox/ProgressLabel
@onready var level_progress_bar: ProgressBar = $HUDLayer/LevelHeaderCard/HeaderMargin/HeaderBox/ProgressBar
@onready var star_goals_box: VBoxContainer = $HUDLayer/LevelHeaderCard/HeaderMargin/HeaderBox/StarGoals
@onready var mission_card: PanelContainer = $HUDLayer/MissionCard
@onready var mission_title_label: Label = $HUDLayer/MissionCard/MissionMargin/MissionBox/MissionTitle
@onready var mission_subtitle_label: Label = $HUDLayer/MissionCard/MissionMargin/MissionBox/MissionSubtitle
@onready var mission_items_box: VBoxContainer = $HUDLayer/MissionCard/MissionMargin/MissionBox/MissionItems
@onready var result_overlay: CanvasLayer = $ResultOverlay
@onready var result_card: PanelContainer = $ResultOverlay/CenterContainer/ResultCard
@onready var status_badge: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Header/StatusBadge
@onready var title_label: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Header/TitleLabel
@onready var subtitle_label: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Header/SubtitleLabel
@onready var score_label: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/ScoreLabel
@onready var star_labels: Array[Label] = [
	$ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Stars/Star1,
	$ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Stars/Star2,
	$ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Stars/Star3,
]
@onready var checks_value_label: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/MetricsPanel/MetricsMargin/MetricsGrid/ChecksValue
@onready var time_value_label: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/MetricsPanel/MetricsMargin/MetricsGrid/TimeValue
@onready var boxes_value_label: Label = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/MetricsPanel/MetricsMargin/MetricsGrid/BoxesValue
@onready var reasons_label: RichTextLabel = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/ReasonsPanel/ReasonsMargin/ReasonsBox/ReasonsScroll/ReasonsLabel
@onready var level_select_button: Button = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Buttons/LevelSelectButton
@onready var retry_button: Button = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Buttons/RetryButton
@onready var next_level_button: Button = $ResultOverlay/CenterContainer/ResultCard/MarginContainer/VBoxContainer/Buttons/NextLevelButton

const INDENT := "    " # 4 spaces to match Mini-C examples
const CODE_FONT_SIZE_DEFAULT := 18
const CODE_FONT_SIZE_MIN := 12
const CODE_FONT_SIZE_MAX := 34
const PLAYGROUND_CONTENT_PADDING := Vector2(14, 14)
const PLAYGROUND_BACKDROP_PADDING := PLAYGROUND_CONTENT_PADDING * 2.0
const PLAYGROUND_OVERLAY_Z_INDEX := 120
const PLAYGROUND_COMPACT_BOX_SIZE := Vector2(448, 646)
const PLAYGROUND_EXPANDED_BOX_SIZE := Vector2(592, 788)
const PLAYGROUND_COMPACT_EDITOR_SIZE := Vector2(448, 232)
const PLAYGROUND_EXPANDED_EDITOR_SIZE := Vector2(592, 328)
const PLAYGROUND_COMPACT_STATUS_SIZE := Vector2(448, 220)
const PLAYGROUND_EXPANDED_STATUS_SIZE := Vector2(592, 268)
const PLAYGROUND_COMPACT_STATION_SHELL_SIZE := Vector2(448, 126)
const PLAYGROUND_EXPANDED_STATION_SHELL_SIZE := Vector2(592, 146)

# VS Code-ish (Dark+) palette for our "grouped" highlighter.
# Note: VS Code uses many token types; we only have a few groups here by design.
const COLOR_CMD := Color8(197, 134, 192)      # action opcodes (purple)
const COLOR_VAR := Color8(156, 220, 254)      # var names (light blue)
const COLOR_FUNC := Color8(220, 220, 170)     # func names (yellow)
const COLOR_FLOW := Color8(86, 156, 214)      # keywords (blue)
const COLOR_COMMENT := Color8(106, 153, 85)   # comments (green)
const COLOR_STRING := Color8(206, 145, 120)   # strings (orange)
const COLOR_NUMBER := Color8(181, 206, 168)   # numbers (green-ish)
const LEVEL_SEQUENCE := [
	"level_1",
	"level_2",
	"level_3",
	"level_4",
	"level_5",
	"level_6",
	"level_7",
	"level_8",
]
const LEVEL_SCENES := {
	"level_1": "res://Test.tscn",
	"level_2": "res://test_2.tscn",
	"level_3": "res://test_3.tscn",
	"level_4": "res://test_4.tscn",
	"level_5": "res://test_6.tscn",
	"level_6": "res://test_5.tscn",
	"level_7": "res://test_7.tscn",
	"level_8": "res://test_8.tscn",
	# Tutorial scenes: แยกออกจากด่านจริง — ไม่มี mission evaluation
	"tutorial_1": "res://tutorial_1.tscn",
}
const LEVEL_FAILURE_GUIDES := {
	"level_1": [
		"ต้องมี start(spawner); เพื่อเริ่มปล่อยกล่อง",
		"ต้องมี start(conveyor); เพื่อให้สายพานทำงาน",
	],
	"level_2": [
		"ต้องเริ่ม spawner และ conveyor ก่อน",
		"ต้อง wait until weight(has_value) เพื่อรอ sensor เจอกล่อง",
		"หลัง sensor เจอกล่อง ต้อง stop(spawner); และ stop(conveyor);",
	],
	"level_3": [
		"ต้อง rotate แขนกล 2 ครั้ง",
		"ต้องมี wait until action(done) ก่อนสั่งรอบถัดไป",
	],
	"level_4": [
		"ต้องรอ weight(has_value) ก่อนหยุดระบบ",
		"ต้อง stop spawner/conveyor ก่อนใช้แขนกล",
		"ต้อง pick และ drop พร้อมรอ action(done) ตามลำดับ",
	],
	"level_5": [
		"ต้องมี while true เพื่อทำงานวนซ้ำ",
		"ต้องตรวจ weight > 5 และมี else",
		"ต้องเรียงลำดับ start -> รอ sensor -> stop -> แขนกล pick/drop -> start ต่อ",
	],
	"level_6": [
		"ต้องมี if (weight > 5)",
		"กล่องหนักต้องไปถึง destroyer2 อย่างน้อย 1 กล่อง",
	],
	"level_7": [
		"ต้องมี if (weight > 5) และ else",
		"กล่องหนักต้องไป destroyer2 และกล่องเบาต้องไป destroyer3",
	],
	"level_8": [
		"ต้องมี if (weight > 5) และ else",
		"ต้องคัดแยกครบ 5 กล่อง",
		"กล่องหนักไป destroyer2 และกล่องเบาไป destroyer3",
	],
}

# ==================================================
# SYSTEM (ADAPTER BINDING)
# ==================================================
@export var real_factory_path: NodePath
@onready var real_factory: RealFactoryController = get_node_or_null(real_factory_path)
@export var mission_level_id: String = "level_1"
@export var station_root_path: NodePath
@export var editor_width: int = 320

var runtime: MiniCRuntime = MiniCRuntime.new()
var mission_evaluator: MissionEvaluator = MissionEvaluator.new()
var _run_active: bool = false
var _highlighted_exec_line: int = -1
const EXEC_LINE_HIGHLIGHT_COLOR := Color8(86, 156, 214, 70)
var _mission_reported_early: bool = false
var _destroyers: Array[BoxDestroyer] = []
var _spawners: Array[BoxSpawner] = []
var _spawner_finish_state: Dictionary = {} # instance_id -> bool
var _spawner_spawn_totals: Dictionary = {} # instance_id -> spawned total
var _expected_total_boxes: int = 0
var _run_started_at_msec: int = 0
var _last_run_duration_msec: int = 0
var _is_restoring_editor_text: bool = false
var _show_popup_on_finalize: bool = false
var _code_editor_font_size := CODE_FONT_SIZE_DEFAULT
var _level_ui_meta: Dictionary = {}
var _mission_objectives: Array[Dictionary] = []
var _live_action_counts: Dictionary = {}
var _live_sensor_counts: Dictionary = {}
var _live_action_done_counts: Dictionary = {}
var _live_destroyer_counts: Dictionary = {}
var _live_destroyed_total: int = 0
var _editor_playground_box_size := Vector2.ZERO
var _editor_playground_box_min_size := Vector2.ZERO
var _editor_root_global_position := Vector2.ZERO
var _editor_root_size := Vector2.ZERO
var _editor_root_min_size := Vector2.ZERO
var _is_playground_expanded := false
var _station_entries: Array[Dictionary] = []
var _station_tab_buttons: Array[Button] = []
var _run_all_button: Button = null
var _run_all_confirm_dialog: ConfirmationDialog = null
var _feedback_tab_buttons: Dictionary = {}
var _active_feedback_tab: String = "mission"
var _output_log_lines: Array[String] = []
var _error_log_lines: Array[String] = []

# ==================================================
# TUTORIAL GHOST TEXT SYSTEM
# ==================================================
## โค้ดตัวอย่างแยกตามประเภท syntax สำหรับ Tutorial 1
const TUTORIAL_GHOST_CODE := {
	"tutorial_1": {
		"category": "คำสั่งพื้นฐาน (Basic Commands)",
		"description": "ลองพิมพ์ตามคำสั่งที่เห็นเป็นเงาข้างล่าง แล้วกด RUN",
		"code": "start(spawner);\nstart(conveyor);",
	},
	"tutorial_2": {
		"category": "รอเซนเซอร์ (Wait & Sensor)",
		"description": "รอให้เซนเซอร์ตรวจพบก่อนทำต่อ",
		"code": "start(spawner);\nstart(conveyor);\nwait until (weight(has_value));\nrotate(arm(-90));",
	},
	"tutorial_3": {
		"category": "เงื่อนไข (If / Else)",
		"description": "ตัดสินใจตามน้ำหนักของกล่อง",
		"code": "start(spawner);\nstart(conveyor);\nwait until (weight(has_value));\nif (weight > 5) {\n    rotate(arm(90));\n} else {\n    rotate(arm(-90));\n}",
	},
	"tutorial_4": {
		"category": "วนซ้ำ (While Loop)",
		"description": "ทำซ้ำๆ ตลอดไปโดยอัตโนมัติ",
		"code": "while true {\n    start(spawner);\n    start(conveyor);\n    wait until (weight(has_value));\n    stop(conveyor);\n}",
	},
}

var _ghost_label: RichTextLabel = null
var _ghost_target_code: String = ""
var _tutorial_ghost_active: bool = false

# ==================================================
# LIFECYCLE
# ==================================================
func _ready() -> void:
	summit_button = get_node_or_null("PlaygroundScroll/VBoxContainer/HBoxContainer/SummitButton")
	_capture_editor_ui_sizes()
	_configure_playground_overlay()
	visible = true
	run_button.pressed.connect(_on_run_pressed)
	if reset_button != null:
		reset_button.pressed.connect(_on_reset_pressed)
	if summit_button != null:
		summit_button.pressed.connect(_on_summit_pressed)
	if zoom_in_button != null:
		zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	if zoom_out_button != null:
		zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	if panel_expand_button != null:
		panel_expand_button.pressed.connect(_on_panel_expand_pressed)
	# Lightweight auto-indent for the playground editor (Enter key).
	code_editor.gui_input.connect(_on_code_editor_gui_input)
	# Syntax highlight rebuilds on text changes (for dynamic var/func names).
	code_editor.text_changed.connect(_refresh_syntax_highlighting)
	code_editor.text_changed.connect(_on_code_editor_text_changed)
	_apply_vscode_dark_theme()
	_configure_code_editor_features()
	_apply_debug_console_theme()
	_apply_playground_panel_theme()
	_setup_station_selector()
	_setup_feedback_tabs()
	_level_ui_meta = LevelUiData.get_level_data(mission_level_id)
	_setup_level_hud()
	_reset_live_mission_state()
	_refresh_syntax_highlighting()
	runtime.action_executed.connect(_on_action_executed)
	runtime.execution_finished.connect(_on_runtime_execution_finished)
	runtime.line_executing.connect(_on_runtime_line_executing)
	_bind_result_popup()
	_bind_destroyers()
	_bind_spawners()
	_restore_level_script()
	_refresh_station_selector_ui()
	_print("Mini-C Playground ready")
	_set_feedback_state("info", "พร้อมเริ่มภารกิจ", "กด RUN เพื่อทดสอบโค้ด หรือกด SUBMIT เพื่อส่งตรวจ")
	if _is_tutorial_mode():
		_set_feedback_state("info", "โหมดฝึกหัด", "พิมพ์คำสั่งแล้วกด RUN ดูผลลัพธ์ได้เลย ไม่มีการผ่าน/ตก")
		_setup_tutorial_ghost_text()
	_add_back_to_menu_button()

	if real_factory == null:
		_print_error("⚠ RealFactoryController not bound (check NodePath)")
	else:
		if not real_factory.sensor_updated.is_connected(_on_sensor_updated):
			real_factory.sensor_updated.connect(_on_sensor_updated)
		if not real_factory.action_finished.is_connected(_on_action_finished):
			real_factory.action_finished.connect(_on_action_finished)
		_print("🏭 RealFactoryController bound successfully")

func _add_back_to_menu_button() -> void:
	if zoom_controls == null or zoom_controls.get_parent() == null:
		return
	var header_actions = zoom_controls.get_parent()
	var back_btn = Button.new()
	back_btn.name = "BackToMenuButton"
	back_btn.text = "BACK TO MENU"
	back_btn.focus_mode = Control.FOCUS_NONE
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color8(255, 230, 230))
	back_btn.add_theme_stylebox_override("normal", _make_ui_style(Color8(180, 50, 50, 200), 8, Color8(100, 20, 20), 1))
	back_btn.add_theme_stylebox_override("hover", _make_ui_style(Color8(220, 70, 70, 220), 8, Color8(150, 30, 30), 1))
	back_btn.add_theme_stylebox_override("pressed", _make_ui_style(Color8(150, 30, 30, 255), 8, Color8(80, 10, 10), 1))
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://mainmenu.tscn"))
	
	header_actions.add_child(back_btn)
	header_actions.move_child(back_btn, 0)

## Called by game_split_screen.gd after it reparents nodes into SubViewport.
## Re-establishes signal links if the @onready resolution in _ready() found null.
func rebind_factory(rfc: Node) -> void:
	var new_factory := rfc as RealFactoryController
	if new_factory == null:
		return
	if real_factory == new_factory:
		return  # already connected, nothing to do
	# Disconnect stale connections if any
	if real_factory != null:
		if real_factory.sensor_updated.is_connected(_on_sensor_updated):
			real_factory.sensor_updated.disconnect(_on_sensor_updated)
		if real_factory.action_finished.is_connected(_on_action_finished):
			real_factory.action_finished.disconnect(_on_action_finished)
	real_factory = new_factory
	if not real_factory.sensor_updated.is_connected(_on_sensor_updated):
		real_factory.sensor_updated.connect(_on_sensor_updated)
	if not real_factory.action_finished.is_connected(_on_action_finished):
		real_factory.action_finished.connect(_on_action_finished)
	_print("🏭 RealFactory rebound after split-screen setup")

# ==================================================
# ACTION
# ==================================================
func _restore_level_script() -> void:
	_is_restoring_editor_text = true
	var script_key := _script_storage_key()
	if GameData.has_level_script(script_key):
		code_editor.text = GameData.get_level_script(script_key)
	else:
		_apply_level_template_if_needed()
		GameData.save_level_script(script_key, code_editor.text)
	_is_restoring_editor_text = false
	_refresh_syntax_highlighting()

func _apply_level_template_if_needed() -> void:
	var station_entry: Dictionary = {}
	var current_index: int = _current_station_entry_index()
	if current_index >= 0 and current_index < _station_entries.size():
		station_entry = _station_entries[current_index]
	var starter_lines: Array[String] = [
		"// Write Mini-C code for this warehouse station",
		"// %s" % str(station_entry.get("title", "Station Control")),
		"// ภารกิจ: %s" % str(_level_ui_meta.get("title", "เริ่มภารกิจ")),
	]
	if mission_level_id == "level_1":
		starter_lines.append("start(spawner);")
		starter_lines.append("start(conveyor);")
	code_editor.text = "\n".join(starter_lines)

func _script_storage_key() -> String:
	var station_key := ""
	if station_root_path != NodePath():
		station_key = str(station_root_path)
	elif real_factory_path != NodePath():
		station_key = str(real_factory_path)
	if station_key == "":
		return mission_level_id
	return "%s::%s" % [mission_level_id, station_key]

func _on_code_editor_text_changed() -> void:
	if _is_restoring_editor_text:
		return
	GameData.save_level_script(_script_storage_key(), code_editor.text)
	_refresh_station_selector_ui()
	# Ghost text \u0e2d\u0e31\u0e1b\u0e40\u0e14\u0e15\u0e17\u0e38\u0e01\u0e04\u0e23\u0e31\u0e49\u0e07\u0e40\u0e14\u0e47\u0e01\u0e1e\u0e34\u0e21\u0e1e\u0e4c
	if _tutorial_ghost_active:
		_update_ghost_text()

func _on_run_pressed() -> void:
	_show_popup_on_finalize = false
	_refresh_station_selector_ui()
	_start_execution()

func _on_summit_pressed() -> void:
	_show_popup_on_finalize = true
	_refresh_station_selector_ui()
	_start_execution()

func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()

# ==================================================
# TUTORIAL GHOST TEXT FUNCTIONS
# ==================================================

## \u0e15\u0e31\u0e49\u0e07\u0e04\u0e48\u0e32 ghost text overlay \u0e2a\u0e33\u0e2b\u0e23\u0e31\u0e1a tutorial
func _setup_tutorial_ghost_text() -> void:
	if code_editor == null:
		return
	# \u0e14\u0e36\u0e07\u0e42\u0e04\u0e49\u0e14\u0e15\u0e31\u0e27\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e2a\u0e33\u0e2b\u0e23\u0e31\u0e1a level_id \u0e19\u0e35\u0e49
	var ghost_data: Dictionary = TUTORIAL_GHOST_CODE.get(mission_level_id, {})
	if ghost_data.is_empty():
		# fallback: ถ้าไม่มี entry ใน TUTORIAL_GHOST_CODE ใช้ tutorial_1
		ghost_data = TUTORIAL_GHOST_CODE.get("tutorial_1", {})
	if ghost_data.is_empty():
		return

	_ghost_target_code = str(ghost_data.get("code", ""))
	_tutorial_ghost_active = true

	# ล้าง editor แล้วใส่โค้ดว่าง (tutorial เริ่มจากว่างเสมอ)
	_is_restoring_editor_text = true
	code_editor.text = ""
	_is_restoring_editor_text = false

	# สร้าง RichTextLabel เป็น ghost overlay ซ้อนบน TextEdit
	_ghost_label = RichTextLabel.new()
	_ghost_label.name = "GhostTextOverlay"
	_ghost_label.bbcode_enabled = true
	_ghost_label.scroll_active = false
	_ghost_label.fit_content = false
	_ghost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # ไม่ยึด input

	# ใส่เข้าใน code_editor โดยตรงเพื่อให้อยู่บน TextEdit พอดี และไม่ถูก VBoxContainer ดันออก
	code_editor.add_child(_ghost_label)
	_ghost_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# คำนวณระยะขอบที่ถูกต้อง 100% (Margin + Gutter)
	var exact_offset_x = 0.0
	var exact_offset_y = 0.0
	var style = code_editor.get_theme_stylebox("normal")
	if style != null:
		exact_offset_x += style.content_margin_left
		exact_offset_y += style.content_margin_top
	
	# บวกความกว้างของ Gutter (เลขบรรทัด) ทุกอันที่มี
	for i in range(code_editor.get_gutter_count()):
		if code_editor.is_gutter_drawn(i):
			exact_offset_x += code_editor.get_gutter_width(i)
			
	_ghost_label.offset_left = exact_offset_x
	_ghost_label.offset_top = exact_offset_y
	_ghost_label.offset_right = - (style.content_margin_right if style != null else 0)
	_ghost_label.offset_bottom = - (style.content_margin_bottom if style != null else 0)

	# สีพื้นหลังโปร่งใส
	var ghost_bg := StyleBoxFlat.new()
	ghost_bg.bg_color = Color(0, 0, 0, 0)
	_ghost_label.add_theme_stylebox_override("normal", ghost_bg)

	# เอา font และ size เดียวกันกับ code_editor
	var font_size: int = _code_editor_font_size
	_ghost_label.add_theme_font_size_override("normal_font_size", font_size)
	_ghost_label.add_theme_font_size_override("bold_font_size", font_size)
	var editor_font: Font = code_editor.get_theme_font("font")
	if editor_font != null:
		_ghost_label.add_theme_font_override("normal_font", editor_font)
		_ghost_label.add_theme_font_override("bold_font", editor_font)

	# สร้าง info banner ใน subtitle
	if playground_subtitle_label != null:
		var cat: String = str(ghost_data.get("category", "Tutorial"))
		var desc: String = str(ghost_data.get("description", ""))
		playground_subtitle_label.text = "\U0001f4dd  %s  —  %s" % [cat, desc]
		playground_subtitle_label.add_theme_color_override("font_color", Color8(100, 210, 255))

	_update_ghost_text()
	_print("\U0001f47b Ghost text tutorial activated: %s" % mission_level_id)

## อัปเดต ghost text ตามที่เด็กพิมพ์ — ตัวอักษรที่พิมพ์ถูกแล้วจะสีฟ้าสดใส ส่วนที่ยังไม่ได้พิมพ์จะเป็นเงาจาง
func _update_ghost_text() -> void:
	if _ghost_label == null or not is_instance_valid(_ghost_label):
		return
	var typed: String = code_editor.text
	var target: String = _ghost_target_code

	# สร้าง BBCode โดยแยกตัวอักษรแต่ละตัว
	var result_bbcode := ""
	var typed_lines := typed.split("\n")
	var target_lines := target.split("\n")

	for line_idx in range(target_lines.size()):
		var tgt_line: String = target_lines[line_idx]
		var typ_line: String = ""
		if line_idx < typed_lines.size():
			typ_line = typed_lines[line_idx]

		var tgt_len := tgt_line.length()
		var typ_len := typ_line.length()

		for char_idx in range(tgt_len):
			var ch: String = tgt_line[char_idx]
			if char_idx < typ_len:
				result_bbcode += "[color=#00000000]%s[/color]" % ch
			else:
				if char_idx == typ_len:
					result_bbcode += " "
				result_bbcode += "[color=#404855]%s[/color]" % ch

		if line_idx < target_lines.size() - 1:
			result_bbcode += "\n"

	_ghost_label.text = result_bbcode
	# ลบตัวหนังสือลอยออก ให้แสดงผลแค่ที่ feedback panel ด้านล่างเพื่อความสะอาดตา
	if typed.strip_edges() == target.strip_edges():
		_set_feedback_state("success", "เยี่ยม! พิมพ์ครบแล้ว", "ตอนนี้ลองกด RUN เพื่อดูว่าโปรแกรมทำงานยังไงครับ!")

## \u0e25\u0e1a ghost overlay \u0e2d\u0e2d\u0e01
func _clear_tutorial_ghost() -> void:
	_tutorial_ghost_active = false
	if _ghost_label != null and is_instance_valid(_ghost_label):
		_ghost_label.queue_free()
	_ghost_label = null
	_ghost_target_code = ""


func _on_runtime_line_executing(line: int) -> void:
	_highlight_exec_line(line)

func _highlight_exec_line(line: int) -> void:
	if code_editor == null:
		return
	_clear_exec_line_highlight()
	if line < 0 or line >= code_editor.get_line_count():
		return
	code_editor.set_line_background_color(line, EXEC_LINE_HIGHLIGHT_COLOR)
	code_editor.set_caret_line(line)
	_highlighted_exec_line = line

func _clear_exec_line_highlight() -> void:
	if code_editor == null:
		return
	if _highlighted_exec_line >= 0 and _highlighted_exec_line < code_editor.get_line_count():
		code_editor.set_line_background_color(_highlighted_exec_line, Color(0, 0, 0, 0))
	_highlighted_exec_line = -1

func _on_zoom_in_pressed() -> void:
	_zoom_code_editor(2)

func _on_zoom_out_pressed() -> void:
	_zoom_code_editor(-2)

func _on_panel_expand_pressed() -> void:
	_is_playground_expanded = not _is_playground_expanded
	_apply_playground_layout()

## \u0e23\u0e30\u0e1a\u0e38\u0e27\u0e48\u0e32\u0e15\u0e2d\u0e19\u0e19\u0e35\u0e49\u0e40\u0e1b\u0e47\u0e19 tutorial mode \u0e2b\u0e23\u0e37\u0e2d\u0e14\u0e48\u0e32\u0e19\u0e08\u0e23\u0e34\u0e07
func _is_tutorial_mode() -> bool:
	return mission_level_id.begins_with("tutorial") or bool(_level_ui_meta.get("is_tutorial", false))

## \u0e1b\u0e23\u0e31\u0e1a\u0e2a\u0e35\u0e41\u0e25\u0e30\u0e02\u0e49\u0e2d\u0e04\u0e27\u0e32\u0e21\u0e02\u0e2d\u0e07 console header \u0e43\u0e2b\u0e49\u0e40\u0e1b\u0e47\u0e19\u0e2a\u0e35\u0e1f\u0e49\u0e32\u0e2a\u0e33\u0e2b\u0e23\u0e31\u0e1a tutorial
func _apply_tutorial_console_style() -> void:
	if debug_console_title != null:
		debug_console_title.text = "TUTORIAL MODE"
		debug_console_title.add_theme_color_override("font_color", Color8(64, 200, 255))
	if debug_console_panel != null:
		debug_console_panel.add_theme_stylebox_override("panel",
			_make_ui_style(Color(0.04, 0.09, 0.16, 0.96), 24, Color8(40, 120, 180), 2))
	if feedback_panel != null:
		feedback_panel.add_theme_stylebox_override("panel",
			_make_ui_style(Color(0.06, 0.13, 0.22, 0.97), 18, Color8(40, 130, 200), 2))
	# \u0e0b\u0e48\u0e2d\u0e19\u0e1b\u0e38\u0e48\u0e21 SUBMIT (\u0e44\u0e21\u0e48\u0e21\u0e35 submit \u0e43\u0e19 tutorial)
	if summit_button != null:
		summit_button.visible = false
	# \u0e40\u0e1b\u0e25\u0e35\u0e48\u0e22\u0e19\u0e2a\u0e35 tab MISSION \u0e43\u0e2b\u0e49\u0e40\u0e1b\u0e47\u0e19\u0e1f\u0e49\u0e32
	if mission_tab_button != null:
		mission_tab_button.add_theme_color_override("font_color", Color8(100, 220, 255))

func _setup_level_hud() -> void:
	_style_level_hud()
	_build_level_header()
	_build_mission_card()
	_sync_progress_panel()
	_refresh_mission_checklist()
	# \u0e16\u0e49\u0e32\u0e40\u0e1b\u0e47\u0e19 tutorial: \u0e40\u0e1b\u0e25\u0e35\u0e48\u0e22\u0e19 title \u0e41\u0e25\u0e30\u0e2a\u0e35 console header
	if _is_tutorial_mode():
		_apply_tutorial_console_style()

func _setup_station_selector() -> void:
	_discover_station_entries()
	_rebuild_station_tabs()
	_ensure_run_all_button()

func _setup_feedback_tabs() -> void:
	_feedback_tab_buttons = {
		"mission": mission_tab_button,
		"output": output_tab_button,
		"errors": errors_tab_button,
		"hints": hints_tab_button,
	}
	for tab_name in _feedback_tab_buttons.keys():
		var button: Button = _feedback_tab_buttons[tab_name] as Button
		if button == null:
			continue
		if not button.pressed.is_connected(_on_feedback_tab_pressed.bind(String(tab_name))):
			button.pressed.connect(_on_feedback_tab_pressed.bind(String(tab_name)))
	_refresh_feedback_tabs()

func _on_feedback_tab_pressed(tab_name: String) -> void:
	_active_feedback_tab = tab_name
	_refresh_feedback_tabs()

func _discover_station_entries() -> void:
	_station_entries.clear()
	var host_button: Button = get_parent() as Button
	if host_button == null:
		return
	var root: Node = host_button.get_parent()
	if root == null:
		return

	var buttons: Array[Button] = []
	for child in root.get_children():
		if child is Button:
			var button: Button = child as Button
			if button.get_node_or_null("Control") is MiniCPlayground:
				buttons.append(button)

	buttons.sort_custom(func(a: Button, b: Button) -> bool:
		return _station_button_sort_key(a.name) < _station_button_sort_key(b.name)
	)

	var station_index: int = 0
	for button in buttons:
		var playground := button.get_node_or_null("Control") as MiniCPlayground
		if playground == null:
			continue
		button.position = Vector2(-10000.0, -10000.0)
		button.disabled = true
		var station_root: Node = null
		if playground.station_root_path != NodePath():
			station_root = playground.get_node_or_null(playground.station_root_path)
		var label_id: String = _station_label_for_index(station_index)
		var role: String = _station_role_from_root(station_root)
		var title: String = "Station %s - %s" % [label_id, role]
		var starter: String = _station_starter_hint(role)
		_station_entries.append({
			"index": station_index,
			"button": button,
			"playground": playground,
			"station_root": station_root,
			"label_id": label_id,
			"title": title,
			"role": role,
			"starter": starter,
		})
		station_index += 1

	var own_index: int = _current_station_entry_index()
	visible = own_index == 0

func _rebuild_station_tabs() -> void:
	if station_tabs == null:
		return
	for child in station_tabs.get_children():
		child.queue_free()
	_station_tab_buttons.clear()

	for entry_variant in _station_entries:
		var entry: Dictionary = entry_variant
		var button := Button.new()
		button.toggle_mode = false
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(128, 34)
		button.text = "%s  %s" % [str(entry.get("label_id", "A")), str(entry.get("role", "Station"))]
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_on_station_tab_pressed.bind(int(entry.get("index", 0))))
		station_tabs.add_child(button)
		_station_tab_buttons.append(button)

func _on_station_tab_pressed(index: int) -> void:
	if index < 0 or index >= _station_entries.size():
		return
	var entry: Dictionary = _station_entries[index]
	var target_playground: MiniCPlayground = entry.get("playground") as MiniCPlayground
	if target_playground == null:
		return
	if target_playground == self:
		_refresh_station_selector_ui()
		return
	_switch_to_station_playground(target_playground)

func _switch_to_station_playground(target_playground: MiniCPlayground) -> void:
	# CodePanelToggle only ever reparents the FIRST station's panel out of its
	# original "codeN" Button into a screen-space CanvasLayer, then hides every
	# codeN button (button.visible = false). A station panel that is still a
	# child of one of those hidden buttons stays invisible no matter what we set
	# on its own `visible` flag, since Godot's CanvasItem visibility is
	# hierarchical. Re-home the target next to the currently active panel
	# (which already escaped its hidden button) before showing it.
	var host_parent: Node = get_parent()
	for entry_variant in _station_entries:
		var entry: Dictionary = entry_variant
		var button: Button = entry.get("button") as Button
		var playground: MiniCPlayground = entry.get("playground") as MiniCPlayground
		if button == null or playground == null:
			continue
		var is_target: bool = playground == target_playground
		playground.visible = is_target
		if is_target:
			if host_parent != null and playground.get_parent() != host_parent:
				playground.reparent(host_parent, true)
			playground.z_as_relative = false
			playground.z_index = 300
			# Use current panel position/size so repositioning by CodePanelToggle is respected
			playground.global_position = global_position
			playground.custom_minimum_size = custom_minimum_size
			playground.size = size
			playground._editor_root_global_position = global_position
			playground._refresh_station_selector_ui()
		var closed_text: String = str(button.get_meta("closed_text", button.text))
		button.text = "HIDE PANEL" if is_target else closed_text

func _ensure_run_all_button() -> void:
	if station_header_title == null:
		return
	var header_row: HBoxContainer = station_header_title.get_parent() as HBoxContainer
	if header_row == null:
		return
	if _run_all_button == null:
		_run_all_button = Button.new()
		_run_all_button.text = "RUN ALL"
		_run_all_button.custom_minimum_size = Vector2(86, 26)
		_run_all_button.focus_mode = Control.FOCUS_NONE
		_run_all_button.add_theme_font_size_override("font_size", 11)
		_run_all_button.pressed.connect(_on_run_all_pressed)
		header_row.add_child(_run_all_button)
		# Keep it between the title and the status badge.
		if station_status_badge != null:
			header_row.move_child(_run_all_button, station_status_badge.get_index())
	# Only worth offering when this map actually has more than one station.
	_run_all_button.visible = _station_entries.size() > 1

func _on_run_all_pressed() -> void:
	if _run_all_confirm_dialog == null:
		_run_all_confirm_dialog = ConfirmationDialog.new()
		_run_all_confirm_dialog.title = "Run All Stations"
		_run_all_confirm_dialog.ok_button_text = "Run All"
		_run_all_confirm_dialog.cancel_button_text = "Cancel"
		_run_all_confirm_dialog.confirmed.connect(_execute_run_all)
		add_child(_run_all_confirm_dialog)
	_run_all_confirm_dialog.dialog_text = "ต้องการรันคำสั่งของทุกสถานี (%d สถานี) พร้อมกันหรือไม่?" % _station_entries.size()
	_run_all_confirm_dialog.popup_centered()

func _execute_run_all() -> void:
	for entry_variant in _station_entries:
		var entry: Dictionary = entry_variant
		var playground: MiniCPlayground = entry.get("playground") as MiniCPlayground
		if playground == null:
			continue
		# Mirror what the individual RUN button does, just looped across stations.
		# Each station owns its own MiniCRuntime instance, so this kicks off N
		# independent interpreters that step forward on their own deferred/timer
		# cadence -- they execute concurrently within Godot's single-threaded
		# frame loop instead of one blocking the next.
		playground._show_popup_on_finalize = false
		playground._refresh_station_selector_ui()
		playground._start_execution()

func _refresh_station_selector_ui() -> void:
	if station_shell == null:
		return
	if _station_entries.is_empty():
		station_shell.visible = false
		return
	station_shell.visible = true
	_ensure_run_all_button()

	var current_index: int = _current_station_entry_index()
	var current_entry: Dictionary = {}
	if current_index >= 0 and current_index < _station_entries.size():
		current_entry = _station_entries[current_index]
	var current_role: String = str(current_entry.get("role", "Warehouse Station"))
	var current_title: String = str(current_entry.get("title", "Station"))
	var status_key: String = _station_status_key_for(self, true)

	if playground_title_label != null:
		playground_title_label.text = "MINI-C EDITOR"
	if debug_console_title != null:
		debug_console_title.text = "MISSION STATUS  |  %s" % str(current_entry.get("label_id", "A"))

	if station_header_title != null:
		station_header_title.text = "STATION SELECTOR"
		station_header_title.add_theme_color_override("font_color", Color8(255, 199, 87))
	if station_status_badge != null:
		station_status_badge.text = _station_status_title(status_key)
		_station_status_badge_theme(station_status_badge, status_key)
	if station_context_label != null:
		station_context_label.text = "Editing: %s" % current_title
		station_context_label.add_theme_color_override("font_color", Color8(239, 244, 255))
		station_context_label.add_theme_font_size_override("font_size", 15)
	if station_role_label != null:
		station_role_label.text = "Role: %s" % _station_role_description(current_role)
		station_role_label.add_theme_color_override("font_color", Color8(171, 191, 224))
		station_role_label.add_theme_font_size_override("font_size", 12)
	if station_signal_label != null:
		station_signal_label.text = "System Link: %s" % ("ONLINE" if real_factory != null else "OFFLINE")
		station_signal_label.add_theme_color_override("font_color", Color8(131, 223, 187) if real_factory != null else Color8(236, 104, 104))
		station_signal_label.add_theme_font_size_override("font_size", 12)
	if station_code_hint_label != null:
		station_code_hint_label.text = "Starter: %s" % str(current_entry.get("starter", "Ready"))
		station_code_hint_label.add_theme_color_override("font_color", Color8(176, 197, 233))
		station_code_hint_label.add_theme_font_size_override("font_size", 12)

	for index in range(_station_tab_buttons.size()):
		var button: Button = _station_tab_buttons[index]
		var entry: Dictionary = _station_entries[index]
		var playground: MiniCPlayground = entry.get("playground") as MiniCPlayground
		var is_current: bool = playground == self
		var button_status: String = _station_status_key_for(playground, is_current)
		button.text = "%s  %s" % [str(entry.get("label_id", "A")), str(entry.get("role", "Station"))]
		_style_station_tab(button, button_status, is_current)

func _current_station_entry_index() -> int:
	for index in range(_station_entries.size()):
		var entry: Dictionary = _station_entries[index]
		var playground: MiniCPlayground = entry.get("playground") as MiniCPlayground
		if playground == self:
			return index
	return 0

func _station_button_sort_key(button_name: String) -> String:
	var digits: String = ""
	for i in range(button_name.length()):
		var ch: String = button_name.substr(i, 1)
		if ch >= "0" and ch <= "9":
			digits += ch
	if digits != "":
		return "%04d" % int(digits)
	return button_name.to_lower()

func _station_label_for_index(index: int) -> String:
	return String.chr(65 + index)

func _station_role_from_root(station_root: Node) -> String:
	if station_root == null:
		return "Control Node"
	if station_root.get_node_or_null("BoxSpawner") != null:
		return "Spawner"
	if station_root.get_node_or_null("ColorSensor") != null and station_root.get_node_or_null("Divertergatecloseopen") != null:
		return "Conveyor Sorting"
	if station_root.get_node_or_null("WeightSensor") != null and station_root.get_node_or_null("RobotArm") != null:
		return "Weight Sensor"
	if station_root.get_node_or_null("CartSpawner") != null or station_root.get_node_or_null("ROD") != null:
		return "Output Zone"
	if station_root.get_node_or_null("RobotArm") != null:
		return "Robot Arm"
	return station_root.name

func _station_role_description(role: String) -> String:
	match role:
		"Spawner":
			return "Injects new boxes into the smart warehouse flow."
		"Conveyor Sorting":
			return "Reads colors and routes boxes to the correct lane."
		"Weight Sensor":
			return "Measures box weight and hands heavy items to the arm."
		"Robot Arm":
			return "Rotates, picks, and drops boxes at the right timing."
		"Output Zone":
			return "Collects finished items and closes the warehouse loop."
		_:
			return "Controls a warehouse subsystem in this mission."

func _station_starter_hint(role: String) -> String:
	match role:
		"Spawner":
			return "start(spawner)"
		"Conveyor Sorting":
			return "wait until color"
		"Weight Sensor":
			return "wait until weight"
		"Robot Arm":
			return "rotate / pick / drop"
		"Output Zone":
			return "route + collect"
		_:
			return "mission logic"

func _station_status_key_for(playground: MiniCPlayground, is_current: bool) -> String:
	if playground == null:
		return "inactive"
	if playground._run_active:
		return "active"
	if playground.code_editor == null:
		return "inactive"
	var source: String = playground.code_editor.text.strip_edges()
	var has_code: bool = false
	for line in source.split("\n", false):
		var trimmed: String = str(line).strip_edges()
		if trimmed != "" and not trimmed.begins_with("//") and not trimmed.begins_with("#"):
			has_code = true
			break
	if is_current:
		return "current"
	return "ready" if has_code else "needs_code"

func _station_status_title(status_key: String) -> String:
	match status_key:
		"active":
			return "ACTIVE"
		"needs_code":
			return "NEEDS CODE"
		"ready":
			return "READY"
		"current":
			return "CURRENT"
		_:
			return "INACTIVE"

func _station_status_colors(status_key: String) -> Dictionary:
	match status_key:
		"active":
			return {"bg": Color8(34, 110, 170), "border": Color8(110, 190, 255), "font": Color8(241, 248, 255)}
		"needs_code":
			return {"bg": Color8(112, 79, 25), "border": Color8(246, 169, 49), "font": Color8(255, 240, 212)}
		"ready":
			return {"bg": Color8(25, 95, 66), "border": Color8(84, 214, 146), "font": Color8(236, 255, 244)}
		"current":
			return {"bg": Color8(47, 72, 129), "border": Color8(128, 177, 244), "font": Color8(245, 249, 255)}
		_:
			return {"bg": Color8(56, 63, 74), "border": Color8(98, 111, 133), "font": Color8(223, 229, 238)}

func _style_station_tab(button: Button, status_key: String, is_current: bool) -> void:
	if button == null:
		return
	var colors: Dictionary = _station_status_colors(status_key)
	var bg: Color = Color8(31, 43, 62)
	var border: Color = Color8(77, 102, 141)
	var font_color: Color = Color8(235, 241, 255)
	if colors.has("bg"):
		bg = colors["bg"] as Color
	if colors.has("border"):
		border = colors["border"] as Color
	if colors.has("font"):
		font_color = colors["font"] as Color
	var border_width: int = 1
	if is_current:
		border_width = 2
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", _make_ui_style(bg, 12, border, border_width))
	button.add_theme_stylebox_override("hover", _make_ui_style(bg.lightened(0.08), 12, border.lightened(0.1), 2))
	button.add_theme_stylebox_override("pressed", _make_ui_style(bg.darkened(0.08), 12, Color8(246, 169, 49), 2))

func _station_status_badge_theme(label: Label, status_key: String) -> void:
	if label == null:
		return
	var colors: Dictionary = _station_status_colors(status_key)
	var bg: Color = Color8(31, 43, 62)
	var border: Color = Color8(77, 102, 141)
	var font_color: Color = Color8(235, 241, 255)
	if colors.has("bg"):
		bg = colors["bg"] as Color
	if colors.has("border"):
		border = colors["border"] as Color
	if colors.has("font"):
		font_color = colors["font"] as Color
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_stylebox_override("normal", _make_ui_style(bg, 12, border, 2))

func _refresh_feedback_tabs() -> void:
	for tab_name in _feedback_tab_buttons.keys():
		var button: Button = _feedback_tab_buttons[tab_name] as Button
		if button == null:
			continue
		var is_active: bool = String(tab_name) == _active_feedback_tab
		_style_feedback_tab(button, is_active)
	_refresh_feedback_view()

func _style_feedback_tab(button: Button, is_active: bool) -> void:
	if button == null:
		return
	var bg: Color = Color8(33, 45, 66)
	var border: Color = Color8(79, 110, 162)
	var font_color: Color = Color8(218, 228, 244)
	if is_active:
		bg = Color8(224, 156, 43)
		border = Color8(255, 219, 138)
		font_color = Color8(23, 27, 36)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_stylebox_override("normal", _make_ui_style(bg, 12, border, 2))
	button.add_theme_stylebox_override("hover", _make_ui_style(bg.lightened(0.08), 12, border.lightened(0.08), 2))
	button.add_theme_stylebox_override("pressed", _make_ui_style(bg.darkened(0.06), 12, Color8(246, 169, 49), 2))

func _refresh_feedback_view() -> void:
	if feedback_panel == null or debug_log == null:
		return
	feedback_panel.visible = _active_feedback_tab == "mission"
	match _active_feedback_tab:
		"mission":
			debug_log.text = _build_console_text(_build_mission_lines())
		"output":
			debug_log.text = _build_console_text(_output_log_lines)
		"errors":
			var error_lines: Array[String] = []
			error_lines.append_array(_error_log_lines)
			if error_lines.is_empty():
				error_lines.append("No parser or runtime errors.")
			debug_log.text = _build_console_text(error_lines)
		"hints":
			debug_log.text = _build_console_text(_build_hint_lines())
		_:
			debug_log.text = _build_console_text(_output_log_lines)
	if debug_log.get_line_count() > 0:
		debug_log.scroll_to_line(max(debug_log.get_line_count() - 1, 0))

func _build_mission_lines() -> Array[String]:
	var lines: Array[String] = []
	var title = str(_level_ui_meta.get("title", mission_level_id))
	lines.append("[color=#E09C2B][b]" + title + "[/b][/color]")
	lines.append("")
	for objective in _mission_objectives:
		var done: bool = bool(objective.get("done", false))
		var text: String = str(objective.get("text", ""))
		var icon: String = "[color=#56D98C][x][/color]" if done else "[color=#BCCCE8][ ][/color]"
		var color: String = "#F5F7FF" if done else "#D6E0F2"
		lines.append("%s [color=%s]%s[/color]" % [icon, color, text])
	
	lines.append("")
	lines.append("[color=#9CDCFE]• คำแนะนำ: ดูคำแนะนำเพิ่มเติมได้ในแท็บ HINTS[/color]")
	return lines

func _build_console_text(lines: Array[String]) -> String:
	return "\n".join(lines)

func _build_hint_lines() -> Array[String]:
	var hint_lines: Array[String] = []
	for hint in LEVEL_FAILURE_GUIDES.get(mission_level_id, []):
		hint_lines.append("- %s" % str(hint))
	if hint_lines.is_empty():
		hint_lines.append("No extra hints for this station yet.")
	return hint_lines

func _append_output_log(text: String) -> void:
	_output_log_lines.append(text)
	_refresh_feedback_view()

func _append_error_log(text: String) -> void:
	_error_log_lines.append(text)
	_refresh_feedback_view()

func _sync_progress_panel() -> void:
	var level_number := _level_number_from_id(mission_level_id)
	var lesson := str(_level_ui_meta.get("lesson", "บทเรียน"))
	var stars: Array = _level_ui_meta.get("stars", [])
	if progress_meta_label != null:
		if _is_tutorial_mode():
			progress_meta_label.text = "Tutorial  •  %s" % lesson
			progress_meta_label.add_theme_color_override("font_color", Color8(100, 220, 255))
		else:
			progress_meta_label.text = "ด่าน %d/%d  •  %s" % [max(level_number, 1), LEVEL_SEQUENCE.size(), lesson]
	if progress_bar_mini != null:
		if _is_tutorial_mode():
			progress_bar_mini.visible = false
		else:
			progress_bar_mini.max_value = float(LEVEL_SEQUENCE.size())
			progress_bar_mini.value = float(max(level_number, 1))
	if progress_stars_label != null:
		var star_lines: Array[String] = []
		if _is_tutorial_mode():
			var steps: Array = _level_ui_meta.get("tutorial_steps", [])
			for step in steps:
				star_lines.append("→ " + str(step))
			progress_stars_label.add_theme_color_override("font_color", Color8(100, 220, 255))
		else:
			for star_text in stars:
				star_lines.append("★ " + str(star_text))
		progress_stars_label.text = "\n".join(star_lines)
	_refresh_station_selector_ui()

func _style_level_hud() -> void:
	var inner_style := _make_ui_style(Color(0.10, 0.15, 0.24, 0.92), 14, Color8(87, 122, 177), 1)
	if level_header_card != null:
		level_header_card.visible = false
	if mission_card != null:
		mission_card.visible = false
	if feedback_panel != null:
		feedback_panel.add_theme_stylebox_override("panel", inner_style)
	if progress_title_label != null:
		progress_title_label.visible = false
		progress_title_label.add_theme_color_override("font_color", Color8(255, 199, 87))
		progress_title_label.add_theme_font_size_override("font_size", 14)
	if progress_meta_label != null:
		progress_meta_label.add_theme_color_override("font_color", Color8(220, 231, 255))
		progress_meta_label.add_theme_font_size_override("font_size", 12)
	if progress_bar_mini != null:
		progress_bar_mini.add_theme_stylebox_override("background", _make_ui_style(Color8(22, 34, 52), 8))
		progress_bar_mini.add_theme_stylebox_override("fill", _make_ui_style(Color8(86, 217, 140), 8))
	if progress_stars_label != null:
		progress_stars_label.visible = false
		progress_stars_label.add_theme_color_override("font_color", Color8(181, 200, 230))
		progress_stars_label.add_theme_font_size_override("font_size", 11)

func _build_level_header() -> void:
	var level_number := _level_number_from_id(mission_level_id)
	var title := str(_level_ui_meta.get("title", mission_level_id))
	var lesson := str(_level_ui_meta.get("lesson", "บทเรียน"))
	var stars: Array = _level_ui_meta.get("stars", [])

	if _is_tutorial_mode():
		# --- Tutorial Header: ต่างจากด่านจริง ---
		level_badge_label.text = "TUTORIAL"
		level_badge_label.add_theme_color_override("font_color", Color8(18, 24, 34))
		# เปลี่ยนสี badge เป็นฟ้าเพื่อให้ชัดเจนว่าไม่ใช่ด่านจริง
		var badge_style := _make_ui_style(Color8(40, 160, 220), 10)
		if level_badge_label.get_parent() is Panel or level_badge_label.get_parent() is PanelContainer:
			level_badge_label.get_parent().add_theme_stylebox_override("panel", badge_style)
		level_badge_label.add_theme_stylebox_override("normal", badge_style)
		lesson_label.text = lesson
		lesson_label.add_theme_color_override("font_color", Color8(100, 220, 255))
		level_header_title_label.text = title
		level_header_title_label.add_theme_color_override("font_color", Color8(100, 220, 255))
		progress_label.text = "ขั้นตอนการฝึกหัด"
		level_progress_bar.visible = false
		for child in star_goals_box.get_children():
			child.queue_free()
		var steps: Array = _level_ui_meta.get("tutorial_steps", [])
		for step in steps:
			var label := Label.new()
			label.text = str(step)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_color_override("font_color", Color8(140, 220, 255))
			label.add_theme_font_size_override("font_size", 12)
			star_goals_box.add_child(label)
	else:
		# --- ด่านจริง: เหมือนเดิม ---
		level_badge_label.text = "ด่าน %d/%d" % [max(level_number, 1), LEVEL_SEQUENCE.size()]
		lesson_label.text = lesson
		level_header_title_label.text = title
		progress_label.text = "ความคืบหน้าของบทเรียน"
		level_progress_bar.max_value = float(LEVEL_SEQUENCE.size())
		level_progress_bar.value = float(max(level_number, 1))
		for child in star_goals_box.get_children():
			child.queue_free()
		for star_text in stars:
			var label := Label.new()
			label.text = "★ " + str(star_text)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_color_override("font_color", Color8(236, 241, 255))
			label.add_theme_font_size_override("font_size", 12)
			star_goals_box.add_child(label)

func _build_mission_card() -> void:
	var objectives: Array = _level_ui_meta.get("objectives", [])
	_mission_objectives.clear()
	for child in mission_items_box.get_children():
		child.queue_free()

	for objective_variant in objectives:
		var objective: Dictionary = objective_variant.duplicate(true)
		objective["done"] = false
		_mission_objectives.append(objective)

		var row := HBoxContainer.new()
		row.name = str(objective.get("id", "objective"))
		row.add_theme_constant_override("separation", 8)

		var icon := Label.new()
		icon.name = "Icon"
		icon.custom_minimum_size = Vector2(20, 20)
		icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var text := Label.new()
		text.name = "Text"
		text.text = str(objective.get("text", ""))
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		row.add_child(icon)
		row.add_child(text)
		mission_items_box.add_child(row)

func _reset_live_mission_state() -> void:
	_live_action_counts.clear()
	_live_sensor_counts.clear()
	_live_action_done_counts.clear()
	_live_destroyer_counts.clear()
	_live_destroyed_total = 0
	for i in range(_mission_objectives.size()):
		_mission_objectives[i]["done"] = false
	_refresh_mission_checklist()

func _refresh_mission_checklist() -> void:
	for objective in _mission_objectives:
		var done := _is_objective_complete(objective)
		objective["done"] = done
		var row := mission_items_box.get_node_or_null(str(objective.get("id", ""))) as HBoxContainer
		if row == null:
			continue
		var icon := row.get_node_or_null("Icon") as Label
		var text := row.get_node_or_null("Text") as Label
		if icon != null:
			icon.text = "[x]" if done else "[ ]"
			icon.add_theme_color_override("font_color", Color8(86, 217, 140) if done else Color8(188, 204, 232))
			icon.add_theme_font_size_override("font_size", 18)
		if text != null:
			text.add_theme_color_override("font_color", Color8(245, 247, 255) if done else Color8(214, 224, 242))
			text.add_theme_font_size_override("font_size", 16)

	var completed := 0
	for objective in _mission_objectives:
		if bool(objective.get("done", false)):
			completed += 1
	mission_subtitle_label.text = "%d/%d เป้าหมายสำเร็จแล้ว" % [completed, _mission_objectives.size()]

	if feedback_detail_label != null and (not _run_active or feedback_status_label.text.find("พร้อม") != -1):
		feedback_detail_label.text = "เป้าหมายด่านสำเร็จแล้ว %d/%d  •  ดูรายละเอียดเต็มในปุ่ม ภารกิจ" % [completed, _mission_objectives.size()]

	if _active_feedback_tab == "mission":
		_refresh_feedback_view()

func _is_objective_complete(objective: Dictionary) -> bool:
	var rule: Dictionary = objective.get("rule", {})
	if rule.has("action"):
		var action_name := str(rule.get("action", ""))
		var count := int(rule.get("count", 1))
		return int(_live_action_counts.get(action_name, 0)) >= count
	if rule.has("all_actions"):
		var required_actions: Dictionary = rule.get("all_actions", {})
		for action_name in required_actions.keys():
			if int(_live_action_counts.get(str(action_name), 0)) < int(required_actions[action_name]):
				return false
		return true
	if rule.has("sensor"):
		var sensor_type := str(rule.get("sensor", "")).to_lower()
		var count := int(rule.get("count", 1))
		return int(_live_sensor_counts.get(sensor_type, 0)) >= count
	if rule.has("action_done"):
		var action_done := str(rule.get("action_done", ""))
		var count := int(rule.get("count", 1))
		return int(_live_action_done_counts.get(action_done, 0)) >= count
	if rule.has("destroyed_total"):
		return _live_destroyed_total >= int(rule.get("destroyed_total", 1))
	if rule.has("destroyer"):
		var destroyer_id := str(rule.get("destroyer", ""))
		return int(_live_destroyer_counts.get(destroyer_id, 0)) >= int(rule.get("count", 1))
	if rule.has("all_destroyers"):
		var required_destroyers: Dictionary = rule.get("all_destroyers", {})
		for destroyer_id in required_destroyers.keys():
			if int(_live_destroyer_counts.get(str(destroyer_id), 0)) < int(required_destroyers[destroyer_id]):
				return false
		return true
	return false

func _start_execution() -> void:
	_hide_result_popup()
	_clear_exec_line_highlight()
	_output_log_lines.clear()
	_error_log_lines.clear()
	output.clear()
	debug_log.clear()
	_append_output_log("RUN")
	_active_feedback_tab = "mission"
	_refresh_feedback_tabs()
	_run_active = false
	_mission_reported_early = false
	_run_started_at_msec = Time.get_ticks_msec()
	_last_run_duration_msec = 0
	_reset_live_mission_state()
	_set_feedback_state("info", "กำลังทดสอบโค้ด", "ดูว่าเป้าหมายด้านซ้ายเริ่มเปลี่ยนเป็นเครื่องหมายถูกหรือยัง")

	var source: String = code_editor.text.strip_edges()
	GameData.save_level_script(_script_storage_key(), code_editor.text)
	if source.is_empty():
		mission_evaluator.start_run(mission_level_id, source, ["No source code"])
		_print_error("No source code")
		_finalize_mission()
		return

	# --------------------------
	# PARSE
	# --------------------------
	var program: ProgramNode = MiniCParser.parse(source)
	var errors: Array = MiniCParser.get_errors()
	if program == null and errors.is_empty():
		errors.append("Parse failed")

	mission_evaluator.start_run(mission_level_id, source, errors)

	if errors.size() > 0:
		for e in errors:
			_print_error(str(e))
		_finalize_mission()
		return
	if program == null:
		_print_error("Parse failed")
		_finalize_mission()
		return

	# --------------------------
	# CONTROLLER CHECK
	# --------------------------
	if real_factory == null:
		_print_error("RealFactoryController not found in scene")
		_finalize_mission()
		return

	# --------------------------
	# EXECUTE
	# --------------------------
	_prepare_destroyers_for_run()
	_expected_total_boxes = 0
	mission_evaluator.record_event("run_meta", {"expected_total_boxes": -1})
	_run_active = true
	runtime.execute(program, real_factory)

# ==================================================
# OUTPUT
# ==================================================
func _print(msg: String) -> void:
	_append_output_log(msg)
	if output != null:
		output.append_text(msg + "\n")

func _print_error(msg: String) -> void:
	var friendly := _humanize_runtime_error(msg)
	_set_feedback_state("error", friendly.get("title", "ยังมีบางอย่างไม่ถูกต้อง"), friendly.get("detail", "ลองตรวจโค้ดอีกครั้ง"))
	_append_error_log("[color=#F44747]%s[/color]" % msg)
	_append_output_log("[color=#F44747]%s[/color]" % msg)
	if output != null:
		output.append_text("[color=red]" + msg + "[/color]\n")

func _on_action_executed(action: String) -> void:
	_append_output_log(action)
	if _run_active:
		var action_key := _normalize_runtime_action(action)
		if action_key != "":
			_live_action_counts[action_key] = int(_live_action_counts.get(action_key, 0)) + 1
		mission_evaluator.record_event("action_executed", {"action": action})
		_refresh_mission_checklist()
		_try_finalize_live_mission()

func _on_runtime_execution_finished() -> void:
	if not _run_active:
		return
	if mission_level_id == "level_5" and not _can_finalize_after_random_done():
		# Level 5 waits for random generation + destroy accounting to complete.
		return
	if mission_level_id == "level_6" and _get_total_destroyed_count() <= 0:
		# Level 6 should be evaluated only after at least one box reaches a destroyer.
		# Keep run active and wait for _on_box_destroyed -> _try_finalize_live_mission().
		return
	if mission_level_id == "level_7" and _get_total_destroyed_count() <= 0:
		# Level 7 should be evaluated only after at least one box reaches a destroyer.
		return
	if mission_level_id == "level_8" and _get_total_destroyed_count() <= 0:
		# Level 8 should be evaluated only after at least one box reaches a destroyer.
		return
	_run_active = false
	_refresh_station_selector_ui()
	_finalize_mission()

func _finalize_mission() -> void:
	_clear_exec_line_highlight()
	_last_run_duration_msec = max(Time.get_ticks_msec() - _run_started_at_msec, 0)
	var result := mission_evaluator.finish_run()
	_refresh_mission_checklist()
	_print_mission_result(result)
	_refresh_station_selector_ui()
	if _show_popup_on_finalize:
		_show_result_popup(result)

func _print_mission_result(result: Dictionary) -> void:
	var passed := bool(result.get("is_passed", result.get("pass", false)))
	var score := int(result.get("score", 0))
	var checks_passed := int(result.get("checks_passed", 0))
	var checks_total := int(result.get("checks_total", 0))
	var title := str(result.get("display_name", "Mission"))

	var color := "#4EC9B0" if passed else "#F44747"
	_append_output_log("[color=%s]%s: %s (%d%%, %d/%d checks)[/color]" % [
		color,
		title,
		("PASS" if passed else "FAIL"),
		score,
		checks_passed,
		checks_total,
	])

	var reasons: Array = result.get("reasons", [])
	for reason in reasons:
		_append_error_log("[color=#F44747]- %s[/color]" % str(reason))
		_append_output_log("[color=#F44747]- %s[/color]" % str(reason))
	if passed:
		_set_feedback_state("success", "ภารกิจสำเร็จ!", "คุณทำครบ %d/%d เงื่อนไข คะแนน %d/100" % [checks_passed, checks_total, score])
	else:
		var summary := _build_player_failure_summary(result)
		_set_feedback_state("warning", summary.get("title", "ยังไม่ผ่านภารกิจ"), summary.get("detail", "ลองแก้ตามคำแนะนำแล้วกด RUN อีกครั้ง"))

	_print_destroyer_summary()
	_refresh_feedback_view()

func _bind_result_popup() -> void:
	if retry_button != null and not retry_button.pressed.is_connected(_on_retry_button_pressed):
		retry_button.pressed.connect(_on_retry_button_pressed)
	if level_select_button != null and not level_select_button.pressed.is_connected(_on_level_select_button_pressed):
		level_select_button.pressed.connect(_on_level_select_button_pressed)
	if next_level_button != null and not next_level_button.pressed.is_connected(_on_next_level_button_pressed):
		next_level_button.pressed.connect(_on_next_level_button_pressed)
	_hide_result_popup()

func _show_result_popup(result: Dictionary) -> void:
	if result_overlay == null:
		return

	_apply_result_popup_theme()

	var passed := bool(result.get("is_passed", result.get("pass", false)))
	var score := int(result.get("score", 0))
	var checks_passed := int(result.get("checks_passed", 0))
	var checks_total := int(result.get("checks_total", 0))
	var destroyed_boxes: Array = result.get("destroyed_boxes", [])
	var stars := _compute_star_count(score, passed)
	var next_level_id := _next_level_id(mission_level_id)

	title_label.text = str(result.get("display_name", mission_level_id)).replace("_", " ")
	subtitle_label.text = "สรุปผลการรันล่าสุด"
	score_label.text = "%d/100" % score
	checks_value_label.text = "%d/%d" % [checks_passed, checks_total]
	time_value_label.text = _format_duration(_last_run_duration_msec)
	boxes_value_label.text = str(destroyed_boxes.size())

	if passed:
		status_badge.text = "สำเร็จ!"
		status_badge.add_theme_stylebox_override("normal", result_card.get_theme_stylebox("panel").duplicate())
	else:
		status_badge.text = "ยังไม่ผ่าน"
		status_badge.add_theme_stylebox_override("normal", result_card.get_theme_stylebox("panel").duplicate())

	var badge_style := status_badge.get_theme_stylebox("normal")
	if badge_style is StyleBoxFlat:
		var style := badge_style as StyleBoxFlat
		style.bg_color = Color8(31, 156, 104) if passed else Color8(214, 74, 87)

	for idx in range(star_labels.size()):
		star_labels[idx].modulate = Color8(255, 212, 83) if idx < stars else Color8(81, 99, 144)

	_set_result_details_text(_build_result_details(result))

	next_level_button.visible = next_level_id != ""
	next_level_button.disabled = (not passed) or next_level_id == ""

	if passed:
		var level_number := _level_number_from_id(mission_level_id)
		if level_number > 0:
			GameData.unlock_next_level(level_number)

	result_overlay.visible = true

func _apply_result_popup_theme() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var card_width: float = clampf(viewport_size.x * 0.85, 800.0, 1200.0)

	if result_overlay != null:
		result_overlay.layer = 100
		var dim_bg = result_overlay.get_node_or_null("DimBackground")
		if dim_bg == null:
			dim_bg = ColorRect.new()
			dim_bg.name = "DimBackground"
			dim_bg.color = Color(0, 0, 0, 0.85)
			dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
			result_overlay.add_child(dim_bg)
			result_overlay.move_child(dim_bg, 0)

	if result_card != null:
		result_card.custom_minimum_size = Vector2(card_width, viewport_size.y * 0.85)

	var margin: MarginContainer = result_card.get_node_or_null("MarginContainer") as MarginContainer
	if margin != null:
		margin.add_theme_constant_override("margin_left", 40)
		margin.add_theme_constant_override("margin_top", 40)
		margin.add_theme_constant_override("margin_right", 40)
		margin.add_theme_constant_override("margin_bottom", 40)

	var main_box: VBoxContainer = result_card.get_node_or_null("MarginContainer/VBoxContainer") as VBoxContainer
	if main_box != null:
		main_box.add_theme_constant_override("separation", 10)

	var header: VBoxContainer = result_card.get_node_or_null("MarginContainer/VBoxContainer/Header") as VBoxContainer
	if header != null:
		header.add_theme_constant_override("separation", 6)

	status_badge.custom_minimum_size = Vector2(150, 32)
	status_badge.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_font_size_override("font_size", 26)
	subtitle_label.add_theme_font_size_override("font_size", 15)
	score_label.add_theme_font_size_override("font_size", 34)

	for star in star_labels:
		star.add_theme_font_size_override("font_size", 34)

	var reasons_panel: PanelContainer = result_card.get_node_or_null("MarginContainer/VBoxContainer/ReasonsPanel") as PanelContainer
	if reasons_panel != null:
		reasons_panel.custom_minimum_size = Vector2(0, 220)

	var reasons_scroll: ScrollContainer = result_card.get_node_or_null("MarginContainer/VBoxContainer/ReasonsPanel/ReasonsMargin/ReasonsBox/ReasonsScroll") as ScrollContainer
	if reasons_scroll != null:
		reasons_scroll.custom_minimum_size = Vector2(0, 170)
		reasons_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		reasons_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	if reasons_label != null:
		reasons_label.fit_content = false
		reasons_label.scroll_active = true
		reasons_label.custom_minimum_size = Vector2(0, 220)
		reasons_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		reasons_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		reasons_label.add_theme_color_override("default_color", Color8(230, 240, 255))
		reasons_label.add_theme_font_size_override("normal_font_size", 15)

	var metrics_margin: MarginContainer = result_card.get_node_or_null("MarginContainer/VBoxContainer/MetricsPanel/MetricsMargin") as MarginContainer
	if metrics_margin != null:
		metrics_margin.add_theme_constant_override("margin_left", 14)
		metrics_margin.add_theme_constant_override("margin_top", 12)
		metrics_margin.add_theme_constant_override("margin_right", 14)
		metrics_margin.add_theme_constant_override("margin_bottom", 12)

	var buttons: HBoxContainer = result_card.get_node_or_null("MarginContainer/VBoxContainer/Buttons") as HBoxContainer
	if buttons != null:
		buttons.add_theme_constant_override("separation", 10)
		for child in buttons.get_children():
			if child is Button:
				var button := child as Button
				button.custom_minimum_size = Vector2(130, 42)
				button.add_theme_font_size_override("font_size", 15)

func _hide_result_popup() -> void:
	if result_overlay != null:
		result_overlay.visible = false

func _set_result_details_text(details: String) -> void:
	if reasons_label == null:
		return
	reasons_label.clear()
	reasons_label.bbcode_enabled = true
	reasons_label.append_text("[color=#E6F0FF]" + details.replace("[", "\\[").replace("]", "\\]") + "[/color]")
	reasons_label.scroll_to_line(0)

func _build_result_details(result: Dictionary) -> String:
	var lines: Array[String] = []
	var reasons: Array = result.get("reasons", [])
	var passed := bool(result.get("is_passed", result.get("pass", false)))
	var checks_passed := int(result.get("checks_passed", 0))
	var checks_total := int(result.get("checks_total", 0))

	lines.append("สรุป: %s (%d/%d เงื่อนไข)" % ["ผ่าน" if passed else "ยังไม่ผ่าน", checks_passed, checks_total])
	lines.append("คะแนนมาจากจำนวนเงื่อนไขที่ทำถูก เช่น คำสั่งที่ต้องใช้, ลำดับการรอ sensor/action และปลายทางกล่อง")
	lines.append("")

	if reasons.is_empty():
		lines.append("ผลตรวจ: ทำครบทุกเงื่อนไขของด่านนี้แล้ว")
	else:
		lines.append("ต้องแก้เพิ่ม:")
		for reason in reasons:
			lines.append("- " + _friendly_result_reason(str(reason)))
		lines.append("")
		lines.append("เช็กลิสต์ของด่านนี้:")
		var level_hints: Array = LEVEL_FAILURE_GUIDES.get(mission_level_id, [])
		for hint in level_hints:
			lines.append("- " + str(hint))

	var action_counts: Dictionary = result.get("action_counts", {})
	if not action_counts.is_empty():
		var action_summary: Array[String] = []
		for key in action_counts.keys():
			action_summary.append("%s=%s" % [_humanize_action_name(str(key)), str(action_counts[key])])
		action_summary.sort()
		lines.append("")
		lines.append("คำสั่งที่รัน: " + ", ".join(action_summary))

	var destroyer_counts: Dictionary = result.get("destroyer_counts", {})
	if not destroyer_counts.is_empty():
		var destroyer_summary: Array[String] = []
		for key in destroyer_counts.keys():
			destroyer_summary.append("%s: %s" % [str(key), str(destroyer_counts[key])])
		destroyer_summary.sort()
		lines.append("")
		lines.append("ปลายทางกล่อง: " + ", ".join(destroyer_summary))

	var sensor_events: Array = result.get("sensor_events", [])
	var action_done_events: Array = result.get("action_done_events", [])
	if not sensor_events.is_empty() or not action_done_events.is_empty():
		lines.append("")
		lines.append("เหตุการณ์ระหว่างรัน: sensor %d ครั้ง, action(done) %d ครั้ง" % [sensor_events.size(), action_done_events.size()])

	return "\n".join(lines)

func _humanize_result_reason(reason: String) -> String:
	if reason.begins_with("Syntax:"):
		return "โค้ดยังมี syntax error: " + _humanize_parser_error(reason.substr("Syntax:".length()).strip_edges())
	if reason.begins_with("Missing structure token:"):
		return "ยังขาดรูปแบบโค้ดที่ต้องมี: " + reason.substr("Missing structure token:".length()).strip_edges()
	if reason.begins_with("Action '"):
		return reason.replace("Action", "คำสั่ง").replace("requires", "ต้องมีอย่างน้อย").replace("actual", "ตอนนี้มี")
	if reason.begins_with("After sensor"):
		return reason.replace("After sensor", "หลัง sensor").replace("action", "ต้องสั่ง").replace("requires", "อย่างน้อย").replace("actual", "ตอนนี้")
	if reason.begins_with("After ACTION_DONE"):
		return reason.replace("After ACTION_DONE", "หลังรอ action(done)").replace("action", "ต้องสั่ง").replace("requires", "อย่างน้อย").replace("actual", "ตอนนี้")
	if reason.begins_with("Total destroyed boxes"):
		return "จำนวนกล่องที่ถึงปลายทางยังไม่ตรงกับจำนวนที่สร้าง"
	if reason.begins_with("Destroyer"):
		return reason.replace("Destroyer", "ปลายทาง").replace("requires", "ต้องมี").replace("actual", "ตอนนี้มี")
	if reason.find("destroyer") != -1 and reason.find("weight") != -1:
		return "กล่องถูกส่งผิดปลายทางหรือน้ำหนักไม่ตรงเงื่อนไข: " + reason
	if reason.find("At least one destroyer routing rule") != -1:
		return "ยังไม่มีปลายทางใดที่คัดแยกกล่องได้ถูกตามเงื่อนไข"
	if reason.begins_with("Sequence required:"):
		return "ลำดับคำสั่งยังไม่ถูก ต้องเรียงตามโจทย์: " + reason.substr("Sequence required:".length()).strip_edges()
	return reason

func _humanize_parser_error(error: String) -> String:
	if error.begins_with("Action must end with ';' at:"):
		return "คำสั่งต้องจบด้วยเครื่องหมาย ; ที่บรรทัด/คำสั่ง: " + error.substr("Action must end with ';' at:".length()).strip_edges()
	if error.begins_with("Expected"):
		return "รูปแบบคำสั่งไม่ครบ: " + error
	if error.find("Unexpected") != -1:
		return "พบคำสั่งหรือสัญลักษณ์ที่ parser ไม่รู้จัก: " + error
	if error.find("Unknown") != -1:
		return "มีชื่อคำสั่ง/ตัวแปรที่ระบบไม่รู้จัก: " + error
	return error

func _humanize_action_name(action_name: String) -> String:
	match action_name:
		"START_SPAWNER":
			return "เปิด spawner"
		"STOP_SPAWNER":
			return "หยุด spawner"
		"START_CONVEYOR":
			return "เปิด conveyor"
		"STOP_CONVEYOR":
			return "หยุด conveyor"
		"ROTATE_ARM":
			return "หมุนแขนกล"
		"PICK_BOX":
			return "หยิบกล่อง"
		"DROP_BOX":
			return "วางกล่อง"
		_:
			return action_name.to_lower()

func _set_feedback_state(kind: String, title: String, detail: String) -> void:
	if feedback_status_label == null or feedback_detail_label == null:
		return
	var title_color := Color8(245, 247, 255)
	var detail_color := Color8(188, 204, 232)
	match kind:
		"success":
			title_color = Color8(86, 217, 140)
			detail_color = Color8(213, 245, 223)
		"warning":
			title_color = Color8(255, 205, 96)
			detail_color = Color8(255, 235, 186)
		"error":
			title_color = Color8(240, 93, 94)
			detail_color = Color8(255, 210, 210)
		"info":
			title_color = Color8(117, 186, 255)
			detail_color = Color8(214, 229, 255)

	feedback_status_label.text = title
	feedback_detail_label.text = detail
	feedback_status_label.add_theme_color_override("font_color", title_color)
	feedback_status_label.add_theme_font_size_override("font_size", 17)
	feedback_detail_label.add_theme_color_override("font_color", detail_color)
	feedback_detail_label.add_theme_font_size_override("font_size", 13)

func _humanize_runtime_error(msg: String) -> Dictionary:
	var trimmed := msg.strip_edges()
	if trimmed == "No source code":
		return {
			"title": "ยังไม่ได้เขียนโค้ด",
			"detail": "ลองเริ่มด้วย start(spawner); แล้วค่อยกด RUN อีกครั้ง",
		}
	if trimmed == "Parse failed":
		return {
			"title": "โค้ดยังอ่านไม่สำเร็จ",
			"detail": "เช็กวงเล็บ เครื่องหมาย ; และรูปแบบคำสั่งอีกครั้ง",
		}
	if trimmed.find("RealFactoryController not found") != -1:
		return {
			"title": "ระบบโรงงานยังไม่พร้อม",
			"detail": "ฉากนี้ยังผูกตัวควบคุมโรงงานไม่ครบ",
		}
	if trimmed.find("Bottleneck:") == 0:
		return {
			"title": "มีจุดติดขัดในสายการผลิต",
			"detail": "ลองเช็กจังหวะการปล่อยกล่องหรือการหยุดสายพานอีกครั้ง",
		}
	return {
		"title": "ยังมีบางอย่างไม่ถูกต้อง",
			"detail": _friendly_parser_error(trimmed),
	}

func _build_player_failure_summary(result: Dictionary) -> Dictionary:
	var reasons: Array = result.get("reasons", [])
	if reasons.is_empty():
		return {
			"title": "ยังไม่ผ่านภารกิจ",
			"detail": "ลองเช็กเป้าหมายด้านซ้ายและรันอีกครั้ง",
		}
	var first_reason := str(reasons[0])
	if first_reason.begins_with("Syntax:"):
		return {
			"title": "โค้ดยังมีรูปแบบไม่ถูกต้อง",
			"detail": _friendly_parser_error(first_reason.substr("Syntax:".length()).strip_edges()),
		}
	return {
		"title": _friendly_result_reason(first_reason),
		"detail": _next_step_from_reason(first_reason),
	}

func _next_step_from_reason(reason: String) -> String:
	if reason.find("START_SPAWNER") != -1 or reason.find("start(spawner)") != -1:
		return "ลองเพิ่ม start(spawner); เพื่อให้กล่องเริ่มออกจากเครื่อง"
	if reason.find("START_CONVEYOR") != -1 or reason.find("start(conveyor)") != -1:
		return "อย่าลืมใช้ start(conveyor); เพื่อให้กล่องเคลื่อนที่"
	if reason.find("STOP_SPAWNER") != -1 or reason.find("STOP_CONVEYOR") != -1:
		return "หลัง sensor ตรวจพบแล้ว ลองสั่ง stop ให้ระบบหยุดก่อนทำขั้นต่อไป"
	if reason.find("wait until") != -1 or reason.find("ACTION_DONE") != -1:
		return "ลองเพิ่ม wait until (...) เพื่อรอให้เหตุการณ์หรือคำสั่งก่อนหน้าจบ"
	if reason.find("destroyer") != -1:
		return "ลองเช็กว่ากล่องถูกส่งไปปลายทางที่ตรงกับเงื่อนไขหรือยัง"
	return "ลองดูเป้าหมายด้านซ้าย แล้วเพิ่มคำสั่งที่ยังขาด"

func _friendly_result_reason(reason: String) -> String:
	if reason.begins_with("Syntax:"):
		return "โค้ดยังมี syntax error: " + _friendly_parser_error(reason.substr("Syntax:".length()).strip_edges())
	if reason.begins_with("Missing structure token:"):
		return "ยังขาดรูปแบบคำสั่งที่โจทย์ต้องการ: " + reason.substr("Missing structure token:".length()).strip_edges()
	if reason.begins_with("Action '"):
		var action_name := reason.get_slice("'", 1)
		return "ยังขาดคำสั่ง " + _humanize_action_name(action_name)
	if reason.begins_with("After sensor"):
		return "หลัง sensor ทำงานแล้ว ยังไม่มีคำสั่งตอบสนองตามที่โจทย์ต้องการ"
	if reason.begins_with("After ACTION_DONE"):
		return "หลังรอ action(done) แล้ว ยังมีลำดับคำสั่งไม่ครบ"
	if reason.begins_with("Total destroyed boxes"):
		return "จำนวนกล่องที่ถึงปลายทางยังไม่ครบตามที่สร้าง"
	if reason.begins_with("Destroyer"):
		return "ยังส่งกล่องไปปลายทางไม่ครบตามเงื่อนไข"
	if reason.find("destroyer") != -1 and reason.find("weight") != -1:
		return "กล่องถูกส่งผิดปลายทาง หรือคัดตามน้ำหนักยังไม่ตรงเงื่อนไข"
	if reason.find("At least one destroyer routing rule") != -1:
		return "ยังไม่มีเส้นทางคัดแยกไหนที่ผ่านเงื่อนไข"
	if reason.begins_with("Sequence required:"):
		return "ลำดับคำสั่งยังไม่ถูกตามโจทย์"
	return reason

func _friendly_parser_error(error: String) -> String:
	if error.begins_with("Action must end with ';' at:"):
		return "คำสั่งต้องจบด้วย ; ที่ตำแหน่ง: " + error.substr("Action must end with ';' at:".length()).strip_edges()
	if error.begins_with("Expected"):
		return "รูปแบบคำสั่งยังไม่ครบ: " + error
	if error.find("Unexpected") != -1:
		return "พบคำสั่งหรือสัญลักษณ์ที่ระบบยังอ่านไม่เข้าใจ: " + error
	if error.find("Unknown") != -1:
		return "มีชื่อคำสั่งหรือตัวแปรที่ระบบไม่รู้จัก: " + error
	return error

func _normalize_runtime_action(action: String) -> String:
	var trimmed := action.strip_edges().to_upper()
	if trimmed == "":
		return ""
	var parts := trimmed.split(" ", false)
	if parts.is_empty():
		return trimmed
	return str(parts[0])

func _compute_star_count(score: int, passed: bool) -> int:
	if not passed:
		return 0
	if score >= 90:
		return 3
	if score >= 70:
		return 2
	return 1

func _format_duration(duration_msec: int) -> String:
	var seconds: float = max(float(duration_msec) / 1000.0, 0.0)
	if seconds >= 60.0:
		var mins := int(seconds / 60.0)
		var remain: float = seconds - (float(mins) * 60.0)
		return "%d:%04.1f" % [mins, remain]
	return "%.1fs" % seconds

func _next_level_id(level_id: String) -> String:
	var idx := LEVEL_SEQUENCE.find(level_id)
	if idx == -1 or idx >= LEVEL_SEQUENCE.size() - 1:
		return ""
	return LEVEL_SEQUENCE[idx + 1]

func _level_number_from_id(level_id: String) -> int:
	var parts := level_id.split("_")
	if parts.size() != 2:
		return 0
	return int(parts[1])

func _go_to_level(level_id: String) -> void:
	var scene_path := str(LEVEL_SCENES.get(level_id, ""))
	if scene_path == "":
		return
	get_tree().change_scene_to_file(scene_path)

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_next_level_button_pressed() -> void:
	var next_level_id := _next_level_id(mission_level_id)
	if next_level_id == "":
		return
	_go_to_level(next_level_id)

func _print_destroyer_summary() -> void:
	if _destroyers.is_empty():
		return
	_append_output_log("[color=#9CDCFE]Destroyer summary:[/color]")
	for destroyer in _destroyers:
		var id := str(destroyer.get_parent().name) if destroyer.get_parent() != null else str(destroyer.name)
		var total := destroyer.get_destroyed_count()
		var ge5 := 0
		var lt5 := 0
		var weights := destroyer.get_destroyed_weights()
		for w in weights:
			if float(w) >= 5.0:
				ge5 += 1
			else:
				lt5 += 1
		_append_output_log("[color=#9CDCFE]- %s: total=%d, >=5=%d, <5=%d[/color]" % [id, total, ge5, lt5])

func _prepare_destroyers_for_run() -> void:
	_bind_destroyers()
	_bind_spawners()
	_reset_spawner_finish_state()
	for destroyer in _destroyers:
		destroyer.clear_destroyed_history()

func _bind_destroyers() -> void:
	_destroyers.clear()
	var root := _get_station_root()
	if root == null:
		return
	_collect_destroyers(root)
	for destroyer in _destroyers:
		if not destroyer.box_destroyed.is_connected(_on_box_destroyed):
			destroyer.box_destroyed.connect(_on_box_destroyed)

func _collect_destroyers(node: Node) -> void:
	if node is BoxDestroyer:
		_destroyers.append(node as BoxDestroyer)
	for child in node.get_children():
		if child is Node:
			_collect_destroyers(child)

func _bind_spawners() -> void:
	_spawners.clear()
	var root := _get_station_root()
	if root == null:
		return
	_collect_spawners(root)
	for spawner in _spawners:
		if not spawner.spawner_error.is_connected(_on_spawner_error):
			spawner.spawner_error.connect(_on_spawner_error)
		if spawner.has_signal("spawning_finished"):
			var cb := Callable(self, "_on_spawning_finished").bind(spawner)
			if not spawner.spawning_finished.is_connected(cb):
				spawner.spawning_finished.connect(cb)

func _collect_spawners(node: Node) -> void:
	if node is BoxSpawner:
		_spawners.append(node as BoxSpawner)
	for child in node.get_children():
		if child is Node:
			_collect_spawners(child)

func _get_station_root() -> Node:
	if station_root_path != NodePath():
		var station_root := get_node_or_null(station_root_path)
		if station_root != null:
			return station_root
	return get_tree().current_scene

func _on_box_destroyed(data: Dictionary) -> void:
	if _run_active:
		_live_destroyed_total += 1
		var destroyer_id := str(data.get("destroyer_id", "")).strip_edges()
		if destroyer_id != "":
			_live_destroyer_counts[destroyer_id] = int(_live_destroyer_counts.get(destroyer_id, 0)) + 1
		mission_evaluator.record_event("box_destroyed", data)
		_refresh_mission_checklist()
		_try_finalize_live_mission()

func _on_sensor_updated(data: Dictionary) -> void:
	if _run_active:
		var sensor_type := str(data.get("type", "")).strip_edges().to_lower()
		if sensor_type != "":
			_live_sensor_counts[sensor_type] = int(_live_sensor_counts.get(sensor_type, 0)) + 1
		mission_evaluator.record_event("sensor_updated", data)
		_refresh_mission_checklist()
		_try_finalize_live_mission()

func _on_action_finished(action_name: String) -> void:
	if _run_active:
		var action_key := _normalize_runtime_action(action_name)
		if action_key != "":
			_live_action_done_counts[action_key] = int(_live_action_done_counts.get(action_key, 0)) + 1
		mission_evaluator.record_event("action_finished", {"action": action_name})
		_refresh_mission_checklist()
		_try_finalize_live_mission()

func _on_spawner_error(message: String) -> void:
	_print_error("Bottleneck: " + message)
	if _run_active and mission_level_id == "level_5":
		_run_active = false
		_finalize_mission()

func _on_spawning_finished(total_spawned: int, spawner: BoxSpawner) -> void:
	var id := spawner.get_instance_id()
	_spawner_finish_state[id] = true
	_spawner_spawn_totals[id] = int(total_spawned)
	if _all_spawners_finished():
		_expected_total_boxes = _compute_expected_total_boxes()
		mission_evaluator.record_event("run_meta", {"expected_total_boxes": _expected_total_boxes})
	_try_finalize_live_mission()

func _try_finalize_live_mission() -> void:
	# Level 5 typically uses an infinite loop, so execution may never "finish".
	# For this project flow, report mission only after random generation is done
	# and all generated boxes have reached destroyers.
	if not _run_active:
		return
	if _mission_reported_early:
		return
	if mission_level_id == "level_6" or mission_level_id == "level_7" or mission_level_id == "level_8":
		var live := mission_evaluator.get_live_feedback()
		if not bool(live.get("available", false)):
			return
		if not bool(live.get("terminal", false)):
			return
		_mission_reported_early = true
		_run_active = false
		var live_result := mission_evaluator.finish_run()
		_print_mission_result(live_result)
		return

	if mission_level_id != "level_5":
		return
	if not _can_finalize_after_random_done():
		return

	_mission_reported_early = true
	_run_active = false

	var result := mission_evaluator.finish_run()
	_print_mission_result(result)

func _reset_spawner_finish_state() -> void:
	_spawner_finish_state.clear()
	_spawner_spawn_totals.clear()
	for spawner in _spawners:
		var id := spawner.get_instance_id()
		_spawner_finish_state[id] = false
		_spawner_spawn_totals[id] = 0

func _compute_expected_total_boxes() -> int:
	var total := 0
	for spawner in _spawners:
		total += int(_spawner_spawn_totals.get(spawner.get_instance_id(), 0))
	return total

func _get_total_destroyed_count() -> int:
	var total := 0
	for destroyer in _destroyers:
		total += destroyer.get_destroyed_count()
	return total

func _all_spawners_finished() -> bool:
	if _spawners.is_empty():
		return false
	for spawner in _spawners:
		if not bool(_spawner_finish_state.get(spawner.get_instance_id(), false)):
			return false
	return true

func _can_finalize_after_random_done() -> bool:
	if not _all_spawners_finished():
		return false
	return _get_total_destroyed_count() >= _expected_total_boxes

func _apply_debug_console_theme() -> void:
	if debug_log == null:
		return
	debug_log.bbcode_enabled = true
	debug_log.add_theme_color_override("default_color", Color8(212, 212, 212))
	if feedback_status_label != null:
		feedback_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if feedback_detail_label != null:
		feedback_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _apply_playground_panel_theme() -> void:
	if playground_box == null:
		return
	playground_box.add_theme_constant_override("separation", 20)

	if playground_title_label != null:
		playground_title_label.text = "MINI-C EDITOR"
		playground_title_label.add_theme_color_override("font_color", Color8(244, 248, 255))
		playground_title_label.add_theme_font_size_override("font_size", 13)
		playground_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if playground_subtitle_label != null:
		playground_subtitle_label.text = "Station Control Workspace"
		playground_subtitle_label.add_theme_color_override("font_color", Color8(154, 176, 210))
		playground_subtitle_label.add_theme_font_size_override("font_size", 10)

	var header_row := playground_title_label.get_parent() as HBoxContainer
	if header_row != null:
		header_row.alignment = BoxContainer.ALIGNMENT_BEGIN
		header_row.add_theme_constant_override("separation", 8)

	if code_editor != null:
		code_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		code_editor.size_flags_vertical = Control.SIZE_FILL
		_set_code_editor_font_size(_code_editor_font_size)
		code_editor.add_theme_color_override("background_color", Color8(11, 15, 23))
		code_editor.add_theme_color_override("current_line_color", Color8(27, 39, 58))
		code_editor.add_theme_stylebox_override("normal", _make_ui_style(Color8(11, 15, 23), 18, Color8(72, 105, 154), 2))
		code_editor.add_theme_stylebox_override("focus", _make_ui_style(Color8(15, 22, 33), 18, Color8(246, 169, 49), 2))

	if zoom_controls != null:
		zoom_controls.alignment = BoxContainer.ALIGNMENT_END
		zoom_controls.add_theme_constant_override("separation", 3)
	if zoom_label != null:
		zoom_label.add_theme_color_override("font_color", Color8(185, 209, 246))
		zoom_label.add_theme_font_size_override("font_size", 9)
	if zoom_out_button != null:
		_style_zoom_button(zoom_out_button)
	if zoom_in_button != null:
		_style_zoom_button(zoom_in_button)
	if panel_expand_button != null:
		panel_expand_button.add_theme_color_override("font_color", Color8(236, 243, 255))
		panel_expand_button.add_theme_font_size_override("font_size", 9)
		panel_expand_button.add_theme_stylebox_override("normal", _make_ui_style(Color8(47, 62, 89), 10, Color8(98, 127, 177), 2))
		panel_expand_button.add_theme_stylebox_override("hover", _make_ui_style(Color8(62, 81, 114), 10, Color8(129, 162, 218), 2))
		panel_expand_button.add_theme_stylebox_override("pressed", _make_ui_style(Color8(34, 48, 70), 10, Color8(246, 169, 49), 2))

	if station_shell != null:
		station_shell.add_theme_stylebox_override("panel", _make_ui_style(Color(0.08, 0.11, 0.18, 0.96), 22, Color8(74, 104, 153), 2))
	if station_tabs_scroll != null:
		station_tabs_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	if station_context_label != null:
		station_context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if station_role_label != null:
		station_role_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if station_signal_label != null:
		station_signal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if station_code_hint_label != null:
		station_code_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if run_button != null:
		var run_bar := run_button.get_parent() as BoxContainer
		if run_bar != null:
			run_bar.alignment = BoxContainer.ALIGNMENT_BEGIN
			run_bar.add_theme_constant_override("separation", 16)
		run_button.text = "RUN"
		run_button.add_theme_color_override("font_color", Color8(255, 255, 255))
		run_button.add_theme_font_size_override("font_size", 14)
		run_button.add_theme_stylebox_override("normal", _make_ui_style(Color8(24, 170, 102), 14, Color8(10, 92, 57), 2))
		run_button.add_theme_stylebox_override("hover", _make_ui_style(Color8(36, 204, 124), 14, Color8(10, 92, 57), 2))
		run_button.add_theme_stylebox_override("pressed", _make_ui_style(Color8(17, 129, 78), 14, Color8(10, 92, 57), 2))

	if reset_button != null:
		reset_button.text = "RESET"
		reset_button.add_theme_color_override("font_color", Color8(232, 238, 250))
		reset_button.add_theme_font_size_override("font_size", 13)
		reset_button.add_theme_stylebox_override("normal", _make_ui_style(Color8(60, 69, 86), 14, Color8(102, 114, 139), 2))
		reset_button.add_theme_stylebox_override("hover", _make_ui_style(Color8(78, 88, 108), 14, Color8(132, 149, 180), 2))
		reset_button.add_theme_stylebox_override("pressed", _make_ui_style(Color8(45, 54, 69), 14, Color8(246, 169, 49), 2))

	if summit_button != null:
		summit_button.text = "SUBMIT"
		summit_button.add_theme_color_override("font_color", Color8(255, 255, 255))
		summit_button.add_theme_font_size_override("font_size", 14)
		summit_button.add_theme_stylebox_override("normal", _make_ui_style(Color8(72, 96, 210), 14, Color8(36, 49, 108), 2))
		summit_button.add_theme_stylebox_override("hover", _make_ui_style(Color8(95, 124, 238), 14, Color8(36, 49, 108), 2))
		summit_button.add_theme_stylebox_override("pressed", _make_ui_style(Color8(50, 72, 158), 14, Color8(36, 49, 108), 2))

	if output != null:
		output.visible = false

	if debug_console_panel != null:
		debug_console_panel.add_theme_stylebox_override("panel", _make_ui_style(Color(0.05, 0.07, 0.11, 0.96), 24, Color8(83, 103, 136), 2))

	if debug_console_title != null:
		debug_console_title.text = "MISSION STATUS"
		debug_console_title.add_theme_color_override("font_color", Color8(255, 199, 87))
		debug_console_title.add_theme_font_size_override("font_size", 14)

	for button in [mission_tab_button, output_tab_button, errors_tab_button, hints_tab_button]:
		if button != null:
			button.add_theme_font_size_override("font_size", 10)

	if feedback_panel != null:
		feedback_panel.add_theme_stylebox_override("panel", _make_ui_style(Color(0.10, 0.14, 0.23, 0.97), 18, Color8(76, 115, 176), 1))
	if progress_stars_label != null:
		progress_stars_label.visible = false
	if feedback_detail_label != null:
		feedback_detail_label.visible = true

	if debug_log != null:
		debug_log.add_theme_font_size_override("normal_font_size", 15)

	_apply_playground_layout()

	_refresh_playground_bounds()

func _refresh_playground_bounds() -> void:
	call_deferred("_apply_playground_bounds")

func _apply_playground_bounds() -> void:
	if playground_box == null:
		return
	if not is_inside_tree():
		return

	await get_tree().process_frame
	_ensure_playground_backdrop()

func _measure_playground_content_rect() -> Rect2:
	var content_rect := Rect2()
	var has_content := false

	if playground_box == null:
		return content_rect

	for child in playground_box.get_children():
		if not (child is Control):
			continue
		var control := child as Control
		if not control.visible:
			continue

		var child_pos := control.position
		var child_size := control.size.ceil()
		if child_size.x <= 0.0 or child_size.y <= 0.0:
			child_size = control.get_combined_minimum_size().ceil()
		var child_rect := Rect2(child_pos, child_size)
		if not has_content:
			content_rect = child_rect
			has_content = true
		else:
			content_rect = content_rect.merge(child_rect)

	if has_content:
		content_rect.position = Vector2.ZERO

	return content_rect

func _measure_playground_content_size() -> Vector2:
	if playground_box == null:
		return Vector2(288, 390)

	var separation := float(playground_box.get_theme_constant("separation"))
	var total_height := 0.0
	var max_width := 0.0
	var visible_count := 0

	for child in playground_box.get_children():
		if not (child is Control):
			continue
		var control := child as Control
		if not control.visible:
			continue

		var child_size: Vector2 = control.get_combined_minimum_size().ceil()
		max_width = maxf(max_width, child_size.x)
		total_height += child_size.y
		visible_count += 1

	if visible_count > 1:
		total_height += separation * float(visible_count - 1)

	return Vector2(max_width, total_height)

func _ensure_playground_backdrop() -> void:
	var backdrop := get_node_or_null("PlaygroundBackdrop")
	if backdrop != null:
		backdrop.queue_free()

func _capture_editor_ui_sizes() -> void:
	if playground_box != null:
		_editor_playground_box_size = playground_box.size
		_editor_playground_box_min_size = playground_box.custom_minimum_size
	_editor_root_global_position = global_position
	_editor_root_size = size
	_editor_root_min_size = custom_minimum_size

func _configure_playground_overlay() -> void:
	if _is_embedded_split_layout():
		top_level = false
		z_as_relative = true
		z_index = 0
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		if editor_width > 0:
			custom_minimum_size.x = float(editor_width)
		return
	z_as_relative = false
	z_index = PLAYGROUND_OVERLAY_Z_INDEX

func _get_playground_backdrop_size() -> Vector2:
	var base_size := Vector2.ZERO
	var content_rect := _measure_playground_content_rect()
	if content_rect.size.x > 0.0 and content_rect.size.y > 0.0:
		base_size = content_rect.size
	if playground_box != null:
		if base_size.x <= 0.0 or base_size.y <= 0.0:
			base_size = playground_box.size
		if base_size.x <= 0.0 or base_size.y <= 0.0:
			base_size = playground_box.custom_minimum_size
	if base_size.x <= 0.0 or base_size.y <= 0.0:
		base_size = _editor_playground_box_size
	if base_size.x <= 0.0 or base_size.y <= 0.0:
		base_size = _editor_playground_box_min_size
	if base_size.x <= 0.0 or base_size.y <= 0.0:
		base_size = Vector2(260, 434)
	return base_size

func _apply_playground_layout() -> void:
	if _is_embedded_split_layout():
		if playground_box != null:
			playground_box.custom_minimum_size = Vector2.ZERO
			playground_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			playground_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if code_editor != null:
			code_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if debug_console_panel != null:
			debug_console_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if run_button != null:
			run_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if reset_button != null:
			reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if summit_button != null:
			summit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if panel_expand_button != null:
			panel_expand_button.visible = false
		if playground_subtitle_label != null:
			playground_subtitle_label.text = "Programming Workspace"
		_refresh_station_selector_ui()
		_refresh_playground_bounds()
		return

	if run_button != null:
		run_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if reset_button != null:
		reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if summit_button != null:
		summit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if panel_expand_button != null:
		panel_expand_button.visible = true
		panel_expand_button.text = "COMPACT" if _is_playground_expanded else "EXPAND"

	_refresh_station_selector_ui()
	_refresh_playground_bounds()

func _is_embedded_split_layout() -> bool:
	return has_meta("embedded_split_layout") and bool(get_meta("embedded_split_layout"))

func _configure_code_editor_features() -> void:
	if code_editor == null:
		return
	if _has_object_property(code_editor, "gutters_draw_line_numbers"):
		code_editor.set("gutters_draw_line_numbers", true)
	if _has_object_property(code_editor, "highlight_current_line"):
		code_editor.set("highlight_current_line", true)
	if _has_object_property(code_editor, "draw_control_chars"):
		code_editor.set("draw_control_chars", false)

func _has_object_property(target: Object, property_name: String) -> bool:
	for property_info in target.get_property_list():
		if str(property_info.get("name", "")) == property_name:
			return true
	return false

func _apply_vscode_dark_theme() -> void:
	# VS Code Dark+ inspired editor colors.
	# This only affects the playground TextEdit, not the whole Godot editor theme.
	code_editor.add_theme_color_override("background_color", Color8(30, 30, 30))
	code_editor.add_theme_color_override("font_color", Color8(212, 212, 212))
	code_editor.add_theme_color_override("font_readonly_color", Color8(212, 212, 212))
	code_editor.add_theme_color_override("caret_color", Color8(174, 175, 173))
	code_editor.add_theme_color_override("selection_color", Color8(38, 79, 120))
	code_editor.add_theme_color_override("current_line_color", Color8(42, 45, 46))
	code_editor.add_theme_color_override("line_number_color", Color8(133, 133, 133))
	code_editor.add_theme_color_override("line_number_color_selected", Color8(198, 198, 198))

func _set_code_editor_font_size(font_size: int) -> void:
	_code_editor_font_size = clampi(font_size, CODE_FONT_SIZE_MIN, CODE_FONT_SIZE_MAX)
	if code_editor == null:
		return
	code_editor.add_theme_font_size_override("font_size", _code_editor_font_size)
	if zoom_label != null:
		var percent := int(round(float(_code_editor_font_size) / float(CODE_FONT_SIZE_DEFAULT) * 100.0))
		zoom_label.text = "%d%%" % percent

func _zoom_code_editor(delta: int) -> void:
	_set_code_editor_font_size(_code_editor_font_size + delta)

func _style_zoom_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(28, 28)
	button.add_theme_color_override("font_color", Color8(235, 241, 255))
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", _make_ui_style(Color8(31, 43, 62), 10, Color8(77, 102, 141), 2))
	button.add_theme_stylebox_override("hover", _make_ui_style(Color8(45, 61, 86), 10, Color8(106, 139, 189), 2))
	button.add_theme_stylebox_override("pressed", _make_ui_style(Color8(22, 32, 48), 10, Color8(246, 169, 49), 2))

func _make_ui_style(bg: Color, radius: int, border: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_color = Color(0, 0, 0, 0.24)
	style.shadow_size = 10
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style

func _refresh_syntax_highlighting() -> void:
	# TextEdit uses a SyntaxHighlighter resource. We rebuild it on text changes so
	# we can color identifiers declared with var/FUNC/CALL dynamically.
	var hl := CodeHighlighter.new()

	# Comments (Mini-C uses '# ...' lines).
	if hl.has_method("add_color_region"):
		hl.add_color_region("#", "", COLOR_COMMENT, true)
		# Strings (best-effort; doesn't handle escapes perfectly, but good enough).
		hl.add_color_region("\"", "\"", COLOR_STRING, false)
		hl.add_color_region("'", "'", COLOR_STRING, false)

	# Optional built-in token colors (numbers/symbols) when supported by CodeHighlighter.
	_set_hl_prop(hl, "number_color", COLOR_NUMBER)
	_set_hl_prop(hl, "symbol_color", Color8(212, 212, 212))
	_set_hl_prop(hl, "function_color", COLOR_FUNC)

	# Action opcodes.
	var actions := [
		"START",
		"STOP",
		"PICK",
		"DROP",
		"ROTATE",
		"SET",
		"SPAWNER",
		"CONVEYOR",
		"ARM",
		"BOX",
		"DIVERTER",
		"LEFT",
		"RIGHT",
		"OPEN"
	]
	for k in actions:
		_add_keyword_variants(hl, k, COLOR_CMD)

	# Flow / control / wait keywords (group requested: wait/while/repeat).
	var flow := [
		"WAIT", "UNTIL", "ACTION", "DONE",
		"WHILE", "REPEAT",
		"IF", "ELSE", "BREAK",
		"TRUE", "FALSE",
		"HAS", "VALUE", "NOT", "DETECTED",
		"HAS_VALUE", "NOT_DETECTED",
		"FUNC", "CALL", "VAR",
		"INT", "FLOAT"
	]
	for k in flow:
		_add_keyword_variants(hl, k, COLOR_FLOW)

	# Extract variable and function identifiers from the current buffer.
	# Use case-insensitive patterns so highlight stays in sync with the parser.
	var vars := _extract_declared_names("(?i)^\\s*var\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*=")
	var funcs := _extract_declared_names("(?i)^\\s*func\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*\\{")
	funcs.append_array(_extract_declared_names("(?i)^\\s*call\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*;?"))

	for var_name in vars:
		if hl.has_method("add_keyword_color"):
			hl.add_keyword_color(var_name, COLOR_VAR)

	for func_name in funcs:
		if hl.has_method("add_keyword_color"):
			hl.add_keyword_color(func_name, COLOR_FUNC)

	# Apply.
	if code_editor.has_method("set_syntax_highlighter"):
		code_editor.set_syntax_highlighter(hl)
	else:
		code_editor.syntax_highlighter = hl


func _extract_declared_names(pattern: String) -> Array:
	var out: Array = []
	var re := RegEx.new()
	var err := re.compile(pattern)
	if err != OK:
		return out

	for line in code_editor.text.split("\n", false):
		var m := re.search(line)
		if m == null:
			continue
		var ident := str(m.get_string(1))
		if ident != "" and not out.has(ident):
			out.append(ident)
	return out


static func _set_hl_prop(hl: Object, prop: String, value) -> void:
	# CodeHighlighter has optional properties (number_color, symbol_color, etc).
	# Guard via the property list so we don't crash on older Godot builds.
	for p in hl.get_property_list():
		if p.has("name") and str(p["name"]) == prop:
			hl.set(prop, value)
			return

static func _add_keyword_variants(hl: Object, keyword: String, color: Color) -> void:
	if not hl.has_method("add_keyword_color"):
		return
	var added: Dictionary = {}
	var variants := [
		keyword,
		keyword.to_lower(),
		keyword.to_upper(),
	]
	for v in variants:
		if v == "" or added.has(v):
			continue
		hl.add_keyword_color(v, color)
		added[v] = true


func _on_code_editor_gui_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var e: InputEventKey = event
	if not e.pressed or e.echo:
		return

	# Handle Enter/Return.
	if e.keycode == KEY_ENTER or e.keycode == KEY_KP_ENTER:
		_handle_enter_auto_indent()
		accept_event()
		return

	# Handle "}" outdent.
	# If the caret is currently in the indentation region (only whitespace before it),
	# reduce one indent level before inserting the brace.
	if e.keycode == KEY_BRACERIGHT:
		_handle_right_brace_outdent()
		accept_event()
		return


func _handle_enter_auto_indent() -> void:
	var line := code_editor.get_caret_line()
	var col := code_editor.get_caret_column()
	var line_text := code_editor.get_line(line)

	# Use the text around the caret to decide indentation.
	# We support two "smart" behaviors:
	# 1) After "{": indent one level. If a "}" is immediately after the caret,
	#    also create a new outdented line for the closing brace.
	# 2) If the caret is right before a closing "}", keep indentation (so the
	#    closing brace line stays one level less than inner statements).
	var before := line_text.substr(0, col)
	var after := ""
	if col < line_text.length():
		after = line_text.substr(col)

	var base_indent := _leading_ws(line_text)
	var trimmed_before := before.strip_edges()
	var trimmed_after := after.strip_edges()

	if trimmed_before.ends_with("{"):
		var inner_indent := base_indent + INDENT
		if trimmed_after.begins_with("}"):
			# Create:
			#   {
			#       <caret>
			#   }
			code_editor.insert_text_at_caret("\n" + inner_indent + "\n" + base_indent)
			code_editor.set_caret_line(line + 1)
			code_editor.set_caret_column(inner_indent.length())
			return
		code_editor.insert_text_at_caret("\n" + inner_indent)
		return

	if trimmed_after.begins_with("}"):
		code_editor.insert_text_at_caret("\n" + base_indent)
		return

	code_editor.insert_text_at_caret("\n" + base_indent)

func _handle_right_brace_outdent() -> void:
	var line := code_editor.get_caret_line()
	var col := code_editor.get_caret_column()
	var line_text := code_editor.get_line(line)

	var before := line_text.substr(0, col)
	if before.strip_edges() == "":
		var leading := _leading_ws(line_text)
		var remove := 0
		if leading.ends_with(INDENT):
			remove = INDENT.length()
		elif leading.ends_with("\t"):
			remove = 1
		elif leading.ends_with(" "):
			# Remove up to 4 trailing spaces from the indentation.
			remove = min(INDENT.length(), leading.length())

		if remove > 0 and col >= remove:
			var new_leading := leading.substr(0, leading.length() - remove)
			var rest := line_text.substr(leading.length())
			code_editor.set_line(line, new_leading + rest)
			code_editor.set_caret_column(col - remove)

	code_editor.insert_text_at_caret("}")


static func _leading_ws(s: String) -> String:
	var out := ""
	for i in range(s.length()):
		var c := s[i]
		if c == " " or c == "\t":
			out += c
		else:
			break
	return out
