extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]

var data = {}
var slabsFile = ConfigFile.new()

enum {
	RECOGNIZED_AS
	WIBBLE_EDGES
	CUBE_DATA
	FLOOR_DATA
}

func _ready():
	load_file()

func add_custom_slab(newID, slabName, recognizedAs, liquidType, wibbleType, wibbleEdges, slabCubeData, slabFloorData):
	Slabs.data[newID] = [
		slabName,
		Slabs.BLOCK_SLAB,
		Slabs.BITMASK_TALL,
		Slabs.PANEL_TOP_VIEW,
		0,
		Slabs.TAB_CUSTOM,
		wibbleType,
		liquidType,
		Slabs.NOT_OWNABLE
	]
	
	data[newID] = [recognizedAs, wibbleEdges, slabCubeData, slabFloorData]
	
	slabsFile.set_value('SLAB'+str(newID),"NAME", slabName)
	slabsFile.set_value('SLAB'+str(newID),"RECOGNIZED_AS",int(recognizedAs))
	slabsFile.set_value('SLAB'+str(newID),"LIQUID_TYPE", liquidType)
	slabsFile.set_value('SLAB'+str(newID),"WIBBLE_TYPE", wibbleType)
	slabsFile.set_value('SLAB'+str(newID),"WIBBLE_EDGES", wibbleEdges)
	
	for i in 9:
		slabsFile.set_value('SLAB'+str(newID),"CUBES"+str(i),slabCubeData[i])
		slabsFile.set_value('SLAB'+str(newID),"FLOOR"+str(i),slabFloorData[i])
	
	slabsFile.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))

func load_file():
	slabsFile.load(Settings.unearthdata.plus_file("custom_slabs.cfg"))
	
	for sectionName in slabsFile.get_sections():
		var newID = int(sectionName.trim_prefix("SLAB"))
		var slabName = slabsFile.get_value(sectionName, "NAME")
		var recognizedAs = slabsFile.get_value(sectionName, "RECOGNIZED_AS")
		var liquidType = slabsFile.get_value(sectionName, "LIQUID_TYPE")
		var wibbleType = slabsFile.get_value(sectionName, "WIBBLE_TYPE")
		var wibbleEdges = slabsFile.get_value(sectionName, "WIBBLE_EDGES")
		
		var slabCubeData = []
		var slabFloorData = []
		for i in 9:
			slabCubeData.append( slabsFile.get_value(sectionName, "CUBES"+str(i)) )
			slabFloorData.append( slabsFile.get_value(sectionName, "FLOOR"+str(i)) )
		
		add_custom_slab(newID, slabName, recognizedAs, liquidType, wibbleType, wibbleEdges, slabCubeData, slabFloorData)

# The purpose of this function is so I don't have to index the columns into clm for simply displaying within the slab window. Only index when PLACING the custom slab.
func get_top_cube_face(indexIn3x3, slabID):
	var cubesArray = data[slabID][CUBE_DATA][indexIn3x3]
	var get_height = oDataClm.get_real_height(cubesArray)
	if get_height == 0:
		return data[slabID][FLOOR_DATA][indexIn3x3]
	else:
		var cubeID = cubesArray[get_height-1]
		if cubeID > Cube.CUBES_COUNT:
			return 1
		return Cube.tex[cubeID][Cube.SIDE_TOP]

func remove_custom_slab(slabID):
	if slabID < 1000: return # means it's not a custom slab
	
	print('Attempting to remove custom slab:' + str(slabID))
	oPickSlabWindow.set_selection(null)
	
	if data.has(slabID):
		data.erase(slabID)
	
	var section = 'SLAB'+str(slabID)
	if slabsFile.has_section(section):
		slabsFile.erase_section(section)
	
	slabsFile.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))
