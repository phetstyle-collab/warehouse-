extends RefCounted
class_name MiniCParser

static var _last_parser_errors: Array = []

var _errors: Array = []
var _line_nums: Array = []

static func clear_errors() -> void:
	_last_parser_errors.clear()

static func get_errors() -> Array:
	return _last_parser_errors

func _report_error(msg: String) -> void:
	_errors.append(msg)
	push_error(msg)

func _line_at(index: int) -> int:
	if index < 0 or index >= _line_nums.size():
		return -1
	return int(_line_nums[index])


static func parse(source: String) -> ProgramNode:
	var parser := MiniCParser.new()
	var program := parser._do_parse(source)
	_last_parser_errors = parser._errors
	return program

func _do_parse(source: String) -> ProgramNode:
	_errors.clear()
	_line_nums = []
	var lines: Array = []
	# Reflow each original source line independently (braces/ELSE get split onto
	# their own synthetic lines) while recording which original line each
	# synthetic line came from, so execution can later highlight the right line.
	var raw_lines := source.split("\n", true)
	for raw_index in range(raw_lines.size()):
		var text := str(raw_lines[raw_index])
		text = text.replace("} ELSE {", "}\nELSE {")
		text = text.replace("}ELSE{", "}\nELSE {")
		text = text.replace("}ELSE {", "}\nELSE {")
		text = text.replace("} ELSE{", "}\nELSE {")
		text = text.replace("{", "{\n")
		text = text.replace("}", "\n}\n")
		for piece in text.split("\n", false):
			var trimmed := str(piece).strip_edges()
			if trimmed == "":
				continue
			lines.append(trimmed)
			_line_nums.append(raw_index)
	var result := _parse_program(lines, 0)
	if result == null:
		return null
	if _errors.size() > 0:
		return null
	return result.program


# ==================================================
# PROGRAM BLOCK (ONE block -> returns when '}' found)
# returns ParseResult (program, next_index)
# ==================================================
func _parse_program(lines: Array, start: int) -> ParseResult:
	var program := ProgramNode.new()
	var i := start

	while i < lines.size():
		var line := str(lines[i]).strip_edges()

		# skip empty / comments
		if line == "" or line.begins_with("#"):
			i += 1
			continue

		# block end
		if line == "}":
			break

		# FUNC
		if _starts_with_keyword(line, "FUNC"):
			var r := _parse_func(lines, i)
			if r == null:
				return null
			r.node.line = _line_at(i)
			program.add_statement(r.node)
			i = r.next_index
			continue

		# WHILE
		if _starts_with_keyword(line, "WHILE"):
			var r := _parse_while(lines, i)
			if r == null:
				return null
			r.node.line = _line_at(i)
			program.add_statement(r.node)
			i = r.next_index
			continue

		# REPEAT
		if _starts_with_keyword(line, "REPEAT"):
			var r := _parse_repeat(lines, i)
			if r == null:
				return null
			r.node.line = _line_at(i)
			program.add_statement(r.node)
			i = r.next_index
			continue

		# IF
		if _starts_with_keyword(line, "IF"):
			var r := _parse_if(lines, i)
			if r == null:
				return null
			r.node.line = _line_at(i)
			program.add_statement(r.node)
			i = r.next_index
			continue

		# WAIT UNTIL (single-line or block)
		if _starts_with_keyword(line, "WAIT UNTIL"):
			var r := _parse_wait_until(lines, i, program)
			if r == null:
				return null
			i = r.next_index
			continue

		# CALL <name>;
		if _starts_with_keyword(line, "CALL"):
			var call_node := _parse_call(line, i)
			if call_node != null:
				call_node.line = _line_at(i)
				program.add_statement(call_node)
			i += 1
			continue

		# var alias (macro-style)
		# grammar:
		#   var <name> = <ACTION...> ;
		#   var <name> = <numeric_expr> ;
		if _starts_with_keyword(line, "VAR"):
			var var_node := _parse_var_statement(line, i)
			if var_node != null:
				var_node.line = _line_at(i)
				program.add_statement(var_node)
			i += 1
			continue

		# Numeric assignment:
		#   <identifier> = <numeric_expr> ;
		var assign_node := _parse_number_assign(line, i)
		if assign_node != null:
			assign_node.line = _line_at(i)
			program.add_statement(assign_node)
			i += 1
			continue

		# BREAK (allow trailing ;)
		var break_line := line
		if break_line.ends_with(";"):
			break_line = break_line.substr(0, break_line.length() - 1).strip_edges()
		if break_line.to_upper() == "BREAK":
			var break_node := BreakNode.new()
			break_node.line = _line_at(i)
			program.add_statement(break_node)
			i += 1
			continue

		# ACTION (opcode-only detector)
		var action_line := _normalize_action(line)
		if action_line == "__MISSING_SEMI__":
			i += 1
			continue
		if action_line != "":
			var action_node := ActionNode.new(action_line)
			action_node.line = _line_at(i)
			program.add_statement(action_node)
			i += 1
			continue

		# Alias invocation: <name>;
		# Parsed as ActionNode(name) and resolved by runtime at execution time.
		var maybe_alias := line
		if maybe_alias.ends_with(";"):
			maybe_alias = maybe_alias.substr(0, maybe_alias.length() - 1).strip_edges()
			if _is_identifier(maybe_alias):
				var alias_node := ActionNode.new(maybe_alias)
				alias_node.line = _line_at(i)
				program.add_statement(alias_node)
			i += 1
			continue

		# unknown
		_report_error("MiniCParser: unknown statement → " + line)
		i += 1

	return ParseResult.new(program, i)


