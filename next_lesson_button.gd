extends Button

func _pressed() -> void:
	var mission_level_id = ""
	var p = get_parent()
	while p != null:
		if "mission_level_id" in p:
			mission_level_id = p.mission_level_id
			break
		p = p.get_parent()

	var next_level = ""
	if mission_level_id == "tutorial_1" or mission_level_id == "level_1":
		next_level = "tutorial_2"
	elif mission_level_id == "tutorial_2":
		next_level = "tutorial_3"
	elif mission_level_id == "tutorial_3":
		next_level = "tutorial_select"
	else:
		next_level = "tutorial_2"

	if next_level != "":
		get_tree().call_deferred("change_scene_to_file", "res://" + next_level + ".tscn")
