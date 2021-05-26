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

const TILE_NONE = -1
const TILE_CROSS = 0		# ☓
const TILE_BLACK = 1
const TILE_BG_YELLOW = 0
const TILE_BG_GRAY = 1

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
var h_autoFilledCross = []		# 自動計算で☓を入れたセル（ビットボード, x == 0 が最下位ビット）
var v_autoFilledCross = []		# 自動計算で☓を入れたセル（ビットボード, x == 0 が最下位ビット）

func _ready():
	mode = MODE_SOLVE
	update_modeButtons()
	#$TileMap.set_cell(0, 0, 0)
	build_map()
	#print(g_map.size())
	h_clues.resize(N_IMG_CELL_VERT)
	h_autoFilledCross.resize(N_IMG_CELL_VERT)
	v_autoFilledCross.resize(N_IMG_CELL_HORZ)
	for i in N_IMG_CELL_VERT:
		h_clues[i] = [0]
		h_autoFilledCross[i] = 0
	v_clues.resize(N_IMG_CELL_HORZ)
	for i in N_IMG_CELL_HORZ:
		v_clues[i] = [0]
		v_autoFilledCross[i] = 0
	#
	#var vq = ["3", "1 1", "3"]
	#var hq = ["3", "1 1", "3"]
	var vq = ["1", "2", "2", "5 2", "4 3 3", "5 1 2 3", "5 6", "4 7", "4 2 2 3", "4 2 2 3", "3 3 3", "4 2", "2", "2", "1"]
	var hq = ["5", "7", "7", "8", "4 1", "1 2 1", "1 1 2 1", "1 1", "1 1 1", "7", "7", "2", "7", "13", "15"]
	set_quest(vq, hq)
	pass # Replace with function body.
func set_quest(vq, hq):
	for x in range(N_IMG_CELL_HORZ):
		var lst = []
		if x < vq.size():
			var txt : String = vq[x]
			if (txt.length() % 2) == 1:
				txt = " " + txt
			while !txt.empty():
				lst.push_front(int(txt.left(2)))
				txt = txt.substr(2)
		else:
			lst = [0]
		v_clues[x] = lst
		update_v_cluesText(x, lst)
	for y in range(N_IMG_CELL_VERT):
		var lst = []
		if y < hq.size():
			var txt : String = hq[y]
			if (txt.length() % 2) == 1:
				txt = " " + txt
			while !txt.empty():
				lst.push_front(int(txt.left(2)))
				txt = txt.substr(2)
		else:
			lst = [0]
		h_clues[y] = lst
		update_h_cluesText(y, lst)
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
	if !data:
		return [0]
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
	#print(g_map([1]))
	#print(g_map([0]))
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
	if h_autoFilledCross[y0] != 0:
		var vmask = 1 << y0
		var mask = 1
		for x in range(N_IMG_CELL_HORZ):
			if (h_autoFilledCross[y0] & mask) != 0 && (v_autoFilledCross[x] & vmask) == 0:
				$TileMap.set_cell(x, y0, TILE_NONE)
			mask <<= 1
		h_autoFilledCross[y0] = 0
	#
	var d = get_h_data(y0)
	var lst = g_map[h_clues[y0]]
	#var bg = 1 if lst.has(d) else TILE_NONE
	var bg = TILE_NONE
	if lst.has(d):		# d が正解に含まれる場合
		bg = TILE_BG_GRAY			# グレイ
		var mask = 1
		for x in range(N_IMG_CELL_HORZ):
			if $TileMap.get_cell(x, y0) == TILE_NONE:
				$TileMap.set_cell(x, y0, TILE_CROSS)
				h_autoFilledCross[y0] |= mask
			mask <<= 1
	for x in range(h_clues[y0].size()):
		$TileMapBG.set_cell(-x-1, y0, bg)
func check_v_clues(x0 : int):		# 垂直方向チェック
	if v_autoFilledCross[x0] != 0:
		var hmask = 1 << x0
		var mask = 1
		for y in range(N_IMG_CELL_VERT):
			if (v_autoFilledCross[x0] & mask) != 0 && (h_autoFilledCross[y] & hmask) == 0:
				$TileMap.set_cell(x0, y, TILE_NONE)
			mask <<= 1
		v_autoFilledCross[x0] = 0
	#var mask = 1 << x0
	#for y in range(N_IMG_CELL_VERT):
	#	if (h_autoFilledCross[y] & mask) != 0:
	#		$TileMap.set_cell(x0, y, TILE_NONE)
	#		h_autoFilledCross[y] ^= mask
	#
	var d = get_v_data(x0)
	var lst = g_map[v_clues[x0]]
	#var bg = 1 if lst.has(d) else TILE_NONE
	var bg = TILE_NONE
	if lst.has(d):		# d が正解に含まれる場合
		bg = TILE_BG_GRAY			# グレイ
		var mask = 1
		for y in range(N_IMG_CELL_VERT):
			if $TileMap.get_cell(x0, y) == TILE_NONE:
				$TileMap.set_cell(x0, y, TILE_CROSS)
				v_autoFilledCross[x0] |= mask
			mask <<= 1
	for y in range(v_clues[x0].size()):
		$TileMapBG.set_cell(x0, -y-1, bg)
func check_clues(x0, y0):
	check_h_clues(y0)
	check_v_clues(x0)
func get_h_data(y0):
	var data = 0
	for x in range(N_IMG_CELL_HORZ):
		data = data * 2 + (1 if $TileMap.get_cell(x, y0) == TILE_BLACK else 0)
	return data
