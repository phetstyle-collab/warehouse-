extends RefCounted
class_name MissionEvaluator

# ==================================================
# LEVEL EXPECTATION CONFIG (EDIT THIS PER LEVEL)
# ==================================================
# This section is the mission rubric source of truth.
# Add/adjust level requirements here.
const LEVEL_RULES := {
	"level_1": {
		"display_name": "Level 1",
		# Required executed actions: action -> minimum count
		# Level 1 expectation requested:
		# - START_SPAWNER at least 1 time
		# - START_CONVEYOR at least 1 time
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
		},
		# Optional: destroyer hits (destroyer_id -> minimum count)
		"required_destroyers": {
		},
		# Optional: source structure hints (token text that must exist in source)
		"required_structure_tokens": [
		],
	},
	"level_2": {
		"display_name": "Level 2",
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
		},
		"required_destroyers": {
		},
		"required_structure_tokens": [
			"start(spawner)",
			["start(conveyor)", "start(conveyor, 1)"],
			"stop(spawner)",
			["stop(conveyor)", "stop(conveyor, 1)"],
		],
		# Reaction checks: when sensor event occurs, expected action must happen after it.
		"required_reactions": [
			{
				"sensor_type": "weight",
				"action": "STOP_SPAWNER",
				"min_matches": 1,
			},
			{
				"sensor_type": "weight",
				"action": "STOP_CONVEYOR",
				"min_matches": 1,
			}
		],
	},
	"level_3": {
		"display_name": "Level 3",
		"required_actions": {
			"ROTATE_ARM": 2,
		},
		"required_destroyers": {
		},
		"required_structure_tokens": [
			["wait until action_done", "wait until action done"],
		],
		# Require an ACTION_DONE event before the second rotate.
		"required_action_done_reactions": [
			{
				"action": "ROTATE_ARM",
				"min_matches": 1,
			}
		],
	},
	"level_4": {
		"display_name": "Level 4",
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
			"STOP_SPAWNER": 1,
			"STOP_CONVEYOR": 1,
			"ROTATE_ARM": 2,
			"PICK_BOX": 1,
			"DROP_BOX": 1,
		},
		"required_destroyers": {
		},
		"required_structure_tokens": [
			["wait until weight has_value", "wait until weight has value", "wait until weight(has_value)", "wait until weight has(value)"],
			["wait until action_done", "wait until action done", "wait until action(done)"],
		],
		"required_reactions": [
			{
				"sensor_type": "weight",
				"action": "STOP_SPAWNER",
				"min_matches": 1,
			},
			{
				"sensor_type": "weight",
				"action": "STOP_CONVEYOR",
				"min_matches": 1,
			},
		],
		"required_action_done_reactions": [
			{
				"action": "PICK_BOX",
				"min_matches": 1,
			},
			{
				"action": "DROP_BOX",
				"min_matches": 1,
			},
		],
	},
	"level_5": {
		"display_name": "Level 5",
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
			"STOP_SPAWNER": 1,
			"STOP_CONVEYOR": 1,
			"ROTATE_ARM": 3,
			"PICK_BOX": 1,
			"DROP_BOX": 1,
		},
		"required_destroyers": {
		},
		# Destroyer-based grading (from BoxDestroyer snapshots):
		# - destroyer2 should receive heavy boxes (>= 5)
		"destroyer_weight_rules": [
			{
				"destroyer_id": "destroyer2",
				"operator": ">=",
				"weight": 5.0,
				"min_hits": 0,
				"require_all": true,
			},
		],
		# Mission: loop forever, detect weight > 5, then pick/drop with arm sequencing.
		"required_structure_tokens": [
			["while true", "while(true)"],
			["wait until weight", "wait until weight has_value", "wait until weight has value"],
			["weight > 5", "weight>5"],
			["if(weight > 5)", "if (weight > 5)", "if(weight>5)"],
			["else"],
			["rotate(arm(270))", "rotate arm 270", "rotate(arm(180))", "rotate arm 180"],
		],
		"required_reactions": [
			{
				"sensor_type": "weight",
				"action": "STOP_SPAWNER",
				"min_matches": 1,
			},
			{
				"sensor_type": "weight",
				"action": "STOP_CONVEYOR",
				"min_matches": 1,
			},
			{
				"sensor_type": "weight",
				"action": "PICK_BOX",
				"min_matches": 1,
			},
		],
		"required_action_done_reactions": [
			{
				"action": "PICK_BOX",
				"min_matches": 1,
			},
			{
				"action": "DROP_BOX",
				"min_matches": 1,
			},
		],
		# Enforce the full execution order for one valid cycle.
		"require_strict_sequence": true,
	},
	"level_6": {
		"display_name": "Level 6",
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
		},
		"required_destroyers": {
		},
		# Mission:
		# "ตรวจน้ำหนัก ถ้ามากกว่า 5 ให้หยิบไปวางถัง 2"
		"required_structure_tokens": [
			["if(weight > 5)", "if (weight > 5)", "if(weight>5)"],
		],
		"destroyer_weight_rules": [
			{
				"destroyer_id": "destroyer2",
				"operator": ">",
				"weight": 5.0,
				"min_hits": 1,
				"require_all": true,
			},
		],
	},
	"level_7": {
		"display_name": "Level 7",
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
		},
		"required_destroyers": {
		},
		# Mission:
		# - if weight > 5 -> route to destroyer2
		# - else -> route to destroyer3
		"required_structure_tokens": [
			["if(weight > 5)", "if (weight > 5)", "if(weight>5)"],
			["else"],
		],
		"destroyer_weight_rules": [
			{
				"destroyer_id": "destroyer2",
				"operator": ">",
				"weight": 5.0,
				"min_hits": 1,
				"require_all": true,
			},
			{
				"destroyer_id": "destroyer3",
				"operator": "<=",
				"weight": 5.0,
				"min_hits": 1,
				"require_all": true,
			},
		],
		# For scoring in this level, passing either routing branch is acceptable.
		# (heavy -> destroyer2) OR (non-heavy -> destroyer3)
		"destroyer_weight_rules_mode": "any",
	},
	"level_8": {
		"display_name": "Level 8",
		"required_actions": {
			"START_SPAWNER": 1,
			"START_CONVEYOR": 1,
		},
		"required_destroyers": {
		},
		# Mission:
		# - Sort exactly 5 boxes by weight.
		# - weight > 5 goes to destroyer2
		# - weight <= 5 goes to destroyer3
		"required_structure_tokens": [
			["if(weight > 5)", "if (weight > 5)", "if(weight>5)"],
			["else"],
		],
		"destroyer_weight_rules": [
			{
				"destroyer_id": "destroyer2",
				"operator": ">",
				"weight": 5.0,
				"min_hits": 1,
				"require_all": true,
			},
			{
				"destroyer_id": "destroyer3",
				"operator": "<=",
				"weight": 5.0,
				"min_hits": 1,
				"require_all": true,
			},
		],
		"required_destroyer_total": {
			"destroyers": ["destroyer2", "destroyer3"],
			"total": 5,
		},
	}
}

