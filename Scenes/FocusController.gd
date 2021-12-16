extends Control

#func _unhandled_input(event):
func _input(event):
	# Prevents ALT+ENTER from pressing a button
	if Input.is_key_pressed(KEY_ALT):
		var current_focus_control = get_focus_owner()
		if current_focus_control:
			current_focus_control.release_focus()
	
	# This code allows you to deselect all LineEdit nodes by clicking elsewhere.
	# The Rect2 check is important, otherwise focus is released when it shouldn't be when moving the mouse too quickly while clicking.
	if Input.is_action_just_pressed("mouse_left") and event is InputEventMouseButton:
		var current_focus_control = get_focus_owner()
		if is_instance_valid(current_focus_control) and current_focus_control is LineEdit:
			if Rect2( current_focus_control.rect_global_position, current_focus_control.rect_size ).has_point(event.position) == false:
				current_focus_control.release_focus()
