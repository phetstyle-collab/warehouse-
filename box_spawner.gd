extends Node2D
class_name BoxSpawner

signal spawner_error(message: String)
signal spawning_finished(total_spawned: int)
const START_GRACE_SECONDS: float = 0.5

# =========================
# CONFIG
# =========================
@export var box_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var max_boxes: int = 20
@export var force_first_box_heavy: bool = false

# =========================
# NODES
# =========================
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var spawn_timer: Timer = $SpawnTimer

# =========================
# STATE
# =========================
var spawned_count: int = 0
var next_box_id: int = 1
var running: bool = false
var conveyor_running: bool = false
var bottlenecked: bool = false
var _awaiting_conveyor: bool = false
var _start_request_id: int = 0
var _finished_emitted: bool = false

# =========================
# LIFECYCLE
# =========================
func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	print("BoxSpawner ready (waiting for command)")

# =========================
# COMMAND API
# =========================
func handle_command(command: String) -> void:
	match command:
		"START_SPAWNER":
			start_spawning()
		"STOP_SPAWNER":
			stop_spawning()
		_:
			print("BoxSpawner: unknown command =", command)

func start_spawning() -> void:
	if running:
		return
	running = true
	_awaiting_conveyor = false
	_start_request_id += 1

	if not conveyor_running:
		_awaiting_conveyor = true
		_wait_conveyor_grace(_start_request_id)
		print("BoxSpawner waiting for conveyor (%ss grace)" % START_GRACE_SECONDS)
		return

	bottlenecked = false
	running = true
	spawn_timer.start()
	print("BoxSpawner START")

func stop_spawning() -> void:
	_start_request_id += 1
	_awaiting_conveyor = false
	if not running:
		bottlenecked = false
		return

	running = false
	bottlenecked = false
	spawn_timer.stop()
	print("BoxSpawner STOP")

func set_conveyor_running(is_running: bool) -> void:
	conveyor_running = is_running
	if conveyor_running and running and _awaiting_conveyor:
		_awaiting_conveyor = false
		bottlenecked = false
		if spawn_timer.is_stopped():
			spawn_timer.start()
		print("BoxSpawner START (conveyor became available)")
	if conveyor_running and not running:
		bottlenecked = false
	if not conveyor_running and running:
		_report_bottleneck("Conveyor stopped while spawner still running (bottleneck)")

# =========================
# TIMER CALLBACK
# =========================
func _on_spawn_timer_timeout() -> void:
	if not running:
		return
	if _awaiting_conveyor:
		return
	if not conveyor_running:
		_report_bottleneck("Spawn blocked: conveyor is stopped")
		return

	if spawned_count >= max_boxes:
		stop_spawning()
		if not _finished_emitted:
			_finished_emitted = true
			spawning_finished.emit(spawned_count)
		print("Spawning finished")
		return

	_spawn_box()
	spawned_count += 1

func _report_bottleneck(message: String) -> void:
	running = false
	bottlenecked = true
	spawn_timer.stop()
	push_error("BoxSpawner bottleneck: " + message)
	spawner_error.emit(message)

func _wait_conveyor_grace(request_id: int) -> void:
	await get_tree().create_timer(START_GRACE_SECONDS).timeout
	if request_id != _start_request_id:
		return
	if not running or not _awaiting_conveyor:
		return
	if conveyor_running:
		_awaiting_conveyor = false
		bottlenecked = false
		if spawn_timer.is_stopped():
			spawn_timer.start()
		print("BoxSpawner START (after grace)")
		return
	_awaiting_conveyor = false
	_report_bottleneck("Cannot start spawner while conveyor is stopped")

# =========================
# SPAWN LOGIC
# =========================
func _spawn_box() -> void:
	if box_scene == null:
		push_error("BoxSpawner: box_scene not assigned")
		return

	var box: Box = box_scene.instantiate()

	# Optional per-scene rule: force first box of a run to be heavy (> 5).
	# spawned_count is incremented after _spawn_box(), so 0 means first box.
	var is_first_box_of_run := spawned_count == 0
	var weight: int = randi_range(1, 10)
	if force_first_box_heavy and is_first_box_of_run:
		weight = randi_range(6, 10)
	var colors: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE]
	var color: Color = colors.pick_random()
	var size_options: Array[String] = ["S", "M", "L", "XL", "XXL"]
	var size: String = size_options.pick_random()

	var id: int = next_box_id
	next_box_id += 1

	box.apply_data(id, color, weight, size)
	add_child(box)
	box.global_position = spawn_point.global_position