# ==================================================
# RUN STATE
# ==================================================
var _level_id: String = "level_1"
var _source_code: String = ""
var _parser_errors: Array[String] = []

var _action_counts: Dictionary = {}
var _destroyer_counts: Dictionary = {}
var _destroyed_boxes: Array[Dictionary] = []
var _sensor_events: Array[Dictionary] = []
var _event_timeline: Array[Dictionary] = []
var _action_done_events: Array[String] = []
var _expected_total_boxes: int = -1
var _level5_live_failed: bool = false
var _level5_live_fail_reason: String = ""
var _level5_live_passed: bool = false
var _level6_live_passed: bool = false
var _level7_live_passed: bool = false
var _level8_live_passed: bool = false

# ==================================================
# LIFECYCLE
# ==================================================
func start_run(level_id: String, source_code: String, parser_errors: Array = []) -> void:
	_level_id = level_id
	_source_code = source_code
	_parser_errors.clear()
	for e in parser_errors:
		_parser_errors.append(str(e))

	_action_counts.clear()
	_destroyer_counts.clear()
	_destroyed_boxes.clear()
	_sensor_events.clear()
	_event_timeline.clear()
	_action_done_events.clear()
	_expected_total_boxes = -1
	_level5_live_failed = false
	_level5_live_fail_reason = ""
	_level5_live_passed = false
	_level6_live_passed = false
	_level7_live_passed = false
	_level8_live_passed = false

