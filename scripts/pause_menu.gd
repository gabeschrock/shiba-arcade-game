extends Control

@onready var timer_button: Button = $Buttons/TimerButton

func _ready() -> void:
	Settings.show_timer_changed.connect(_on_show_timer_changed)

func resume() -> void:
	visible = false
	get_tree().set_deferred("paused", false)
	AudioServer.set_bus_effect_enabled(0, 0, false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		resume()

func _on_show_timer_changed(value: bool) -> void:
	if value:
		timer_button.text = "Hide Timer"
	else:
		timer_button.text = "Show Timer"

func _on_exit_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_timer_button_pressed() -> void:
	Settings.show_timer = not Settings.show_timer
