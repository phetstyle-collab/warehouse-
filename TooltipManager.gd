extends Node

var label: Label
var _bound_scene: Node

const TOOLTIP_INFO := {
	"spawner": {
		"title": "เครื่องปล่อยกล่อง",
		"hint": "คำสั่งหลัก: start(spawner), stop(spawner)",
	},
	"conveyor": {
		"title": "สายพาน",
		"hint": "คำสั่งหลัก: start(conveyor), stop(conveyor)",
	},
	"weightsensor": {
		"title": "เซนเซอร์น้ำหนัก",
		"hint": "ใช้ตรวจ weight หรือรอ weight(has_value)",
	},
	"sizesensor": {
		"title": "เซนเซอร์ขนาด",
		"hint": "ใช้ตรวจขนาดของกล่อง",
	},
	"colorsensor": {
		"title": "เซนเซอร์สี",
		"hint": "ใช้ตรวจสีของกล่อง",
	},
	"robotarm": {
		"title": "แขนกล",
		"hint": "ใช้ pick/place และรอ action(done)",
	},
	"destroyer": {
		"title": "ถังรับกล่อง",
		"hint": "นับจำนวนกล่องที่เข้าปลายทางนี้",
	},
}

func setup(_label: Label) -> void:
	if _label == null:
		push_error("TooltipManager.setup: label is null")
		return

	label = _label
	_bound_scene = get_tree().current_scene
	label.visible = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 999
	label.add_theme_color_override("font_color", Color8(28, 42, 62))
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_stylebox_override("normal", _make_style(Color8(250, 252, 255), 14, Color8(43, 111, 202), 2))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if label == null or not is_instance_valid(label) or not label.is_inside_tree() or scene != _bound_scene:
		_try_auto_setup(scene)
	if label == null:
		return

	if scene == null:
		return

	var ci := scene as CanvasItem
	if ci == null:
		return

	var main_viewport := ci.get_viewport()
	var main_mouse := main_viewport.get_mouse_position()

	var active_viewport: Viewport = main_viewport
	var sv := scene.get_node_or_null("CanvasLayer/MainLayout/GameViewport/GameScene") as SubViewport
	if sv != null:
		active_viewport = sv

	var sv_mouse := active_viewport.get_mouse_position()
	var world_mouse := active_viewport.get_canvas_transform().affine_inverse() * sv_mouse
	var space := active_viewport.find_world_2d().direct_space_state
	
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_mouse
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hits := space.intersect_point(query, 32)

	var best_area: Area2D = null
	var best_score := -999999999

	for h in hits:
		var a := h.collider as Area2D
		if a == null:
			continue
		if not a.is_in_group("hoverable"):
			continue

		var pr := int(a.get_meta("hover_priority", 0))
		var score := pr * 100000 + int(a.global_position.y)

		if score > best_score:
			best_score = score
			best_area = a

	if best_area == null:
		label.visible = false
		return

	label.text = _format_hover_text(str(best_area.get_meta("hover_text", best_area.name)))
	_resize_label_for_text()
	label.visible = true
	label.global_position = _get_safe_tooltip_position(main_mouse, main_viewport.get_visible_rect().size)

func _try_auto_setup(scene: Node) -> void:
	if scene == null:
		return
	var found := scene.get_node_or_null("CanvasLayer/HoverNameLabel") as Label
	if found != null:
		setup(found)
	else:
		label = null
		_bound_scene = scene

func _format_hover_text(raw_text: String) -> String:
	var normalized := raw_text.strip_edges()
	var base_name := normalized
	var detail := ""

	if normalized.contains("|"):
		var parts := normalized.split("|")
		base_name = str(parts[0]).strip_edges()
		detail = _format_destroyer_detail(parts)

	var lookup_key := base_name.to_lower().strip_edges()
	if lookup_key.begins_with("destroyer"):
		return "ถังรับกล่อง"

	var info: Dictionary = TOOLTIP_INFO.get(lookup_key, {})
	if info.is_empty():
		return normalized

	var title := str(info.get("title", base_name))
	var hint := str(info.get("hint", ""))
	
	var lines: Array[String] = [title]
	if not hint.is_empty():
		lines.append(hint)
	if not detail.is_empty():
		lines.append(detail)
	return "\n".join(lines)

func _format_destroyer_detail(parts: PackedStringArray) -> String:
	var total := ""
	var heavy := ""
	var light := ""

	for part in parts:
		var text := str(part).strip_edges()
		if text.begins_with("total:"):
			total = text.substr("total:".length()).strip_edges()
		elif text.begins_with(">=5:"):
			heavy = text.substr(">=5:".length()).strip_edges()
		elif text.begins_with("<5:"):
			light = text.substr("<5:".length()).strip_edges()

	var details: Array[String] = []
	if not total.is_empty():
		details.append("รวม " + total + " กล่อง")
	if not heavy.is_empty():
		details.append("หนัก >=5kg: " + heavy)
	if not light.is_empty():
		details.append("เบา <5kg: " + light)
	return " | ".join(details)

func _resize_label_for_text() -> void:
	var line_count := label.text.count("\n") + 1
	label.size = Vector2(330, max(72, 28 + line_count * 28))

func _get_safe_tooltip_position(mouse_pos: Vector2, viewport_size: Vector2) -> Vector2:
	var pos := mouse_pos + Vector2(18, 18)
	pos.x = min(pos.x, viewport_size.x - label.size.x - 12)
	pos.y = min(pos.y, viewport_size.y - label.size.y - 12)
	pos.x = max(pos.x, 12.0)
	pos.y = max(pos.y, 12.0)
	return pos

func _make_style(bg: Color, radius: int, border: Color, border_width: int) -> StyleBoxFlat:
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
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 8
	style.content_margin_left = 14
	style.content_margin_top = 8
	style.content_margin_right = 14
	style.content_margin_bottom = 8
	return style