func record_event(event_type: String, data: Dictionary = {}) -> void:
	match event_type:
		"action_executed":
			record_action(str(data.get("action", "")))
		"box_destroyed":
			record_box_destroyed(data)
		"sensor_updated":
			record_sensor_updated(data)
		"action_finished":
			record_action_finished(str(data.get("action", "")))
		"run_meta":
			record_run_meta(data)
		_:
			# Keep skeleton open for future event types.
			pass
	_update_live_state()

func record_action(action: String) -> void:
	var raw := str(action).strip_edges().to_upper()
	var key := _normalize_action(raw)
	if key == "":
		return
	_action_counts[key] = int(_action_counts.get(key, 0)) + 1
	_event_timeline.append({
		"type": "action",
		"action": key,
		"raw_action": raw,
		"angle": _extract_rotate_angle(raw),
	})

func record_box_destroyed(data: Dictionary) -> void:
	_destroyed_boxes.append(data.duplicate(true))

	var destroyer_id := str(data.get("destroyer_id", "")).strip_edges()
	if destroyer_id == "":
		return
	_destroyer_counts[destroyer_id] = int(_destroyer_counts.get(destroyer_id, 0)) + 1

func record_sensor_updated(data: Dictionary) -> void:
	var sensor_type := str(data.get("type", "")).strip_edges().to_lower()
	if sensor_type == "":
		return
	var event := {
		"type": sensor_type,
		"value": data.get("value", null),
		"box_id": data.get("box_id", -1),
	}
	_sensor_events.append(event)
	_event_timeline.append({
		"type": "sensor",
		"sensor_type": sensor_type,
		"sensor_value": data.get("value", null),
	})

func record_action_finished(action_name: String) -> void:
	var key := _normalize_action(action_name)
	if key == "":
		return
	_action_done_events.append(key)
	_event_timeline.append({
		"type": "action_done",
		"action": key,
	})

func record_run_meta(data: Dictionary) -> void:
	if data.has("expected_total_boxes"):
		_expected_total_boxes = int(data.get("expected_total_boxes", -1))

