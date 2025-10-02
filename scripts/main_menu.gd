extends Node2D

const MenuPlayer = preload("res://scripts/menu_player.gd")

@onready var buttons: VBoxContainer = $Buttons
@onready var play_button: Button = $Buttons/PlayButton
@onready var timer_button: Button = $Buttons/TimerButton
@onready var player: MenuPlayer = $MenuPlayer

var has_jumped := false

func _process(_delta: float) -> void:
	if player.position.x > 120 and not has_jumped:
		player.input_jump = true
		has_jumped = true
		for i in range(2):
			await get_tree().physics_frame
		player.input_jump = false

func _ready() -> void:
	Settings.show_timer_changed.connect(_on_show_timer_changed)
	_on_show_timer_changed(Settings.show_timer)
	#buttons.grab_focus()
	play_button.grab_focus.call_deferred()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_timer_button_pressed() -> void:
	Settings.show_timer = not Settings.show_timer

func _on_show_timer_changed(value: bool) -> void:
	if value:
		timer_button.text = "Hide Timer"
	else:
		timer_button.text = "Show Timer"

func _on_github_button_pressed() -> void:
	OS.shell_open("https://github.com/gabeschrock/shiba-arcade-game")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
