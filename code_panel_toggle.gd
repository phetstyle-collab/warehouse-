extends RefCounted
class_name CodePanelToggle

const DEFAULT_BUTTON_NAME := "CodeToggleButton"

static func setup(root: Node) -> void:
	if root == null:
		return

	var shell := root.get_node_or_null("SplitScreenLayout")
	if shell != null:
		shell.queue_free()

	var panel := _find_code_panel(root)
	if panel == null:
		return

	# Ensure panel is inside a CanvasLayer so it renders in fixed screen space
	# (not affected by Camera2D world transform)
	_move_to_canvas_layer(root, panel)
	_hide_code_buttons(root)
	_prepare_panel(panel)
	_refresh_panel_layout(root, panel)

static func _find_code_panel(root: Node) -> Control:
	var direct := root.get_node_or_null("Control") as Control
	if direct != null:
		return direct

	for button_name in ["code1", "code2", "code3", "Button", DEFAULT_BUTTON_NAME]:
		var button := root.get_node_or_null(button_name) as Button
		if button == null:
			continue
		var panel := button.get_node_or_null("Control") as Control
		if panel != null:
			return panel
	return null

static func _move_to_canvas_layer(root: Node, panel: Control) -> void:
	# Check if already inside a CanvasLayer — nothing to do
	var ancestor: Node = panel.get_parent()
	while ancestor != null and ancestor != root:
		if ancestor is CanvasLayer:
			return
		ancestor = ancestor.get_parent()

	# Find existing CanvasLayer at root level (skip the UI layer)
	var canvas_layer: CanvasLayer = null
	for child in root.get_children():
		if child is CanvasLayer and child.name != "UI":
			canvas_layer = child
			break

	if canvas_layer == null:
		canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 2
		canvas_layer.name = "CodeLayer"
		root.add_child(canvas_layer)

	panel.reparent(canvas_layer, false)

static func _hide_code_buttons(root: Node) -> void:
	for button_name in ["code1", "code2", "code3", "Button", DEFAULT_BUTTON_NAME]:
		var button := root.get_node_or_null(button_name) as Button
		if button == null:
			continue
		button.visible = false
		button.disabled = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

static func _prepare_panel(panel: Control) -> void:
	panel.visible = true
	panel.z_as_relative = false
	panel.z_index = 300
	panel.set_meta("embedded_split_layout", false)
	if panel.has_method("_apply_playground_layout"):
		panel.call("_apply_playground_layout")

static func _refresh_panel_layout(root: Node, panel: Control) -> void:
	var viewport := root.get_viewport()
	if viewport == null:
		return

	var viewport_size := viewport.get_visible_rect().size

	# Read editor_width from the MiniCPlayground panel if available, else fallback
	var panel_width := 320.0
	if "editor_width" in panel:
		var ew = panel.get("editor_width")
		if typeof(ew) == TYPE_INT and (ew as int) > 0:
			panel_width = float(ew as int)
	panel_width = clampf(panel_width, 320.0, viewport_size.x * 0.55)

	var panel_height := viewport_size.y
	var panel_x := viewport_size.x - panel_width
	var panel_y := 0.0

	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	panel.size = Vector2(panel_width, panel_height)

	if panel.has_method("_apply_playground_layout"):
		panel.call("_apply_playground_layout")
	panel.global_position = Vector2(panel_x, panel_y)