func get_v_data(x0):
	var data = 0
	for y in range(N_IMG_CELL_VERT):
		data = data * 2 + (1 if $TileMap.get_cell(x0, y) == TILE_BLACK else 0)
	return data
func update_h_cluesText(y0, lst):
	var x = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x, y0, lst[i] + TILE_NUM_0 if lst[i] != 0 else TILE_NONE)
		x -= 1
	while x >= -N_CLUES_CELL_HORZ:
		$TileMap.set_cell(x, y0, TILE_NONE)
		x -= 1
func update_h_clues(y0):
	# 水平方向手がかり数字更新
	var data = get_h_data(y0)
	var lst = data_to_clues(data)
	h_clues[y0] = lst;
	update_h_cluesText(y0, lst)
func update_v_cluesText(x0, lst):
	var y = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x0, y, lst[i] + TILE_NUM_0 if lst[i] != 0 else TILE_NONE)
		y -= 1
	while y >= -N_CLUES_CELL_VERT:
		$TileMap.set_cell(x0, y, TILE_NONE)
		y -= 1
func update_v_clues(x0):
	# 垂直方向手がかり数字更新
	var data = get_v_data(x0)
	var lst = data_to_clues(data)
	v_clues[x0] = lst;
	update_v_cluesText(x0, lst)
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
			$MiniTileMap.set_cell(x, y, TILE_NONE)
func clearTileMap():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			$TileMap.set_cell(x, y, TILE_NONE)
func clearTileMapBG():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			$TileMapBG.set_cell(x, y, TILE_NONE)
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
		if( event.is_action_pressed("click") ||		# left mouse button
			event.is_action_pressed("rt_click") ):		# right mouse button
			#print(event.position)
			var xy = posToXY(event.position)
			#print(xy)
			$MessLabel.text = ""
			clearTileMapBG()
			if xy.x >= 0:
				mouse_pushed = true;
				last_xy = xy
				var v = $TileMap.get_cell(xy.x, xy.y)
				if event.is_action_pressed("click"):		# left mouse button
					v = TILE_BLACK if v == TILE_CROSS else -v;
				else:
					#v = TILE_CROSS if v != TILE_CROSS else TILE_BLACK
					v += 1
					if v > TILE_BLACK:
						v = TILE_NONE
				cell_val = v
				$TileMap.set_cell(xy.x, xy.y, v)
				if mode == MODE_EDIT_PICT:
					update_clues(xy.x, xy.y)
				elif mode == MODE_SOLVE:
					check_clues(xy.x, xy.y)
				var img = 0 if v == TILE_BLACK else TILE_NONE
				$MiniTileMap.set_cell(xy.x, xy.y, img)
		elif event.is_action_released("click") || event.is_action_released("rt_click"):
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
			var img = 0 if cell_val == 1 else TILE_NONE
			$MiniTileMap.set_cell(xy.x, xy.y, img)
	pass
func clear_all():
	for y in range(N_TOTAL_CELL_VERT):
		for x in range(N_TOTAL_CELL_HORZ):
			$TileMap.set_cell(x, y, TILE_NONE)
			$MiniTileMap.set_cell(x, y, TILE_NONE)
	if mode == MODE_EDIT_PICT:
		for y in range(N_TOTAL_CELL_VERT):
			for x in range(N_CLUES_CELL_HORZ):
				$TileMap.set_cell(-x-1, y, TILE_NONE)
		for x in range(N_TOTAL_CELL_HORZ):
			for y in range(N_CLUES_CELL_VERT):
				$TileMap.set_cell(x, -y-1, TILE_NONE)
		for y in range(N_IMG_CELL_VERT):
			h_clues[y] = [0]
			for x in range(N_CLUES_CELL_HORZ):
				$TileMapBG.set_cell(-x-1, y, TILE_NONE)
		for x in range(N_IMG_CELL_HORZ):
			v_clues[x] = [0]
			for y in range(N_CLUES_CELL_VERT):
				$TileMapBG.set_cell(x, -y-1, TILE_NONE)
	else:
		for y in range(N_IMG_CELL_VERT):
			for x in range(N_CLUES_CELL_HORZ):
				$TileMapBG.set_cell(-x-1, y, TILE_NONE)
		for x in range(N_IMG_CELL_HORZ):
			for y in range(N_CLUES_CELL_VERT):
				$TileMapBG.set_cell(x, -y-1, TILE_NONE)
func _on_ClearButton_pressed():
	clear_all()
	pass # Replace with function body.
func upate_imageTileMap():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			var img = 0 if $TileMap.get_cell(x, y) == 1 else TILE_NONE
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
	for x in range(N_IMG_CELL_HORZ-1, 0, TILE_NONE):
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
	for y in range(N_IMG_CELL_VERT-1, 0, TILE_NONE):
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
func change_cross_to_none():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_IMG_CELL_HORZ):
			if $TileMap.get_cell(x, y) == TILE_CROSS:
				$TileMap.set_cell(x, y, TILE_NONE)
func clear_clues_BG():
	for y in range(N_IMG_CELL_VERT):
		for x in range(N_CLUES_CELL_HORZ):
			$TileMapBG.set_cell(-x-1, y, TILE_NONE)
	for x in range(N_IMG_CELL_HORZ):
		for y in range(N_CLUES_CELL_VERT):
			$TileMapBG.set_cell(x, -y-1, TILE_NONE)
func _on_EditPictButton_pressed():
	mode = MODE_EDIT_PICT
	update_modeButtons()
	change_cross_to_none()		#
	clear_clues_BG()			# 手がかり数字強調クリア
	pass # Replace with function body.