# ==================================================
# FUNC
# grammar: FUNC <identifier> {
#          FUNC <identifier>(p1, p2, ...) {
# ==================================================
func _parse_func(lines: Array, start: int) -> ParseIfResult:
	var header := str(lines[start]).strip_edges()
	if not header.ends_with("{"):
		_report_error("FUNC must end with '{' at line " + str(start))
		return null

	# extract signature between "FUNC" and "{"
	var signature := header.substr(4, header.length() - 5).strip_edges()
	var name_text := signature
	var param_names: Array[String] = []
	var open_idx := signature.find("(")
	if open_idx >= 0:
		var close_idx := signature.rfind(")")
		if close_idx < 0 or close_idx != signature.length() - 1:
			_report_error("Invalid FUNC parameter list at line " + str(start))
			return null
		name_text = signature.substr(0, open_idx).strip_edges()
		var raw_params := signature.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
		param_names = _parse_identifier_list(raw_params, "FUNC params", start)
		if raw_params != "" and param_names.is_empty():
			return null
	if not _is_identifier(name_text):
		_report_error("Invalid FUNC name at line " + str(start) + ": " + name_text)
		return null

	var upper := name_text.to_upper()
	var reserved := ["FUNC", "CALL", "VAR", "IF", "ELSE", "WHILE", "REPEAT", "WAIT", "UNTIL", "TRUE", "FALSE", "BREAK"]
	if reserved.has(upper):
		_report_error("Reserved name cannot be used as FUNC at line " + str(start) + ": " + name_text)
		return null

	# Avoid ambiguity with action opcodes (CALL START_SPAWNER; vs START_SPAWNER;).
	var action_opcodes := [
		"START_CONVEYOR",
		"STOP_CONVEYOR",
		"START_SPAWNER",
		"STOP_SPAWNER",
		"PICK_BOX",
		"DROP_BOX",
		"ROTATE_ARM",
		"MOVE_PATH",
		"DIVERTER_LEFT",
		"DIVERTER_RIGHT",
		"DIVERTER_OPEN",
		"DIVERTER_CLOSE",
		"SET_DIVERTER_LEFT",
		"SET_DIVERTER_RIGHT",
		"SET_DIVERTER_OPEN",
		"SET_DIVERTER_CLOSE"
	]
	if action_opcodes.has(upper) or upper.begins_with("START_CONV") or upper.begins_with("STOP_CONV"):
		_report_error("Action opcode name cannot be used as FUNC at line " + str(start) + ": " + name_text)
		return null

	# Parse function body until matching '}'.
	var body_r := _parse_program(lines, start + 1)
	if body_r == null:
		return null
	if body_r.next_index >= lines.size() or str(lines[body_r.next_index]).strip_edges() != "}":
		_report_error("FUNC missing closing '}' for block starting at line " + str(start))
		return null

	var i := body_r.next_index + 1
	return ParseIfResult.new(FuncDefNode.new(name_text, body_r.program, param_names), i)


# ==================================================
# CALL
# grammar: CALL <identifier> ;
#          CALL <identifier>(arg1, arg2, ...) ;
# ==================================================
func _parse_call(line: String, line_index: int) -> CallNode:
	var s := str(line).strip_edges()
	if not _starts_with_keyword(s, "CALL"):
		return null
	if not s.ends_with(";"):
		_report_error("CALL must end with ';' at line " + str(line_index) + ": " + s)
		return null

	var inner := s.substr(4, s.length() - 5).strip_edges()
	var call_name := inner
	var arg_exprs: Array[String] = []
	var open_idx := inner.find("(")
	if open_idx >= 0:
		var close_idx := inner.rfind(")")
		if close_idx < 0 or close_idx != inner.length() - 1:
			_report_error("Invalid CALL argument list at line " + str(line_index) + ": " + inner)
			return null
		call_name = inner.substr(0, open_idx).strip_edges()
		var raw_args := inner.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
		arg_exprs = _parse_call_args(raw_args, line_index)
		if raw_args != "" and arg_exprs.is_empty():
			return null
	if not _is_identifier(call_name):
		_report_error("Invalid CALL target at line " + str(line_index) + ": " + call_name)
		return null

	return CallNode.new(call_name, arg_exprs)


# ==================================================
# WHILE
# grammar: WHILE <comparison-or-TRUE/FALSE> {
# ==================================================
func _parse_while(lines: Array, start: int) -> ParseIfResult:
	var header := str(lines[start]).strip_edges()
	if not header.ends_with("{"):
		_report_error("WHILE must end with '{' at line " + str(start))
		return null

	# extract between "WHILE" and "{"
	var cond_text := header.substr(5, header.length() - 6).strip_edges()
	cond_text = _strip_optional_wrapping_parentheses(cond_text, "WHILE", start)
	if cond_text == "":
		_report_error("WHILE condition is empty at line " + str(start))
		return null
	var condition := _parse_condition(cond_text)
	if condition == null:
		# allow WHILE TRUE/FALSE special forms handled by _parse_comparison
		_report_error("Invalid WHILE condition: " + cond_text)
		return null

	var body_r := _parse_program(lines, start + 1)
	if body_r == null:
		return null
	if body_r.next_index >= lines.size() or str(lines[body_r.next_index]).strip_edges() != "}":
		_report_error("WHILE missing closing '}' for block starting at line " + str(start))
		return null

	var i := body_r.next_index + 1
	return ParseIfResult.new(WhileNode.new(condition, body_r.program), i)


# ==================================================
# IF
# grammar: IF <comparison> {
# ==================================================
func _parse_if(lines: Array, start: int) -> ParseIfResult:
	var header := str(lines[start]).strip_edges()
	if not header.ends_with("{"):
		_report_error("IF must end with '{' at line " + str(start))
		return null

	var cond_text := header.substr(2, header.length() - 3).strip_edges()
	if not (cond_text.begins_with("(") and cond_text.ends_with(")")):
		_report_error("IF must use parenthesized form: if (<condition>) { ... } at line " + str(start))
		return null
	cond_text = cond_text.substr(1, cond_text.length() - 2).strip_edges()
	if cond_text == "":
		_report_error("IF condition is empty at line " + str(start))
		return null
	var condition := _parse_condition(cond_text)
	if condition == null:
		_report_error("Invalid IF condition: " + cond_text)
		return null

	var then_r := _parse_program(lines, start + 1)
	if then_r == null:
		return null
	if then_r.next_index >= lines.size() or str(lines[then_r.next_index]).strip_edges() != "}":
		_report_error("IF missing closing '}' for block starting at line " + str(start))
		return null

	var i := then_r.next_index + 1

	# Optional ELSE block
	var else_program: ProgramNode = null
	var j := i
	while j < lines.size():
		var peek := str(lines[j]).strip_edges()
		if peek == "" or peek.begins_with("#"):
			j += 1
			continue
		if _starts_with_keyword(peek, "ELSE"):
			if not peek.ends_with("{"):
				_report_error("ELSE must end with '{' at line " + str(j))
				return null
			var else_r := _parse_program(lines, j + 1)
			if else_r == null:
				return null
			if else_r.next_index >= lines.size() or str(lines[else_r.next_index]).strip_edges() != "}":
				_report_error("ELSE missing closing '}' for block starting at line " + str(j))
				return null
			else_program = else_r.program
			i = else_r.next_index + 1
		break

	# ConditionNode: (condition, then_program, else_program)
	return ParseIfResult.new(ConditionNode.new(condition, then_r.program, else_program), i)


