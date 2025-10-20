extends Node

enum Difficulty {
	INVINCIBLE,
	UNLIMITED,
	NORMAL,
	NO_HEAL,
	CHECKPOINTLESS,
	IMPOSSIBLE,
}

const BG_WIDTH = 80
const BG_HEIGHT = 45
const PATH = "user://settings.gd"
const Player = preload("res://scripts/player.gd")

signal show_timer_changed(value: bool)

var is_playtest := OS.is_debug_build() or OS.has_feature("playtesting")
var show_timer := false:
	set(value):
		show_timer = value
		show_timer_changed.emit(value)
		save_settings()
var background := Image.create(BG_WIDTH, BG_HEIGHT, false, Image.FORMAT_RGBA4444)
var player: Player
var checkpoints := {}
var volume_sfx := 1.0:
	set(value):
		volume_sfx = value
		AudioServer.set_bus_volume_linear(1, value)
		save_settings()
var volume_music := 1.0:
	set(value):
		volume_music = value
		AudioServer.set_bus_volume_linear(2, value)
		save_settings()
var difficulty := Difficulty.IMPOSSIBLE
var click_sound := AudioStreamPlayer.new()

func is_invincible() -> bool:
	return difficulty == Difficulty.INVINCIBLE

func can_heal() -> bool:
	return difficulty != Difficulty.NO_HEAL

func is_life_unlimited() -> bool:
	return difficulty == Difficulty.UNLIMITED \
		or difficulty >= Difficulty.CHECKPOINTLESS

func has_checkpoints() -> bool:
	return difficulty < Difficulty.CHECKPOINTLESS

func has_double_damage() -> bool:
	return difficulty == Difficulty.IMPOSSIBLE

func _ready() -> void:
	#Engine.time_scale = 0.5
	reset_bg()
	load_settings()
	click_sound.stream = preload("res://assets/click.wav")
	add_child(click_sound)

func reset_bg() -> void:
	background.fill(Color.BLACK)

func load_settings():
	if not FileAccess.file_exists(PATH):
		return
	var file := FileAccess.open(PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	var data: Dictionary = JSON.parse_string(content)
	show_timer = data["show_timer"]
	volume_sfx = data["volume_sfx"]
	volume_music = data["volume_music"]

func save_settings() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"show_timer": show_timer,
		"volume_sfx": volume_sfx,
		"volume_music": volume_music,
	}))
	file.close()
