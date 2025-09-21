extends CharacterBody2D

enum Ability {
	NONE,
	DOUBLE_JUMP,
	DASH,
}

const Checkpoint = preload("res://scripts/checkpoint.gd")
const FlashManager = preload("res://scripts/flash_manager.gd")

const SPEED = 110.0
const DECELERATION = 3000.0
const JUMP_VELOCITY = 200.0
const JUMP_CUTOFF = 0.5
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
var jumping := false
var in_danger := false
var time := 0.0
var ability := Ability.NONE:
	set(value):
		if ability == value:
			return
		ability = value
		var is_none := value == Ability.NONE
		if not is_none:
			ability_label.text = "Ability: " + NICE_NAMES[value]
		ability_label.visible = not is_none
		ability_flash.flash()
var checkpoint: Checkpoint:
	set(value):
		if value.active:
			return
		value.active = true
		checkpoint = value
		value.set_time(self)
		health = MAX_HEALTH
		respawn_pos = get_parent().to_local(checkpoint.sprite.global_position)
		checkpoint_sound.play()
var health: int:
	get():
		return _health
	set(value):
		set_health(value)
var _health: int
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
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ability_label: Label = $GUI/AbilityLabel
@onready var flash: FlashManager = $Flash
@onready var ability_flash: FlashManager = $AbilityFlash
@onready var danger_area: Area2D = $DangerArea
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var checkpoint_sound: AudioStreamPlayer = $CheckpointSound
@onready var timer: Label = $GUI/Timer
@onready var pause_menu: Control = $GUI/PauseMenu
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	health = MAX_HEALTH
	timer.visible = Settings.show_timer
	Settings.show_timer_changed.connect(_on_show_timer_changed)

func _on_show_timer_changed(value: bool) -> void:
	timer.visible = value

func pause() -> void:
	pause_menu.visible = true
	get_tree().set_deferred("paused", true)
	AudioServer.set_bus_effect_enabled(0, 0, true)

func fly(delta: float) -> void:
	position += Input.get_vector("player_left", "player_right", "player_up", "player_down") * FLY_SPEED * delta

func die(force := false) -> void:
	set_health((health - 1) >> 1 << 1, force)

func set_health(value: int, force := false) -> void:
	if _health == value:
		return
	if value < _health and flash.flashing and not force:
		return
	if value <= 0:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	if value < _health:
		if not value & 1:
			position = respawn_pos
			velocity = Vector2.ZERO
		flash.flash()
		hurt_sound.play()
	_health = value
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		hearts,
		"size:x",
		(value >> 1) * HEART_WIDTH - 1 + (HALF_HEART + 1) * (value & 1),
		0.3
	)

func get_time() -> String:
	var hours := floori(time / 3600)
	var minutes := floori(time / 60) % 60
	var seconds := fmod(time, 60)
	var text := "%d:%05.2f" % [minutes, seconds]
	if hours:
		text = str(hours) + ":" + text.pad_zeros(8)
	return text
	
func _process(delta: float) -> void:
	time += delta
	timer.text = get_time()
	if Input.is_action_just_pressed("exit"):
		pause()

func jump() -> void:
	if velocity.y > -JUMP_VELOCITY:
		velocity.y = -JUMP_VELOCITY
		await get_tree().physics_frame
		if velocity.y >= -JUMP_VELOCITY:
			jumping = true
			jump_timer.stop()
			jump_sound.play()

func _physics_process(delta: float):
	var camera_rect := camera.get_viewport_rect()
	camera_rect.position = camera.get_screen_center_position() - camera_rect.size / 2
	if flash.flashing and not camera_rect.has_point(global_position):
		flash.flash()
		return
	if Settings.is_playtest:
		if Input.is_action_pressed("player_fly"):
			fly(delta)
			health = MAX_HEALTH
			return
		elif Input.is_action_just_released("player_fly"):
			velocity = Vector2.ZERO

	var was_in_danger := in_danger
	in_danger = len(danger_area.get_overlapping_bodies()) > 0
	if in_danger and not was_in_danger:
		health -= 1

	var height := -position.y
	if height > 530:
		ability = Ability.DOUBLE_JUMP
	elif height < 510:
		ability = Ability.NONE

	var direction := Input.get_axis("player_left", "player_right")
	if velocity.y > 0:
		jumping = false
	match ability:
		Ability.NONE:
			pass
		Ability.DOUBLE_JUMP:
			if air_jumps and not is_on_floor() and Input.is_action_just_pressed("player_jump"):
				air_jumps -= 1
				jump()
			if Input.is_action_just_released("player_jump") and jumping:
				velocity.y *= JUMP_CUTOFF
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

	if position.y > 200 or Input.is_action_just_pressed("player_restart"):
		die(true)

	if Input.is_action_pressed("player_jump") and jump_timer.time_left:
		jump()
	if Input.is_action_just_released("player_jump") and jumping:
		velocity.y *= JUMP_CUTOFF
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, DECELERATION * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	if is_on_floor():
		sprite.play("run" if direction else "default")
	else:
		var anim := "jump" if velocity.y < 0 else "fall"
		if sprite.animation != anim:
			sprite.play(anim)

	if not is_inside_tree():
		return
	move_and_slide()