func finish_run() -> Dictionary:
	var level_rule := _get_level_rule(_level_id)
	var reasons: Array[String] = []

	if _parser_errors.size() > 0:
		for e in _parser_errors:
			reasons.append("Syntax: " + e)

	var checks_total := 0
	var checks_passed := 0

	# Structure checks from source text.
	var required_tokens: Array = level_rule.get("required_structure_tokens", [])
	for token_variant in required_tokens:
		checks_total += 1
		if _source_matches_structure_token(token_variant):
			checks_passed += 1
		else:
			reasons.append("Missing structure token: " + _format_structure_token(token_variant))

	# Required actions.
	var required_actions: Dictionary = level_rule.get("required_actions", {})
	for action in required_actions.keys():
		var needed := int(required_actions[action])
		var actual := int(_action_counts.get(action, 0))
		checks_total += 1
		if actual >= needed:
			checks_passed += 1
		else:
			reasons.append("Action '%s' requires %d, actual %d" % [action, needed, actual])

	# Required destroyer hits.
	var required_destroyers: Dictionary = level_rule.get("required_destroyers", {})
	for destroyer_id in required_destroyers.keys():
		var needed_hits := int(required_destroyers[destroyer_id])
		var actual_hits := int(_destroyer_counts.get(destroyer_id, 0))
		checks_total += 1
		if actual_hits >= needed_hits:
			checks_passed += 1
		else:
			reasons.append("Destroyer '%s' requires %d, actual %d" % [destroyer_id, needed_hits, actual_hits])

	# Total destroyed must match total generated (if provided by run metadata).
	if _expected_total_boxes >= 0:
		checks_total += 1
		var total_destroyed := _destroyed_boxes.size()
		if total_destroyed == _expected_total_boxes:
			checks_passed += 1
		else:
			reasons.append(
				"Total destroyed boxes must equal generated boxes: expected %d, actual %d"
				% [_expected_total_boxes, total_destroyed]
			)

	# Sensor -> action reaction checks.
	var required_reactions: Array = level_rule.get("required_reactions", [])
	for reaction_variant in required_reactions:
		var reaction: Dictionary = reaction_variant
		var sensor_type := str(reaction.get("sensor_type", "")).strip_edges().to_lower()
		var expected_action := _normalize_action(str(reaction.get("action", "")))
		var min_matches := int(reaction.get("min_matches", 1))
		checks_total += 1

		var matches := _count_reaction_matches(sensor_type, expected_action)
		if matches >= min_matches:
			checks_passed += 1
		else:
			reasons.append(
				"After sensor '%s', action '%s' requires %d, actual %d"
				% [sensor_type, expected_action, min_matches, matches]
			)

	# ACTION_DONE -> action checks.
	var required_action_done_reactions: Array = level_rule.get("required_action_done_reactions", [])
	for reaction_variant in required_action_done_reactions:
		var reaction: Dictionary = reaction_variant
		var expected_action := _normalize_action(str(reaction.get("action", "")))
		var min_matches := int(reaction.get("min_matches", 1))
		checks_total += 1
		var matches := _count_action_done_followed_by_action(expected_action)
		if matches >= min_matches:
			checks_passed += 1
		else:
			reasons.append(
				"After ACTION_DONE, action '%s' requires %d, actual %d"
				% [expected_action, min_matches, matches]
			)

	# Strict ordered-sequence checks (used by level 5).
	var require_strict_sequence := bool(level_rule.get("require_strict_sequence", false))
	if require_strict_sequence:
		checks_total += 1
		if _has_level_5_strict_sequence():
			checks_passed += 1
		else:
			reasons.append(
				"Sequence required: START -> weight>5 -> STOP -> ROTATE(-90) -> PICK -> ROTATE(180) -> DROP -> ROTATE(-90) -> START"
			)

	# Destroyer weight rules (used by level 5 routing objectives).
	var destroyer_weight_rules: Array = level_rule.get("destroyer_weight_rules", [])
	var destroyer_weight_rules_mode := str(level_rule.get("destroyer_weight_rules_mode", "all")).strip_edges().to_lower()
	if destroyer_weight_rules_mode == "any" and not destroyer_weight_rules.is_empty():
		checks_total += 1
		var any_pass := false
		var any_fail_reasons: Array[String] = []
		for rule_variant in destroyer_weight_rules:
			var rule: Dictionary = rule_variant
			var destroyer_id := str(rule.get("destroyer_id", "")).strip_edges()
			var op := str(rule.get("operator", "")).strip_edges()
			var threshold := float(rule.get("weight", 0.0))
			var min_hits := int(rule.get("min_hits", 1))
			var require_all := bool(rule.get("require_all", false))
			if _passes_destroyer_weight_rule(destroyer_id, op, threshold, min_hits, require_all):
				any_pass = true
				break
			any_fail_reasons.append(_describe_destroyer_weight_rule_failure(destroyer_id, op, threshold, min_hits, require_all))
		if any_pass:
			checks_passed += 1
		else:
			reasons.append("At least one destroyer routing rule must pass (OR mode).")
			for r in any_fail_reasons:
				reasons.append(r)
	else:
		for rule_variant in destroyer_weight_rules:
			var rule: Dictionary = rule_variant
			var destroyer_id := str(rule.get("destroyer_id", "")).strip_edges()
			var op := str(rule.get("operator", "")).strip_edges()
			var threshold := float(rule.get("weight", 0.0))
			var min_hits := int(rule.get("min_hits", 1))
			var require_all := bool(rule.get("require_all", false))
			checks_total += 1
			if _passes_destroyer_weight_rule(destroyer_id, op, threshold, min_hits, require_all):
				checks_passed += 1
			else:
				reasons.append(_describe_destroyer_weight_rule_failure(destroyer_id, op, threshold, min_hits, require_all))

	# Exact total check across selected destroyers (optional per level).
	var required_destroyer_total_variant = level_rule.get("required_destroyer_total", null)
	if required_destroyer_total_variant is Dictionary:
		var required_destroyer_total: Dictionary = required_destroyer_total_variant
		var target_destroyers: Array = required_destroyer_total.get("destroyers", [])
		var expected_total := int(required_destroyer_total.get("total", -1))
		if expected_total >= 0 and not target_destroyers.is_empty():
			checks_total += 1
			var actual_total := _count_destroyed_in_destroyers(target_destroyers)
			if actual_total == expected_total:
				checks_passed += 1
			else:
				reasons.append(
					"Destroyers %s must contain exactly %d boxes in total; actual %d"
					% [str(target_destroyers), expected_total, actual_total]
				)

	if _level5_live_failed and _level5_live_fail_reason != "":
		reasons.append(_level5_live_fail_reason)

	var checks_ok := checks_passed == checks_total
	var is_ok := _parser_errors.is_empty() and checks_ok

	var score := 0
	if checks_total > 0:
		score = int(round((float(checks_passed) / float(checks_total)) * 100.0))
	if not _parser_errors.is_empty():
		score = min(score, 10)

	return {
		"level_id": _level_id,
		"display_name": str(level_rule.get("display_name", _level_id)),
		"is_passed": is_ok,
		"score": score,
		"checks_passed": checks_passed,
		"checks_total": checks_total,
		"reasons": reasons,
		"action_counts": _action_counts.duplicate(true),
		"destroyer_counts": _destroyer_counts.duplicate(true),
		"destroyed_boxes": _destroyed_boxes.duplicate(true),
		"sensor_events": _sensor_events.duplicate(true),
		"action_done_events": _action_done_events.duplicate(true),
	}

