extends Area2D

const Player = preload("res://scripts/player.gd")

func _on_body_entered(body: Player) -> void:
	body.dash.emit.call_deferred()
