extends ASTNode
class_name BreakNode

func execute(runtime: MiniCRuntime) -> void:
	runtime.trigger_break()
