extends Node

var tng = []
var numberOfThings = 0

# dat[slabID][variation][subtile]
var dat = []
var blank_dat_entry = []
var CODETIME_START

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

		# IsLight [0-1]
		# Variation
		# Subtile [0-9]
		# RelativeX
		# RelativeY
		# RelativeZ
		# Thing type
		# Thing subtype
		# Effect range

func create_object_list(tng_buffer):
	tng_buffer.seek(0)
	numberOfThings = tng_buffer.get_u16() # It says 359, however there are actually 362 entries in the file.
	print('Number of Things: '+str(numberOfThings))
	
	tng_buffer.seek(2 + (1304*2))
	
	var object_info = []
	object_info.resize(numberOfThings)
	for i in object_info.size():
		object_info[i] = []
		object_info[i].resize(9) #(this is coincidentally size 9, it has nothing to do with subtiles)
		object_info[i][0] = tng_buffer.get_u8() # 0 = object/effectgen, 1 = light
		
		var variation = tng_buffer.get_u16() # Extract the old slab variation index
		if variation >= 1176: # If the variation index is from the short slabs in the original structure, calculate its new index in the uniform 58*28 structure.
			variation = 1176 + ((variation - 1176) / 8) * 28 + (variation % 8)
		object_info[i][1] = variation # Set the new slab variation index
		
		object_info[i][2] = tng_buffer.get_u8() # subtile (between 0 and 8)
		
		for xxx in [3,4,5]: # Location values can look like 255.75, this is supposed to be -0.25
			var datnum = tng_buffer.get_u16() / 256.0
			if datnum > 255: datnum -= 256
			object_info[i][xxx] = datnum
		
		for xxx in [6,7,8]: # Thing type, # Thing subtype, # Effect range
			object_info[i][xxx] = tng_buffer.get_u8() 
	
	return object_info

func fetch_column_index(variation, subtile):
	if variation < dat.size():
		return dat[variation][subtile]
	else:
		return 0


#func create_cfg_slabset(filePath): #"res://slabset.cfg"
#	var oMessage = Nodelist.list["oMessage"]
#	var textFile = File.new()
#	if textFile.open(filePath, File.WRITE) == OK:
#		var slabSection = 0
#
#		for slabID in 58:
#			#textFile.store_line('[[slab' + str(slabSection) + '.columns]]')
#
#			var variationStart = (slabID * 28)
#			if slabID >= 42:
#				variationStart = (42 * 28) + (8 * (slabID - 42))
#
#			var variationCount = 28
#			if slabID >= 42:
#				variationCount = 8
#
#			textFile.store_line('[slab' + str(slabID) + ']')
#
#			for variationNumber in variationCount:
#				if variationStart + variationNumber < Slabset.dat.size():
#					#var beginLine = get_dir_text(variationNumber) + ' = '
#					textFile.store_line('[slab' + str(slabSection) + '.' + get_dir_text(variationNumber) + ']')
#					textFile.store_line('columns = ' + String(Slabset.dat[variationStart + variationNumber])) #.replace(',','').replace('[','').replace(']','')
#
#				#var objectNumber = 0
#				var hasObjects = false
#				for i in tngObject.size():
#					if tngObject[i][1] == variationStart + variationNumber: #VariationIndex
#						textFile.store_line("\r")
#						hasObjects = true
#						textFile.store_line('[[slab' + str(slabSection) + '.' + get_dir_text(variationNumber) + '_objects' + ']]')
#						for z in 9:
#							var val = tngObject[i][z]
#							var beginLine = ''
#							match z:
#								0: beginLine = 'IsLight'
#								1: beginLine = 'VariationIndex'
#								2: beginLine = 'Subtile'
#								3: beginLine = 'RelativeX'
#								4: beginLine = 'RelativeY'
#								5: beginLine = 'RelativeZ'
#								6: beginLine = 'ThingType'
#								7: beginLine = 'Subtype'
#								8: beginLine = 'EffectRange'
#							if z == 1: continue # skip "VariationIndex"
#
#							beginLine += ' = '
#
#							textFile.store_line(beginLine + String(val))
#						#objectNumber += 1
#
#				if hasObjects == false:
#					textFile.store_line('objects = []')
#
#				textFile.store_line("\r")
#
#			textFile.store_line("\r")
#
#			slabSection += 1
#
#		textFile.close()
#		oMessage.quick("aaaaa Saved: " + filePath)
#	else:
#		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")

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