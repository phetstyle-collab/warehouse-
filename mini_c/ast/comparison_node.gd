extends ASTNode
class_name ComparisonNode

# Semantic constants used by parser/runtime.
const NOT_DETECTED := "NOT_DETECTED"
const HAS_VALUE := "HAS_VALUE"

var sensor: String
var operator: String
var value

func _init(_sensor: String, _operator: String, _value) -> void:
	sensor = _sensor
	operator = str(_operator).strip_edges()
	value = _value

func evaluate(runtime) -> bool:
	# Constant boolean expression (TRUE/FALSE pseudo sensor).
	if sensor == "__const__":
		return _compare(bool(value), true)

	# Sensor names are case-insensitive in Mini-C source.
	var sensor_key := str(sensor).strip_edges().to_lower()
	var current = null
	if runtime.has_method("has_number_var") and runtime.call("has_number_var", sensor_key):
		current = runtime.call("get_number_var", sensor_key)
	else:
		current = runtime.get_sensor_state(sensor_key)
	current = _resolve_runtime_var(current, runtime)
	var rhs = _resolve_runtime_var(value, runtime)
	_debug_log(sensor_key, current)

	if operator.to_upper() in ["IS", "HAS_VALUE", "EXISTS"]:
		return _compare_semantic(current)

	if current == null or rhs == null:
		return _compare_null(current, rhs)

	var a = _normalize(current)
	var b = _normalize(rhs)
	return _compare(a, b)

func _resolve_runtime_var(v, runtime):
	if typeof(v) != TYPE_STRING:
		return v
	var key := str(v).strip_edges().to_lower()
	if key == "":
		return v
	if runtime != null and runtime.has_method("has_number_var") and runtime.call("has_number_var", key):
		return runtime.call("get_number_var", key)
	return v

func _debug_log(sensor_key: String, current) -> void:
	print(
		"COMPARE:",
		"sensor=", sensor_key,
		"current=", current, "(type=", typeof(current), ")",
		"value=", value, "(type=", typeof(value), ")",
		"operator=", operator
	)

func _normalize(v):
	if v == null:
		return null

	if typeof(v) == TYPE_BOOL:
		return v

	if typeof(v) == TYPE_STRING:
		var s: String = str(v).strip_edges()
		if s.is_valid_int():
			return int(s)
		if s.is_valid_float():
			return float(s)
		return s

	return v

func _compare(a, b) -> bool:
	var ta = typeof(a)
	var tb = typeof(b)

	if ta in [TYPE_INT, TYPE_FLOAT] and tb in [TYPE_INT, TYPE_FLOAT]:
		return _compare_number(float(a), float(b))

	if ta == TYPE_BOOL and tb == TYPE_BOOL:
		return _compare_bool(a, b)

	if ta == TYPE_STRING and tb == TYPE_STRING:
		return _compare_string(a, b)

	return _compare_string(str(a), str(b))

func _compare_semantic(current) -> bool:
	var v = str(value).to_upper()
	match v:
		"HAS_VALUE", "EXISTS":
			return current != null
		"NOT_DETECTED", "NULL":
			return current == null
		_:
			return false

func _compare_null(a, b) -> bool:
	match operator:
		"==":
			return a == b
		"!=":
			return a != b
		_:
			return false

func _compare_bool(a: bool, b: bool) -> bool:
	match operator:
		"==":
			return a == b
		"!=":
			return a != b
		_:
			return false

func _compare_string(a: String, b: String) -> bool:
	var left := a.strip_edges()
	var right := b.strip_edges()
	var left_ci := left.to_lower()
	var right_ci := right.to_lower()
	match operator:
		"==":
			return left_ci == right_ci
		"!=":
			return left_ci != right_ci
		"CONTAINS":
			return right_ci in left_ci
		"STARTS_WITH":
			return left_ci.begins_with(right_ci)
		"ENDS_WITH":
			return left_ci.ends_with(right_ci)
		_:
			return false

func _compare_number(a: float, b: float) -> bool:
	match operator:
		"==":
			return a == b
		"!=":
			return a != b
		">":
			return a > b
		"<":
			return a < b
		">=":
			return a >= b
		"<=":
			return a <= b
		_:
			return false
