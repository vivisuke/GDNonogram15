extends Node2D

onready var g = get_node("/root/Global")

var mouse_pushed = false
var mouse_pos
var scroll_pos

var QuestPanel = load("res://QuestPanel.tscn")


func _ready():
	print(g.quest_list.size())
	for i in g.quest_list.size():
		var panel = QuestPanel.instance()
		panel.set_number(i+1)
		panel.set_difficulty(g.quest_list[i][0])
		panel.set_author(g.quest_list[i][2])
		$ScrollContainer/VBoxContainer.add_child(panel)
		#
		panel.connect("pressed", self, "_on_QuestPanel_pressed")
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
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
	pass # Replace with function body.
