extends SpinBox
class_name SpinBoxPropertiesValue

func _ready():
	get_line_edit().expand_to_text_length = true

func _input(event):
	if is_instance_valid(get_focus_owner()) == false: return
	if get_focus_owner().get_parent() != self: return # get_parent is used because LineEdit is a child of SpinBox
	
	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		value -= 1
		get_tree().set_input_as_handled()
	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		value += 1
		get_tree().set_input_as_handled()