# ==================================================
# REPEAT
# grammar: REPEAT <int> {
# ==================================================
func _parse_repeat(lines: Array, start: int) -> ParseIfResult:
	var header := str(lines[start]).strip_edges()
	if not header.ends_with("{"):
		_report_error("REPEAT must end with '{' at line " + str(start))
		return null

	var inner := header.substr(6, header.length() - 7).strip_edges()
	# Support C-like form: REPEAT(<int>) { ... }
	inner = _strip_optional_wrapping_parentheses(inner, "REPEAT", start)
	if inner == "" or not inner.is_valid_int():
		_report_error("REPEAT requires integer count at line " + str(start))
		return null

	var count := int(inner)
	var body_r := _parse_program(lines, start + 1)
	if body_r == null:
		return null
	if body_r.next_index >= lines.size() or str(lines[body_r.next_index]).strip_edges() != "}":
		_report_error("REPEAT missing closing '}' for block starting at line " + str(start))
		return null

	var i := body_r.next_index + 1
	return ParseIfResult.new(RepeatNode.new(count, body_r.program), i)


# ==================================================
# WAIT UNTIL
# WAIT UNTIL is a gate.
# Supported syntax:
#   WAIT UNTIL (action(done));                 # statement form
#   WAIT UNTIL (weight(has_value));            # statement form
#   WAIT UNTIL (<comparison>);                 # statement form, e.g. (weight > 5)
#   WAIT UNTIL (...) { ... }                   # block sugar, expanded to WAIT + body
# ==================================================
func _parse_wait_until(lines: Array, start: int, program: ProgramNode) -> ParseIfResult:
	var header := str(lines[start]).strip_edges()
	var is_block := false
	var is_statement := false
	if header.ends_with("{"):
		is_block = true
		header = header.substr(0, header.length() - 1).strip_edges()
	elif header.ends_with(";"):
		is_statement = true
		header = header.substr(0, header.length() - 1).strip_edges()
	else:
		_report_error("WAIT UNTIL must end with ';' or '{' at line " + str(start))
		return null

	# extract condition text after "WAIT UNTIL"
	var cond_text := header.substr(10, header.length() - 10).strip_edges()
	if cond_text == "":
		_report_error("WAIT UNTIL missing condition at line " + str(start))
		return null

	# Enforce parenthesized condition form:
	#   WAIT UNTIL (<condition>)
	# Legacy no-parentheses forms are intentionally rejected.
	if not (cond_text.begins_with("(") and cond_text.ends_with(")")):
		_report_error("WAIT UNTIL must use new form: wait until (action(done)) or wait until (weight(has_value)) at line " + str(start))
		return null
	var inner := cond_text.substr(1, cond_text.length() - 2).strip_edges()
	if inner == "":
		_report_error("WAIT UNTIL condition is empty at line " + str(start))
		return null

	# build wait node
	var wait_node: WaitUntilNode = null
	if _is_wait_action_done_call(inner):
		wait_node = WaitUntilNode.new(WaitUntilNode.WaitType.ACTION_DONE, null)
	else:
		# Normalize sensor(has_value) to parser-friendly form: "sensor HAS_VALUE".
		var normalized_sensor_state := _normalize_wait_sensor_state_call(inner)
		if normalized_sensor_state != "":
			inner = normalized_sensor_state

		var condition := _parse_condition(inner)
		if condition == null:
			_report_error("Invalid WAIT UNTIL condition: " + inner)
			return null
		wait_node = WaitUntilNode.new(WaitUntilNode.WaitType.SENSOR_CONDITION, condition)

	wait_node.line = _line_at(start)

	# statement form: WAIT UNTIL <cond>;
	# Runtime resumes at next statement after condition becomes true.
	if is_statement:
		program.add_statement(wait_node)
		return ParseIfResult.new(null, start + 1)

	# block form: WAIT UNTIL <cond> { ... }
	if is_block:
		var body_r := _parse_program(lines, start + 1)
		if body_r == null:
			return null
		if body_r.next_index >= lines.size() or str(lines[body_r.next_index]).strip_edges() != "}":
			_report_error("WAIT UNTIL missing closing '}' for block starting at line " + str(start))
			return null
		# Expand to: WAIT UNTIL <cond> ; <body statements...>
		program.add_statement(wait_node)
		for stmt in body_r.program.statements:
			program.add_statement(stmt)
		var i := body_r.next_index + 1
		return ParseIfResult.new(null, i)

	# Unreachable (guarded by ';'/'{' checks above).
	return null

func _is_wait_action_done_call(text: String) -> bool:
	var compact := str(text).to_lower().replace(" ", "")
	return compact == "action(done)"

func _normalize_wait_sensor_state_call(text: String) -> String:
	var compact := str(text).to_lower().replace(" ", "")
	var open_idx := compact.find("(")
	var close_idx := compact.rfind(")")
	if open_idx <= 0 or close_idx < 0 or close_idx != compact.length() - 1:
		return ""
	var sensor := compact.substr(0, open_idx)
	if not _is_identifier(sensor):
		return ""
	var state := compact.substr(open_idx + 1, close_idx - open_idx - 1)
	if state == "has_value":
		return sensor + " HAS_VALUE"
	if state == "not_detected":
		return sensor + " NOT_DETECTED"
	return ""


# ==================================================
# COMPARISON
# Accepts:
#   TRUE
#   FALSE
#   sensor op value   (e.g. weight > 5)
#   sensor HAS_VALUE   (or sensor IS HAS_VALUE)
#   sensor NOT_DETECTED
# ==================================================
func _parse_condition(text: String) -> ASTNode:
	if text == null:
		return null

	var s := text.strip_edges()

	# Support combined comparisons with boolean operators.
	# Precedence: && higher than ||
	# Example: weight > 5 && weight < 7
	var tokens := s.replace("&&", " && ").replace("||", " || ").split(" ", false)
	if tokens.size() == 0:
		return null

	var st := {"i": 0}
	var expr := _parse_or(tokens, st)
	if expr == null:
		return null
	# If we didn't consume all tokens, something is malformed.
	if int(st["i"]) < tokens.size():
		_report_error("Invalid condition (unexpected token): " + str(tokens[int(st["i"])]))
		return null
	return expr


func _parse_or(tokens: Array, st: Dictionary) -> ASTNode:
	var left := _parse_and(tokens, st)
	if left == null:
		return null
	while int(st["i"]) < tokens.size() and str(tokens[int(st["i"])]) == "||":
		st["i"] = int(st["i"]) + 1
		var right := _parse_and(tokens, st)
		if right == null:
			return null
		left = LogicalNode.new("||", left, right)
	return left


func _parse_and(tokens: Array, st: Dictionary) -> ASTNode:
	var left := _parse_atom(tokens, st)
	if left == null:
		return null
	while int(st["i"]) < tokens.size() and str(tokens[int(st["i"])]) == "&&":
		st["i"] = int(st["i"]) + 1
		var right := _parse_atom(tokens, st)
		if right == null:
			return null
		left = LogicalNode.new("&&", left, right)
	return left


