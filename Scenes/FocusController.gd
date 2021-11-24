extends Control

#func _unhandled_input(event):
func _input(event):
	# Prevents ALT+ENTER from pressing a button
	if Input.is_key_pressed(KEY_ALT):
		var current_focus_control = get_focus_owner()
		if current_focus_control:
			current_focus_control.release_focus()
	
	if Input.is_action_just_pressed("mouse_left"):
		var current_focus_control = get_focus_owner()
		if current_focus_control is LineEdit:
			current_focus_control.release_focus()
