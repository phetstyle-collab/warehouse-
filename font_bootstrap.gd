extends Node

const THAI_FONT_PATH := "res://fonts/THSarabunNew Bold.ttf"

func _ready() -> void:
	if not ResourceLoader.exists(THAI_FONT_PATH):
		push_warning("FontBootstrap: Thai font not found at " + THAI_FONT_PATH)
		return

	var font := load(THAI_FONT_PATH)

	if font is Font:
		ThemeDB.fallback_font = font
		ThemeDB.fallback_font_size = 20
		print("FontBootstrap: Thai fallback font configured successfully.")
	else:
		push_warning("FontBootstrap: Failed to load font resource.")
