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
const IMAGE_ORG = Vector2(CELL_WIDTH*(N_CLUES_CELL_HORZ), CELL_WIDTH*(N_CLUES_CELL_VERT)+1)

var pos1 = Vector2(-1, -1)		# ライン起点、-1 for ライン無し
var pos2 = Vector2(0, 0)		# ライン終点

func _ready():
	pass # Replace with function body.
func clearLine():
	pos1 = Vector2(-1, -1)
	update()
func setLine(p1, p2):
	pos1 = p1
	pos2 = p2
	update()
func _draw():
	var y2 = BOARD_HEIGHT + 1
	for x in range(N_TOTAL_CELL_HORZ+1):
		var y1 = 0 if x >= N_CLUES_CELL_HORZ || !x else CLUES_WIDTH
		#var col = Color.black if x == 0 || x >= N_CLUES_CELL_HORZ && (x - N_CLUES_CELL_HORZ) % 5 == 0 else Color.gray
		var col = Color.black if (x - N_CLUES_CELL_HORZ) % 5 == 0 else Color.gray
		draw_line(Vector2(x * CELL_WIDTH+1, y1), Vector2(x * CELL_WIDTH+1, y2), col)
	var x2 = BOARD_WIDTH + 1
	for y in range(N_TOTAL_CELL_VERT+1):
		var x1 = 0 if y >= N_CLUES_CELL_HORZ || !y else CLUES_WIDTH
		#var col = Color.black if y == 0 || y >= N_CLUES_CELL_VERT && (y - N_CLUES_CELL_VERT) % 5 == 0 else Color.gray
		var col = Color.black if (y - N_CLUES_CELL_VERT) % 5 == 0 else Color.gray
		draw_line(Vector2(x1, y * CELL_WIDTH+1), Vector2(x2, y * CELL_WIDTH+1), col)
	draw_line(Vector2(0, 0), Vector2(x2, 0), Color.black)
	draw_line(Vector2(0, y2+1), Vector2(x2, y2+1), Color.black)
	#for y in range(4):
	#	var py = (y*5 + N_CLUES_CELL_VERT) * CELL_WIDTH
	#	draw_line(Vector2(0, py), Vector2(x2, py), Color.black)
	draw_line(Vector2(0, 0), Vector2(0, y2+1), Color.black)
	draw_line(Vector2(x2+1, 0), Vector2(x2+1, y2+1), Color.black)
	#for x in range(4):
	#	var px = (x*5 + N_CLUES_CELL_HORZ) * CELL_WIDTH
	#	draw_line(Vector2(px, 0), Vector2(px, y2), Color.black)
	if pos1.x >= 0:
		print("pos1 = ", pos1, ", pos2 = ", pos2)
		#var p1 = pos1 * CELL_WIDTH + IMAGE_ORG
		#var p2 = pos2 * CELL_WIDTH + IMAGE_ORG
		#draw_line(p1, p2, Color.blue, CELL_WIDTH/3+1)
		var left = min(pos1.x, pos2.x) * CELL_WIDTH + IMAGE_ORG.x
		var right = (max(pos1.x, pos2.x) + 1) * CELL_WIDTH + IMAGE_ORG.x
		var wd = right - left
		var upper = min(pos1.y, pos2.y) * CELL_WIDTH + IMAGE_ORG.y
		var bottom = (max(pos1.y, pos2.y) + 1) * CELL_WIDTH + IMAGE_ORG.y
		var ht = bottom - upper
		print(left, ", ", upper, ", ", wd, ", ", ht)
		draw_rect(Rect2(left, upper, wd, ht), Color(0.5, 0.5, 1.0, 0.5))
func _input(event):
	#print("BoardGrid::_input()")
	pass
