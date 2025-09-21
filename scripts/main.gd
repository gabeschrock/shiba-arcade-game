extends Node2D

var hitboxes: Array[Node2D] = []

@onready var player: CharacterBody2D = $Player
@onready var player_path: Node2D = $PlayerPath
@onready var hitbox_node: Node2D = $PlayerPath/Hitbox
@onready var last_point := player.position
@onready var playtest_label: Label = $PlaytestLabel

func _ready() -> void:
	if Settings.is_playtest:
		playtest_label.visible = true

func _process(_delta: float) -> void:
	return
	@warning_ignore("unreachable_code")
	var new_point := player.position
	if (new_point - last_point).length() > 2:
		var new_hitbox := hitbox_node.duplicate() as Node2D
		new_hitbox.visible = true
		new_hitbox.position = new_point
		hitboxes.push_back(new_hitbox)
		player_path.add_child(new_hitbox)
		last_point = new_point
	if Input.is_action_just_pressed("player_fly"):
		for hitbox in hitboxes:
			hitbox.queue_free()
		hitboxes = []
