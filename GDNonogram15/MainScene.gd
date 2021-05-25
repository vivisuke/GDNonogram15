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

const BITS_MASK = (1<<N_IMG_CELL_HORZ) - 1

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
	update_modeButtons()
	#$TileMap.set_cell(0, 0, 0)
	build_map()
	#print(g_map.size())
	h_clues.resize(N_IMG_CELL_VERT)
	v_clues.resize(N_IMG_CELL_HORZ)
	pass # Replace with function body.
func init_arrays():
	h_candidates.resize(N_IMG_CELL_VERT)
	v_candidates.resize(N_IMG_CELL_HORZ)
	h_fixed_bits_1.resize(N_IMG_CELL_VERT)
	h_fixed_bits_0.resize(N_IMG_CELL_VERT)
	v_fixed_bits_1.resize(N_IMG_CELL_HORZ)
	v_fixed_bits_0.resize(N_IMG_CELL_HORZ)
	#print(h_candidates)
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
func to_binText(d : int) -> String:
	var txt = ""
	var mask = 1 << (N_IMG_CELL_HORZ - 1)
	while mask != 0:
		txt += '1' if (d&mask) != 0 else '0'
		mask >>= 1
	return txt
func to_hexText(lst : Array) -> String:
	var txt = "["
	for i in range(lst.size()):
		txt += to_binText(lst[i])
		txt += ", "
	txt += "]"
	return txt
func init_candidates():
	#print("\n*** init_candidates():")
	#print("g_map[[4]] = ", g_map[[4]])
	for y in range(N_IMG_CELL_VERT):
		#print("h_clues[", y, "] = ", h_clues[y])
		if h_clues[y] == null:
			h_candidates[y] = [0]
		else:
			h_candidates[y] = g_map[h_clues[y]].duplicate()
		#print( "h_cand[", y, "] = ", to_hexText(h_candidates[y]) )
	for x in range(N_IMG_CELL_HORZ):
		#print("v_clues[", x, "] = ", v_clues[x])
		if v_clues[x] == null:
			v_candidates[x] = [0]
		else:
			v_candidates[x] = g_map[v_clues[x]].duplicate()
		#print( "v_cand[", x, "] = ", to_hexText(v_candidates[x]) )
	#print("g_map[[4]] = ", g_map[[4]])
func num_candidates():
	var sum = 0
	for y in range(N_IMG_CELL_VERT):
		sum += h_candidates[y].size()
	for x in range(N_IMG_CELL_HORZ):
		sum += v_candidates[x].size()
	return sum
# h_candidates[] を元に h_fixed_bits_1, 0 を計算
func update_h_fixedbits():
	#print("\n*** update_h_fixedbits():")
	for y in range(N_IMG_CELL_VERT):
		var lst = h_candidates[y]
		if lst.size() == 1:
			h_fixed_bits_1[y] = lst[0]
			h_fixed_bits_0[y] = ~lst[0] & BITS_MASK
		else:
			var bits1 = BITS_MASK
			var bits0 = BITS_MASK
			for i in range(lst.size()):
				bits1 &= lst[i]
				bits0 &= ~lst[i]
			h_fixed_bits_1[y] = bits1
			h_fixed_bits_0[y] = bits0
		#print("h_fixed[", y , "] = ", to_binText(h_fixed_bits_1[y]), ", ", to_binText(h_fixed_bits_0[y]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
# v_candidates[] を元に v_fixed_bits_1, 0 を計算
func update_v_fixedbits():
	#print("\n*** update_v_fixedbits():")
	for x in range(N_IMG_CELL_HORZ):
		var lst = v_candidates[x]
		if lst.size() == 1:
			v_fixed_bits_1[x] = lst[0]
			v_fixed_bits_0[x] = ~lst[0] & BITS_MASK
		else:
			var bits1 = BITS_MASK
			var bits0 = BITS_MASK
			for i in range(lst.size()):
				bits1 &= lst[i]
				bits0 &= ~lst[i]
			v_fixed_bits_1[x] = bits1
			v_fixed_bits_0[x] = bits0
		#print("v_fixed[", x , "] = ", to_binText(v_fixed_bits_1[x]), ", ", to_binText(v_fixed_bits_0[x]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
