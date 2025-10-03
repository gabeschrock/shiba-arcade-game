extends Area2D

const Player = preload("res://scripts/player.gd")
const LAUNCH_VELOCITY = 280.0

@onready var sound: AudioStreamPlayer = $Sound

func _on_body_entered(body: Player) -> void:
	if body.movement:
		return
	body.velocity.y = min(-abs(body.velocity.y), -LAUNCH_VELOCITY)
	body.circle_effect(Color.BLUE)
	sound.play()
