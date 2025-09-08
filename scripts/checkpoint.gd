extends Area2D

const Player = preload("res://scripts/player.gd")
var active: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
	sprite.play("active" if active else "default")

func _on_body_entered(body: Player) -> void:
	body.checkpoint = self
