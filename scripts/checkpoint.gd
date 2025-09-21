extends Area2D

const Player = preload("res://scripts/player.gd")
var active: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var time: Label = $Time

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
	body.checkpoint = self
