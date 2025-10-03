extends Sprite2D

@export var remove_target: Node = self
@export var speed := 0.1

func _ready() -> void:
	scale.y = 0
	await get_tree().process_frame
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale:y", 1, speed)
	tween.parallel().tween_property(self, "position:y", position.y + 4, speed)
	await tween.finished
	tween = get_tree().create_tween()
	var new_color := self_modulate
	new_color.a = 0
	tween.tween_property(self, "modulate", new_color, speed)
	await tween.finished
	remove_target.queue_free()
