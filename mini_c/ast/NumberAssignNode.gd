extends ASTNode
class_name NumberAssignNode

var name: String
var expr: String

func _init(_name: String, _expr: String) -> void:
	name = str(_name).strip_edges()
	expr = str(_expr).strip_edges()

func execute(runtime: MiniCRuntime) -> void:
	if runtime == null:
		push_error("NumberAssignNode.execute: runtime is null")
		return
	runtime.set_number_var(name, runtime.eval_numeric_expr(expr))
