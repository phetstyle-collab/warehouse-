extends Node2D

# Tutorial Scene - ไม่มีการ evaluate mission
# เป็นพื้นที่ฝึกหัดอิสระ ให้เด็กลองพิมพ์โค้ดและกดรันดูผลลัพธ์โดยไม่มีเงื่อนไขผ่าน/ตก

func _ready() -> void:
	TooltipManager.setup($CanvasLayer/HoverNameLabel)
	call_deferred("_show_tutorial_welcome")

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _show_tutorial_welcome() -> void:
	# Tutorial mode: ไม่มี mission evaluation, ไม่มี fail state
	# เด็กสามารถรันโค้ดได้เสรี เพื่อสำรวจ syntax และดูผลลัพธ์
	pass
