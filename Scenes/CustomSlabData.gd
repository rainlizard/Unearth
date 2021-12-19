extends Node
onready var oDataClm = Nodelist.list["oDataClm"]

var customSlabsFile = File.new()

var data = {
	
}
enum {
	GENERAL
	RECOGNIZED_AS
	CUBE_DATA
	FLOOR_DATA
}

func add_custom_slab(newID, general, recognizedAs, slabCubeData, slabFloorData):
	
	data[newID] = [general, recognizedAs, slabCubeData, slabFloorData]
	
	Slabs.data[newID] = general
	
	customSlabsFile.open(Settings.unearthdata.plus_file("unearthcustomslabs.cfg"),File.READ)
	
	customSlabsFile.close()

# The purpose of this function is so I don't have to index the columns into clm for simply displaying within the slab window. Only index when PLACING the custom slab.
func get_top_cube_face(indexIn3x3, slabID):
	var cubesArray = data[slabID][CUBE_DATA][indexIn3x3]
	var get_height = oDataClm.get_real_height(cubesArray)
	if get_height == 0:
		return data[slabID][FLOOR_DATA][indexIn3x3]
	else:
		var cubeID = cubesArray[get_height-1]
		return Cube.tex[cubeID][Cube.SIDE_TOP]
