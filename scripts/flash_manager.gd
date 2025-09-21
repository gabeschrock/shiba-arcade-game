extends Node

@export var target: Node
@export var flash_time := 0.1
@export var flashing_time := 1.0

@onready var flash_timer: Timer = $FlashTimer
@onready var flashing_timer: Timer = $FlashingTimer

var keep_target := true
var flashing: bool:
	get():
		return flashing_timer.time_left > 0

func _ready() -> void:
	flash_timer.wait_time = flash_time
	flashing_timer.wait_time = flashing_time

func _enter_tree() -> void:
	if not target or not keep_target:
		keep_target = false
		target = get_parent() as Node2D

func flash() -> void:
	if target.visible:
		flash_timer.start()
		flashing_timer.start()
	else:
		flash_timer.stop()
		flashing_timer.stop()

func _on_flash_timer_timeout() -> void:
	target.visible = not target.visible

func _on_flashing_timer_timeout() -> void:
	target.visible = true
	flash_timer.stop()
