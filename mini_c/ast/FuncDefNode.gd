extends ASTNode
class_name FuncDefNode

# A named, reusable block of statements.
# This is a definition-only node: execution registers the function in the runtime
# but does not execute the body at the definition site.

var name: String
var body: ProgramNode
var params: Array[String] = []


func _init(_name: String, _body: ProgramNode, _params: Array = []) -> void:
	name = _name
	body = _body
	params.clear()
	for p in _params:
		params.append(str(p).strip_edges().to_lower())


func execute(runtime: MiniCRuntime) -> void:
	if runtime == null:
		push_error("FuncDefNode.execute: runtime is null")
		return
	runtime.register_function(name, body, params)
