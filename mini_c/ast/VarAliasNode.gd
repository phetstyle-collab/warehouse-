extends ASTNode
class_name VarAliasNode

var name: String
var action: String


func _init(_name: String, _action: String) -> void:
	name = _name
	action = _action


func execute(runtime: MiniCRuntime) -> void:
	runtime.set_alias(name, action)
