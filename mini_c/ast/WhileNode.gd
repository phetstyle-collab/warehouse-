extends ASTNode
class_name WhileNode

var condition        # ComparisonNode
var body: ProgramNode


func _init(_condition, _body: ProgramNode) -> void:
	condition = _condition
	body = _body


func execute(runtime: MiniCRuntime) -> void:
	print("WhileNode.execute")

	# 1) Evaluate condition (C-like)
	if not condition.evaluate(runtime):
		print("WHILE exit (condition false)")
		return

	# Capture outer program/ip so we can re-run this WHILE.
	var outer_program := runtime._current_program
	var outer_ip := runtime._resume_ip

	# 2) Execute body ONE iteration
	# - Let ProgramNode advance the ip
	# - WhileNode must not loop by itself
	# Register loop so the body can return to the WHILE when it ends.
	runtime.push_loop(body, outer_program, outer_ip, null)
	body.execute_from(runtime, 0)

	# Prevent outer ProgramNode from falling through; the body controls flow now.
	runtime.block_fallthrough(outer_program)
	return
