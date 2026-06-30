extends RefCounted
class_name ASTNode

# 0-based source line (matches TextEdit line numbers) this node was parsed from.
# -1 means unknown (e.g. synthetic nodes created at runtime).
var line: int = -1

func execute(_runtime: MiniCRuntime) -> void:
	push_error("ASTNode.execute() must be overridden")
