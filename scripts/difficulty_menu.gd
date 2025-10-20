extends VBoxContainer

func click():
	Settings.click_sound.play()

func _ready() -> void:
	$NormalButton.grab_focus()
	const OVERRIDES := [
		"font_hover_press_color",
		"font_hover_color",
		"font_focus_color",
		"font_pressed_color",
	]
	for button: Button in get_children().slice(1):
		if not button.has_theme_color_override("font_color"):
			return
		var font_color := button.get_theme_color("font_color")
		for override in OVERRIDES:
			button.add_theme_color_override(override, font_color)

func _on_button_pressed(difficulty: Settings.Difficulty):
	click()
	Settings.difficulty = difficulty
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_cancel_button_pressed() -> void:
	click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
