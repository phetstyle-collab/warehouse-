extends ConveyorRight
class_name ConveyorRightAuto

func _ready() -> void:
	add_to_group("conveyor")
	_world_direction = Vector2.RIGHT.rotated(global_rotation).normalized()

	if belt_area == null:
		push_error("ConveyorRightAuto: missing BeltArea/beltarea node")
		return

	belt_area.area_entered.connect(_on_area_entered)
	belt_area.area_exited.connect(_on_area_exited)
	start()
