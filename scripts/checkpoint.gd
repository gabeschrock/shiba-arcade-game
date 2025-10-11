extends Area2D

const CIRCLE_EFFECT = preload("res://scenes/circle_effect.tscn")

const Player = preload("res://scripts/player.gd")
var active: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var time_label: Label = $Time
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var map_pos: Vector2i = get_parent().local_to_map(position)

func _ready() -> void:
	if not (Settings.has_checkpoints() or map_pos == Vector2i(-11, -121)):
		queue_free()
		return
	Settings.show_timer_changed.connect(_on_show_timer_changed)
	Settings.checkpoints[map_pos] = self

func _on_show_timer_changed(value: bool) -> void:
	time_label.visible = value

func set_time(player: Player) -> void:
	time_label.text = player.get_time()
	time_label.visible = Settings.show_timer

func _process(_delta: float) -> void:
	sprite.play("active" if active else "default")

func _on_body_entered(body: Player) -> void:
	if OS.is_debug_build():
		print("Checkpoint at ", map_pos)
	active = true
	$CollisionShape2D.set_deferred("disabled", true)
	sound.play()
	set_time(body)
	body.checkpoint = self
	var effect := CIRCLE_EFFECT.instantiate()
	effect.self_modulate = Color.GREEN
	add_child(effect)
	if map_pos.y < -36 and \
			Settings.has_checkpoints() and \
			not Settings.checkpoints[Vector2i(-16, -36)].active:
		Achievements.add("time_saver")
	if map_pos == Vector2i(-11, -121):
		Achievements.add("the_end")
		if Settings.difficulty == Settings.Difficulty.IMPOSSIBLE:
			Achievements.add("pro_gamer")
		var mins := body.stopwatch.time / 60
		if mins < 3.5:
			Achievements.add("speedy")
			if mins < 2.5:
				Achievements.add("super_speedy")
				if mins < 1.5:
					Achievements.add("wait_thats_possible")
