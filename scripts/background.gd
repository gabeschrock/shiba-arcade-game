extends CanvasLayer

const WIDTH = Settings.BG_WIDTH
const HEIGHT = Settings.BG_HEIGHT
const COLORS: Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.WHITE,
]

@onready var sprite: Sprite2D = $Sprite2D
var image := Settings.background

func update_texture() -> void:
	(sprite.texture as ImageTexture).update(image)

func random_color() -> Color:
	return COLORS[randi_range(0, len(COLORS) - 1)] / 2

func _ready() -> void:
	sprite.texture = ImageTexture.create_from_image(image)

func _on_mutate_timer_timeout() -> void:
	randomize()
	var x := randi_range(0, WIDTH - 1)
	var y := randi_range(0, HEIGHT - 1)
	var color := COLORS[randi_range(0, len(COLORS) - 1)] / 2
	image.set_pixel(x, y, color)
	update_texture()
