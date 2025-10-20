extends Node2D

const MenuPlayer = preload("res://scripts/menu_player.gd")

@onready var buttons: VBoxContainer = $Buttons
@onready var play_button: Button = $Buttons/PlayButton
@onready var timer_button: Button = $Buttons/TimerButton
@onready var player: MenuPlayer = $MenuPlayer

var jumps := 0

func click():
	Settings.click_sound.play()

func jump_player():
	if not is_instance_valid(player):
		return
	if player.position.x > 260 and jumps == 0:
		player.input_jump = true
		jumps += 1
		for i in range(2):
			await get_tree().physics_frame
		player.input_jump = false
	elif player.position.x > 600 and jumps == 1:
		player.input_jump = true
		jumps += 1
		for i in range(2):
			await get_tree().physics_frame
		player.input_jump = false

func _process(_delta: float) -> void:
	jump_player()

func _ready() -> void:
	Settings.show_timer_changed.connect(_on_show_timer_changed)
	_on_show_timer_changed(Settings.show_timer)
	#buttons.grab_focus()
	play_button.grab_focus.call_deferred()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")

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

func _on_player_timer_timeout() -> void:
	player.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_achievements_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/achievements_menu.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")
