extends ASTNode
class_name NumberVarNode

var name: String
var expr: String
var var_type: String

func _init(_name: String, _expr: String, _var_type: String = "float") -> void:
	name = str(_name).strip_edges()
	expr = str(_expr).strip_edges()
	var_type = str(_var_type).strip_edges().to_lower()

func execute(runtime: MiniCRuntime) -> void:
	if runtime == null:
		push_error("NumberVarNode.execute: runtime is null")
		return
	var value = runtime.eval_numeric_expr(expr)
	if runtime.has_method("declare_number_var"):
		runtime.call("declare_number_var", name, value, var_type)
	else:
		runtime.set_number_var(name, value)
