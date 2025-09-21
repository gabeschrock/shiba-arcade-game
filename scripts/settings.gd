extends Node

const BG_WIDTH = 80
const BG_HEIGHT = 45

signal show_timer_changed(value: bool)

var is_playtest := OS.is_debug_build() or OS.has_feature("playtesting")
var show_timer := false:
	set(value):
		show_timer = value
		show_timer_changed.emit(value)
var background := Image.create(BG_WIDTH, BG_HEIGHT, false, Image.FORMAT_RGBA4444)

func _ready() -> void:
	background.fill(Color.BLACK)
