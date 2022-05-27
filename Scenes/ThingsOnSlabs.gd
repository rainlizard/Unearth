extends Node
onready var oGame = Nodelist.list["oGame"]

var CODETIME_START
var tngIndex = []
var tngObject = []
var numberOfThings = 0

func tng_load_slabset():
	var filePath = oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.TNG")
	var buffer = Filetypes.file_path_to_buffer(filePath)
	
	buffer.seek(0)
	numberOfThings = buffer.get_u16() # It says 359, however there are actually 362 entries in the file.
	print('Number of Things: '+str(numberOfThings))
	
	slabtng_index_asset(buffer)
	slabtng_object_entry_asset(buffer)
	
	#test_creation_of_object()

#func test_creation_of_object():
#	var idx = 0
#	for yTile in 52:
#		for xTile in 28:
#			create_obj_on_slab(xTile, yTile, idx)
#			idx += 1

func slabtng_index_asset(buffer):
	CODETIME_START = OS.get_ticks_msec()
	
#	var textFile = File.new()
#	textFile.open("res://slabtng_index_asset.txt", File.WRITE)
	
	buffer.seek(2)
	var numberOfSets = 1304
	tngIndex.resize(numberOfSets)
	
	for i in tngIndex.size():
		var value = buffer.get_u16()
		tngIndex[i] = value
		#var lineOfText = str(value)
		#textFile.store_line(lineOfText)
	
	#textFile.close()
	#print('slabtng_index_asset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func slabtng_object_entry_asset(buffer):
	CODETIME_START = OS.get_ticks_msec()
	
	buffer.seek(2 + (1304*2))
	
	#var textFile = File.new()
	#textFile.open("res://slabtng_object_entry_asset.txt", File.WRITE)
	
	tngObject.resize(numberOfThings)
	for i in tngObject.size():
		
		tngObject[i] = []
		tngObject[i].resize(9) #(this is coincidentally size 9, it has nothing to do with subtiles)
		tngObject[i][0] = buffer.get_u8() # 0 = object/effectgen, 1 = light
		tngObject[i][1] = buffer.get_u16() # slabVariation
		tngObject[i][2] = buffer.get_u8() # subtile (between 0 and 8)
		
		var datnum
		
		# Location values can look like 255.75, this is supposed to be -0.25
		datnum = buffer.get_u16() / 256.0
		if datnum > 255: datnum -= 256
		tngObject[i][3] = datnum
		
		datnum = buffer.get_u16() / 256.0
		if datnum > 255: datnum -= 256
		tngObject[i][4] = datnum
		
		datnum = buffer.get_u16() / 256.0
		if datnum > 255: datnum -= 256
		tngObject[i][5] = datnum
		
		tngObject[i][6] = buffer.get_u8() # Thing type
		tngObject[i][7] = buffer.get_u8() # Thing subtype
		tngObject[i][8] = buffer.get_u8() # Effect range
		
#		textFile.store_line(str(i)+'---------------------')
#		for blah in 9:
#			textFile.store_line(str(tngObject[i][blah]))
	
	#textFile.close()
	
	print('slabtng_object_entry_asset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

#		tngObject[i][3] = wrapi(file.get_u16(), -511, 65025) / 256.0
#		tngObject[i][4] = wrapi(file.get_u16(), -511, 65025) / 256.0
#		tngObject[i][5] = wrapi(file.get_u16(), -511, 65025) / 256.0


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