func _parse_atom(tokens: Array, st: Dictionary) -> ASTNode:
	# Parse a single comparison expression until we hit && / || or end.
	if int(st["i"]) >= tokens.size():
		return null
	var parts: Array = []
	while int(st["i"]) < tokens.size():
		var t := str(tokens[int(st["i"])])
		if t == "&&" or t == "||":
			break
		parts.append(t)
		st["i"] = int(st["i"]) + 1
	var text := " ".join(parts).strip_edges()
	return _parse_comparison_atom(text)


func _parse_comparison_atom(text: String) -> ComparisonNode:
	if text == null:
		return null

	var s := text.strip_edges()
	var s_upper := s.to_upper()
	if s_upper == "TRUE":
		return ComparisonNode.new("__const__", "==", true)
	if s_upper == "FALSE":
		return ComparisonNode.new("__const__", "==", false)

	var parts := s.split(" ", false)
	if parts.size() < 2:
		_report_error("Invalid comparison (too short): " + s)
		return null

	var sensor := parts[0]
	var op := ""
	var raw = null 

	# support 2-token forms: "sensor HAS_VALUE"
	# and 3+ token forms: "sensor IS HAS_VALUE" or "sensor > 5"
	if parts.size() == 2:
		op = _normalize_word_operator(parts[1])
		raw = null
	else:
		op = _normalize_word_operator(parts[1])
		raw = ""
		for j in range(2, parts.size()):
			raw += parts[j]
			if j < parts.size() - 1:
				raw += " "
		raw = raw.strip_edges()

	# interpret semantic values
	var value = null
	var op_upper := str(op).to_upper()
	match raw:
		null:
			# two-token forms or operator-only forms
			if op_upper == "HAS_VALUE" or op_upper == "EXISTS":
				op = "IS"
				value = ComparisonNode.HAS_VALUE
			elif op_upper == "NOT_DETECTED":
				op = "IS"
				value = ComparisonNode.NOT_DETECTED
			else:
				# if op is relational and no raw -> invalid
				if ["==", "!=", ">", "<", ">=", "<=", "IS"].has(op_upper) == false:
					_report_error("Invalid comparison operator or missing value: " + op + " in '" + s + "'")
					return null
				# treat missing raw for IS as error unless IS used with HAS_VALUE before
				if op_upper == "IS":
					_report_error("Operator 'IS' requires a right-hand token for: " + s)
					return null
				# for '==' etc without raw -> invalid
				_report_error("Missing right-hand value for operator " + op + " in: " + s)
				return null

		_:
			# raw exists -> parse number or special keyword
			var raw_upper := str(raw).to_upper()
			if raw_upper == "HAS_VALUE" or raw_upper == "EXISTS":
				value = ComparisonNode.HAS_VALUE
			elif raw_upper == "NOT_DETECTED":
				value = ComparisonNode.NOT_DETECTED
			elif raw_upper == "TRUE":
				value = true
			elif raw_upper == "FALSE":
				value = false
			elif raw.is_valid_int():
				value = int(raw)
			elif raw.is_valid_float():
				value = float(raw)
			else:
				# raw as string literal
				value = raw

	# Final sanity: ensure op is meaningful
	# allow alias "IS" => treat as '==' with special RHS handled above
	if op_upper == "IS" and (value == ComparisonNode.HAS_VALUE or value == ComparisonNode.NOT_DETECTED):
		# keep op as "IS" (ComparisonNode.evaluate should understand this)
		pass

	return ComparisonNode.new(sensor, op, value)


# ==================================================
# ACTION DETECTOR
# - checks first token opcode
# - extend list if you add new opcodes
# ==================================================
func _normalize_action(line: String) -> String:
	var trimmed := str(line).strip_edges()
	# Parse opcode from the semicolon-stripped form so no-arg actions like
	# "START_SPAWNER;" are detected correctly (otherwise opcode would include ';').
	var has_semi := trimmed.ends_with(";")
	var candidate := trimmed
	if has_semi:
		candidate = trimmed.substr(0, trimmed.length() - 1).strip_edges()

	# ROTATE must use function-like syntax:
	#   rotate(arm(-90));
	var first_token := ""
	var first_parts := candidate.split(" ", false)
	if first_parts.size() > 0:
		first_token = str(first_parts[0]).to_upper()
	if first_token.begins_with("START(") or first_token.begins_with("STOP("):
		return _normalize_start_stop_call_action(candidate, line, has_semi)
	if first_token.begins_with("ROTATE_ARM"):
		_report_error("Use rotate(arm(<angle>)); or rotate(arm_1(<angle>)); ROTATE_ARM(...) is not allowed at: " + line)
		return "__MISSING_SEMI__"
	if first_token.begins_with("ROTATE("):
		return _normalize_rotate_arm_action(candidate, line, has_semi)
	if first_token.begins_with("PICK(") or first_token.begins_with("DROP("):
		return _normalize_pick_drop_action(candidate, line, has_semi)
	if first_token == "ROBOT":
		return _normalize_robot_path_action(candidate, line, has_semi)
	if first_token == "ROD" or first_token == "CART":
		return _normalize_cart_action(candidate, line, has_semi)
	if first_token.begins_with("SET("):
		return _normalize_set_call_action(candidate, line, has_semi)
	if first_token.begins_with("START_CONV") or first_token.begins_with("STOP_CONV"):
		_report_error("Use start(conveyor) / start(conveyor, n) / stop(conveyor) / stop(conveyor, n) only at: " + line)
		return "__MISSING_SEMI__"
	if first_token.begins_with("DIVERTER_") or first_token.begins_with("SET_DIVERTER_"):
		return _normalize_diverter_action(candidate, line, has_semi)

	var parts := candidate.split(" ", false)
	if parts.size() == 0:
		return ""
	var opcode := parts[0]
	var opcode_upper := opcode.to_upper()

	var actions := [
		"START_CONVEYOR",
		"STOP_CONVEYOR",
		"START_SPAWNER",
		"STOP_SPAWNER",
		"PICK_BOX",
		"DROP_BOX",
		"ROTATE_ARM",
		"MOVE_PATH",
		"DIVERTER_LEFT",
		"DIVERTER_RIGHT",
		"DIVERTER_OPEN",
		"DIVERTER_CLOSE",
		"SET_DIVERTER_LEFT",
		"SET_DIVERTER_RIGHT",
		"SET_DIVERTER_OPEN",
		"SET_DIVERTER_CLOSE"
	]
	# Enforce start/stop call style only (disallow direct opcodes).
	if opcode_upper == "START_SPAWNER" or opcode_upper == "STOP_SPAWNER":
		_report_error("Use start(spawner); or stop(spawner); only at: " + line)
		return "__MISSING_SEMI__"
	if opcode_upper == "START_CONVEYOR" or opcode_upper == "STOP_CONVEYOR" or opcode_upper.begins_with("START_CONV") or opcode_upper.begins_with("STOP_CONV"):
		_report_error("Use start(conveyor); start(conveyor, n); stop(conveyor); or stop(conveyor, n); only at: " + line)
		return "__MISSING_SEMI__"
	if _is_action_opcode(opcode_upper, actions):
		if not has_semi:
			_report_error("Action must end with ';' at: " + line)
			return "__MISSING_SEMI__"
		return opcode_upper + candidate.substr(opcode.length())

	return ""

