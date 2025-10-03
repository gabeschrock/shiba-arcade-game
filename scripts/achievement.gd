extends VBoxContainer

var is_toast_ready := false
signal toast_ready

@export var id: String

func _ready() -> void:
	var info: Array
	if id in Achievements.INFO:
		info = Achievements.INFO[id]
	else:
		info = ["Unknown Achievement", "Unknown Achievement"]
	$Name.text = info[0]
	$Description.text = info[1]
	#print(size, " ", get_minimum_size())
	#size = get_minimum_size()
	#print(size)
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
