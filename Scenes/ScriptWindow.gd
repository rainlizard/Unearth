extends WindowDialog
onready var oMapSettingsTabs = Nodelist.list["oMapSettingsTabs"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	oMapSettingsTabs.set_tab_title(0,"Properties")
	oMapSettingsTabs.set_tab_title(1,"Script generator")
	oMapSettingsTabs.set_tab_title(2,"Edit script")

