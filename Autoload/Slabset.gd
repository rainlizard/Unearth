extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oBuffers = Nodelist.list["oBuffers"]

var tng = []
var dat = []
var default_data = {}

enum obj {
	IS_LIGHT,     # [0] IsLight [0-1]
	VARIATION,    # [1] Variation
	SUBTILE,      # [2] Subtile [0-9]
	RELATIVE_X,   # [3] RelativeX
	RELATIVE_Y,   # [4] RelativeY
	RELATIVE_Z,   # [5] RelativeZ
	THING_TYPE,   # [6] Thing type
	THING_SUBTYPE,# [7] Thing subtype
	EFFECT_RANGE  # [8] Effect range
}

enum dir {
	s = 0
	w = 1
	n = 2
	e = 3
	sw = 4
	nw = 5
	ne = 6
	se = 7
	all = 8
	center = 27
}

func clear_all_slabset_data():
	tng = []
	dat = []

func import_toml_slabset(filePath):
	var processed_string = preprocess_toml_file(filePath)
	if processed_string == null:
		return
	var cfg = ConfigFile.new()
	var err = cfg.parse(processed_string)
	if err != OK:
		return
	
	resize_dat_and_tng_based_on_file(cfg)
	
	if cfg.has_section("slab0.S"):
		if cfg.has_section_key("slab0.S", "columns"): # Lowercase "Columns" means it's an out of date slabset.toml file
			oMessage.big("Failed loading Slabset", "Old /fxdata/slabset.toml file, please install the latest KeeperFX alpha patch")
	
	
	for section in cfg.get_sections():
		var parts = section.split(".")
		if parts.size() <= 1:
			continue
		
		var slabID = int(parts[0])
		var localVariation = int(dir_numbers[parts[1]]) # ["slab34", "CENTER"]
		var variation = (slabID * 28) + localVariation

		var objectIndex
		var getObject
		if parts.size() >= 3: # ["slab34", "CENTER", "objects0"]
			objectIndex = int(parts[2])
			while objectIndex >= tng[variation].size():
				tng[variation].append([0,variation,0, 0,0,0, 0,0,0])
			getObject = tng[variation][objectIndex]

		var keyList = cfg.get_section_keys(section)
		for key in keyList:
			var value = cfg.get_value(section, key)
			match key:
				"Columns": dat[variation] = value
				"Objects": tng[variation] = value
				"IsLight": getObject[obj.IS_LIGHT] = int(value)
				"Subtile": getObject[obj.SUBTILE] = int(value)
				"RelativePosition":
					getObject[obj.RELATIVE_X] = int(value[0])
					getObject[obj.RELATIVE_Y] = int(value[1])
					getObject[obj.RELATIVE_Z] = int(value[2])
				"ThingType": getObject[obj.THING_TYPE] = int(value) #int(Things.reverse_data_structure_name.get(value, 0))
				"Subtype": getObject[obj.THING_SUBTYPE] = int(value)
				"EffectRange": getObject[obj.EFFECT_RANGE] = int(value)
	
	if "fxdata" in filePath:
		store_default_data()


