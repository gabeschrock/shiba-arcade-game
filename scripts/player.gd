extends CharacterBody2D

enum Ability {
	NONE,
	DOUBLE_JUMP,
	DASH,
}

const Checkpoint = preload("res://scripts/checkpoint.gd")

const SPEED = 100.0
const DECELERATION = 3000.0
const JUMP_VELOCITY = 210.0
const MAX_FALL_SPEED = 40 * 60
const FLY_SPEED = 200.0
const HEART_WIDTH = 9
const HALF_HEART = 4
const MAX_HEALTH = 10
const DASHES = 1
const AIR_JUMPS = 1
const NICE_NAMES = {
	Ability.DOUBLE_JUMP: "Double Jump",
	Ability.DASH: "Dash",
}

var respawn_pos := position
var dashes := 0
var air_jumps := 0
var ability := Ability.NONE:
	set(value):
		if ability == value:
			return
		ability = value
		var is_none := value == Ability.NONE
		if not is_none:
			ability_label.text = "Ability: " + NICE_NAMES[value]
		ability_label.visible = not is_none
var checkpoint: Checkpoint:
	set(value):
		if checkpoint == value:
			return
		if checkpoint:
			checkpoint.active = false
		value.active = true
		checkpoint = value
		health = MAX_HEALTH
		respawn_pos = get_parent().to_local(checkpoint.sprite.global_position)
var health: int:
	set(value):
		if value < health and not value & 1:
			position = respawn_pos
			velocity = Vector2.ZERO
		health = value
		var tween := get_tree().create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(
			hearts,
			"size:x",
			(value >> 1) * HEART_WIDTH + HALF_HEART * (value & 1),
			0.2
		)
		if value <= 0:
			get_tree().quit()
var movement: Variant:
	set(value):
		if movement:
			movement.queue_free()
		movement = value
		if value is Movement:
			add_child(value)
@onready var jump_timer: Timer = $JumpTimer
@onready var hearts: TextureRect = $GUI/Hearts
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var ability_label: Label = $GUI/AbilityLabel

func _ready() -> void:
	health = MAX_HEALTH

func fly(delta: float) -> void:
	position += Input.get_vector("player_left", "player_right", "player_up", "player_down") * FLY_SPEED * delta

func die():
	@warning_ignore("integer_division")
	health = (health - 1) / 2 * 2

func _physics_process(delta: float) -> void:
	if OS.is_debug_build():
		if Input.is_action_pressed("player_fly"):
			fly(delta)
			health = MAX_HEALTH
			return
		elif Input.is_action_just_released("player_fly"):
			velocity = Vector2.ZERO

	var direction := Input.get_axis("player_left", "player_right")
	match ability:
		Ability.NONE:
			pass
		Ability.DOUBLE_JUMP:
			if air_jumps and not is_on_floor() and Input.is_action_just_pressed("player_jump"):
				air_jumps -= 1
				velocity.y = min(velocity.y, -JUMP_VELOCITY)
		Ability.DASH:
			if dashes and direction and Input.is_action_just_pressed("player_action"):
				dashes -= 1
				movement = Movement.Dash.new(Vector2(signf(direction), 0))
	if movement:
		return
	
	if is_on_floor():
		dashes = DASHES
		air_jumps = AIR_JUMPS
		jump_timer.start()
	else:
		velocity += get_gravity() * delta
	
	velocity.y = minf(velocity.y, MAX_FALL_SPEED)

	if position.y > 200:
		die()

	if Input.is_action_pressed("player_jump") and jump_timer.time_left:
		velocity.y = min(velocity.y, -JUMP_VELOCITY)
		jump_timer.stop()

	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, DECELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	move_and_slide()
