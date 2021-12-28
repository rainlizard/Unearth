extends ColorRect

var clingTo = null

func highlight(node):
	clingTo = node
	visible = true

func _process(delta):
	if is_instance_valid(clingTo):
		rect_size = clingTo.rect_size
		rect_global_position = clingTo.rect_global_position
		
		var current_focus_control = get_focus_owner()
		if is_instance_valid(current_focus_control) and current_focus_control is LineEdit:
			clingTo = null
			visible = false

func _input(event):
	if visible == false: return
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed == true:
		yield(get_tree(),'idle_frame') # otherwise is overwritten by what's inside of ResearchableItem gui_input
		clingTo = null
		visible = false

