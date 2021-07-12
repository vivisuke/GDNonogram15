extends ColorRect

onready var g = get_node("/root/Global")


func _ready():
	#print(CELL_WIDTH)
	pass # Replace with function body.
func _draw():
	draw_rect(Rect2(0, g.CLUES_WIDTH, g.CLUES_WIDTH, g.IMG_AREA_WIDTH), Color.lightblue)
	draw_rect(Rect2(g.CLUES_WIDTH, 0, g.IMG_AREA_WIDTH, g.CLUES_WIDTH), Color.lightblue)
# warning-ignore:unused_argument
func _input(event):
	#print("BoardBG::_input()")
	pass
