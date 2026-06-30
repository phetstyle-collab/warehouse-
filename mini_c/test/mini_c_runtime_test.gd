extends Node
class_name MiniCRuntimeTest

# ==================================================
# ENTRY
# ==================================================
func _ready() -> void:
	print("🧪 MiniC Runtime Test START")

	test_linear_commands()
	test_if_true()
	test_if_false()
	test_if_else_true()
	test_if_else_false()
	test_mixed_statements()
	test_func_call_simple()

	print("✅ ALL MiniC Runtime Tests DONE")


# ==================================================
# TEST 1: Linear commands
# ==================================================
func test_linear_commands() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	var program := ProgramNode.new()
	program.statements.append(ActionNode.new("START_CONVEYOR"))
	program.statements.append(ActionNode.new("STOP_CONVEYOR"))

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		["START_CONVEYOR", "STOP_CONVEYOR"],
		"Linear commands"
	)


# ==================================================
# TEST 2: IF (TRUE, no else)
# ==================================================
func test_if_true() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	runtime.set_sensor_state("weight", 10)

	var cmp := ComparisonNode.new("weight", ">", 5)

	var then_program := ProgramNode.new()
	then_program.statements.append(ActionNode.new("START_CONVEYOR"))

	var condition := ConditionNode.new(cmp, then_program, null)

	var program := ProgramNode.new()
	program.statements.append(condition)

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		["START_CONVEYOR"],
		"If TRUE"
	)


# ==================================================
# TEST 3: IF (FALSE, no else)
# ==================================================
func test_if_false() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	runtime.set_sensor_state("weight", 2)

	var cmp := ComparisonNode.new("weight", ">", 5)

	var then_program := ProgramNode.new()
	then_program.statements.append(ActionNode.new("START_CONVEYOR"))

	var condition := ConditionNode.new(cmp, then_program, null)

	var program := ProgramNode.new()
	program.statements.append(condition)

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		[],
		"If FALSE"
	)


# ==================================================
# TEST 4: IF / ELSE (TRUE)
# ==================================================
func test_if_else_true() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	runtime.set_sensor_state("weight", 10)

	var cmp := ComparisonNode.new("weight", ">", 5)

	var then_program := ProgramNode.new()
	then_program.statements.append(ActionNode.new("START_CONVEYOR"))

	var else_program := ProgramNode.new()
	else_program.statements.append(ActionNode.new("STOP_CONVEYOR"))

	var condition := ConditionNode.new(cmp, then_program, else_program)

	var program := ProgramNode.new()
	program.statements.append(condition)

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		["START_CONVEYOR"],
		"If ELSE TRUE"
	)


# ==================================================
# TEST 5: IF / ELSE (FALSE)
# ==================================================
func test_if_else_false() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	runtime.set_sensor_state("weight", 2)

	var cmp := ComparisonNode.new("weight", ">", 5)

	var then_program := ProgramNode.new()
	then_program.statements.append(ActionNode.new("START_CONVEYOR"))

	var else_program := ProgramNode.new()
	else_program.statements.append(ActionNode.new("STOP_CONVEYOR"))

	var condition := ConditionNode.new(cmp, then_program, else_program)

	var program := ProgramNode.new()
	program.statements.append(condition)

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		["STOP_CONVEYOR"],
		"If ELSE FALSE"
	)


# ==================================================
# TEST 6: Mixed statements (CORRECT semantics)
#
# START_CONVEYOR
# IF weight > 5 { STOP_CONVEYOR }
# STOP_CONVEYOR
# ==================================================
func test_mixed_statements() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	runtime.set_sensor_state("weight", 10)

	var cmp := ComparisonNode.new("weight", ">", 5)

	var then_program := ProgramNode.new()
	then_program.statements.append(ActionNode.new("STOP_CONVEYOR"))

	var condition := ConditionNode.new(cmp, then_program, null)

	var program := ProgramNode.new()
	program.statements.append(ActionNode.new("START_CONVEYOR"))
	program.statements.append(condition)
	program.statements.append(ActionNode.new("STOP_CONVEYOR"))

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		["START_CONVEYOR", "STOP_CONVEYOR", "STOP_CONVEYOR"],
		"Mixed statements"
	)


# ==================================================
# TEST 7: FUNC / CALL
#
# FUNC do_two {
#   START_CONVEYOR;
#   STOP_CONVEYOR;
# }
# CALL do_two;
# ==================================================
func test_func_call_simple() -> void:
	var runtime := MiniCRuntime.new()
	var mock := MockFactoryController.new()

	var fn_body := ProgramNode.new()
	fn_body.statements.append(ActionNode.new("START_CONVEYOR"))
	fn_body.statements.append(ActionNode.new("STOP_CONVEYOR"))

	var program := ProgramNode.new()
	program.statements.append(FuncDefNode.new("do_two", fn_body))
	program.statements.append(CallNode.new("do_two"))

	runtime.execute(program, mock)

	_assert_eq(
		mock.commands,
		["START_CONVEYOR", "STOP_CONVEYOR"],
		"FUNC/CALL simple"
	)


# ==================================================
# ASSERT HELPER
# ==================================================
func _assert_eq(actual, expected, label: String) -> void:
	if actual == expected:
		print("✅ PASS:", label)
	else:
		push_error(
			"❌ FAIL %s\nExpected: %s\nActual: %s"
			% [label, expected, actual]
		)
