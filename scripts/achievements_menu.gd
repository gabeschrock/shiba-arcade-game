extends Control

const ACHIEVEMENT = preload("res://scenes/achievement.tscn")
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer

func _ready() -> void:
	$ExitButton.grab_focus()
	for id in Achievements.INFO.keys():
		var achievement := ACHIEVEMENT.instantiate()
		achievement.id = id
		if not Achievements.has(id):
			print("No achievement")
			achievement.modulate.a = 0.3
		container.add_child(achievement)

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
