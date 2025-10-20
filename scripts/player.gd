extends CharacterBody2D

signal dash

enum Ability {
	NONE,
	DOUBLE_JUMP,
	DASH,
	DOUBLE_JUMP_DASH,
}

const Checkpoint = preload("res://scripts/checkpoint.gd")
const FlashManager = preload("res://scripts/flash_manager.gd")
const Stopwatch = preload("res://scripts/stopwatch.gd")

const CIRCLE_EFFECT = preload("res://scenes/circle_effect.tscn")
const PLATFORM_EFFECT = preload("res://scenes/platform_effect.tscn")

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
	Ability.DOUBLE_JUMP_DASH: "Double Jump + Dash",
}

var dashes := 0
var air_jumps := 0
var jumping := false
var in_danger := false
var dying := false
var facing: int:
	get():
		return -1 if sprite.flip_h else 1
var ability := Ability.NONE:
	set(value):
		if ability == value:
			return
		var was_zoomed_out := ability == Ability.DOUBLE_JUMP_DASH
		ability = value
		var is_none := value == Ability.NONE
		if not is_none:
			ability_label.text = "Ability: " + NICE_NAMES[value]
		ability_label.visible = not is_none
		ability_flash.flash()
		var zoom_out := value == Ability.DOUBLE_JUMP_DASH
		if zoom_out != was_zoomed_out:
			var tween := get_tree().create_tween()
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(camera, "zoom", Vector2.ONE * (1 if zoom_out else 2), 0.3)
var checkpoint: Checkpoint:
	set(value):
		checkpoint = value
		if Settings.can_heal():
			health = MAX_HEALTH
		respawn_pos = get_parent().to_local(checkpoint.sprite.global_position)
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
@onready var respawn_pos := position
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
@onready var dash_sound: AudioStreamPlayer = $DashSound
@onready var timer: Label = $GUI/Timer
@onready var pause_menu: Control = $GUI/PauseMenu
@onready var camera: Camera2D = $Camera2D
@onready var stopwatch: Stopwatch = $Stopwatch

func circle_effect(color := Color.WHITE):
	var effect := CIRCLE_EFFECT.instantiate()
	effect.self_modulate = color
	get_parent().add_child(effect)
	effect.global_position = global_position
	
func platform_effect(color := Color.WHITE):
	var effect := PLATFORM_EFFECT.instantiate()
	effect.self_modulate = color
	get_parent().add_child(effect)
	effect.global_position = $Bottom.global_position

func _ready() -> void:
	health = MAX_HEALTH
	timer.visible = Settings.show_timer
	Settings.show_timer_changed.connect(_on_show_timer_changed)
	Settings.player = self

func _on_show_timer_changed(value: bool) -> void:
	timer.visible = value

func pause() -> void:
	pause_menu.visible = true
	get_tree().set_deferred("paused", true)

func fly(delta: float) -> void:
	position += Input.get_vector("player_left", "player_right", "player_up", "player_down") * FLY_SPEED * delta

func die(force := false) -> void:
	set_health((health - 1) >> 1 << 1, force)

func set_health(value: int, force := false) -> void:
	if _health == value or dying:
		return
	if value < _health and flash.flashing and not force:
		return
	if value <= 0 and not Settings.is_invincible():
		dying = true
		shape.disabled = true
		hurt_sound.play()
		flash.flash()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	if value < _health:
		if not value & 1:
			position = respawn_pos
			velocity = Vector2.ZERO
			movement = null
			if Settings.is_life_unlimited():
				value = MAX_HEALTH
		visible = true
		flash.flash()
		hurt_sound.play()
	if Settings.is_invincible() and not force:
		return
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
	var time := stopwatch.time
	var hours := floori(time / 3600)
	var minutes := floori(time / 60) % 60
	var seconds := fmod(time, 60)
	var text := "%d:%05.2f" % [minutes, seconds]
	if hours:
		text = str(hours) + ":" + text.pad_zeros(5)
	return text
	
func _process(_delta: float) -> void:
	timer.text = get_time()
	if Input.is_action_just_pressed("exit"):
		pause()
	if Input.is_action_just_pressed("screenshot") and OS.is_debug_build():
		await RenderingServer.frame_post_draw
		var screen := get_viewport().get_texture().get_image()
		var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
		var path = "user://screenshot_%s.png" % timestamp
		screen.save_png(path)
		print("Screenshot saved as ", ProjectSettings.globalize_path(path))
	if Input.is_action_just_pressed("slow") and OS.is_debug_build():
		pass

func jump() -> void:
	if velocity.y > -JUMP_VELOCITY:
		var platform_vy := get_platform_velocity().y
		velocity.y = -JUMP_VELOCITY
		movement = null
		await get_tree().physics_frame
		if velocity.y >= -JUMP_VELOCITY + platform_vy * 1.1:
			jumping = true
			jump_timer.stop()
			jump_sound.play()

func handle_double_jump():
	if air_jumps and not is_on_floor() and Input.is_action_just_pressed("player_jump"):
		air_jumps -= 1
		platform_effect()
		jump()
	if Input.is_action_just_released("player_jump") and jumping:
		velocity.y *= JUMP_CUTOFF

func handle_dash():
	if dashes and Input.is_action_just_pressed("player_action"):
		dashes -= 1
		movement = Movement.Dash.new(Vector2(facing, 0))
		dash.emit()

func _physics_process(delta: float):
	if dying:
		return
	var camera_rect := camera.get_viewport_rect()
	camera_rect.position = camera.get_screen_center_position() - camera_rect.size / 2
	if flash.flashing and not camera_rect.has_point(global_position):
		flash.flash()
		return
	if Settings.is_playtest:
		if OS.is_debug_build() and Input.is_action_just_pressed("player_fly"):
			print(-position.y)
		if Input.is_action_pressed("player_fly"):
			fly(delta)
			health = MAX_HEALTH
			return
		elif Input.is_action_just_released("player_fly"):
			velocity = Vector2.ZERO

	var was_in_danger := in_danger
	in_danger = len(danger_area.get_overlapping_bodies()) > 0
	if in_danger and not was_in_danger:
		health -= 2 if Settings.has_double_damage() else 1

	var height := -position.y
	if height > 1750:
		ability = Ability.NONE
	elif 1300 < height and height < 1740:
		ability = Ability.DOUBLE_JUMP_DASH
	elif 900 < height and height < 1260:
		ability = Ability.DASH
	elif 530 < height and height < 830:
		ability = Ability.DOUBLE_JUMP
	elif height < 510:
		ability = Ability.NONE

	var has_jumped := false
	if Input.is_action_pressed("player_jump") and jump_timer.time_left:
		jump()
		has_jumped = true

	var direction := Input.get_axis("player_left", "player_right")
	if velocity.y > 0:
		jumping = false
	match ability:
		Ability.NONE:
			pass
		Ability.DOUBLE_JUMP:
			if not has_jumped:
				handle_double_jump()
		Ability.DASH:
			handle_dash()
		Ability.DOUBLE_JUMP_DASH:
			handle_double_jump()
			handle_dash()
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

	if Input.is_action_just_released("player_jump") and jumping:
		velocity.y *= JUMP_CUTOFF
	
	if direction:
		stopwatch.start()
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

func _on_dash() -> void:
	circle_effect(Color.RED)
	dash_sound.play()