func get_live_feedback() -> Dictionary:
	_update_live_state()
	if _level_id == "level_6":
		if _level6_live_passed:
			return {
				"available": true,
				"terminal": true,
				"passed": true,
			}
		return {
			"available": true,
			"terminal": false,
		}
	if _level_id == "level_7":
		if _level7_live_passed:
			return {
				"available": true,
				"terminal": true,
				"passed": true,
			}
		return {
			"available": true,
			"terminal": false,
		}
	if _level_id == "level_8":
		if _level8_live_passed:
			return {
				"available": true,
				"terminal": true,
				"passed": true,
			}
		return {
			"available": true,
			"terminal": false,
		}
	if _level_id != "level_5":
		return {"available": false}
	if _level5_live_failed:
		return {
			"available": true,
			"terminal": true,
			"passed": false,
			"reason": _level5_live_fail_reason,
		}
	if _level5_live_passed:
		return {
			"available": true,
			"terminal": true,
			"passed": true,
		}
	return {
		"available": true,
		"terminal": false,
	}

func get_level_rule(level_id: String) -> Dictionary:
	return _get_level_rule(level_id).duplicate(true)

func _get_level_rule(level_id: String) -> Dictionary:
	if LEVEL_RULES.has(level_id):
		return LEVEL_RULES[level_id]
	return LEVEL_RULES["level_1"]

func _normalize_action(action: String) -> String:
	var trimmed := action.strip_edges().to_upper()
	if trimmed == "":
		return ""
	# Normalize to opcode only so parameterized actions like
	# "ROTATE_ARM 90" and "ROTATE_ARM -90" are scored as ROTATE_ARM.
	var parts := trimmed.split(" ", false)
	if parts.is_empty():
		return trimmed
	return str(parts[0])

func _count_reaction_matches(sensor_type: String, expected_action: String) -> int:
	if sensor_type == "" or expected_action == "":
		return 0
	var matches := 0
	var pending_sensor := 0
	for event in _event_timeline:
		var kind := str(event.get("type", ""))
		if kind == "sensor" and str(event.get("sensor_type", "")) == sensor_type:
			pending_sensor += 1
			continue
		if kind == "action" and str(event.get("action", "")) == expected_action and pending_sensor > 0:
			matches += 1
			pending_sensor -= 1
	return matches

