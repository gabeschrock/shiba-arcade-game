extends Sprite2D

@export var remove_target: Node = self
@export var speed := 0.2

func _ready() -> void:
	scale = Vector2.ZERO
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, speed)
	await tween.finished
	tween = get_tree().create_tween()
	var new_color := self_modulate
	new_color.a = 0
	tween.tween_property(self, "modulate", new_color, speed)
	await tween.finished
	remove_target.queue_free()
