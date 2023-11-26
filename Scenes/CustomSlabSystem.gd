extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oMessage = Nodelist.list["oMessage"]

var cfg = ConfigFile.new()

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
		var slabCubeData = []
		var slabFloorData = []
		for i in 9:
			var cd = cfg.get_value(section, "cubes"+str(i), [])
			if cd.size() > 0:
				slabCubeData.append(cd)
			
			var fd = cfg.get_value(section, "floor"+str(i), -1)
			if fd != -1:
				slabFloorData.append(fd)
		
		var slab_dict = {
			"header_id": int(section.trim_prefix("slab")),
			"name": cfg.get_value(section, "name", "Unknown"),
			"recognized_as": cfg.get_value(section, "recognized_as", Slabs.ROCK),
			"liquid_type": cfg.get_value(section, "liquid_type", Slabs.REMEMBER_PATH),
			"wibble_type": cfg.get_value(section, "wibble_type", Slabs.WIBBLE_ON),
			"wibble_edges": cfg.get_value(section, "wibble_edges", false),
			"cube_data": slabCubeData,
			"floor_data": slabFloorData,
			"bitmask": cfg.get_value(section, "bitmask", Slabs.BITMASK_FLOOR),
			"is_solid": cfg.get_value(section, "is_solid", Slabs.EMPTY_SLAB),
			"ownable": cfg.get_value(section, "ownable", Slabs.OWNABLE)
		}
		
		add_custom_slab(slab_dict)


func add_custom_slab(slab_dict):
	#var newID = slab_dict.id
	#var section = 'slab'+str(newID)
	Slabs.data[slab_dict.header_id] = [
		slab_dict.name,
		slab_dict.is_solid,
		slab_dict.bitmask,
		Slabs.PANEL_TOP_VIEW,
		0, # SIDE_VIEW_Z_OFFSET
		Slabs.TAB_CUSTOM,
		slab_dict.wibble_type,
		slab_dict.liquid_type,
		slab_dict.ownable,
	]
	if slab_dict.header_id >= 1000:
		Slabs.fake_extra_data[slab_dict.header_id] = [
			slab_dict.cube_data,
			slab_dict.floor_data,
			slab_dict.recognized_as,
			slab_dict.wibble_edges,
		]
	
	var section = 'slab'+str(slab_dict.header_id)
	cfg.set_value(section,"name", slab_dict.name)
	cfg.set_value(section,"recognized_as", slab_dict.recognized_as)
	cfg.set_value(section,"liquid_type", slab_dict.liquid_type)
	cfg.set_value(section,"wibble_type", slab_dict.wibble_type)
	cfg.set_value(section,"wibble_edges", slab_dict.wibble_edges)
	cfg.set_value(section,"bitmask", slab_dict.bitmask)
	cfg.set_value(section,"is_solid", slab_dict.is_solid)
	cfg.set_value(section,"ownable", slab_dict.ownable)
	
	for i in 9:
		if slab_dict.cube_data.size() > 0:
			cfg.set_value(section,"cubes"+str(i),slab_dict.cube_data[i])
		if slab_dict.floor_data.size() > 0:
			cfg.set_value(section,"floor"+str(i),slab_dict.floor_data[i])
	
	cfg.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))

func remove_custom_slab(header_id):
	oPickSlabWindow.set_selection(null)
	var statusOfRemoval = Slabs.data.erase(header_id)
	if statusOfRemoval == true:
		oMessage.quick("Removed custom slab")
	else:
		oMessage.quick("Tried to remove a custom slab that wasn't present in the data")
	Slabs.fake_extra_data.erase(header_id)
	
	var section = 'slab'+str(header_id)
	if cfg.has_section(section):
		cfg.erase_section(section)
	
	cfg.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))

func get_top_fake_cube_face(indexIn3x3, slabID):
	var cubesArray = Slabs.fake_extra_data[slabID][Slabs.FAKE_CUBE_DATA][indexIn3x3]
	var get_height = oDataClm.get_real_height(cubesArray)
	if get_height == 0:
		return Slabs.fake_extra_data[slabID][Slabs.FAKE_FLOOR_DATA][indexIn3x3]
	else:
		var cubeID = cubesArray[get_height-1]
		if cubeID > Cube.CUBES_COUNT:
			return 1
		return Cube.tex[cubeID][Cube.SIDE_TOP]