func _count_action_done_followed_by_action(expected_action: String) -> int:
	if expected_action == "":
		return 0
	var matches := 0
	var pending_done := 0
	for event in _event_timeline:
		var kind := str(event.get("type", ""))
		if kind == "action_done":
			pending_done += 1
			continue
		if kind == "action" and str(event.get("action", "")) == expected_action and pending_done > 0:
			matches += 1
			pending_done -= 1
	return matches

func _has_level_5_strict_sequence() -> bool:
	for i in range(_event_timeline.size()):
		var e: Dictionary = _event_timeline[i]
		if str(e.get("type", "")) != "sensor":
			continue
		if str(e.get("sensor_type", "")) != "weight":
			continue
		var sensor_value = e.get("sensor_value", null)
		if not _is_number_value(sensor_value):
			continue
		var is_heavy := float(sensor_value) > 5.0

		var cursor := i + 1
		cursor = _find_next_action(cursor, "STOP_SPAWNER")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "STOP_CONVEYOR")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "ROTATE_ARM", -90.0)
		if cursor < 0:
			continue
		cursor = _find_next_action_done(cursor + 1, "ROTATE_ARM")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "PICK_BOX")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "ROTATE_ARM", 270.0 if is_heavy else 180.0)
		if cursor < 0:
			continue
		cursor = _find_next_action_done(cursor + 1, "ROTATE_ARM")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "DROP_BOX")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "ROTATE_ARM", -180.0 if is_heavy else -90.0)
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "START_SPAWNER")
		if cursor < 0:
			continue
		cursor = _find_next_action(cursor + 1, "START_CONVEYOR")
		if cursor < 0:
			continue

		return true
	return false

func _find_next_action(start_index: int, expected_action: String, expected_angle = null) -> int:
	for idx in range(start_index, _event_timeline.size()):
		var e: Dictionary = _event_timeline[idx]
		if str(e.get("type", "")) != "action":
			continue
		if str(e.get("action", "")) != expected_action:
			continue
		if expected_angle == null:
			return idx
		var angle = e.get("angle", null)
		if not _is_number_value(angle):
			continue
		if abs(float(angle) - float(expected_angle)) < 0.001:
			return idx
	return -1

func _find_next_action_done(start_index: int, expected_action: String) -> int:
	for idx in range(start_index, _event_timeline.size()):
		var e: Dictionary = _event_timeline[idx]
		if str(e.get("type", "")) != "action_done":
			continue
		if str(e.get("action", "")) == expected_action:
			return idx
	return -1

func _extract_rotate_angle(raw_action: String):
	var s := str(raw_action).strip_edges().to_upper()
	if not s.begins_with("ROTATE_ARM"):
		return null
	var parts := s.split(" ", false)
	if parts.size() < 2:
		return null
	var angle_text := str(parts[1]).strip_edges()
	if angle_text.is_valid_int():
		return float(int(angle_text))
	if angle_text.is_valid_float():
		return float(angle_text)
	return null

func _is_number_value(v) -> bool:
	var t := typeof(v)
	if t == TYPE_INT or t == TYPE_FLOAT:
		return true
	if t == TYPE_STRING:
		var s := str(v).strip_edges()
		return s.is_valid_int() or s.is_valid_float()
	return false

