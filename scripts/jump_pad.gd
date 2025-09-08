extends Area2D

const Player = preload("res://scripts/player.gd")
const LAUNCH_VELOCITY = 280.0

func _on_body_entered(body: Player) -> void:
	body.velocity.y = min(-abs(body.velocity.y), -LAUNCH_VELOCITY)
