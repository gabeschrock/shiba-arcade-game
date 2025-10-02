extends StaticBody2D

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	await get_tree().process_frame
	Settings.player.dash.connect(toggle)

func toggle():
	shape.disabled = not shape.disabled
	sprite.play("default" if sprite.animation == "off" else "off")
