extends VBoxContainer

var is_toast_ready := false
signal toast_ready
signal toast_done

var info: Achievements.Info

@export var id: String
@export var show_secret := false:
	set(value):
		if not is_node_ready():
			await ready
		show_secret = value
		var secret := info.secret and not show_secret
		$Name.text = "Secret Achievement" if secret else info.name
		$Description.text = "Shhhh!" if secret else info.description

func _ready() -> void:
	if id in Achievements.info:
		info = Achievements.info[id]
	else:
		info = Achievements.Info.new("Unknown Achievement", "Unknown Achievement")
	show_secret = show_secret
	set_deferred("is_toast_ready", true)
	toast_ready.emit.call_deferred()

func toast() -> void:
	if not is_toast_ready:
		await toast_ready
	position = get_viewport_rect().size - Vector2(2, size.y + 10)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position:x", position.x - size.x, 0.3)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
	toast_done.emit()
