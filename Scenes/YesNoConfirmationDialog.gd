extends ConfirmationDialog

func _ready():
	get_ok().text = "Yes"
	get_cancel().text = "No"
	connect("about_to_show", self, "_on_about_to_show")

func _on_about_to_show():
	yield(get_tree(),'idle_frame')
	get_ok().grab_focus()

func _input(event):
	if visible == false: return
	if event is InputEventKey and event.pressed == true:
		if get_focus_owner() is LineEdit: return # If typing some text into somewhere
		match event.scancode:
			KEY_Y:
				get_ok().emit_signal("pressed")
			KEY_N:
				get_cancel().emit_signal("pressed")
