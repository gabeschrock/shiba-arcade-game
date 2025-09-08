extends Node

const Player = preload("res://scripts/player.gd")

var player: Player:
	get():
		if not player:
			player = get_parent() as Player
		return player

func end():
	if not is_inside_tree():
		return
	player.movement = null

class Dash extends Movement:
	const SPEED = 300.0
	const TIME = 0.15
	var velocity: Vector2
	
	func _init(direction: Vector2) -> void:
		velocity = direction * SPEED
	
	func end():
		player.velocity = velocity
		super()
	
	func _ready() -> void:
		await get_tree().create_timer(TIME).timeout
		end()
	
	func _physics_process(delta: float) -> void:
		if Input.is_action_just_pressed("player_action") or player.move_and_collide(velocity * delta):
			end()
			return
