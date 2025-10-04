extends Control

const ACHIEVEMENT = preload("res://scenes/achievement.tscn")
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer

func _ready() -> void:
	$ExitButton.grab_focus()
	for id in Achievements.info:
		var achievement := ACHIEVEMENT.instantiate()
		achievement.id = id
		if Achievements.has(id):
			achievement.show_secret = true
		else:
			achievement.modulate.a = 0.3
		container.add_child(achievement)

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
