extends Control
onready var oSelection = Nodelist.list["oSelection"]

var sd

func _ready():
	var scene = preload("res://Scenes/SlabDisplay.tscn")
	sd = scene.instance()
	sd.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sd)

func update_side():
	var slabID = oSelection.cursorOverSlab
	if Slabs.data[slabID][Slabs.IS_SOLID] == false:
		sd.modulate.a = 0
		return
	
	sd.modulate.a = 0.75
	
	var slabVariation = slabID*28
	var columnArray = [0,0,0, 0,0,0, 0,0,0]
	for i in 9:
		columnArray[i] = Slabset.fetch_column_index(slabVariation, i)
	sd.set_meta("ID_of_slab", slabID)
	sd.panelView = Slabs.data[slabID][Slabs.PANEL_VIEW]
	sd.set_visual(columnArray)