func _update_live_state() -> void:
	if _level_id == "level_6":
		if _level6_live_passed:
			return
		var has_if := _source_matches_structure_token(["if(weight > 5)", "if (weight > 5)", "if(weight>5)"])
		if not has_if:
			return
		if _passes_destroyer_weight_rule("destroyer2", ">", 5.0, 1, true):
			_level6_live_passed = true
		return

	if _level_id == "level_7":
		if _level7_live_passed:
			return
		var has_if := _source_matches_structure_token(["if(weight > 5)", "if (weight > 5)", "if(weight>5)"])
		if not has_if:
			return
		var has_else := _source_matches_structure_token(["else"])
		if not has_else:
			return
		var ok_d2 := _passes_destroyer_weight_rule("destroyer2", ">", 5.0, 1, true)
		var ok_d3 := _passes_destroyer_weight_rule("destroyer3", "<=", 5.0, 1, true)
		if ok_d2 or ok_d3:
			_level7_live_passed = true
		return

	if _level_id == "level_8":
		if _level8_live_passed:
			return
		var has_if := _source_matches_structure_token(["if(weight > 5)", "if (weight > 5)", "if(weight>5)"])
		if not has_if:
			return
		var has_else := _source_matches_structure_token(["else"])
		if not has_else:
			return
		var ok_d2 := _passes_destroyer_weight_rule("destroyer2", ">", 5.0, 1, true)
		var ok_d3 := _passes_destroyer_weight_rule("destroyer3", "<=", 5.0, 1, true)
		var total_ok := _count_destroyed_in_destroyers(["destroyer2", "destroyer3"]) == 5
		if ok_d2 and ok_d3 and total_ok:
			_level8_live_passed = true
		return

	if _level_id != "level_5":
		return
	if _level5_live_passed:
		return

	# Non-blocking live validation: pass as soon as one full valid cycle is found.
	# Avoid early false-fail because level 5 now has both >5 and <=5 branches.
	if _has_level_5_strict_sequence():
		_level5_live_passed = true

func _fail_level5_live(reason: String) -> void:
	_level5_live_failed = true
	_level5_live_fail_reason = "Level 5 sequence error: " + reason

func _is_action_event(e: Dictionary) -> bool:
	return str(e.get("type", "")) == "action"

func _is_action_done_event(e: Dictionary) -> bool:
	return str(e.get("type", "")) == "action_done"

func _action_matches(e: Dictionary, action_name: String, angle = null) -> bool:
	if str(e.get("action", "")) != action_name:
		return false
	if angle == null:
		return true
	var a = e.get("angle", null)
	if not _is_number_value(a):
		return false
	return abs(float(a) - float(angle)) < 0.001

func _action_done_matches(e: Dictionary, action_name: String) -> bool:
	return str(e.get("action", "")) == action_name

func _is_sensor_weight_gt5_event(e: Dictionary) -> bool:
	if str(e.get("type", "")) != "sensor":
		return false
	if str(e.get("sensor_type", "")) != "weight":
		return false
	var v = e.get("sensor_value", null)
	if not _is_number_value(v):
		return false
	return float(v) > 5.0

func _source_matches_structure_token(token_variant) -> bool:
	var source_norm := _normalize_structure_text(_source_code)
	var source_compact := _compact_alnum_text(source_norm)
	if token_variant is Array:
		for one in token_variant:
			var token := _normalize_structure_text(str(one))
			if token == "":
				continue
			if source_norm.find(token) != -1:
				return true
			var token_compact := _compact_alnum_text(token)
			if token_compact != "" and source_compact.find(token_compact) != -1:
				return true
			if _contains_words_in_order(source_norm, token):
				return true
		return false
	var single := _normalize_structure_text(str(token_variant))
	if single == "":
		return true
	if source_norm.find(single) != -1:
		return true
	var single_compact := _compact_alnum_text(single)
	if single_compact == "":
		return true
	if source_compact.find(single_compact) != -1:
		return true
	return _contains_words_in_order(source_norm, single)

func _format_structure_token(token_variant) -> String:
	if token_variant is Array:
		var options: Array[String] = []
		for one in token_variant:
			var s := str(one).strip_edges()
			if s != "":
				options.append(s)
		return "[" + " OR ".join(options) + "]"
	return str(token_variant)

func _normalize_structure_text(text: String) -> String:
	var s := str(text).to_lower()
	s = s.replace("\r", "\n")
	s = s.replace("\t", " ")
	s = s.replace("\n", " ")
	# Canonicalize common syntax variants so structure checks focus on intent.
	# Examples:
	# - action(done) == action_done == action done
	# - has(value) == has_value == has value
	# - punctuation/spacing variants collapse to the same structure text
	s = s.replace("_", " ")
	for ch in ["(", ")", "{", "}", ";", ","]:
		s = s.replace(ch, " ")
	while s.find("  ") != -1:
		s = s.replace("  ", " ")
	return s.strip_edges()

