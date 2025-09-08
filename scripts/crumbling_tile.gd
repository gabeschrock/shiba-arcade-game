extends StaticBody2D

enum TileState {
	IDLE,
	CRUMBLING,
	RESPAWNING
}
const animations := {
	TileState.IDLE: "default",
	TileState.CRUMBLING: "crumble",
	TileState.RESPAWNING: "respawn"
}
var state := TileState.IDLE:
	set(value):
		state = value
		animate()
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var respawn_timer: Timer = $RespawnTimer
@onready var player_area: Area2D = $PlayerArea

func animate() -> void:
	sprite.play(animations[state])

func _process(_delta: float) -> void:
	animate()

func _on_player_area_body_entered(_body: Node2D) -> void:
	state = TileState.CRUMBLING

func _on_sprite_animation_looped() -> void:
	if state == TileState.CRUMBLING:
		state = TileState.IDLE
		visible = false
		collision_shape.disabled = true
		player_area.monitoring = false
		respawn_timer.start()
	elif state == TileState.RESPAWNING:
		state = TileState.IDLE
		player_area.monitoring = true

func _on_respawn_timer_timeout() -> void:
	state = TileState.RESPAWNING
	set_deferred("visible", true)
	collision_shape.disabled = false
