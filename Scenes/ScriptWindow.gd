extends WindowDialog
onready var oMapSettingsTabs = Nodelist.list["oMapSettingsTabs"]
onready var oResizeCurrentMapSize = Nodelist.list["oResizeCurrentMapSize"]

func _ready():
	oMapSettingsTabs.set_tab_title(0,"Properties")
	oMapSettingsTabs.set_tab_title(1,"Script generator")
	oMapSettingsTabs.set_tab_title(2,"Edit script")


func _on_MapSettingsWindow_about_to_show():
	oResizeCurrentMapSize.visible = false
