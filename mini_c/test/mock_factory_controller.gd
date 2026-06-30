extends RefCounted
class_name MockFactoryController

var commands: Array[String] = []

func send_command(command: String) -> void:
	commands.append(command)
