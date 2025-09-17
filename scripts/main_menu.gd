extends Node2D

@onready var timer_button: Button = $Buttons/TimerButton

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_timer_button_pressed() -> void:
	Settings.show_timer = not Settings.show_timer
	if Settings.show_timer:
		timer_button.text = "Hide Timer"
	else:
		timer_button.text = "Show Timer"
