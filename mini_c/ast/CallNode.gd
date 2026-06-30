extends ASTNode
class_name CallNode

# CALL <name>;
# Jumps into the function body and returns to the next statement after CALL.

var name: String
var args: Array[String] = []


func _init(_name: String, _args: Array = []) -> void:
	name = _name
	args.clear()
	for a in _args:
		args.append(str(a).strip_edges())


func execute(runtime: MiniCRuntime) -> void:
	if runtime == null:
		push_error("CallNode.execute: runtime is null")
		return

	var fn_sig: Dictionary = runtime.get_function_signature(name)
	if fn_sig.is_empty():
		push_error("CALL unknown function: " + str(name))
		return
	var fn_body: ProgramNode = fn_sig.get("body", null)
	var fn_params: Array = fn_sig.get("params", [])
	if fn_body == null:
		push_error("CALL invalid function body: " + str(name))
		return
	if args.size() != fn_params.size():
		push_error("CALL '%s' expects %d args, got %d" % [name, fn_params.size(), args.size()])
		return

	# ProgramNode sets these before running the statement, so we can return to
	# the next statement after CALL.
	var return_program: ProgramNode = runtime._current_program
	var return_ip := runtime._resume_ip + 1
	var scope_restore := runtime.push_function_scope(fn_params, args)

	# Reuse the same "return stack" mechanism used by IF bodies.
	runtime.push_return(fn_body, return_program, return_ip, scope_restore)
	runtime.save_execution_state(fn_body, 0)

	# Prevent the caller ProgramNode from auto-advancing to ip+1 in the same tick;
	# control is now managed by save_execution_state().
	runtime.block_fallthrough(return_program)
