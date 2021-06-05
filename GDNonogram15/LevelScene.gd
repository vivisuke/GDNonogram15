extends Node2D

onready var g = get_node("/root/Global")

var mouse_pushed = false
var mouse_pos
var scroll_pos



func _ready():
	print(g.quest_list.size())
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
	
