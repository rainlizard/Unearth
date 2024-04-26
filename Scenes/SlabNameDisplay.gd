extends Label
onready var oSelector = Nodelist.list["oSelector"]
onready var oSelection = Nodelist.list["oSelection"]

func _process(delta):
	if oSelector.visible == false: return
	
	var slabID = oSelection.cursorOverSlab
	
	var slabName = "Unknown"
	if Slabs.data.has(slabID):
		slabName = Slabs.data[slabID][Slabs.NAME]
	
	text = slabName + ' : ' + str(slabID)
	#get_parent().self_modulate = Constants.ownerRoomCol[oDataOwnership.get_cell_ownership(oSelector.cursorTile.x,oSelector.cursorTile.y)]
