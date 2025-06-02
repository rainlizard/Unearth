extends Node2D
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oUi = Nodelist.list["oUi"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	oCamera2D.connect("zoom_level_changed",self,"_on_zoom_level_changed")
	_on_zoom_level_changed(oCamera2D.zoom)


func _on_zoom_level_changed(zoom):
	var inventScale = Vector2()
	inventScale.x = clamp(zoom.x, 0.0, oScriptHelpers.SCRIPT_ICON_SIZE_MAX)
	inventScale.y = clamp(zoom.y, 0.0, oScriptHelpers.SCRIPT_ICON_SIZE_MAX)
	
	if zoom.x > oScriptHelpers.SCRIPT_ICON_SIZE_MAX:
		visible = false
	else:
		visible = true
	
	scale = inventScale * oScriptHelpers.SCRIPT_ICON_SIZE_BASE


func _on_MouseDetection_mouse_entered():
	if oUi.mouseOnUi == true: return
	oCustomTooltip.set_text(get_meta('line'))

func _on_MouseDetection_mouse_exited():
	oCustomTooltip.set_text("")
