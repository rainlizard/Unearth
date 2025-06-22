extends WindowDialog
onready var oResizeCurrentMapSize = Nodelist.list["oResizeCurrentMapSize"]

func _on_MapSettingsWindow_about_to_show():
	oResizeCurrentMapSize.visible = false
