extends ReferenceRect

const RADIUS = 10
const POSITION = Vector2(2, 2)
const SIZE = Vector2(450-10, 90)
const THUMBNAIL_WIDTH = 15*4
const THUMBNAIL_POS = (90-THUMBNAIL_WIDTH)/2+5
const THUMBNAIL_X = 100-30

func _ready():
	pass # Replace with function body.

func set_number(n : int):
	$numLabel.text = "#%d" % n
func _draw():
	# 外枠
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(RADIUS)
	style_box.border_color = Color.green
	style_box.set_border_width_all(2)
	style_box.shadow_offset = Vector2(4, 4)
	style_box.shadow_size = 8
	draw_style_box(style_box, Rect2(POSITION, SIZE))
	# サムネイル
	draw_rect(Rect2(THUMBNAIL_X, THUMBNAIL_POS, THUMBNAIL_WIDTH, THUMBNAIL_WIDTH), Color.white)