func _compact_alnum_text(text: String) -> String:
	var s := str(text).to_lower()
	var out := ""
	for i in range(s.length()):
		var c := s.unicode_at(i)
		var is_num := c >= 48 and c <= 57
		var is_lower := c >= 97 and c <= 122
		if is_num or is_lower:
			out += char(c)
	return out

func _contains_words_in_order(source_text: String, token_text: String) -> bool:
	var source_words := str(source_text).split(" ", false)
	var token_words := str(token_text).split(" ", false)
	if token_words.is_empty():
		return true
	var cursor := 0
	for sw in source_words:
		if cursor >= token_words.size():
			return true
		if str(sw) == str(token_words[cursor]):
			cursor += 1
	return cursor >= token_words.size()

func _count_destroyed_in_destroyers(destroyer_ids: Array) -> int:
	var wanted: Dictionary = {}
	for id_variant in destroyer_ids:
		var id := str(id_variant).strip_edges()
		if id == "":
			continue
		wanted[id] = true
	if wanted.is_empty():
		return 0
	var total := 0
	for box_var in _destroyed_boxes:
		var box_data: Dictionary = box_var
		var destroyer_id := str(box_data.get("destroyer_id", "")).strip_edges()
		if wanted.has(destroyer_id):
			total += 1
	return total

func _passes_destroyer_weight_rule(destroyer_id: String, op: String, threshold: float, min_hits: int, require_all: bool = false) -> bool:
	if destroyer_id == "":
		return false
	var matched := 0
	var total_for_destroyer := 0
	for box_var in _destroyed_boxes:
		var box_data: Dictionary = box_var
		if str(box_data.get("destroyer_id", "")).strip_edges() != destroyer_id:
			continue
		total_for_destroyer += 1
		var w = box_data.get("weight", null)
		if not _is_number_value(w):
			continue
		var pass_one := _compare_weight(float(w), op, threshold)
		if pass_one:
			matched += 1
		elif require_all:
			return false
	# If no boxes reached this destroyer, allow pass when min_hits is 0.
	if total_for_destroyer == 0:
		return min_hits <= 0
	return matched >= min_hits

func _compare_weight(value: float, op: String, threshold: float) -> bool:
	match op:
		">":
			return value > threshold
		">=":
			return value >= threshold
		"<":
			return value < threshold
		"<=":
			return value <= threshold
		"==":
			return abs(value - threshold) < 0.0001
		"!=":
			return abs(value - threshold) >= 0.0001
		_:
			return false

func _describe_destroyer_weight_rule_failure(destroyer_id: String, op: String, threshold: float, min_hits: int, require_all: bool) -> String:
	var total_for_destroyer := 0
	var matched := 0
	var failed_samples: Array[String] = []
	for box_var in _destroyed_boxes:
		var box_data: Dictionary = box_var
		if str(box_data.get("destroyer_id", "")).strip_edges() != destroyer_id:
			continue
		total_for_destroyer += 1
		var w = box_data.get("weight", null)
		if not _is_number_value(w):
			continue
		var wf := float(w)
		if _compare_weight(wf, op, threshold):
			matched += 1
		elif failed_samples.size() < 5:
			var box_id := int(box_data.get("box_id", -1))
			failed_samples.append("#%d(%.1f)" % [box_id, wf])

	if require_all and min_hits <= 0:
		if total_for_destroyer == 0:
			return "Destroyer '%s' has no boxes (allowed)" % destroyer_id
		if not failed_samples.is_empty():
			return "All boxes in destroyer '%s' must have weight %s %s; failed: %s" % [destroyer_id, op, str(threshold), ", ".join(failed_samples)]
		return "All boxes in destroyer '%s' must have weight %s %s" % [destroyer_id, op, str(threshold)]

	var base := "Destroyer '%s' requires at least %d boxes with weight %s %s; matched=%d total=%d" % [
		destroyer_id, min_hits, op, str(threshold), matched, total_for_destroyer
	]
	if not failed_samples.is_empty():
		base += " failed: " + ", ".join(failed_samples)
	return base
