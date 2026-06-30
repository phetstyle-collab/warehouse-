extends ASTNode
class_name RepeatNode

var count_total: int
var body: ProgramNode
var _remaining: int = 0
var _initialized: bool = false


func _init(_count: int, _body: ProgramNode) -> void:
	count_total = _count
	body = _body


func execute(runtime: MiniCRuntime) -> void:
	if not _initialized:
		_remaining = max(count_total, 0)
		_initialized = true

	if _remaining <= 0:
		# Reset so a later re-entry (e.g. outer loop) starts fresh.
		_initialized = false
		return

	_remaining -= 1

	# Capture outer program/ip so we can re-run this REPEAT.
	var outer_program := runtime._current_program
	var outer_ip := runtime._resume_ip

	# Run body one iteration.
	runtime.push_loop(body, outer_program, outer_ip, self)
	body.execute_from(runtime, 0)

	# Prevent outer ProgramNode from falling through while body runs.
	runtime.block_fallthrough(outer_program)

func should_continue() -> bool:
	return _remaining > 0

func reset_done() -> void:
	_initialized = false

func force_reset() -> void:
	_initialized = false
	_remaining = 0
