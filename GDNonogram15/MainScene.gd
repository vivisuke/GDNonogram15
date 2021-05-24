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

const TILE_NUM_0 = 1
const ColorClues = Color("#dff9fb")

enum { MODE_SOLVE, MODE_EDIT_PICT, MODE_EDIT_CLUES }

var mode = MODE_EDIT_PICT;
var dialog_opened = false;
var mouse_pushed = false
var last_xy = Vector2()
var cell_val = 0
var g_map = {}		# 水平・垂直方向手がかり数字配列 → 候補数値マップ
var h_clues = []		# 水平方向手がかり数字リスト
var v_clues = []		# 垂直方向手がかり数字リスト
var h_candidates = []	# 水平方向候補リスト
var v_candidates = []	# 垂直方向候補リスト
var h_fixed_bits_1 = []
var h_fixed_bits_0 = []
var v_fixed_bits_1 = []
var v_fixed_bits_0 = []

func _ready():
	mode = MODE_EDIT_PICT
	#$TileMap.set_cell(0, 0, 0)
	build_map()
	#print(g_map.size())
	h_clues.resize(N_IMG_CELL_VERT)
	v_clues.resize(N_IMG_CELL_HORZ)
	pass # Replace with function body.
# 101101110 → [3, 2, 1]	下位ビットの方が配列先頭とする
func data_to_clues(data : int) -> Array:
	var lst = []
	while data != 0:
		var b = data & -data
		data ^= b
		var n = 1
		b <<= 1
		while (data & b) != 0:
			data ^= b
			b <<= 1
			n += 1
		lst.push_back(n)
	return lst
# key は連配列、下位ビットの方が配列先頭
func build_map():
	g_map.clear()
	for data in range(1<<N_IMG_CELL_HORZ):
		var key = data_to_clues(data)
		if g_map.has(key):
			g_map[key].push_back(data)
		else:
			g_map[key] = [data]
func check_clues(x0, y0):
	pass
func update_h_clues(y0):
	# 水平方向手がかり数字更新
	var data = 0
	for x in range(N_IMG_CELL_HORZ):
		data = data * 2 + (1 if $TileMap.get_cell(x, y0) == 1 else 0)
	var lst = data_to_clues(data)
	h_clues[y0] = lst;
	var x = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x, y0, lst[i] + TILE_NUM_0)
		x -= 1
	while x >= -N_CLUES_CELL_HORZ:
		$TileMap.set_cell(x, y0, -1)
		x -= 1
func update_v_clues(x0):
	# 垂直方向手がかり数字更新
	var data = 0
	for y in range(N_IMG_CELL_VERT):
		data = data * 2 + (1 if $TileMap.get_cell(x0, y) == 1 else 0)
	var lst = data_to_clues(data)
	v_clues[x0] = lst;
	var y = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x0, y, lst[i] + TILE_NUM_0)
		y -= 1
	while y >= -N_CLUES_CELL_VERT:
		$TileMap.set_cell(x0, y, -1)
		y -= 1
func update_clues(x0, y0):
	update_h_clues(y0)
	update_v_clues(x0)
	pass
func update_all_clues():
	for y in range(N_IMG_CELL_VERT):
		update_h_clues(y)
	for x in range(N_IMG_CELL_HORZ):
		update_v_clues(x)
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
				$ImageTileMap.set_cell(xy.x, xy.y, img)
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
			$ImageTileMap.set_cell(xy.x, xy.y, img)
	pass


func clear_all():
	# undone: 候補数字クリア
	for y in range(N_TOTAL_CELL_VERT):
		for x in range(N_TOTAL_CELL_HORZ):
			$TileMap.set_cell(x, y, -1)
			$ImageTileMap.set_cell(x, y, -1)
		for x in range(N_CLUES_CELL_HORZ):
			$TileMap.set_cell(-x-1, y, -1)
	for x in range(N_TOTAL_CELL_HORZ):
		for y in range(N_CLUES_CELL_VERT):
			$TileMap.set_cell(x, -y-1, -1)
func _on_ClearButton_pressed():
	clear_all()
	pass # Replace with function body.

func rotate_left():
	var ar = []
	for y in range(N_IMG_CELL_VERT):
		ar.push_back($TileMap.get_cell(0, y))	# may be -1 or +1
	for x in range(N_IMG_CELL_HORZ-1):
		for y in range(N_IMG_CELL_VERT):
			$TileMap.set_cell(x, y, $TileMap.get_cell(x+1, y))
	for y in range(N_IMG_CELL_VERT):
		$TileMap.set_cell(N_IMG_CELL_HORZ-1, y, ar[y])
	update_all_clues()
func _on_LeftButton_pressed():
	rotate_left()
	pass # Replace with function body.
func rotate_right():
	var ar = []
	for y in range(N_IMG_CELL_VERT):
		ar.push_back($TileMap.get_cell(N_IMG_CELL_HORZ-1, y))	# may be -1 or +1
	for x in range(N_IMG_CELL_HORZ-1, 0, -1):
		for y in range(N_IMG_CELL_VERT):
			$TileMap.set_cell(x, y, $TileMap.get_cell(x-1, y))
	for y in range(N_IMG_CELL_VERT):
		$TileMap.set_cell(0, y, ar[y])
	update_all_clues()
func _on_RightButton_pressed():
	rotate_right()
	pass # Replace with function body.
func rotate_down():
	var ar = []
	for x in range(N_IMG_CELL_HORZ):
		ar.push_back($TileMap.get_cell(x, N_IMG_CELL_VERT-1))	# may be -1 or +1
	for y in range(N_IMG_CELL_VERT-1, 0, -1):
		for x in range(N_IMG_CELL_HORZ):
			$TileMap.set_cell(x, y, $TileMap.get_cell(x, y-1))
	for x in range(N_IMG_CELL_HORZ):
		$TileMap.set_cell(x, 0, ar[x])
	update_all_clues()
func _on_DownButton_pressed():
	rotate_down()
	pass # Replace with function body.
func rotate_up():
	var ar = []
	for x in range(N_IMG_CELL_HORZ):
		ar.push_back($TileMap.get_cell(x, 0))	# may be -1 or +1
	for y in range(N_IMG_CELL_VERT-1):
		for x in range(N_IMG_CELL_HORZ):
			$TileMap.set_cell(x, y, $TileMap.get_cell(x, y+1))
	for x in range(N_IMG_CELL_HORZ):
		$TileMap.set_cell(x, N_IMG_CELL_VERT-1, ar[x])
	update_all_clues()
func _on_UpButton_pressed():
	rotate_up()
	pass # Replace with function body.
