@tool
extends Path2D

@export var speed := 40.0
@export var dash_based := false

var direction := 1

@onready var follow: PathFollow2D = $PathFollow2D
@onready var body: StaticBody2D = $AnimatableBody2D
@onready var reverse_timer: Timer = $ReverseTimer

@export_tool_button("Snap to Map", "TileMapLayer")
var snap_action = snap

func snap() -> void:
	var offset := Vector2.ZERO
	if curve.point_count > 0:
		offset = curve.get_point_position(0)
		position += offset
		curve.set_point_position(0, Vector2.ZERO)
	position = round_pos(position, 0.5)
	for i in range(curve.point_count):
		curve.set_point_position(i, round_pos(
			curve.get_point_position(i) - (Vector2.ZERO if i == 0 else offset)
		))

func round_pos(pos: Vector2, offset := 0.0):
	var o := Vector2.ONE * offset
	return ((pos / 16 + o).round() - o) * 16

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	follow.progress = 1
	await get_tree().process_frame
	if dash_based:
		Settings.player.dash.connect(reverse)
		$AnimatableBody2D/DashIndicator.visible = true

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	follow.progress += direction * speed * delta
	if not dash_based and \
			fmod(follow.progress_ratio, 1.0) == 0 and \
			not reverse_timer.time_left:
		reverse_timer.start()

func reverse() -> void:
	direction = -direction
