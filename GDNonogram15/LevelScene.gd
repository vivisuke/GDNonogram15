extends Node2D

const N_IMG_CELL_VERT = 15

onready var g = get_node("/root/Global")

var mouse_pushed = false
var mouse_pos
var scroll_pos

var QuestPanel = load("res://QuestPanel.tscn")

class MyCustomSorter:
	var g 
	static func sort_ascending(a, b):
		return true if a[1] < b[1] else false
	#static func sort_descending(a, b):
	#	return true if a > b else false
func _ready():
	#var vsb = $ScrollContainer.get_v_scrollbar()
	#vsb.step = 10
	if !g.solvedPatLoaded:			# クリア履歴未読込の場合
		g.solvedPatLoaded = true
		var file = File.new()
		#print(g.solvedPatFileName)
		if file.file_exists(g.solvedPatFileName):
			file.open(g.solvedPatFileName, File.READ)
			g.solvedPat = file.get_var()
			file.close()
			print(g.solvedPat)
	print(g.quest_list0.size())
	if g.quest_list.empty():	# ソート済み問題配列が空
		g.quest_list.resize(g.quest_list0.size())
		for i in range(g.quest_list0.size()):
			g.quest_list[i] = g.quest_list0[i]
		g.quest_list.sort_custom(MyCustomSorter, "sort_ascending")
	#if g.qNum2QIX.empty():			# 問題番号 → 問題リストIX（qix）テーブルが未構築の場合
	#	g.qNum2QIX.resize(g.quest_list.size())
	#	for i in range(g.quest_list.size()):
	#		g.qNum2QIX[i] = i
	#	MyCustomSorter.g = g
	#	g.qNum2QIX.sort_custom(MyCustomSorter, "sort_ascending")
	g.ans_images.resize(g.quest_list.size())
	g.qix2ID.resize(g.quest_list.size())
	for i in g.quest_list.size():	# 問題パネルセットアップ
		#if g.solved.size() <= i:
		#	g.solved.push_back(false)
		#var qix = g.qNum2QIX[i]
		var qix = i
		g.qix2ID[qix] = g.quest_list[qix][g.KEY_ID]
		var panel = QuestPanel.instance()
		panel.set_number(i+1)
		panel.set_difficulty(g.quest_list[qix][g.KEY_DIFFICULTY])
		#if g.solved[i]:
		if g.solvedPat.has(g.qix2ID[qix]):
			panel.set_title(g.quest_list[qix][g.KEY_TITLE])
			var lst = g.solvedPat[g.qix2ID[qix]]
			panel.set_ans_image(lst)
			#panel.set_ans_image(g.ans_images[i])
			panel.set_clearTime(lst[N_IMG_CELL_VERT] if lst.size() > N_IMG_CELL_VERT else 0)
		else:
			panel.set_title(g.quest_list[qix][g.KEY_TITLE][0] + "???")
			panel.set_clearTime(0)
		panel.set_author(g.quest_list[qix][g.KEY_AUTHOR])
		$ScrollContainer/VBoxContainer.add_child(panel)
		#
		panel.connect("pressed", self, "_on_QuestPanel_pressed")
	print("vscroll = ", g.lvl_vscroll)
	$ScrollContainer.set_v_scroll(g.lvl_vscroll)
	pass # Replace with function body.
func _process(delta):
	if g.lvl_vscroll > 0:
		$ScrollContainer.set_v_scroll(g.lvl_vscroll)
		g.lvl_vscroll = -1
	pass
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				print("BUTTON_WHEEL_UP")
			if event.button_index == BUTTON_WHEEL_DOWN:
				print("BUTTON_WHEEL_DOWN")
		#print("InputEventMouseButton")
		if event.is_action_pressed("click"):		# left mouse button
			if $ScrollContainer.get_global_rect().has_point(event.position):		# in ScrollContainer
				mouse_pushed = true;
				mouse_pos = event.position
				scroll_pos = $ScrollContainer.get_v_scroll()
		elif event.is_action_released("click"):
			mouse_pushed = false;
	elif event is InputEventMouseMotion && mouse_pushed:	# mouse Moved
		$ScrollContainer.set_v_scroll(scroll_pos + mouse_pos.y - event.position.y)
	pass

func _on_QuestPanel_pressed(num):
	print("QuestPanel_pressed(", num, ")")
	g.lvl_vscroll = $ScrollContainer.scroll_vertical
	print("vscroll = ", g.lvl_vscroll)
	g.solveMode = true;
	g.qNumber = num
	#g.qix = qNum2QIX[num-1]
	get_tree().change_scene("res://MainScene.tscn")
	pass # Replace with function body.


func _on_EditButton_pressed():
	g.lvl_vscroll = $ScrollContainer.scroll_vertical
	print("vscroll = ", g.lvl_vscroll)
	g.solveMode = false;
	get_tree().change_scene("res://MainScene.tscn")
	pass # Replace with function body.
