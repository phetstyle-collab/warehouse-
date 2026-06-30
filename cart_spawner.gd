extends Node2D
class_name CartSpawner

@export var cart_scene: PackedScene
@export var initial_cart_path: NodePath
@export var spawn_point_path: NodePath = NodePath("SpawnPoint")
@export var active_carts_path: NodePath = NodePath("../ActiveCarts")
@export var path_follow_paths: Array[NodePath] = []
@export var path_names: Array[String] = []
@export var spawn_clear_radius: float = 70.0
@export var min_ready_carts: int = 1
@export var max_carts: int = 6
@export var auto_spawn: bool = true
@export var spawn_only_when_idle: bool = true
# Optional: when set, max_carts is overridden at runtime to match this
# BoxSpawner's max_boxes, so the ROD fleet can never spawn more carts than
# there will ever be boxes to carry.
@export var box_spawner_path: NodePath

@onready var spawn_point: Node2D = get_node_or_null(spawn_point_path) as Node2D
@onready var active_carts: Node = get_node_or_null(active_carts_path)
@onready var box_spawner: BoxSpawner = get_node_or_null(box_spawner_path) as BoxSpawner

var _carts: Array[RodCart] = []
var _next_cart_id: int = 1


func _ready() -> void:
	if active_carts == null:
		active_carts = Node2D.new()
		active_carts.name = "ActiveCarts"
		get_parent().call_deferred("add_child", active_carts)
	if box_spawner != null:
		max_carts = box_spawner.max_boxes
	_register_initial_cart()
	call_deferred("_ensure_ready_cart")


func _process(_delta: float) -> void:
	if auto_spawn:
		_ensure_ready_cart()


func get_ready_cart() -> RodCart:
	_prune_invalid_carts()
	if _carts.is_empty():
		_register_initial_cart()
		_ensure_ready_cart()
	for cart in _carts:
		if _is_cart_ready(cart):
			cart.set_meta("cart_state", "reserved")
			print("CartSpawner reserved:", cart.name)
			_ensure_ready_cart()
			return cart
	print("CartSpawner has no ready cart. carts=%d active=%d ready=%d spawn_clear=%s" % [_carts.size(), _count_active_carts(), _count_ready_carts(), _is_spawn_point_clear()])
	return null


func release_cart(cart: RodCart) -> void:
	if cart == null or not is_instance_valid(cart):
		return
	cart.set_meta("cart_state", "ready")
	_ensure_ready_cart()


func complete_cart(cart: RodCart) -> void:
	if cart == null or not is_instance_valid(cart):
		return
	cart.set_meta("cart_state", "done")
	_ensure_ready_cart()


func _ensure_ready_cart() -> void:
	_prune_invalid_carts()
	if cart_scene == null or spawn_point == null:
		return
	if _count_ready_carts() >= min_ready_carts:
		return
	if spawn_only_when_idle and _count_busy_carts() > 0:
		return
	if _count_active_carts() >= max_carts:
		return
	if not _is_spawn_point_clear():
		return
	_spawn_cart()


func _spawn_cart() -> RodCart:
	var cart := cart_scene.instantiate() as RodCart
	if cart == null:
		push_error("CartSpawner: cart_scene must instantiate RodCart")
		return null

	# Keep spawned carts as direct children of the station so their NodePath
	# setup matches the initial ROD (../PathA, ../PathB, ...).
	get_parent().add_child(cart)

	cart.name = "ROD_%d" % _next_cart_id
	_next_cart_id += 1
	cart.global_position = spawn_point.global_position
	cart.path_follow_paths = path_follow_paths.duplicate()
	cart.path_names = path_names.duplicate()
	cart.set_meta("cart_state", "ready")
	_carts.append(cart)
	print("CartSpawner spawned: %s at=%s paths=%s" % [cart.name, str(cart.global_position), str(cart.path_names)])
	return cart


func _register_initial_cart() -> void:
	if initial_cart_path == NodePath():
		return
	var cart := get_node_or_null(initial_cart_path) as RodCart
	if cart == null:
		push_error("CartSpawner: initial_cart_path not found or wrong type")
		return
	if _carts.has(cart):
		return
	cart.path_follow_paths = path_follow_paths.duplicate()
	cart.path_names = path_names.duplicate()
	cart.set_meta("cart_state", "ready")
	_carts.append(cart)
	print("CartSpawner registered initial cart: %s at=%s paths=%s" % [cart.name, str(cart.global_position), str(cart.path_names)])


func _count_ready_carts() -> int:
	var count := 0
	for cart in _carts:
		if _is_cart_ready(cart):
			count += 1
	return count


func _count_active_carts() -> int:
	var count := 0
	for cart in _carts:
		if cart == null or not is_instance_valid(cart):
			continue
		if cart.get_meta("cart_state", "ready") == "done":
			continue
		count += 1
	return count


func _count_busy_carts() -> int:
	var count := 0
	for cart in _carts:
		if cart == null or not is_instance_valid(cart):
			continue
		var state := str(cart.get_meta("cart_state", "ready"))
		if state == "ready" or state == "done":
			continue
		count += 1
	return count


func _is_cart_ready(cart: RodCart) -> bool:
	if cart == null or not is_instance_valid(cart):
		return false
	if cart.get_meta("cart_state", "ready") != "ready":
		return false
	if cart.held_box != null:
		return false
	return not bool(cart.get("_moving_on_path")) and not bool(cart.get("_moving_to_path_start"))


func _is_spawn_point_clear() -> bool:
	for cart in _carts:
		if cart == null or not is_instance_valid(cart):
			continue
		if cart.global_position.distance_to(spawn_point.global_position) <= spawn_clear_radius:
			return false
	return true


func _prune_invalid_carts() -> void:
	_carts = _carts.filter(func(cart: RodCart) -> bool:
		return cart != null and is_instance_valid(cart)
	)
