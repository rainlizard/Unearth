extends Label

onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]

func _process(delta):
	if oSelector.visible == false: return
	var slabID = oDataSlab.get_cell(oSelector.cursorTile.x,oSelector.cursorTile.y)
	
	var slabName = "Unknown"
	if Slabs.data.has(slabID):
		slabName = Slabs.data[slabID][Slabs.NAME]
	
	text = slabName + ' : ' + str(slabID)
	#get_parent().self_modulate = Constants.ownershipColors[oDataOwnership.get_cell(oSelector.cursorTile.x,oSelector.cursorTile.y)]
