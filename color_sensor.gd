extends Node2D
class_name ColorSensor

# =========================
# SIGNAL
# =========================
signal box_detected(data: Dictionary)

# =========================
# NODES
# =========================
@onready var display: Label = $DisplayRoot/Display
@onready var display_panel: Panel = $DisplayRoot/DisplayPanel
@onready var detect_area: Area2D = $DetectArea
@onready var anim: AnimatedSprite2D = $Anim   # ต้องมีโหนด Anim

# =========================
# CONFIG
# =========================
@export var target_color: String = "GREEN"  # สีที่ต้องการตรวจ
@export var normal_frame: int = 0           # เฟรมปกติ
@export var detected_frame: int = 1         # เฟรมตอนตรวจพบ
@export var detect_delay: float = 0.3       # เวลาหน่วงให้กล่องมาอยู่กลางเครื่อง

# =========================
# LIFECYCLE
# =========================
func _ready():
	_apply_display_theme()
	_clear_display()

	# เริ่มต้นเป็นเฟรมปกติ
	if anim:
		anim.stop()
		anim.frame = normal_frame

	detect_area.area_entered.connect(_on_area_entered)
	detect_area.area_exited.connect(_on_area_exited)

# =========================
# SIGNAL CALLBACKS
# =========================
func _on_area_entered(area: Area2D):
	var box := area.get_parent()
	if box is Box:
		_report_color(box)

func _on_area_exited(area: Area2D):
	var box := area.get_parent()
	if box is Box:
		_clear_display()

# =========================
# REPORT COLOR
# =========================
func _report_color(box: Box):
	var color_name := _color_to_name(box.box_color)

	# แสดงสีบนหน้าจอ
	display.text = "COLOR: " + color_name
	display.modulate = _get_readable_color(box.box_color)

	# รอให้กล่องอยู่กลางเครื่องก่อน
	await get_tree().create_timer(detect_delay).timeout

	# เปลี่ยนเฟรมครั้งเดียว (ไม่ loop)
	if color_name == target_color and anim:
		anim.stop()
		anim.frame = detected_frame

	# ส่งข้อมูลออกไปเหมือนเดิม
	var data := {
		"sensor": "ColorSensor",
		"box_id": box.box_id,
		"color": color_name
	}

	box_detected.emit(data)

# =========================
# CLEAR DISPLAY
# =========================
func _clear_display():
	display.text = "COLOR: ---"
	display.modulate = Color8(232, 240, 255)

func _apply_display_theme() -> void:
	if display_panel != null:
		display_panel.add_theme_stylebox_override("panel", _make_display_style(Color(0.02, 0.05, 0.08, 0.88), Color8(84, 193, 255)))
	if display != null:
		display.add_theme_font_size_override("font_size", 13)
		display.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
		display.add_theme_constant_override("outline_size", 3)
		display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _make_display_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	return style

func _get_readable_color(color: Color) -> Color:
	if color.is_equal_approx(Color.RED):
		return Color8(255, 90, 84)
	if color.is_equal_approx(Color.GREEN):
		return Color8(95, 235, 120)
	if color.is_equal_approx(Color.BLUE):
		return Color8(96, 170, 255)
	return Color8(232, 240, 255)

# =========================
# COLOR UTILITY
# =========================
func _color_to_name(color: Color) -> String:
	if color.is_equal_approx(Color.RED):
		return "RED"
	elif color.is_equal_approx(Color.GREEN):
		return "GREEN"
	elif color.is_equal_approx(Color.BLUE):
		return "BLUE"
	else:
		return "UNKNOWN"
