extends WindowDialog
onready var oScriptTabs = Nodelist.list["oScriptTabs"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	oScriptTabs.set_tab_title(0,"Generate script")
	oScriptTabs.set_tab_title(1,"Edit script")