func _normalize_robot_path_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("Robot path command must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var parts := candidate.split(" ", false)
	if parts.size() != 3 and parts.size() != 4:
		_report_error("Use robot arm to A;, robot arm home;, or robot arm pick; at: " + line)
		return "__MISSING_SEMI__"
	if str(parts[0]).strip_edges().to_lower() != "robot":
		return ""
	if str(parts[1]).strip_edges().to_lower() != "arm":
		_report_error("Use robot arm to A;, robot arm home;, or robot arm pick; at: " + line)
		return "__MISSING_SEMI__"

	var path_name := ""
	if parts.size() == 3:
		path_name = str(parts[2]).strip_edges()
	else:
		if str(parts[2]).strip_edges().to_lower() != "to":
			_report_error("Use robot arm to A;, robot arm home;, or robot arm pick; at: " + line)
			return "__MISSING_SEMI__"
		path_name = str(parts[3]).strip_edges()
	if not _is_identifier(path_name):
		_report_error("Robot path name must be identifier at: " + line)
		return "__MISSING_SEMI__"
	return "ROBOT_MOVE_PATH " + path_name

func _normalize_cart_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("Cart command must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var parts := candidate.split(" ", false)
	if parts.size() != 2 and parts.size() != 3:
		_report_error("Use rod to A;, rod home;, rod pick;, or rod drop; at: " + line)
		return "__MISSING_SEMI__"
	var subject := str(parts[0]).strip_edges().to_lower()
	if subject != "rod" and subject != "cart":
		return ""

	var direct_command := str(parts[1]).strip_edges().to_lower()
	if parts.size() == 2 and direct_command == "pick":
		return "ROD_PICK_BOX"
	if parts.size() == 2 and direct_command == "drop":
		return "ROD_DROP_BOX"

	var path_name := ""
	if parts.size() == 2:
		path_name = str(parts[1]).strip_edges()
	else:
		if str(parts[1]).strip_edges().to_lower() != "to":
			_report_error("Use rod to A;, rod home;, rod pick;, or rod drop; at: " + line)
			return "__MISSING_SEMI__"
		path_name = str(parts[2]).strip_edges()
	if not _is_identifier(path_name):
		_report_error("Cart path name must be identifier at: " + line)
		return "__MISSING_SEMI__"
	return "ROD_MOVE_PATH " + path_name

func _normalize_conveyor_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("Action must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var trimmed := candidate.strip_edges()
	var open_idx := trimmed.find("(")
	if open_idx >= 0:
		var close_idx := trimmed.rfind(")")
		if close_idx < 0 or close_idx != trimmed.length() - 1:
			_report_error("Conveyor command must use function style: START_CONVEYOR(n); or STOP_CONVEYOR(n); at: " + line)
			return "__MISSING_SEMI__"

		var prefix := trimmed.substr(0, open_idx).strip_edges().to_upper()
		var fn_opcode := _normalize_conveyor_opcode(prefix)
		if fn_opcode == "":
			return ""

		var index_text := trimmed.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
		if index_text == "":
			return fn_opcode
		if not index_text.is_valid_int() and not _is_identifier(index_text):
			_report_error("Conveyor index must be integer or identifier at: " + line)
			return "__MISSING_SEMI__"
		return fn_opcode + " " + index_text

	var parts := trimmed.split(" ", false)
	if parts.is_empty():
		return ""

	var opcode := _normalize_conveyor_opcode(str(parts[0]).to_upper())
	if opcode == "":
		return ""
	if parts.size() == 1:
		return opcode
	if parts.size() == 2 and (str(parts[1]).is_valid_int() or _is_identifier(str(parts[1]))):
		return opcode + " " + str(parts[1])

	_report_error("Invalid conveyor command format at: " + line)
	return "__MISSING_SEMI__"

func _normalize_conveyor_opcode(opcode: String) -> String:
	var up := str(opcode).to_upper()
	if up.begins_with("START_CONV"):
		return "START_CONVEYOR"
	if up.begins_with("STOP_CONV"):
		return "STOP_CONVEYOR"
	return ""

func _normalize_rotate_arm_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("ROTATE_ARM must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var open_idx := candidate.find("(")
	var close_idx := candidate.rfind(")")
	if open_idx < 0 or close_idx < 0 or close_idx != candidate.length() - 1:
		_report_error("ROTATE must use function style: rotate(arm(angle)); or rotate(arm_1(angle)); at: " + line)
		return "__MISSING_SEMI__"

	var prefix := candidate.substr(0, open_idx).strip_edges().to_upper()
	var args_text := candidate.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()

	if prefix == "ROTATE":
		# Preferred style:
		#   rotate(arm(-90));
		# Multi-arm style:
		#   rotate(arm_1(-90));
		var compact := args_text.replace(" ", "")
		if compact.begins_with("arm(") and compact.ends_with(")"):
			var inner := compact.substr(4, compact.length() - 5).strip_edges()
			if inner == "":
				_report_error("ROTATE form is rotate(arm(angle)); at: " + line)
				return "__MISSING_SEMI__"
			if not inner.is_valid_int() and not inner.is_valid_float() and not _is_identifier(inner):
				_report_error("ROTATE angle must be numeric or identifier at: " + line)
				return "__MISSING_SEMI__"
			return "ROTATE_ARM " + inner

		var arm_open := compact.find("(")
		var arm_close := compact.rfind(")")
		if arm_open > 0 and arm_close >= 0 and arm_close == compact.length() - 1:
			var arm_label := compact.substr(0, arm_open).strip_edges()
			var arm_angle := compact.substr(arm_open + 1, arm_close - arm_open - 1).strip_edges()
			if not _is_identifier(arm_label):
				_report_error("ROTATE arm label must be identifier at: " + line)
				return "__MISSING_SEMI__"
			if not arm_label.to_lower().begins_with("arm_"):
				_report_error("ROTATE multi-arm label must start with arm_ (e.g. arm_1) at: " + line)
				return "__MISSING_SEMI__"
			if arm_angle == "" or (not arm_angle.is_valid_int() and not arm_angle.is_valid_float() and not _is_identifier(arm_angle)):
				_report_error("ROTATE angle must be numeric or identifier at: " + line)
				return "__MISSING_SEMI__"
			return "ROTATE_ARM %s %s" % [arm_label.to_lower(), arm_angle]

		_report_error("ROTATE form is rotate(arm(angle)); or rotate(arm_1(angle)); at: " + line)
		return "__MISSING_SEMI__"

	return ""

func _normalize_pick_drop_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("Action must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var trimmed := candidate.strip_edges()
	var open_idx := trimmed.find("(")
	var close_idx := trimmed.rfind(")")
	if open_idx <= 0 or close_idx < 0 or close_idx != trimmed.length() - 1:
		_report_error("Use pick(box); drop(box); pick(arm_1, box); or drop(arm_1, box); at: " + line)
		return "__MISSING_SEMI__"

	var verb := trimmed.substr(0, open_idx).strip_edges().to_upper()
	var args_text := trimmed.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
	var args := args_text.split(",", false)

	if args.size() == 1:
		var arg := str(args[0]).strip_edges().to_lower()
		if arg != "box":
			_report_error("pick/drop target must be box at: " + line)
			return "__MISSING_SEMI__"
		if verb == "PICK":
			return "PICK_BOX"
		if verb == "DROP":
			return "DROP_BOX"
		return ""

	if args.size() == 2:
		var arm_label := str(args[0]).strip_edges().to_lower()
		var target := str(args[1]).strip_edges().to_lower()
		if target != "box":
			_report_error("pick/drop target must be box at: " + line)
			return "__MISSING_SEMI__"
		if not _is_identifier(arm_label):
			_report_error("pick/drop arm label must be identifier at: " + line)
			return "__MISSING_SEMI__"
		if not arm_label.begins_with("arm_"):
			_report_error("pick/drop arm label must start with arm_ (e.g. arm_1) at: " + line)
			return "__MISSING_SEMI__"
		if verb == "PICK":
			return "PICK_BOX " + arm_label
		if verb == "DROP":
			return "DROP_BOX " + arm_label
		return ""

	_report_error("Use pick(box); drop(box); pick(arm_1, box); or drop(arm_1, box); at: " + line)
	return ""

func _normalize_set_call_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("Action must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var trimmed := candidate.strip_edges()
	var open_idx := trimmed.find("(")
	var close_idx := trimmed.rfind(")")
	if open_idx <= 0 or close_idx < 0 or close_idx != trimmed.length() - 1:
		_report_error("Use set(diverter, left|right|open|close); at: " + line)
		return "__MISSING_SEMI__"

	var head := trimmed.substr(0, open_idx).strip_edges().to_upper()
	if head != "SET":
		return ""
	var args := trimmed.substr(open_idx + 1, close_idx - open_idx - 1).split(",", false)
	if args.size() != 2:
		_report_error("Use set(diverter, left|right|open|close); at: " + line)
		return "__MISSING_SEMI__"

	var target := str(args[0]).strip_edges().to_lower()
	var mode := str(args[1]).strip_edges().to_lower()
	if target != "diverter":
		_report_error("Unsupported set target '" + target + "' at: " + line)
		return "__MISSING_SEMI__"
	match mode:
		"left":
			return "DIVERTER_LEFT"
		"right":
			return "DIVERTER_RIGHT"
		"open":
			return "DIVERTER_OPEN"
		"close":
			return "DIVERTER_CLOSE"
		_:
			_report_error("Unsupported diverter mode '" + mode + "' at: " + line)
			return "__MISSING_SEMI__"

func _normalize_diverter_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("DIVERTER action must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var trimmed := candidate.strip_edges()
	var open_idx := trimmed.find("(")
	var action_name := trimmed.to_upper()

	if open_idx >= 0:
		var close_idx := trimmed.rfind(")")
		if close_idx < 0 or close_idx != trimmed.length() - 1:
			_report_error("DIVERTER command must use empty args: DIVERTER_LEFT(); or DIVERTER_RIGHT(); at: " + line)
			return "__MISSING_SEMI__"
		var args := trimmed.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
		if args != "":
			_report_error("DIVERTER action takes no arguments at: " + line)
			return "__MISSING_SEMI__"
		action_name = trimmed.substr(0, open_idx).strip_edges().to_upper()

	match action_name:
		"DIVERTER_LEFT", "SET_DIVERTER_LEFT":
			return "DIVERTER_LEFT"
		"DIVERTER_RIGHT", "SET_DIVERTER_RIGHT":
			return "DIVERTER_RIGHT"
		"DIVERTER_OPEN", "SET_DIVERTER_OPEN":
			return "DIVERTER_OPEN"
		"DIVERTER_CLOSE", "SET_DIVERTER_CLOSE":
			return "DIVERTER_CLOSE"
		_:
			return ""

func _normalize_start_stop_call_action(candidate: String, line: String, has_semi: bool) -> String:
	if not has_semi:
		_report_error("Action must end with ';' at: " + line)
		return "__MISSING_SEMI__"

	var trimmed := candidate.strip_edges()
	var open_idx := trimmed.find("(")
	var close_idx := trimmed.rfind(")")
	if open_idx <= 0 or close_idx < 0 or close_idx != trimmed.length() - 1:
		_report_error("Use start(...); or stop(...); only at: " + line)
		return "__MISSING_SEMI__"

	var verb := trimmed.substr(0, open_idx).strip_edges().to_upper()
	if verb != "START" and verb != "STOP":
		return ""

	var raw_args := trimmed.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
	if raw_args == "":
		_report_error("Missing target in " + verb + "(...) at: " + line)
		return "__MISSING_SEMI__"

	var args := raw_args.split(",", false)
	var target := str(args[0]).strip_edges().to_lower()
	if target == "":
		_report_error("Missing target in " + verb + "(...) at: " + line)
		return "__MISSING_SEMI__"

	if target == "spawner":
		if args.size() != 1:
			_report_error("Spawner form does not take index: " + verb.to_lower() + "(spawner); at: " + line)
			return "__MISSING_SEMI__"
		return verb + "_SPAWNER"

	if target == "conveyor":
		if args.size() == 1:
			return verb + "_CONVEYOR"
		if args.size() == 2:
			var idx_text := str(args[1]).strip_edges()
			if not idx_text.is_valid_int() and not _is_identifier(idx_text):
				_report_error("Conveyor index must be integer or identifier at: " + line)
				return "__MISSING_SEMI__"
			return verb + "_CONVEYOR " + idx_text
		_report_error("Invalid conveyor call form at: " + line)
		return "__MISSING_SEMI__"

	# Parameterized target form in functions:
	#   func f(sp, cv) { start(sp); stop(cv); }
	# Runtime will resolve identifier to spawner/conveyor.
	if _is_identifier(target) and args.size() == 1:
		return verb + "_TARGET " + target

	_report_error("Unsupported target '" + target + "' in " + verb.to_lower() + "(...) at: " + line)
	return "__MISSING_SEMI__"

func _is_action_opcode(opcode: String, actions: Array) -> bool:
	var upper := opcode.to_upper()
	return actions.has(upper)

func _starts_with_keyword(line: String, keyword: String) -> bool:
	var s := str(line).strip_edges()
	var key := keyword.to_upper()
	var up := s.to_upper()
	if not up.begins_with(key):
		return false
	if up.length() == key.length():
		return true
	var next := s[key.length()]
	return next == " " or next == "\t" or next == "{" or next == "("

func _strip_optional_wrapping_parentheses(text: String, keyword: String, line_index: int) -> String:
	var s := str(text).strip_edges()
	if s == "":
		return s
	if s.begins_with("(") or s.ends_with(")"):
		if not (s.begins_with("(") and s.ends_with(")")):
			_report_error(keyword + " condition has unbalanced parentheses at line " + str(line_index))
			return ""
		if s.length() < 2:
			return ""
		s = s.substr(1, s.length() - 2).strip_edges()
	return s

func _normalize_word_operator(op: String) -> String:
	var upper := str(op).strip_edges().to_upper()
	if upper == "(HAS_VALUE)":
		return "HAS_VALUE"
	if upper == "(NOT_DETECTED)":
		return "NOT_DETECTED"
	if upper == "HAS(VALUE)":
		return "HAS_VALUE"
	if upper == "NOT(DETECTED)":
		return "NOT_DETECTED"
	if ["IS", "HAS_VALUE", "NOT_DETECTED", "EXISTS", "CONTAINS", "STARTS_WITH", "ENDS_WITH"].has(upper):
		return upper
	return str(op).strip_edges()

func _parse_var_statement(line: String, line_index: int) -> ASTNode:
	var parts := _parse_var_parts(line, line_index)
	if parts.is_empty():
		return null

	var name := str(parts.get("name", ""))
	var rhs := str(parts.get("rhs", ""))
	var var_type := str(parts.get("var_type", ""))

	var normalized_action := _normalize_action(rhs + ";")
	if normalized_action != "" and normalized_action != "__MISSING_SEMI__":
		if var_type != "":
			_report_error("Typed var (%s) cannot be used as action alias at line %d" % [var_type, line_index])
			return null
		return VarAliasNode.new(name, normalized_action)

	if var_type == "":
		_report_error("Numeric variable must declare type: use 'var int' or 'var float' at line " + str(line_index))
		return null

	return NumberVarNode.new(name, rhs, var_type)

func _parse_var_parts(line: String, line_index: int) -> Dictionary:
	var s := str(line).strip_edges()
	if not _starts_with_keyword(s, "VAR"):
		return {}
	if not s.ends_with(";"):
		_report_error("var statement must end with ';' at line " + str(line_index) + ": " + s)
		return {}

	var inner := s.substr(0, s.length() - 1).strip_edges()
	inner = inner.substr(3, inner.length() - 3).strip_edges()

	var eq_pos := inner.find("=")
	if eq_pos < 0:
		_report_error("var statement requires '=' at line " + str(line_index) + ": " + s)
		return {}

	var left := inner.substr(0, eq_pos).strip_edges()
	var rhs := inner.substr(eq_pos + 1, inner.length() - (eq_pos + 1)).strip_edges()

	var var_type := ""
	var name := left
	var left_parts := left.split(" ", false)
	if left_parts.size() == 2:
		var maybe_type := str(left_parts[0]).to_lower()
		if maybe_type in ["int", "float"]:
			var_type = maybe_type
			name = str(left_parts[1])
	elif left_parts.size() > 2:
		_report_error("Invalid var declaration at line " + str(line_index) + ": " + s)
		return {}

	if not _is_identifier(name):
		_report_error("Invalid var name at line " + str(line_index) + ": " + name)
		return {}

	var upper := name.to_upper()
	var reserved := ["VAR", "IF", "ELSE", "WHILE", "REPEAT", "WAIT", "UNTIL", "TRUE", "FALSE", "BREAK"]
	if reserved.has(upper):
		_report_error("Reserved name cannot be used as var at line " + str(line_index) + ": " + name)
		return {}

	var action_opcodes := [
		"START_CONVEYOR",
		"STOP_CONVEYOR",
		"START_SPAWNER",
		"STOP_SPAWNER",
		"PICK_BOX",
		"DROP_BOX",
		"ROTATE_ARM",
		"MOVE_PATH",
		"DIVERTER_LEFT",
		"DIVERTER_RIGHT",
		"DIVERTER_OPEN",
		"DIVERTER_CLOSE",
		"SET_DIVERTER_LEFT",
		"SET_DIVERTER_RIGHT",
		"SET_DIVERTER_OPEN",
		"SET_DIVERTER_CLOSE"
	]
	if action_opcodes.has(upper) or upper.begins_with("START_CONV") or upper.begins_with("STOP_CONV"):
		_report_error("Action opcode name cannot be used as var at line " + str(line_index) + ": " + name)
		return {}

	if rhs == "":
		_report_error("var statement requires right-hand expression at line " + str(line_index) + ": " + s)
		return {}

	return {
		"name": name,
		"rhs": rhs,
		"var_type": var_type,
	}

func _parse_number_assign(line: String, line_index: int) -> NumberAssignNode:
	var s := str(line).strip_edges()
	if s == "" or not s.ends_with(";"):
		return null
	if _starts_with_keyword(s, "IF") or _starts_with_keyword(s, "WHILE") or _starts_with_keyword(s, "REPEAT") or _starts_with_keyword(s, "WAIT UNTIL") or _starts_with_keyword(s, "FUNC") or _starts_with_keyword(s, "CALL") or _starts_with_keyword(s, "VAR"):
		return null

	var body := s.substr(0, s.length() - 1).strip_edges()

	# ++ / -- support
	if body.ends_with("++"):
		var name_post := body.substr(0, body.length() - 2).strip_edges()
		if _is_identifier(name_post):
			return NumberAssignNode.new(name_post, name_post + " + 1")
	if body.ends_with("--"):
		var name_post_dec := body.substr(0, body.length() - 2).strip_edges()
		if _is_identifier(name_post_dec):
			return NumberAssignNode.new(name_post_dec, name_post_dec + " - 1")
	if body.begins_with("++"):
		var name_pre := body.substr(2, body.length() - 2).strip_edges()
		if _is_identifier(name_pre):
			return NumberAssignNode.new(name_pre, name_pre + " + 1")
	if body.begins_with("--"):
		var name_pre_dec := body.substr(2, body.length() - 2).strip_edges()
		if _is_identifier(name_pre_dec):
			return NumberAssignNode.new(name_pre_dec, name_pre_dec + " - 1")

	# Compound assignment support: +=, -=, *=, /=, %=, //=
	var compound_ops := ["//=", "%=", "+=", "-=", "*=", "/="]
	for raw_op in compound_ops:
		var op: String = str(raw_op)
		var op_pos := body.find(op)
		if op_pos > 0:
			var name_c := body.substr(0, op_pos).strip_edges()
			var op_len: int = op.length()
			var rhs_c := body.substr(op_pos + op_len, body.length() - (op_pos + op_len)).strip_edges()
			if _is_identifier(name_c):
				if rhs_c == "":
					_report_error("compound assignment requires right-hand expression at line " + str(line_index) + ": " + s)
					return null
				if op == "//=":
					return NumberAssignNode.new(name_c, "idiv(%s, (%s))" % [name_c, rhs_c])
				var op_char: String = op.substr(0, 1)
				return NumberAssignNode.new(name_c, "%s %s (%s)" % [name_c, op_char, rhs_c])

	var eq_pos := body.find("=")
	if eq_pos < 0:
		return null

	# Avoid catching comparisons (==, >=, <=, !=) as assignment.
	var eq_prev := body.substr(max(eq_pos - 1, 0), 1)
	var eq_next := ""
	if eq_pos + 1 < body.length():
		eq_next = body.substr(eq_pos + 1, 1)
	if eq_prev in ["=", "!", "<", ">"] or eq_next == "=":
		return null

	var name := body.substr(0, eq_pos).strip_edges()
	var rhs := body.substr(eq_pos + 1, body.length() - (eq_pos + 1)).strip_edges()
	if not _is_identifier(name):
		return null
	if rhs == "":
		_report_error("assignment requires right-hand expression at line " + str(line_index) + ": " + s)
		return null
	return NumberAssignNode.new(name, rhs)

func _is_identifier(identifier_text: String) -> bool:
	var s := str(identifier_text).strip_edges()
	if s == "":
		return false

	var c0 := s.unicode_at(0)
	var is_first_ok := (c0 >= 65 and c0 <= 90) or (c0 >= 97 and c0 <= 122) or (c0 == 95) # A-Z a-z _
	if not is_first_ok:
		return false

	for i in range(1, s.length()):
		var c := s.unicode_at(i)
		var ok := (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or (c == 95) or (c >= 48 and c <= 57) # A-Z a-z _ 0-9
		if not ok:
			return false
	return true

func _parse_identifier_list(raw: String, context_label: String, line_index: int) -> Array[String]:
	var out: Array[String] = []
	var seen: Dictionary = {}
	var s := str(raw).strip_edges()
	if s == "":
		return out
	var items := s.split(",", false)
	for item in items:
		var name := str(item).strip_edges()
		if not _is_identifier(name):
			_report_error("%s must be identifiers at line %d: %s" % [context_label, line_index, name])
			return []
		var key := name.to_lower()
		if seen.has(key):
			_report_error("%s has duplicate name at line %d: %s" % [context_label, line_index, name])
			return []
		seen[key] = true
		out.append(key)
	return out

func _parse_call_args(raw: String, line_index: int) -> Array[String]:
	var out: Array[String] = []
	var s := str(raw).strip_edges()
	if s == "":
		return out
	var current := ""
	var depth := 0
	for i in range(s.length()):
		var ch := s[i]
		if ch == "(":
			depth += 1
			current += ch
			continue
		if ch == ")":
			depth -= 1
			if depth < 0:
				_report_error("Unbalanced CALL args at line " + str(line_index))
				return []
			current += ch
			continue
		if ch == "," and depth == 0:
			var token := current.strip_edges()
			if token == "":
				_report_error("Empty CALL argument at line " + str(line_index))
				return []
			out.append(token)
			current = ""
			continue
		current += ch
	if depth != 0:
		_report_error("Unbalanced CALL args at line " + str(line_index))
		return []
	var last := current.strip_edges()
	if last == "":
		_report_error("Empty CALL argument at line " + str(line_index))
		return []
	out.append(last)
	return out

func _parse_var_alias(line: String, line_index: int) -> VarAliasNode:
	var s := str(line).strip_edges()
	if not _starts_with_keyword(s, "VAR"):
		return null
	if not s.ends_with(";"):
		_report_error("var alias must end with ';' at line " + str(line_index) + ": " + s)
		return null

	# Remove trailing ';' and leading 'var'
	var inner := s.substr(0, s.length() - 1).strip_edges()
	inner = inner.substr(3, inner.length() - 3).strip_edges()

	var eq_pos := inner.find("=")
	if eq_pos < 0:
		_report_error("var alias requires '=' at line " + str(line_index) + ": " + s)
		return null

	var name := inner.substr(0, eq_pos).strip_edges()
	var rhs := inner.substr(eq_pos + 1, inner.length() - (eq_pos + 1)).strip_edges()

	if not _is_identifier(name):
		_report_error("Invalid var name at line " + str(line_index) + ": " + name)
		return null

	var upper := name.to_upper()
	var reserved := ["VAR", "IF", "ELSE", "WHILE", "REPEAT", "WAIT", "UNTIL", "TRUE", "FALSE", "BREAK"]
	if reserved.has(upper):
		_report_error("Reserved name cannot be used as var alias at line " + str(line_index) + ": " + name)
		return null

	# Disallow action opcode names to avoid ambiguity (e.g. var START_SPAWNER = ...)
	var action_opcodes := [
		"START_CONVEYOR",
		"STOP_CONVEYOR",
		"START_SPAWNER",
		"STOP_SPAWNER",
		"PICK_BOX",
		"DROP_BOX",
		"ROTATE_ARM",
		"MOVE_PATH",
		"DIVERTER_LEFT",
		"DIVERTER_RIGHT",
		"DIVERTER_OPEN",
		"DIVERTER_CLOSE",
		"SET_DIVERTER_LEFT",
		"SET_DIVERTER_RIGHT",
		"SET_DIVERTER_OPEN",
		"SET_DIVERTER_CLOSE"
	]
	if action_opcodes.has(upper) or upper.begins_with("START_CONV") or upper.begins_with("STOP_CONV"):
		_report_error("Action opcode name cannot be used as var alias at line " + str(line_index) + ": " + name)
		return null

	# RHS must be a valid ACTION (with args), normalized to match existing behavior.
	var normalized := _normalize_action(rhs + ";")
	if normalized == "" or normalized == "__MISSING_SEMI__":
		_report_error("var alias RHS must be an ACTION at line " + str(line_index) + ": " + rhs)
		return null

	return VarAliasNode.new(name, normalized)


# ==================================================
# RESULT STRUCTS
# ==================================================
class ParseResult:
	var program: ProgramNode
	var next_index: int
	func _init(p, i):
		program = p
		next_index = i

class ParseIfResult:
	var node
	var next_index: int
	func _init(n, i):
		node = n
		next_index = i
