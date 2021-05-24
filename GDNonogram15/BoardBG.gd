extends ColorRect

const SCREEN_WIDTH = 480.0
const SCREEN_HEIGHT = 800.0
const BOARD_WIDTH = 460.0
const BOARD_HEIGHT = BOARD_WIDTH
const LR_SPC = (SCREEN_WIDTH - BOARD_WIDTH) / 2

const N_CLUES_CELL_HORZ = 8		# 手がかり数字 セル数
const N_IMG_CELL_HORZ = 15		# 画像 セル数
const N_TOTAL_CELL_HORZ = N_CLUES_CELL_HORZ + N_IMG_CELL_HORZ
const N_CLUES_CELL_VERT = 8		# 手がかり数字 セル数
const N_IMG_CELL_VERT = 15		# 画像 セル数
const N_TOTAL_CELL_VERT = N_CLUES_CELL_VERT + N_IMG_CELL_VERT
const CELL_WIDTH = BOARD_WIDTH / N_TOTAL_CELL_HORZ
const CLUES_WIDTH = CELL_WIDTH * N_CLUES_CELL_HORZ
const IMG_AREA_WIDTH = CELL_WIDTH * N_IMG_CELL_HORZ


func _ready():
	#print(CELL_WIDTH)
	pass # Replace with function body.
func _draw():
	draw_rect(Rect2(0, CLUES_WIDTH, CLUES_WIDTH, IMG_AREA_WIDTH), Color.lightblue)
	draw_rect(Rect2(CLUES_WIDTH, 0, IMG_AREA_WIDTH, CLUES_WIDTH), Color.lightblue)
# warning-ignore:unused_argument
func _input(event):
	#print("BoardBG::_input()")
	pass
