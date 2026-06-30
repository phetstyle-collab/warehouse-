extends Node
class_name MiniCTestRunner

# ==================================================
# CONFIG
# ==================================================
@export var factory_controller_path: NodePath
@export var source_code: String = ""  # Mini-C source (ภายหลังจะมาจาก editor)

# ==================================================
# INTERNAL
# ==================================================
var factory: FactoryController
var runtime: MiniCRuntime

# ==================================================
# LIFECYCLE
# ==================================================
func _ready() -> void:
	print("🧪 MiniCTestRunner ready")

	_resolve_factory()
	_setup_language_pipeline()
	_bind_world_events()

	print("✅ MiniCTestRunner setup complete")

# ==================================================
# RESOLVE
# ==================================================
func _resolve_factory() -> void:
	factory = get_node_or_null(factory_controller_path)
	if factory == null:
		push_error("MiniCTestRunner: FactoryController not found")
		return

	print("🔗 FactoryController resolved")

# ==================================================
# LANGUAGE PIPELINE
# ==================================================
func _setup_language_pipeline() -> void:
	if source_code.strip_edges() == "":
		print("ℹ No Mini-C source provided (runner idle)")
		return

	# --- PARSE (STATIC) ---
	var program: ProgramNode = MiniCParser.parse(source_code)
	if program == null:
		push_error("MiniCTestRunner: parse failed")
		return

	# --- RUNTIME ---
	runtime = MiniCRuntime.new()
	runtime.load_program(program)

	# runtime -> world
	runtime.command_emitted.connect(_on_runtime_command)

	print("🧠 Mini-C program loaded")

# ==================================================
# WORLD ↔ LANGUAGE
# ==================================================
func _bind_world_events() -> void:
	if factory == null or runtime == null:
		return

	# world -> runtime
	factory.sensor_updated.connect(runtime.on_sensor_event)

	print("🌍 World events bound to runtime")

# ==================================================
# RUNTIME → WORLD
# ==================================================
func _on_runtime_command(command: String) -> void:
	if factory == null:
		return

	print("➡ Runtime command:", command)
	factory.send_command(command)
