extends Node
onready var oDataClm = Nodelist.list["oDataClm"]

var customSlabsFile = File.new()

var data = {
	
}
enum {
	SLAB_COLUMNS
	GENERAL
	RECOGNIZED_AS
}

func add_custom_slab(newID, slabColumns, general, recognizedAs):
	data[newID] = [slabColumns, general, recognizedAs]
	Slabs.data[newID] = general
	customSlabsFile.open(Settings.unearthdata.plus_file("unearthcustomslabs.cfg"),File.READ)
	
	customSlabsFile.close()

#oDataClm.index_entry(cubeArray, setFloorID)
