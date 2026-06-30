extends ASTNode
class_name ActionNode

var action: String


func _init(_action: String) -> void:
	action = _action


func execute(runtime: MiniCRuntime) -> void:
	if runtime == null:
		push_error("ActionNode.execute: runtime is null")
		return

	var resolved := runtime.resolve_action(action)
	print("ActionNode:", resolved)
	runtime.execute_action(resolved)
