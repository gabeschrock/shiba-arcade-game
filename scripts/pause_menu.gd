extends Control

const OPTIONS_MENU = preload("res://scenes/options_menu.tscn")

@onready var resume_button: Button = $Buttons/ResumeButton
@onready var timer_button: Button = $Buttons/TimerButton

func click():
	Settings.click_sound.play()

func _ready() -> void:
	Settings.show_timer_changed.connect(_on_show_timer_changed)
	_on_show_timer_changed(Settings.show_timer)

func resume() -> void:
	visible = false
	for i in range(2):
		await get_tree().physics_frame
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	await resume()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_show_timer_changed(value: bool) -> void:
	if value:
		timer_button.text = "Hide Timer"
	else:
		timer_button.text = "Show Timer"

func _on_exit_button_pressed() -> void:
	await resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_timer_button_pressed() -> void:
	Settings.show_timer = not Settings.show_timer

func _on_visibility_changed() -> void:
	if visible:
		resume_button.grab_focus.call_deferred()

func _on_options_button_pressed() -> void:
	var menu := OPTIONS_MENU.instantiate()
	menu.target = self
	get_parent().add_child(menu)
