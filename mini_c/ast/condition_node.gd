extends ASTNode
class_name ConditionNode

# ==================================================
# AST DATA
# ==================================================
var condition # ComparisonNode | LogicalNode
var then_body: ProgramNode
var else_body: ProgramNode   # nullable


# ==================================================
# INIT
# ==================================================
func _init(
	_condition,
	_then_body: ProgramNode,
	_else_body: ProgramNode = null
) -> void:
	condition = _condition
	then_body = _then_body
	else_body = _else_body


# ==================================================
# EXECUTION (C-like + Golden Key)
# ==================================================
func execute(runtime: MiniCRuntime) -> void:
	# --------------------------------------------------
	# 1) Evaluate condition
	# --------------------------------------------------
	if condition.evaluate(runtime):
		# TRUE branch
		var outer_program := runtime._current_program
		var outer_ip := runtime._resume_ip
		runtime.push_return(then_body, outer_program, outer_ip + 1)
		then_body.execute_from(runtime, 0)
		runtime.block_fallthrough(outer_program)
	else:
		# FALSE branch (optional)
		if else_body != null:
			var outer_program := runtime._current_program
			var outer_ip := runtime._resume_ip
			runtime.push_return(else_body, outer_program, outer_ip + 1)
			else_body.execute_from(runtime, 0)
			runtime.block_fallthrough(outer_program)

	# --------------------------------------------------
	# 2) DO NOT touch flow flags
	# --------------------------------------------------
	# - BREAK is handled by WhileNode
	# - WAIT is handled by ProgramNode / Runtime
	# - Just return to ProgramNode
	return
