extends Area2D

@export var display_name := "destroyer"
@export var hover_priority := 10

var _box_destroyer: BoxDestroyer

func _ready() -> void:
	_box_destroyer = get_parent().get_node_or_null("BoxDestroyer") as BoxDestroyer
	if display_name == "destroyer" and get_parent() != null:
		display_name = str(get_parent().name)
	set_meta("hover_text", _build_hover_text())
	set_meta("hover_priority", hover_priority)
	add_to_group("hoverable")
	set_process(true)

func _process(_delta: float) -> void:
	set_meta("hover_text", _build_hover_text())

func _build_hover_text() -> String:
	if _box_destroyer == null:
		return display_name
	var total := _box_destroyer.get_destroyed_count()
	var weights := _box_destroyer.get_destroyed_weights()
	var ge5 := 0
	var lt5 := 0
	for w in weights:
		if float(w) >= 5.0:
			ge5 += 1
		else:
			lt5 += 1
	return "%s | total:%d | >=5:%d | <5:%d" % [display_name, total, ge5, lt5]
