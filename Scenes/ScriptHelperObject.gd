extends Node2D
onready var oMessage = Nodelist.list["oMessage"]
onready var oCamera2D = Nodelist.list["oCamera2D"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	oCamera2D.connect("zoom_level_changed",self,"_on_zoom_level_changed")
	_on_zoom_level_changed(oCamera2D.zoom)


func _on_MouseDetection_mouse_entered():
	oMessage.quick(get_meta('line'))

var SCRIPT_ICON_SIZE_MAX = 10
var SCRIPT_ICON_SIZE_BASE = 0.5

func _on_zoom_level_changed(zoom):
	var oUi = Nodelist.list["oUi"]
	var inventScale = Vector2()
	inventScale.x = clamp(zoom.x, 0.0, SCRIPT_ICON_SIZE_MAX)
	inventScale.y = clamp(zoom.y, 0.0, SCRIPT_ICON_SIZE_MAX)
	
	if zoom.x > SCRIPT_ICON_SIZE_MAX:
		visible = false
	else:
		visible = true
	
	scale = inventScale * SCRIPT_ICON_SIZE_BASE
