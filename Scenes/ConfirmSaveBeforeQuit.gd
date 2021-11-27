extends WindowDialog
onready var oFileDialogSaveAs = Nodelist.list["oFileDialogSaveAs"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

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
