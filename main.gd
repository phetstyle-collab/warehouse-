extends Control

func _ready():
	# เข้าหน้าเมนูทันที
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
