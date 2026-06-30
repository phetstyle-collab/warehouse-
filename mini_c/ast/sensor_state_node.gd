# sensor_state_node.gd
extends ASTNode
class_name SensorStateNode

enum Mode {
	NOT_DETECTED,
	HAS_VALUE
}

var sensor_name: String
var mode: Mode

func _init(sensor_name: String, mode: Mode):
	self.sensor_name = sensor_name
	self.mode = mode


func evaluate(runtime) -> bool:
	var value = runtime.get_sensor_state(sensor_name)

	match mode:
		Mode.NOT_DETECTED:
			return _is_not_detected(value)

		Mode.HAS_VALUE:
			return _has_value(value)

	return false


# ===============================
# INTERNAL HELPERS
# ===============================
func _is_not_detected(value) -> bool:
	# รองรับทั้ง null และค่า default
	return value == null


func _has_value(value) -> bool:
	return value != null
