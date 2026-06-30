extends ASTNode
class_name ProgramNode

var statements: Array = []

# ===============================
# BUILD
# ===============================
func add_statement(stmt: ASTNode) -> void:
	statements.append(stmt)


# ===============================
# DEBUG DUMP
# ===============================
func debug_dump(prefix := "") -> void:
	print(prefix, "ProgramNode dump:")
	for i in range(statements.size()):
		var s = statements[i]
		print(prefix, "  [", i, "] ", s.get_class())


# ===============================
# CORE EXECUTION
# ===============================
func execute_from(runtime: MiniCRuntime, ip: int) -> void:
	print("ProgramNode.execute_from ip =", ip)

	debug_dump("   ")

	# END OF PROGRAM
	if ip >= statements.size():
		print("ProgramNode END (ip out of range)")
		runtime.consume_pending_clear()
		# BREAK: exit nearest loop
		if runtime.is_breaking():
			var loop_break = runtime.pop_nearest_loop_for_break()
			if loop_break != null:
				runtime.consume_pending_clear()
				if loop_break.has("loop_owner") and loop_break["loop_owner"] is RepeatNode:
					loop_break["loop_owner"].force_reset()
				runtime.clear_break()
				runtime.save_execution_state(loop_break["outer_program"], loop_break["outer_ip"] + 1)
				return
			runtime.clear_break()
			runtime.notify_execution_finished()
			return
		# Return to caller if this ProgramNode is an IF body
		var ret = runtime.pop_return_for_body(self)
		if ret != null:
			runtime.pop_function_scope(ret.get("scope_restore", {}))
			runtime.save_execution_state(ret["return_program"], ret["return_ip"])
			return
		# If this ProgramNode is a WHILE body, jump back to the WHILE statement.
		var loop_info = runtime.pop_loop_for_body(self)
		if loop_info != null:
			if loop_info.has("loop_owner") and loop_info["loop_owner"] is RepeatNode:
				if loop_info["loop_owner"].should_continue():
					runtime.save_execution_state(loop_info["outer_program"], loop_info["outer_ip"])
				else:
					loop_info["loop_owner"].reset_done()
					runtime.save_execution_state(loop_info["outer_program"], loop_info["outer_ip"] + 1)
			else:
				runtime.save_execution_state(loop_info["outer_program"], loop_info["outer_ip"])
			return
		runtime.notify_execution_finished()
		return

	var stmt: ASTNode = statements[ip]
	print("Execute stmt[", ip, "] =", stmt.get_class())

	# Track current program/ip so WAIT UNTIL can resume correctly.
	runtime._current_program = self
	runtime._resume_ip = ip
	runtime.notify_line_executing(stmt.line)
	stmt.execute(runtime)

	# WAIT gate
	if runtime.is_waiting():
		print("ProgramNode WAIT at ip =", ip)
		# If this statement set flow control (e.g. WHILE), consume it now so
		# a stale flag does not block fallthrough when the loop condition later
		# becomes false.
		runtime.consume_flow_controlled(self)
		runtime.save_execution_state(self, ip)
		return

	# BREAK handling (exit WHILE body if applicable)
	if runtime.is_breaking():
		# Break exits the nearest WHILE immediately, even if BREAK is inside IF bodies.
		var loop_info = runtime.pop_nearest_loop_for_break()
		if loop_info != null:
			# Avoid leaking a pending sensor clear into unrelated code after the loop.
			runtime.consume_pending_clear()
			if loop_info.has("loop_owner") and loop_info["loop_owner"] is RepeatNode:
				loop_info["loop_owner"].force_reset()
			runtime.clear_break()
			runtime.save_execution_state(loop_info["outer_program"], loop_info["outer_ip"] + 1)
		else:
			# BREAK outside any loop -> just clear and stop.
			runtime.clear_break()
			runtime.notify_execution_finished()
		return

	# Clear sensor after the next statement has consumed it.
	# If this statement is a WAIT UNTIL, defer clearing to the following statement.
	if not (stmt is WaitUntilNode):
		runtime.consume_pending_clear()
 
	# FLOW CONTROL (e.g., WHILE)
	if runtime.consume_flow_controlled(self):
		return

	# NORMAL FALLTHROUGH
	print("ProgramNode NEXT ip =", ip + 1)
	runtime.save_execution_state(self, ip + 1)
