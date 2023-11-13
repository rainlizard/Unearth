extends Node
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

func load_slabset():
	tng = []
	dat = []
	var CODETIME_START = OS.get_ticks_msec()
	var oGame = Nodelist.list["oGame"]
	var oMessage = Nodelist.list["oMessage"]
	
	var dat_buffer = Filetypes.file_path_to_buffer(oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.DAT"))
	var tng_buffer = Filetypes.file_path_to_buffer(oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.TNG"))
	
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
	
	print('Created Slabset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	store_default_data()

func store_default_data():
	default_data["dat"] = dat.duplicate(true)
	default_data["tng"] = tng.duplicate(true)

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
		
		object_info[i][obj.RELATIVE_X] = Things.convert_relative_256_to_float(tng_buffer.get_u16())
		object_info[i][obj.RELATIVE_Y] = Things.convert_relative_256_to_float(tng_buffer.get_u16())
		object_info[i][obj.RELATIVE_Z] = Things.convert_relative_256_to_float(tng_buffer.get_u16())
		
		# Thing type, # Thing subtype, # Effect range
		object_info[i][obj.THING_TYPE] = tng_buffer.get_u8()
		object_info[i][obj.THING_SUBTYPE] = tng_buffer.get_u8()
		object_info[i][obj.EFFECT_RANGE] = tng_buffer.get_u8()
	
	return object_info

func fetch_column_index(variation, subtile):
	if variation < dat.size():
		return dat[variation][subtile]
	else:
		return 0

enum { # BitFlags
	SKIP_NONE = 0,
	SKIP_COLUMNS = 1,
	SKIP_OBJECTS = 2,
}

func create_cfg_slabset(filePath, fullExport): #"res://slabset.cfg"
	var CODETIME_START = OS.get_ticks_msec()
	var oMessage = Nodelist.list["oMessage"]
	
	
	# Find differences if not a full export
	var dat_diffs = []
	var tng_diffs = []
	if fullExport == false:
		dat_diffs = find_differences(dat, default_data["dat"])
		tng_diffs = find_differences(tng, default_data["tng"])
		if tng_diffs.size() == 0 and dat_diffs.size() == 0:
			oMessage.big("File wasn't saved", "You've made zero changes, so the file wasn't saved.")
			return
	
	# Print differences for debugging
	for i in tng_diffs:
		print("---------Differences---------")
		print("Current: ", tng[i])
		if i < default_data["tng"].size():
			print("Default: ",default_data["tng"][i])
		else:
			print("Default: Beyond array size")
	
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) != OK:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")
		return
	
	var biggest_array = max(dat.size(), tng.size())
	for variation in biggest_array:
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
		var dirText = get_dir_text(variationNumber)
		
		if variationNumber == 0:
			textFile.store_line("[slab" + str(slabID) + "]")
		textFile.store_line("[slab" + str(slabID) + "." + dirText + "]")
		
		if skip != SKIP_COLUMNS:
			textFile.store_line("columns = " + str(dat[variation]))
		
		if skip != SKIP_OBJECTS:
			for object in tng[variation]:
				textFile.store_line("\r")
				textFile.store_line("[[slab" + str(slabID) + "." + dirText + "_objects" + "]]")
				for z in 9:
					var val = object[z]
					var beginLine = get_property_name(z) # Implement this method based on your match statement.
					if beginLine:
						beginLine += " = "
						if z == obj.THING_TYPE: # Use string as value instead of an integer
							if object[obj.IS_LIGHT] == 1:
								val = '"Unused"' # Lights don't use ThingType field
							else:
								val = '"'+Things.data_structure_name.get(val, "?")+'"'
						textFile.store_line(beginLine + str(val))
			if tng[variation].size() == 0:
				textFile.store_line("objects = []")
		
		textFile.store_line("\r")
	
	textFile.close()
	oMessage.quick("Saved: " + filePath)
	
	print('Exported in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func find_differences(current, default):
	var diff_indices = []
	for i in current.size():
		if current[i].empty(): # If the current element is an empty array, skip it
			continue
		if current[i] == [0,0,0, 0,0,0, 0,0,0]: # If it's got nothing on it, then skip it
			continue
		if i >= default.size() or current[i] != default[i]: # If 'default' is shorter, or the current and default elements differ
			diff_indices.append(i)
	return diff_indices


func get_property_name(i):
	match i:
		obj.IS_LIGHT: return 'IsLight'
		obj.SUBTILE: return 'Subtile'
		obj.RELATIVE_X: return 'RelativeX'
		obj.RELATIVE_Y: return 'RelativeY'
		obj.RELATIVE_Z: return 'RelativeZ'
		obj.THING_TYPE: return 'ThingType'
		obj.THING_SUBTYPE: return 'Subtype'
		obj.EFFECT_RANGE: return 'EffectRange'
		_: return ''

func get_dir_text(variationNumber):
	match variationNumber:
		00: return 'S'
		01: return 'W'
		02: return 'N'
		03: return 'E'
		04: return 'SW'
		05: return 'NW'
		06: return 'NE'
		07: return 'SE'
		08: return 'ALL' #SWNE
		09: return 'S_LAVA'
		10: return 'W_LAVA'
		11: return 'N_LAVA'
		12: return 'E_LAVA'
		13: return 'SW_LAVA'
		14: return 'NW_LAVA'
		15: return 'NE_LAVA'
		16: return 'SE_LAVA'
		17: return 'ALL_LAVA' #SWNE_LAVA
		18: return 'S_WATER'
		19: return 'W_WATER'
		20: return 'N_WATER'
		21: return 'E_WATER'
		22: return 'SW_WATER'
		23: return 'NW_WATER'
		24: return 'NE_WATER'
		25: return 'SE_WATER'
		26: return 'ALL_WATER' #SWNE_WATER
		27: return 'CENTER'



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
