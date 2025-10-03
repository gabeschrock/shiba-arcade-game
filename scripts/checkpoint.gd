extends Area2D

const CIRCLE_EFFECT = preload("res://scenes/circle_effect.tscn")

const Player = preload("res://scripts/player.gd")
var active: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var time: Label = $Time
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var map: TileMapLayer = get_parent()

func _ready() -> void:
	Settings.show_timer_changed.connect(_on_show_timer_changed)

func _on_show_timer_changed(value: bool) -> void:
	time.visible = value

func set_time(player: Player) -> void:
	time.text = player.get_time()
	time.visible = Settings.show_timer

func _process(_delta: float) -> void:
	sprite.play("active" if active else "default")

func _on_body_entered(body: Player) -> void:
	active = true
	$CollisionShape2D.set_deferred("disabled", true)
	sound.play()
	set_time(body)
	body.checkpoint = self
	var effect := CIRCLE_EFFECT.instantiate()
	effect.self_modulate = Color.GREEN
	add_child(effect)
	var map_pos: Vector2i = map.local_to_map(position)
	if map_pos == Vector2i(17, -74):
		Achievements.add("all_for_now")
