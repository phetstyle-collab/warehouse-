extends Area2D
class_name BoxDestroyer

signal box_destroyed(data: Dictionary)

@export var delay_seconds: float = 1.3
@export var destroyer_id: String = ""

# Stores all destroyed box snapshots in destroy order.
var destroyed_boxes: Array[Dictionary] = []
var last_destroyed_box: Dictionary = {}

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var box := area.get_parent()
	if box is Box:
		_destroy_later(box, area)

func _destroy_later(box: Box, box_area: Area2D) -> void:
	var destroyer_key := str(get_instance_id())
	var pending_key := "destroy_pending_" + destroyer_key
	# Always update latest target so pass-through cases can retarget to downstream destroyer.
	box.set_meta("destroy_target_destroyer", destroyer_key)

	# Prevent duplicate timers from this same destroyer for the same box.
	if box.has_meta(pending_key):
		return
	box.set_meta(pending_key, true)

	# Snapshot before queue_free, so score/mission logic can read stable values.
	var snapshot := _build_box_snapshot(box)
	await get_tree().create_timer(delay_seconds).timeout
	if not is_instance_valid(box):
		return

	# Timer finished, clear this destroyer's pending marker.
	box.remove_meta(pending_key)

	# Destroy/count only if this destroyer is still the latest target.
	if str(box.get_meta("destroy_target_destroyer", "")) != destroyer_key:
		return
	# Additional guard: must still overlap this destroyer when timer completes.
	if not is_instance_valid(box_area) or not overlaps_area(box_area):
		return

	box.queue_free()

	destroyed_boxes.append(snapshot)
	last_destroyed_box = snapshot
	box_destroyed.emit(snapshot)

func clear_destroyed_history() -> void:
	destroyed_boxes.clear()
	last_destroyed_box.clear()

func get_destroyed_count() -> int:
	return destroyed_boxes.size()

func get_last_destroyed() -> Dictionary:
	return last_destroyed_box.duplicate(true)

func get_destroyed_history() -> Array[Dictionary]:
	return destroyed_boxes.duplicate(true)

func get_destroyed_colors() -> Array[String]:
	var out: Array[String] = []
	for item in destroyed_boxes:
		out.append(str(item.get("color_name", "UNKNOWN")))
	return out

func get_destroyed_weights() -> Array[float]:
	var out: Array[float] = []
	for item in destroyed_boxes:
		out.append(float(item.get("weight", 0.0)))
	return out

func _build_box_snapshot(box: Box) -> Dictionary:
	return {
		"destroyer_id": _resolve_destroyer_id(),
		"destroyer_path": str(get_path()),
		"timestamp_ms": Time.get_ticks_msec(),
		"box_id": box.box_id,
		"weight": box.weight_kg,
		"color_name": _color_to_name(box.box_color),
		"color": box.box_color,
		"on_conveyor": box.on_conveyor,
		"held_by_robot": box.held_by_robot,
	}

func _resolve_destroyer_id() -> String:
	if destroyer_id != "":
		return destroyer_id
	# Prefer instance parent name (e.g. destroyer2, destroyer3) so each instance
	# is distinguishable in mission analytics.
	if get_parent() != null:
		return str(get_parent().name)
	return name

func _color_to_name(color: Color) -> String:
	if color == Color.RED:
		return "RED"
	if color == Color.GREEN:
		return "GREEN"
	if color == Color.BLUE:
		return "BLUE"
	return "UNKNOWN"
