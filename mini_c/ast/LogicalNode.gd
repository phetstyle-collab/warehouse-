extends ASTNode
class_name LogicalNode

# Boolean operator node for conditions:
# - left && right
# - left || right
#
# Used by IF / WHILE / WAIT UNTIL parsing to support combined comparisons like:
#   IF weight > 5 && weight < 7 { ... }

var op: String
var left: ASTNode
var right: ASTNode


func _init(_op: String, _left: ASTNode, _right: ASTNode) -> void:
	op = str(_op).strip_edges()
	left = _left
	right = _right


func evaluate(runtime) -> bool:
	# Short-circuit evaluation to match typical programming languages.
	if op == "&&":
		if not left.evaluate(runtime):
			return false
		return right.evaluate(runtime)
	if op == "||":
		if left.evaluate(runtime):
			return true
		return right.evaluate(runtime)

	push_error("LogicalNode: unknown operator: " + str(op))
	return false
