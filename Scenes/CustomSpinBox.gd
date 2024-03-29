extends SpinBox
class_name CustomSpinBox

func _ready():
	get_line_edit().expand_to_text_length = true
#	get_line_edit().grow_horizontal = Control.GROW_DIRECTION_BEGIN
#	get_line_edit().size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _input(event):
	if is_instance_valid(get_focus_owner()) == false: return
	if get_focus_owner().get_parent() != self: return # get_parent is used because LineEdit is a child of SpinBox
	
	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		value -= step
		get_tree().set_input_as_handled()
	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		value += step
		get_tree().set_input_as_handled()
