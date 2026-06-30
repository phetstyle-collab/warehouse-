extends Node

const SAVE_PATH := "user://longgradan_save.json"

var unlocked_level := 1
var level_scripts: Dictionary = {}
var level_hint_indices: Dictionary = {}

func _ready() -> void:
	load_progress()

func save_progress() -> void:
	var data := {
		"unlocked_level": unlocked_level,
		"level_scripts": level_scripts,
		"level_hint_indices": level_hint_indices,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_progress() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var content := file.get_as_text()
			var parse_result = JSON.parse_string(content)
			if parse_result is Dictionary:
				unlocked_level = int(parse_result.get("unlocked_level", 1))
				level_scripts = parse_result.get("level_scripts", {})
				level_hint_indices = parse_result.get("level_hint_indices", {})
			file.close()

func unlock_next_level(level: int) -> void:
	if level >= unlocked_level:
		unlocked_level = level + 1
		save_progress()

func save_level_script(level_id: String, source_code: String) -> void:
	level_scripts[level_id] = source_code
	save_progress()

func get_level_script(level_id: String) -> String:
	return str(level_scripts.get(level_id, ""))

func has_level_script(level_id: String) -> bool:
	return level_scripts.has(level_id)

func get_level_hint_index(level_id: String) -> int:
	return int(level_hint_indices.get(level_id, 0))

func consume_level_hint(level_id: String, hint_count: int) -> int:
	if hint_count <= 0:
		level_hint_indices[level_id] = 0
		save_progress()
		return 0

	var current_index := clampi(get_level_hint_index(level_id), 0, hint_count - 1)
	level_hint_indices[level_id] = min(current_index + 1, hint_count - 1)
	save_progress()
	return current_index

func set_level_hint_index(level_id: String, hint_index: int, hint_count: int) -> int:
	if hint_count <= 0:
		level_hint_indices[level_id] = 0
		save_progress()
		return 0

	var clamped_index := clampi(hint_index, 0, hint_count - 1)
	level_hint_indices[level_id] = clamped_index
	save_progress()
	return clamped_index

func reset_level_hint(level_id: String) -> void:
	level_hint_indices[level_id] = 0
	save_progress()
