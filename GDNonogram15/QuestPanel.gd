extends ReferenceRect

signal pressed(num)

const RADIUS = 10
const POSITION = Vector2(2, 2)
const SIZE = Vector2(450-10, 90)
const THUMBNAIL_WIDTH = 15*4
const THUMBNAIL_POS = (90-THUMBNAIL_WIDTH)/2+2
const THUMBNAIL_X = 100-30

var mouse_pushed = false
var saved_pos
var number :int = 0

func _ready():
	pass # Replace with function body.

func set_number(n : int):
	number = n
	$number.text = "#%d" % n
func set_difficulty(n : int):
	$difficulty.text = "Difficulty: %d" % n
func set_title(ttl):
	$title.text = "Title: " + ttl
func set_author(name):
	$author.text = "Author: " + name
func _input(event):
	if event is InputEventMouseButton:
		#print("InputEventMouseButton")
		if event.is_action_pressed("click"):		# left mouse button
			if get_global_rect().has_point(event.position):		# 
				mouse_pushed = true;
				saved_pos = get_global_rect()
				update()
		elif event.is_action_released("click") && mouse_pushed:
			if get_global_rect() == saved_pos:
				if get_global_rect().has_point(event.position):		# 
					print("pressed: ", $number.text)
					emit_signal("pressed", number)
			mouse_pushed = false;
			update()
	elif event is InputEventMouseMotion && mouse_pushed:	# mouse Moved
		if get_global_rect() != saved_pos || !get_global_rect().has_point(event.position):	# 
			mouse_pushed = false;
			update()
func _draw():
	# 外枠
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(RADIUS)
	style_box.bg_color = Color.darkslategray if !mouse_pushed else Color.gray
	style_box.border_color = Color.green
	style_box.set_border_width_all(2)
	style_box.shadow_offset = Vector2(4, 4)
	style_box.shadow_size = 8
	draw_style_box(style_box, Rect2(POSITION, SIZE))
	# サムネイル
	draw_rect(Rect2(THUMBNAIL_X, THUMBNAIL_POS, THUMBNAIL_WIDTH, THUMBNAIL_WIDTH), Color.white)

