extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]

var data = {}
var slabsFile = ConfigFile.new()

enum {
	RECOGNIZED_AS
	CUBE_DATA
	FLOOR_DATA
	WIBBLE_NEARBY
}

func _ready():
	load_file()

func add_custom_slab(newID, general, recognizedAs, slabCubeData, slabFloorData, wibbleNearby):
	Slabs.data[newID] = general
	data[newID] = [recognizedAs, slabCubeData, slabFloorData, wibbleNearby]
	
	slabsFile.set_value('SLAB'+str(newID),"GENERAL", general)
	slabsFile.set_value('SLAB'+str(newID),"RECOGNIZED_AS",int(recognizedAs))
	for i in 9:
		slabsFile.set_value('SLAB'+str(newID),"CUBES"+str(i),slabCubeData[i])
	for i in 9:
		slabsFile.set_value('SLAB'+str(newID),"FLOOR"+str(i),slabFloorData[i])
	
	slabsFile.set_value('SLAB'+str(newID),"WIBBLE_NEARBY", wibbleNearby)
	
	slabsFile.save(Settings.unearthdata.plus_file("unearthcustomslabs.cfg"))

func load_file():
	slabsFile.load(Settings.unearthdata.plus_file("unearthcustomslabs.cfg"))
	
	for sectionName in slabsFile.get_sections():
		var newID = int(sectionName.trim_prefix("SLAB"))
		var generalArray = slabsFile.get_value(sectionName, "GENERAL")
		var recognizedAs = slabsFile.get_value(sectionName, "RECOGNIZED_AS")
		
		var slabCubeData = []
		var slabFloorData = []
		for i in 9:
			slabCubeData.append( slabsFile.get_value(sectionName, "CUBES"+str(i)) )
			slabFloorData.append( slabsFile.get_value(sectionName, "FLOOR"+str(i)) )
		
		var extraSlabData = slabsFile.get_value(sectionName, "WIBBLE_NEARBY")
		
		add_custom_slab(newID, generalArray, recognizedAs, slabCubeData, slabFloorData, extraSlabData)

# The purpose of this function is so I don't have to index the columns into clm for simply displaying within the slab window. Only index when PLACING the custom slab.
func get_top_cube_face(indexIn3x3, slabID):
	var cubesArray = data[slabID][CUBE_DATA][indexIn3x3]
	var get_height = oDataClm.get_real_height(cubesArray)
	if get_height == 0:
		return data[slabID][FLOOR_DATA][indexIn3x3]
	else:
		var cubeID = cubesArray[get_height-1]
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
	
	slabsFile.save(Settings.unearthdata.plus_file("unearthcustomslabs.cfg"))