func hFixed_to_vFixed():
	#print("\n*** hFixed_to_vFixed():")
	for x in range(N_IMG_CELL_HORZ):
		v_fixed_bits_1[x] = 0
		v_fixed_bits_0[x] = 0
	var hmask = 1 << N_IMG_CELL_HORZ;
	for x in range(N_IMG_CELL_HORZ):
		hmask >>= 1
		var vmask = 1 << N_IMG_CELL_VERT;
		for y in range(N_IMG_CELL_VERT):
			vmask >>= 1
			if( (h_fixed_bits_1[y] & hmask) != 0 ):
				v_fixed_bits_1[x] |= vmask;
			if( (h_fixed_bits_0[y] & hmask) != 0 ):
				v_fixed_bits_0[x] |= vmask;
		#print("v_fixed[", x , "] = ", to_binText(v_fixed_bits_1[x]), ", ", to_binText(v_fixed_bits_0[x]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
func vFixed_to_hFixed():
	#print("\n*** vFixed_to_hFixed():")
	for y in range(N_IMG_CELL_VERT):
		h_fixed_bits_1[y] = 0
		h_fixed_bits_0[y] = 0
	var vmask = 1 << N_IMG_CELL_VERT;
	for y in range(N_IMG_CELL_VERT):
		vmask >>= 1
		var hmask = 1 << N_IMG_CELL_HORZ;
		for x in range(N_IMG_CELL_HORZ):
			hmask >>= 1
			if( (v_fixed_bits_1[x] & vmask) != 0 ):
				h_fixed_bits_1[y] |= hmask;
			if( (v_fixed_bits_0[x] & vmask) != 0 ):
				h_fixed_bits_0[y] |= hmask;
		#print("h_fixed[", y , "] = ", to_binText(h_fixed_bits_1[y]), ", ", to_binText(h_fixed_bits_0[y]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
# v_fixed_bits_1, 0 を元に v_candidates[] から不可能なパターンを削除
func update_v_candidates():
	#print("\n*** update_v_candidates():")
	for x in range(N_IMG_CELL_HORZ):
		for i in range(v_candidates[x].size()-1, -1, -1):
			if( (v_candidates[x][i] & v_fixed_bits_1[x]) != v_fixed_bits_1[x] ||
					(~v_candidates[x][i] & v_fixed_bits_0[x]) != v_fixed_bits_0[x] ):
				v_candidates[x].remove(i)
		#print( "v_cand[", x, "] = ", to_hexText(v_candidates[x]) )
	#print("g_map[[4]] = ", g_map[[4]])
	pass
# h_fixed_bits_1, 0 を元に h_candidates[] から不可能なパターンを削除
func update_h_candidates():
	#print("\n*** update_h_candidates():")
	for y in range(N_IMG_CELL_VERT):
		for i in range(h_candidates[y].size()-1, -1, -1):
			if( (h_candidates[y][i] & h_fixed_bits_1[y]) != h_fixed_bits_1[y] ||
					(~h_candidates[y][i] & h_fixed_bits_0[y]) != h_fixed_bits_0[y] ):
				h_candidates[y].remove(i)
		#print( "h_cand[", y, "] = ", to_hexText(h_candidates[y]) )
	#print("g_map[[4]] = ", g_map[[4]])
	pass
func check_h_clues(y0):		# 水平方向チェック
	var d = get_h_data(y0)
	var lst = g_map[h_clues[y0]]
	var bg = -1 if lst.has(d) else 0
	for x in range(N_CLUES_CELL_HORZ):
		$TileMapBG.set_cell(-x-1, y0, bg)
func check_v_clues(x0):		# 垂直方向チェック
	var d = get_v_data(x0)
	var lst = g_map[v_clues[x0]]
	var bg = -1 if lst.has(d) else 0
	for y in range(N_CLUES_CELL_VERT):
		$TileMapBG.set_cell(x0, -y-1, bg)
func check_clues(x0, y0):
	check_h_clues(y0)
	check_v_clues(x0)
func get_h_data(y0):
	var data = 0
	for x in range(N_IMG_CELL_HORZ):
		data = data * 2 + (1 if $TileMap.get_cell(x, y0) == 1 else 0)
	return data
func get_v_data(x0):
	var data = 0
	for y in range(N_IMG_CELL_VERT):
		data = data * 2 + (1 if $TileMap.get_cell(x0, y) == 1 else 0)
	return data
