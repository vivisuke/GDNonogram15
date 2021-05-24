extends Node2D

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

enum { MODE_SOLVE, MODE_EDIT_PICT, MODE_EDIT_CLUES }

var mode = MODE_EDIT_PICT;
var dialog_opened = false;
var mouse_pushed = false
var last_xy = Vector2()
var cell_val = 0

func _ready():
	#$TileMap.set_cell(0, 0, 0)
	pass # Replace with function body.
func check_clues(x0, y0):
	pass
func update_clues(x0, y0):
	pass
func posToXY(pos):
	var xy = Vector2(-1, -1)
	var X0 = $TileMap.position.x
	var Y0 = $TileMap.position.y
	if pos.x >= X0 && pos.x < X0 + CELL_WIDTH*N_IMG_CELL_HORZ:
		if pos.y >= Y0 && pos.y < Y0 + CELL_WIDTH*N_IMG_CELL_VERT:
			xy.x = floor((pos.x - X0) / CELL_WIDTH)
			xy.y = floor((pos.y - Y0) / CELL_WIDTH)
	return xy
func _input(event):
	if dialog_opened:
		return;
	if event is InputEventMouseButton:
		#print("InputEventMouseButton")
		if event.is_action_pressed("click"):	# left mouse button
			#print(event.position)
			var xy = posToXY(event.position)
			#print(xy)
			#$MessLabel.text = ""
			#clearTileMapBG()
			if xy.x >= 0:
				mouse_pushed = true;
				last_xy = xy
				var v = $TileMap.get_cell(xy.x, xy.y)
				v = -v;
				cell_val = v
				$TileMap.set_cell(xy.x, xy.y, v)
				if mode == MODE_EDIT_PICT:
					update_clues(xy.x, xy.y)
				elif mode == MODE_SOLVE:
					check_clues(xy.x, xy.y)
				var img = 0 if v == 1 else -1
				#$ImageTileMap.set_cell(xy.x, xy.y, img)
		elif event.is_action_released("click"):
			mouse_pushed = false;
	elif event is InputEventMouseMotion && mouse_pushed:
		var xy = posToXY(event.position)
		if xy.x >= 0 && xy != last_xy:
			#print(xy)
			last_xy = xy
			$TileMap.set_cell(xy.x, xy.y, cell_val)
			update_clues(xy.x, xy.y)
			var img = 0 if cell_val == 1 else -1
			#$ImageTileMap.set_cell(xy.x, xy.y, img)
	pass
