extends WindowDialog
onready var oMapSettingsTabs = Nodelist.list["oMapSettingsTabs"]

func _ready():
	oMapSettingsTabs.set_tab_title(0,"Properties")
	oMapSettingsTabs.set_tab_title(1,"Script generator")
	oMapSettingsTabs.set_tab_title(2,"Edit script")