func update_h_clues(y0):
	# 水平方向手がかり数字更新
	var data = get_h_data(y0)
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
	var data = get_v_data(x0)
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
func clearMiniTileMap():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			$MiniTileMap.set_cell(x, y, -1)
func clearTileMap():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			$TileMap.set_cell(x, y, -1)
func clearTileMapBG():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			$TileMapBG.set_cell(x, y, -1)
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
			$MessLabel.text = ""
			clearTileMapBG()
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
				$MiniTileMap.set_cell(xy.x, xy.y, img)
		elif event.is_action_released("click"):
			mouse_pushed = false;
	elif event is InputEventMouseMotion && mouse_pushed:
		var xy = posToXY(event.position)
		if xy.x >= 0 && xy != last_xy:
			#print(xy)
			last_xy = xy
			$TileMap.set_cell(xy.x, xy.y, cell_val)
			if( mode == MODE_EDIT_PICT):
				update_clues(xy.x, xy.y)
			elif mode == MODE_SOLVE:
				check_clues(xy.x, xy.y)
			var img = 0 if cell_val == 1 else -1
			$MiniTileMap.set_cell(xy.x, xy.y, img)
	pass


func clear_all():
	for y in range(N_TOTAL_CELL_VERT):
		for x in range(N_TOTAL_CELL_HORZ):
			$TileMap.set_cell(x, y, -1)
			$MiniTileMap.set_cell(x, y, -1)
		for x in range(N_CLUES_CELL_HORZ):
			$TileMap.set_cell(-x-1, y, -1)
	for x in range(N_TOTAL_CELL_HORZ):
		for y in range(N_CLUES_CELL_VERT):
			$TileMap.set_cell(x, -y-1, -1)
	for y in range(N_IMG_CELL_VERT):
		h_clues[y] = null
	for x in range(N_IMG_CELL_HORZ):
		v_clues[x] = null
func _on_ClearButton_pressed():
	clear_all()
	pass # Replace with function body.
func upate_imageTileMap():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			var img = 0 if $TileMap.get_cell(x, y) == 1 else -1
			$MiniTileMap.set_cell(x, y, img)

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
	upate_imageTileMap()
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
	upate_imageTileMap()
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
	upate_imageTileMap()
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
	upate_imageTileMap()
func _on_UpButton_pressed():
	rotate_up()
	pass # Replace with function body.


func _on_CheckButton_pressed():
	init_arrays()
	init_candidates()
	var nc0 = 0
	var solved = false
	while true:
		update_h_fixedbits()
		#print("num candidates = ", num_candidates())
		var nc = num_candidates()
		if nc == N_IMG_CELL_HORZ + N_IMG_CELL_VERT:	# solved
			solved = true
			break
		if nc == nc0:	# CAN't be solved
			break;
		nc0 = nc
		hFixed_to_vFixed()
		update_v_candidates()
		update_v_fixedbits()
		vFixed_to_hFixed()
		update_h_candidates()
	print(solved)
	if solved:
		$MessLabel.add_color_override("font_color", Color("black"))
		$MessLabel.text = "Propper Quest"
	else:
		$MessLabel.add_color_override("font_color", Color("#ff0000"))
		$MessLabel.text = "Impropper Quest"
	var txt = ""
	for y in range(N_IMG_CELL_VERT):
		#print(to_binText(h_fixed_bits_1[y]), " ", to_binText(h_fixed_bits_0[y]))
		var mask = 1<<(N_IMG_CELL_HORZ-1)
		var x = -1
		while mask != 0:
			x += 1
			if (h_fixed_bits_1[y] & mask) != 0:
				txt += "#"
			elif (h_fixed_bits_0[y] & mask) != 0:
				txt += "."
			else:
				txt += "?"
				$TileMapBG.set_cell(x, y, 0)	# yellow
			mask >>= 1
		txt += "\n"
	print(txt)
	pass # Replace with function body.
func update_modeButtons():
	if mode == MODE_SOLVE:
		$SolveButton.add_color_override("font_color", Color.white)
		$SolveButton.icon = load("res://images/light_white.png")
		$EditButton.add_color_override("font_color", Color.darkgray)
		$EditButton.icon = load("res://images/edit_gray.png")
	elif mode == MODE_EDIT_PICT:
		$SolveButton.add_color_override("font_color", Color.darkgray)
		$SolveButton.icon = load("res://images/light_gray.png")
		$EditButton.add_color_override("font_color", Color.white)
		$EditButton.icon = load("res://images/edit_white.png")
	pass
func _on_SolveButton_pressed():
	mode = MODE_SOLVE
	update_modeButtons()
	clearMiniTileMap()
	#clearTileMapBG()
	clearTileMap()
	pass # Replace with function body.
func _on_EditPictButton_pressed():
	mode = MODE_EDIT_PICT
	update_modeButtons()
	pass # Replace with function body.
