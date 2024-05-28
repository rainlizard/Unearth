extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oMessage = Nodelist.list["oMessage"]

var cfg = ConfigFile.new()

func load_unearth_custom_slabs_file():
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
			"bitmask": cfg.get_value(section, "bitmask", Slabs.BITMASK_GENERAL),
			"is_solid": cfg.get_value(section, "is_solid", Slabs.FLOOR_SLAB),
			"ownable": cfg.get_value(section, "ownable", Slabs.OWNABLE),
		}
		
		var retrieve_value
		retrieve_value = cfg.get_value(section, "door_thing", "NOT_FOUND") # Default = null
		if retrieve_value != "NOT_FOUND": slab_dict["door_thing"] = retrieve_value
		retrieve_value = cfg.get_value(section, "door_orientation", "NOT_FOUND")
		if retrieve_value != "NOT_FOUND": slab_dict["door_orientation"] = retrieve_value
		
		add_custom_slab(slab_dict)


func add_custom_slab(slab_dict):
	var head_id = slab_dict["header_id"]
	
	if head_id < 1000: return
	
	var section = 'slab'+str(head_id)
	if head_id >= 1000:
		Slabs.fake_extra_data[head_id] = [
			slab_dict["cube_data"],
			slab_dict["floor_data"],
			slab_dict["recognized_as"],
			slab_dict["wibble_edges"],
		]
	Slabs.data[head_id] = [
		slab_dict["name"],
		slab_dict["is_solid"],
		slab_dict["bitmask"],
		Slabs.PANEL_TOP_VIEW,
		0, # SIDE_VIEW_Z_OFFSET
		Slabs.TAB_CUSTOM,
		slab_dict["wibble_type"],
		slab_dict["liquid_type"],
		slab_dict["ownable"],
	]
	cfg.set_value(section,"name", slab_dict["name"])
	cfg.set_value(section,"recognized_as", slab_dict["recognized_as"])
	cfg.set_value(section,"liquid_type", slab_dict["liquid_type"])
	cfg.set_value(section,"wibble_type", slab_dict["wibble_type"])
	cfg.set_value(section,"wibble_edges", slab_dict["wibble_edges"])
	cfg.set_value(section,"bitmask", slab_dict["bitmask"])
	cfg.set_value(section,"is_solid", slab_dict["is_solid"])
	cfg.set_value(section,"ownable", slab_dict["ownable"])
	
#	if slab_dict.has("door_thing") and slab_dict.has("door_orientation"):
#		cfg.set_value(section,"door_thing", slab_dict["door_thing"])
#		cfg.set_value(section,"door_orientation", slab_dict["door_orientation"])
#		Slabs.door_data[head_id] = [
#			slab_dict["door_thing"],
#			slab_dict["door_orientation"],
#		]
	
	for i in 9:
		if slab_dict["cube_data"].size() > 0:
			cfg.set_value(section,"cubes"+str(i),slab_dict["cube_data"][i])
		if slab_dict["floor_data"].size() > 0:
			cfg.set_value(section,"floor"+str(i),slab_dict["floor_data"][i])
	
	print("ADDED CUSTOM SLAB ", head_id)
	
	cfg.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))

func attempt_to_remove_custom_slab(header_id):
	oPickSlabWindow.set_selection(null)
	
	# If it's a door then it'll have "door_data", so remove the other one too
#	if Slabs.door_data.has(header_id) == true:
#		Slabs.door_data.erase(header_id)
#		var door2_id = header_id+1
#		if Slabs.door_data.has(door2_id) == true:
#			if Slabs.door_data[door2_id][Slabs.DOORSLAB_ORIENTATION] == 0: # Second direction always has orientation of 0
#				Slabs.door_data.erase(door2_id)
#				remove_custom_slab(door2_id)
	
	remove_custom_slab(header_id)

func remove_custom_slab(header_id):
	if Slabs.data.has(header_id) == false:
		oMessage.quick("Tried to remove a custom slab that wasn't present in the data")
		return
	
	Slabs.data.erase(header_id)
	Slabs.fake_extra_data.erase(header_id)
	
	var section = 'slab'+str(header_id)
	if cfg.has_section(section):
		cfg.erase_section(section)
	
	cfg.save(Settings.unearthdata.plus_file("custom_slabs.cfg"))
	
	oMessage.quick("Removed custom slab: " + str(header_id))

func get_top_fake_cube_face(indexIn3x3, slabID):
	var cubesArray = Slabs.fake_extra_data[slabID][Slabs.FAKE_CUBE_DATA][indexIn3x3]
	var get_height = oDataClm.get_highest_cube_height(cubesArray)
	if get_height == 0:
		return Slabs.fake_extra_data[slabID][Slabs.FAKE_FLOOR_DATA][indexIn3x3]
	else:
		var cubeID = cubesArray[get_height-1]
		if cubeID > Cube.CUBES_COUNT:
			return 1
		return Cube.tex[cubeID][Cube.SIDE_TOP]
