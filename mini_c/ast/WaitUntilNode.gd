extends ASTNode
class_name WaitUntilNode

enum WaitType {
	SENSOR_CONDITION,
	ACTION_DONE
}

var wait_type: int
var condition   # ComparisonNode หรือ ConditionNode

func _init(_wait_type: int, _condition = null) -> void:
	wait_type = _wait_type
	condition = _condition


func execute(runtime: MiniCRuntime) -> void:
	print("⏳ WAIT UNTIL execute type =", wait_type)

	# runtime จะเป็นคน:
	# - เปิด gate
	# - จำ program + resume ip
	# - ปิด gate เมื่อ condition true
	#
	# ❌ ห้ามเดิน ip ต่อเอง
	# ❌ ห้าม loop
	# ❌ ห้าม call ProgramNode

	var program := runtime._current_program
	var resume_ip := runtime._resume_ip + 1

	runtime.enter_wait(
		program,
		resume_ip,
		self
	)
