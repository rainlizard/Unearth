extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oMessage = Nodelist.list["oMessage"]

var data = {}
var cfg = ConfigFile.new()

enum {
	RECOGNIZED_AS
	WIBBLE_EDGES
	CUBE_DATA
	FLOOR_DATA
}

func _ready():
	load_file()


func load_file():
	var filePath = Settings.unearthdata.plus_file("custom_slabs.cfg")
	
	var file = File.new()
	if file.open(filePath, File.READ) != OK:
		# No custom_slabs.cfg file found
		return
	
	var fileText = file.get_as_text().to_lower()
	var err = cfg.parse(fileText)
	if err != OK:
		oMessage.big("Error", "Failed to parse custom_slabs.cfg file")
		return
	
	for section in cfg.get_sections():
		var newID = int(section.trim_prefix("slab"))
		var slabName = cfg.get_value(section, "name")
		var recognizedAs = cfg.get_value(section, "recognized_as")
		var liquidType = cfg.get_value(section, "liquid_type")
		var wibbleType = cfg.get_value(section, "wibble_type")
		var wibbleEdges = cfg.get_value(section, "wibble_edges")
		
		var slabCubeData = []
		var slabFloorData = []
		for i in 9:
			slabCubeData.append( cfg.get_value(section, "cubes"+str(i)) )
			slabFloorData.append( cfg.get_value(section, "floor"+str(i)) )
		
		add_custom_slab(newID, slabName, recognizedAs, liquidType, wibbleType, wibbleEdges, slabCubeData, slabFloorData)


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
	var section = 'slab'+str(newID)
	cfg.set_value(section,"name", slabName)
	cfg.set_value(section,"recognized_as",int(recognizedAs))
	cfg.set_value(section,"liquid_type", liquidType)
	cfg.set_value(section,"wibble_type", wibbleType)
	cfg.set_value(section,"wibble_edges", wibbleEdges)
	
	for i in 9:
		cfg.set_value(section,"cubes"+str(i),slabCubeData[i])
		cfg.set_value(section,"floor"+str(i),slabFloorData[i])
	
	cfg.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))


# The purpose of this function is so I don't have to index the columns into clm for simply displaying within the slab window. Only index when PLACING the Fake Slab.
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
	if slabID < 1000: return # means it's not a Fake Slab
	
	print('Attempting to remove Custom Slab:' + str(slabID))
	oPickSlabWindow.set_selection(null)
	
	if data.has(slabID):
		data.erase(slabID)
	
	var section = 'slab'+str(slabID)
	if cfg.has_section(section):
		cfg.erase_section(section)
	
	cfg.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))
