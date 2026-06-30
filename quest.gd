extends CanvasLayer

@onready var guide_window = get_node_or_null("GuideWindow")
@onready var quest_button  = get_node_or_null("QuestButton")
@onready var close_button = get_node_or_null("GuideWindow/CloseButton")

var _tween: Tween

func _ready():
	print("✅ UIController READY RUNNING")

	print("guide_window =", guide_window)
	print("quest_button  =", quest_button)
	print("close_button =", close_button)

	if guide_window == null:
		push_error("❌ หา GuideWindow ไม่เจอ: ตรวจชื่อ/ตำแหน่งใน Scene Tree ให้ตรงกับ get_node_or_null()")
		return
	if quest_button == null:
		push_error("❌ หา HelpButton ไม่เจอ: ตรวจชื่อ/ตำแหน่งใน Scene Tree ให้ตรงกับ get_node_or_null()")
		return
	if close_button == null:
		push_error("❌ หา CloseButton ไม่เจอ: ตรวจชื่อ/ตำแหน่งใน Scene Tree ให้ตรงกับ get_node_or_null()")
		return

	guide_window.visible = false
	guide_window.modulate.a = 1.0

	quest_button.pressed.connect(func():
		print("🟦 questButton pressed")
		open_guide()
	)

	close_button.pressed.connect(func():
		print("🟥 CloseButton pressed")
		close_guide()
	)

func open_guide():
	print("➡️ open_guide() called")
	_kill_tween()

	guide_window.visible = true
	guide_window.modulate.a = 0.0

	_tween = create_tween()
	_tween.tween_property(guide_window, "modulate:a", 1.0, 0.2)

func close_guide():
	print("⬅️ close_guide() called")
	_kill_tween()

	_tween = create_tween()
	_tween.tween_property(guide_window, "modulate:a", 0.0, 0.2)
	_tween.finished.connect(func():
		guide_window.visible = false
		guide_window.modulate.a = 1.0
	)

func _kill_tween():
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
