extends Node
## Attach as a direct child of any level scene root (Node2D).
## On startup, replaces the transparent GameSpacer in CanvasLayer/MainLayout
## with a SubViewportContainer so the game world is confined to the left area.

const KEEP_AT_ROOT: Array[String] = [
	"CanvasLayer", "UI", "Back", "Panel", "RestartButton",
	"Back", "RestartButton2", "Label"
]

@export var panel_width: int = 320

func _ready() -> void:
	call_deferred("_build_split_screen")

func _build_split_screen() -> void:
	var root: Node = get_parent()

	var canvas := root.get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas == null:
		push_error("SplitScreen: CanvasLayer not found")
		return

	var hbox := canvas.get_node_or_null("MainLayout") as HBoxContainer
	if hbox == null:
		push_error("SplitScreen: MainLayout not found in CanvasLayer")
		return

	# Remove the placeholder transparent GameSpacer
	var spacer := hbox.get_node_or_null("GameSpacer")
	if spacer != null:
		spacer.queue_free()

	# Viewport size
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var game_w := int(vp_size.x) - panel_width
	var game_h := int(vp_size.y)

	# --- SubViewportContainer (takes the left portion) ---
	var svc := SubViewportContainer.new()
	svc.name = "GameViewport"
	svc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	svc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	svc.stretch = true

	# --- SubViewport (isolated world so Camera2D only renders here) ---
	var sv := SubViewport.new()
	sv.name = "GameScene"
	sv.world_2d = World2D.new()  # isolated physics world (Godot 4 API)
	sv.size = Vector2i(game_w, game_h)
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	svc.add_child(sv)
	hbox.add_child(svc)
	hbox.move_child(svc, 0)  # game area before editor panel

	# World-offset proxy: preserves root Node2D's position offset
	var world_root := Node2D.new()
	world_root.name = "WorldRoot"
	if root is Node2D:
		world_root.position = (root as Node2D).position
	sv.add_child(world_root)

	# Collect game world nodes (skip UI / CanvasLayer / this script)
	var to_move: Array[Node] = []
	for child in root.get_children():
		if child == self:
			continue
		if child is CanvasLayer:
			continue
		if child.name in KEEP_AT_ROOT:
			continue
		to_move.append(child)

	for node in to_move:
		node.reparent(world_root, false)

	# One frame later: reconnect MiniCPlayground → RealFactoryController
	await get_tree().process_frame
	_reconnect_playground(hbox, sv)

func _reconnect_playground(hbox: HBoxContainer, sv: SubViewport) -> void:
	var control := hbox.get_node_or_null("Control")
	if control == null:
		return
	var rfc := sv.find_child("RealFactoryController", true, false)
	if rfc == null:
		return
	if control.has_method("rebind_factory"):
		control.call("rebind_factory", rfc)
