extends Node2D

@export var target: CanvasItem
@onready var top := get_parent() == get_window()

func _ready() -> void:
	if not top:
		target.visible = false
	$Menu/Sounds/SFX.value = Settings.volume_sfx
	$Menu/Sounds/Music.value = Settings.volume_music
	$Menu/ExitButton.grab_focus()

func _on_sfx_value_changed(value: float) -> void:
	Settings.volume_sfx = value

func _on_music_value_changed(value: float) -> void:
	Settings.volume_music = value

func _on_exit_button_pressed() -> void:
	if get_parent() == get_window():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		target.visible = true
		queue_free()
