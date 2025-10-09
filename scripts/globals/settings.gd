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
const Player = preload("res://scripts/player.gd")

signal show_timer_changed(value: bool)

var is_playtest := OS.is_debug_build() or OS.has_feature("playtesting")
var show_timer := false:
	set(value):
		show_timer = value
		show_timer_changed.emit(value)
var background := Image.create(BG_WIDTH, BG_HEIGHT, false, Image.FORMAT_RGBA4444)
var player: Player
var checkpoints := {}
@export var difficulty := Difficulty.IMPOSSIBLE

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
	Engine.time_scale = 0.5
	reset_bg()

func reset_bg() -> void:
	background.fill(Color.BLACK)
