extends Node
class_name RealFactoryController

# ==================================================
# SIGNALS (Golden Key)
# ==================================================
signal sensor_updated(data: Dictionary)
signal action_finished(action_name: String)

# ==================================================
# CONFIG
# ==================================================
@export var factory_controller_path: NodePath

# ==================================================
# INTERNAL STATE
# ==================================================
var _factory: FactoryController = null
var _sensors: Dictionary = {}   # { "weight": value | null, "color": value | null }

# ==================================================
# LIFECYCLE
# ==================================================
func _ready() -> void:
	_factory = get_node_or_null(factory_controller_path)

	if _factory == null:
		push_error(
			"RealFactoryController: FactoryController not found at path: %s"
			% factory_controller_path
		)
		return

	# World -> Adapter (Sensors)
	if not _factory.sensor_updated.is_connected(_on_sensor_updated):
		_factory.sensor_updated.connect(_on_sensor_updated)

	# World -> Adapter (Action Done)
	if _factory.has_signal("action_finished"):
		if not _factory.action_finished.is_connected(_on_action_finished):
			_factory.action_finished.connect(_on_action_finished)

	# initialize sensors as NOT_DETECTED
	_sensors.clear()
	_sensors["weight"] = null
	_sensors["color"] = null

	print("Sensor cache reset:", _sensors)
	print("RealFactoryController ready (adapter mode)")
	print("Bound to FactoryController:", _factory.name)

# ==================================================
# API FOR MiniCRuntime (Golden Key)
# ==================================================
func execute_action(action: String) -> void:
	if _factory == null:
		return

	print("Mini-C -> World action:", action)
	_factory.send_command(action)

func get_sensor_state(sensor_name: String):
	var key := str(sensor_name).strip_edges().to_lower()
	var v = _sensors.get(key, null)

	# Weight must be read live so consumed boxes do not re-trigger cart jobs.
	# ColorSensor reports by signal only, so keep color on the event cache.
	if key == "weight" and _factory != null and _factory.has_method("get_sensor_state"):
		v = _factory.call("get_sensor_state", key)
		if _sensors.has(key):
			_sensors[key] = v
	elif v == null and _factory != null and _factory.has_method("get_sensor_state"):
		var live_value = _factory.call("get_sensor_state", key)
		if live_value != null:
			v = live_value
			if _sensors.has(key):
				_sensors[key] = v
	print("Mini-C read sensor:", sensor_name, "=", v)
	return v

func clear_sensor(sensor_name: String) -> void:
	if _sensors.has(sensor_name):
		_sensors[sensor_name] = null
	if _factory != null and _factory.has_method("clear_sensor"):
		_factory.call("clear_sensor", sensor_name)

# ==================================================
# SENSOR ADAPTER (World -> Mini-C)
# ==================================================
func _on_sensor_updated(data: Dictionary) -> void:
	if not data.has("type"):
		return

	var sensor_type := String(data["type"])
	var value: Variant = data.get("value", null)

	match sensor_type:
		"weight":
			_sensors["weight"] = value
		"color":
			_sensors["color"] = value
		_:
			return

	print("World -> Mini-C sensor:", sensor_type, "=", value)

	# forward to runtime
	emit_signal("sensor_updated", data)

# ==================================================
# ACTION DONE ADAPTER (World -> Mini-C)
# ==================================================
func _on_action_finished(action_name: String) -> void:
	print("World -> Mini-C action finished:", action_name)
	emit_signal("action_finished", action_name)