func load_default_original_slabset():
	
	var dat_buffer = oBuffers.file_path_to_buffer(oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.DAT"))
	var tng_buffer = oBuffers.file_path_to_buffer(oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.TNG"))
	
	var object_info = create_object_list(tng_buffer)
	if object_info.size() == 0:
		oMessage.quick("Failed to load objects")
		return
	
	var totalSlabs = 42 + 16
	var totalVariations = totalSlabs * 28
	tng.resize(totalVariations)
	dat.resize(totalVariations)
	tng_buffer.seek(2)
	dat_buffer.seek(2)
	
	for variation in dat.size():
		tng[variation] = []
		dat[variation] = [0,0,0, 0,0,0, 0,0,0]
		if variation < 42*28 or (variation % 28) < 8: # Handle the longslabs and the shortslabs
			
			for subtile in 9:
				dat[variation][subtile] = 65536 - dat_buffer.get_u16()
			
			var getObjectIndex = tng_buffer.get_u16()
			
			while getObjectIndex < object_info.size(): # Continue until "break"
				var objectStuff = object_info[getObjectIndex]
				if objectStuff[1] != variation:
					break
				tng[variation].append(objectStuff)
				getObjectIndex += 1
	
	store_default_data()


func store_default_data():
	default_data["dat"] = dat.duplicate(true)
	default_data["tng"] = tng.duplicate(true)


func resize_dat_and_tng_based_on_file(cfg):
	# Determine maximum needed size for dat and tng arrays
	var max_variation = 0
	for section in cfg.get_sections():
		var parts = section.split(".")
		if parts.size() >= 1:
			var slabID = int(parts[0])
			var variation = (slabID+1) * 28
			max_variation = max(max_variation, variation)
	
	# This is necessary rather than using fill([]), because we need to keep the original data there
	while max_variation >= dat.size():
		dat.append(EMPTY_SLAB)
	while max_variation >= tng.size():
		tng.append([])

const EMPTY_SLAB = [0,0,0, 0,0,0, 0,0,0]

func preprocess_toml_file(filePath): # 7ms
	var file = File.new()
	if file.open(filePath, File.READ) != OK:
		return null

	# [[slab20.NW_WATER_objects]]
	# [[slab20.NW_WATER_objects]]
	# [[slab20.NW_WATER_objects]]
	# Turns into:
	# [[slab20.NW_WATER.objects0]]
	# [[slab20.NW_WATER.objects1]]
	# [[slab20.NW_WATER.objects2]]

	# Replace all instances of [[ with [ in the entire file text first, important for parsing to be correct
	var fileText = file.get_as_text().replace("[[", "[").replace("]]", "]")
	var arrayOfLines = fileText.split("\n")
	var calculateObjectIndex = 0
	var rememberLine = ""
	for i in range(arrayOfLines.size()):
		var line = arrayOfLines[i]
		if "_objects" in line:
			if rememberLine != line:
				calculateObjectIndex = 0
			rememberLine = line
			arrayOfLines[i] = line.replace("_objects", ".objects" + str(calculateObjectIndex))
			calculateObjectIndex += 1
	var processed_string = "\n".join(arrayOfLines)
	return processed_string

#print(processed_string)
# test
#	var textFile = File.new()
#	if textFile.open("D:/AI/debug_slabset.toml", File.WRITE) != OK:
#		return
#	textFile.store_string(processed_string)
#	textFile.close()

func create_object_list(tng_buffer):
	tng_buffer.seek(0)
	var numberOfThings = tng_buffer.get_u16() # It says 359, however there are actually 362 entries in the file.
	print('Number of Things: '+str(numberOfThings))
	
	tng_buffer.seek(2 + (1304*2))
	
	var object_info = []
	object_info.resize(numberOfThings)
	for i in object_info.size():
		object_info[i] = []
		object_info[i].resize(9) #(this is coincidentally size 9, it has nothing to do with subtiles)
		object_info[i][obj.IS_LIGHT] = tng_buffer.get_u8() # 0 = object/effectgen, 1 = light
		
		var variation = tng_buffer.get_u16() # Extract the old slab variation index
		if variation >= 1176: # If the variation index is from the short slabs in the original structure, calculate its new index in the uniform 58*28 structure.
			variation = 1176 + ((variation - 1176) / 8) * 28 + (variation % 8)
		object_info[i][obj.VARIATION] = variation # Set the new slab variation index
		
		object_info[i][obj.SUBTILE] = tng_buffer.get_u8() # subtile (between 0 and 8)
		
		# Note: using get_16() instead of get_u16()
		object_info[i][obj.RELATIVE_X] = tng_buffer.get_16()
		object_info[i][obj.RELATIVE_Y] = tng_buffer.get_16()
		object_info[i][obj.RELATIVE_Z] = tng_buffer.get_16()
		
		# Thing type, # Thing subtype, # Effect range
		object_info[i][obj.THING_TYPE] = tng_buffer.get_u8()
		object_info[i][obj.THING_SUBTYPE] = tng_buffer.get_u8()
		object_info[i][obj.EFFECT_RANGE] = tng_buffer.get_u8()
	
	return object_info

func fetch_columnset_index(variation, subtile):
	if variation < dat.size():
		return dat[variation][subtile]
	else:
		return 0

enum { # BitFlags
	SKIP_NONE = 0,
	SKIP_COLUMNS = 1,
	SKIP_OBJECTS = 2,
}

func export_toml_slabset(filePath, fullExport): #"res://slabset.toml"
	var CODETIME_START = OS.get_ticks_msec()
	
	# Find differences if not a full export
	var dat_diffs = []
	var tng_diffs = []
	if fullExport == false:
		dat_diffs = find_all_dat_differences()
		tng_diffs = find_all_tng_differences()
		if tng_diffs.size() == 0 and dat_diffs.size() == 0:
			oMessage.big("File wasn't saved", "You've made zero changes, so the file wasn't saved. Did you mean to enable 'Full'?")
			return
	
	# Print differences for debugging
	for i in tng_diffs:
		print("---------TNG differences---------")
		print("Current: ", tng[i])
		if i < default_data["tng"].size():
			print("Default: ", default_data["tng"][i])
		else:
			print("Default: Beyond array size")
	
	# Print differences for debugging
	for i in dat_diffs:
		print("---------DAT differences---------")
		print("Current: ", dat[i])
		if i < default_data["dat"].size():
			print("Default: ", default_data["dat"][i])
		else:
			print("Default: Beyond array size")
	
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) != OK:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")
		return
	
	var biggest_array = max(dat.size(), tng.size())
	for variation in biggest_array:
		# If both are empty then skip writing this slab
		if (variation >= dat.size() or dat[variation] == [0,0,0, 0,0,0, 0,0,0]) and (variation >= tng.size() or tng[variation] == []):
			continue
		
		# Skip differences
		var skip = SKIP_NONE
		if fullExport == false:
			if dat_diffs.has(variation) == false:
				skip += SKIP_COLUMNS
			if tng_diffs.has(variation) == false:
				skip += SKIP_OBJECTS
			if skip == SKIP_COLUMNS + SKIP_OBJECTS:
				continue # skip both
		
		var slabID = int(variation / 28)
		var variationNumber = variation % 28
		var dirText = dir_texts[variationNumber]
		
		if variationNumber == 0:
			textFile.store_line("[slab" + str(slabID) + "]")
		textFile.store_line("[slab" + str(slabID) + "." + dirText + "]")
		
		if skip != SKIP_COLUMNS:
			textFile.store_line("Columns = " + str(dat[variation]))
		
		if skip != SKIP_OBJECTS:
			for object in tng[variation]:
				textFile.store_line("\r")
				textFile.store_line("[[slab" + str(slabID) + "." + dirText + "_objects" + "]]")
				for z in 9:
					var propertyName
					var value
					# 1 = Variation, 4 = RelativeY, 5 = RelativeZ
					match z:
						0:
							propertyName = "IsLight"
							value = object[z]
						2:
							propertyName = "Subtile"
							value = object[z]
						3:
							propertyName = "RelativePosition"
							value = [ object[3], object[4], object[5] ]
						6:
							propertyName = "ThingType"
							value = object[z]
						7:
							propertyName = "Subtype"
							value = object[z]
						8:
							propertyName = "EffectRange"
							value = object[z]
					if propertyName:
						textFile.store_line(propertyName + " = " + str(value))
			if tng[variation].size() == 0:
				textFile.store_line("Objects = []")
		
		textFile.store_line("\r")
	
	textFile.close()
	oMessage.quick("Saved: " + filePath)
	
	print('Exported in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')



func find_all_dat_differences():
	var diff_indices = []
	for variation in dat.size():
		if is_dat_variation_different(variation) == true:
			diff_indices.append(variation)
	return diff_indices


func find_all_tng_differences():
	var diff_indices = []
	for variation in tng.size():
		if is_tng_variation_different(variation) == true:
			diff_indices.append(variation)
	return diff_indices


func is_dat_variation_different(variation):
	if variation >= dat.size() or dat[variation].empty(): # This function should not have been called
		return false
	if dat[variation] == [0,0,0, 0,0,0, 0,0,0]: # If it's got nothing on it, then skip it
		return false
	if variation >= default_data["dat"].size() or dat[variation] != default_data["dat"][variation]: # If 'default' is shorter, or the current and default elements differ
		return true
	return false


func is_tng_variation_different(variation):
	if variation >= tng.size() or tng[variation].empty(): # This function should not have been called
		return false
	if tng[variation] == [0,0,0, 0,0,0, 0,0,0]: # If it's got nothing on it, then skip it
		return false
	if variation >= default_data["tng"].size() or tng[variation] != default_data["tng"][variation]: # If 'default' is shorter, or the current and default elements differ
		return true
	return false


func is_dat_column_different(variation, subtile):
	if variation >= dat.size() or dat[variation].empty():
		return false
	if variation >= default_data["dat"].size() or default_data["dat"][variation].empty():
		return dat[variation][subtile] != 0
	return dat[variation][subtile] != default_data["dat"][variation][subtile]


func is_tng_object_different(variation, objectIndex, objectProperty):
	# Check if the variation index is out of bounds for either array.
	if variation >= tng.size() or variation >= default_data["tng"].size():
		return false

	# Check if the objectIndex is out of bounds for either array.
	if objectIndex >= tng[variation].size() or objectIndex >= default_data["tng"][variation].size():
		return true
	# Compare the property values of the current and default objects.
	return tng[variation][objectIndex][objectProperty] != default_data["tng"][variation][objectIndex][objectProperty]


var dir_texts = {
	0: 'S',
	1: 'W',
	2: 'N',
	3: 'E',
	4: 'SW',
	5: 'NW',
	6: 'NE',
	7: 'SE',
	8: 'ALL',
	9: 'S_LAVA',
	10: 'W_LAVA',
	11: 'N_LAVA',
	12: 'E_LAVA',
	13: 'SW_LAVA',
	14: 'NW_LAVA',
	15: 'NE_LAVA',
	16: 'SE_LAVA',
	17: 'ALL_LAVA',
	18: 'S_WATER',
	19: 'W_WATER',
	20: 'N_WATER',
	21: 'E_WATER',
	22: 'SW_WATER',
	23: 'NW_WATER',
	24: 'NE_WATER',
	25: 'SE_WATER',
	26: 'ALL_WATER',
	27: 'CENTER'
}

var dir_numbers = {
	'S': 0,
	'W': 1,
	'N': 2,
	'E': 3,
	'SW': 4,
	'NW': 5,
	'NE': 6,
	'SE': 7,
	'ALL': 8,
	'S_LAVA': 9,
	'W_LAVA': 10,
	'N_LAVA': 11,
	'E_LAVA': 12,
	'SW_LAVA': 13,
	'NW_LAVA': 14,
	'NE_LAVA': 15,
	'SE_LAVA': 16,
	'ALL_LAVA': 17,
	'S_WATER': 18,
	'W_WATER': 19,
	'N_WATER': 20,
	'E_WATER': 21,
	'SW_WATER': 22,
	'NW_WATER': 23,
	'NE_WATER': 24,
	'SE_WATER': 25,
	'ALL_WATER': 26,
	'CENTER': 27
}


#
#.................slabs.tng.................
#First 16bit: Number of things. It says 359, however there are actually 362 entries in the file. Possibly cut content or something.
#1304 entries - 16bit each. They determine "which tngEntry idx" is in the slabvariation.
#Each slabvariation has only one tngEntry.
#Each index is a 16bit integer. (255,255) or 65535 means there is no tngEntry there.
#After the first 84 entries (28+28+28) then comes the first torch entry.
#
#
#the subsequent 362 or so lines are obj like below
#
#0: 1=light, if it's 0 then it's an object OR effectgen.
#89: field_1: slabVariation?
#0
#3: field 3: this is 0-8, this definitely "subtile". 0 = top left, 4 = middle subtile, 8 = bottom right.
#192: field 4: within-subtile
#255
#128: field 6: within-subtile
#0
#224: field 8: within-subtile
#2
#1: field A: "objclass": Can be: 0, 1 or 7. Might be "thing subtype" so 7 might be "roomeffect".
#2: sofield B: "objmodel" (Item/decoration subtype values, 1-134, see "Map Files Format Reference" page.
#0: sofield C: effect range
#
##define SLABSET_COUNT        1304
##define SLABOBJS_COUNT        512
#
#208, 4
#
#
#
#.................slabs.obj.................
#same as slabs.tng where it has 3 sections, the number of objects, the slabvariation with indexes, then the list of array obj
#The number of slabvariations is less than in slabs.tng and so are the number of objects.
#42 * 28 = 1176 (and 1176*2=2352)
#The list of arrays is of size 10. This one is different to the one inside slabs.tng. Who knows what the values are. One value is a subtile (0-8) though.


#func test_creation_of_object():
#	var idx = 0
#	for yTile in 52:
#		for xTile in 28:
#			create_obj_on_slab(xTile, yTile, idx)
#			idx += 1
