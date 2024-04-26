extends WindowDialog
onready var oFileDialogSaveAs = Nodelist.list["oFileDialogSaveAs"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

func _ready():
	connect("about_to_show", self, "_on_about_to_show")

func _on_ButtonConfirmExitSave_pressed():
	# Save or save as based on whether there is a path
	oSaveMap.queueExit = true
	if oCurrentMap.path == "":
		Utils.popup_centered(oFileDialogSaveAs)
	else:
		oSaveMap.clicked_save_on_menu()


func _on_ButtonConfirmExitDontSave_pressed():
	get_tree().quit()

func _on_ButtonConfirmExitCancel_pressed():
	hide()

func _on_about_to_show():
	yield(get_tree(),'idle_frame')
	$"%ButtonConfirmExitSave".grab_focus()

func _input(event):
	if visible == false: return
	if event is InputEventKey and event.pressed == true:
		if get_focus_owner() is LineEdit: return # If typing some text into somewhere
		match event.scancode:
			KEY_Y:
				$"%ButtonConfirmExitSave".emit_signal("pressed")
			KEY_N:
				$"%ButtonConfirmExitDontSave".emit_signal("pressed")
