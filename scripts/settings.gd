extends Node

const BG_WIDTH = 80
const BG_HEIGHT = 45

var show_timer := false
var background := Image.create(BG_WIDTH, BG_HEIGHT, false, Image.FORMAT_RGBA4444)

func _ready() -> void:
	background.fill(Color.BLACK)
