extends 'res://Class/ColumnEditClass.gd'
onready var oMessage = Nodelist.list["oMessage"]
onready var oTimerUpdateColumnEntries = Nodelist.list["oTimerUpdateColumnEntries"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]

# Storing these values outside of main array so I can do array comparisons
var utilized = []
var orientation = []
var solidMask = []
var permanent = []
var lintel = []
var height = []
var cubes = []
var floorTexture = []



#var testingSpecialByte = []

var unknownData #The second 4 bytes

func clm_data_exists():
	if cubes.empty() == true:
		return false # Nothing in arrays, so column data doesn't exist
	else:
		return true # Something in arrays, so column data exists

func clear_all():
	utilized.clear()
	orientation.clear()
	solidMask.clear()
	permanent.clear()
	lintel.clear()
	height.clear()
	cubes.clear()
	floorTexture.clear()
#	testingSpecialByte.clear()

func get_top_cube_face(index, slabID):
	var get_height = height[index]
	if slabID == Slabs.PORTAL:
		get_height = get_real_height(cubes[index])
	if get_height == 0:
		return floorTexture[index]
	else:
		var cubeID = cubes[index][get_height-1] #get_height
		return Cube.tex[cubeID][Cube.SIDE_TOP]



func count_filled_clm_entries():
	var numberOfFilledEntries = 0
	for entry in 2048:
		if cubes[entry] != [0,0,0,0, 0,0,0,0]:
			numberOfFilledEntries += 1
	return numberOfFilledEntries

func index_entry_replace_one_cube(index, cubePosition, setCubeID):
	var cubeArray = cubes[index].duplicate(true)
	cubeArray[cubePosition] = setCubeID
	return index_entry(cubeArray, floorTexture[index])

func index_entry(cubeArray, setFloorID):
	var idx = find_cubearray_index(cubeArray, setFloorID)
	if idx != -1: return idx
	
	# Add new entry
	var index = find_cubearray_index([0,0,0,0,0,0,0,0], 0)
	if index != -1:
		utilized[index] = 1 # This can be whatever, it's automatically set when saving
		orientation[index] = 0
		solidMask[index] = calculate_solid_mask(cubeArray)
		permanent[index] = 1 # Does this affect whether columns get reset?
		lintel[index] = 0
		height[index] = get_real_height(cubeArray)
		cubes[index] = cubeArray
		floorTexture[index] = setFloorID
		
		oTimerUpdateColumnEntries.start()
		return index

	oMessage.quick("ERROR: CAN'T ADD CLM ENTRY, RAN OUT OF BLANK CLM ENTRIES")
	print("ERROR: CAN'T ADD CLM ENTRY, RAN OUT OF BLANK CLM ENTRIES")
	return 0

func update_all_utilized():
	var CODETIME_START = OS.get_ticks_msec()
	for clearIndex in 2048:
		utilized[clearIndex] = 0
	for y in 255:
		for x in 255:
			var value = oDataClmPos.get_cell(x,y)
			utilized[value] += 1
	
	print('All CLM utilized updated in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func update_all_solid_mask():
	var CODETIME_START = OS.get_ticks_msec()
	for index in 2048:
		solidMask[index] = calculate_solid_mask(cubes[index])
	print('All CLM solid bitmask updated in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


#func find_blank_slot():
#	var index = cubes.find([0,0,0,0, 0,0,0,0], 1) # Skip looking at index 0
#	if index != -1: return index
#
#	print('ERROR: NO BLANK CLM ENTRY FOUND!')
#	return -1

#func get_use(array):
#	return array[USE] | (array[USE+1] << 8) # 16 bit

#enum {
#	USE = 0 # to 1
#	PERMANENT = 2
#	HEIGHT = 2
#	LINTEL = 2
#	SOLID = 3 # to 4
#	BASE = 5 # to 6
#	ORIENTATION = 7
#	C0 = 8 # to 9
#	C1 = 10 # to 11
#	C2 = 12 # to 13
#	C3 = 14 # to 15
#	C4 = 16 # to 17
#	C5 = 18 # to 19
#	C6 = 20 # to 21
#	C7 = 22 # to 23
#}

#func index_entry(array):
#	# Search for existing entry
#	var idx = cubes.find_last(array) # It's just faster to search backwards
#	if idx != -1: return idx
#
#	# Add new entry
#	var entryIndex = get_blank()
#	if entryIndex != -1:
#
#		cubes[entryIndex] = array
#		use[entryIndex] = 0
#		orientation[entryIndex] = 0
#		solidMask[entryIndex] = 0
#		permanent[entryIndex] = 0
#		lintel[entryIndex] = 0
#		height[entryIndex] = 5
#		cubes[entryIndex] = 0
#		floorTexture[entryIndex] = 0
#
#		oTimerUpdateColumnEntries.start()
#		return entryIndex
#
#	oMessage.quick("ERROR: CAN'T ADD CLM ENTRY, RAN OUT OF BLANK CLM ENTRIES")
#	print("ERROR: CAN'T ADD CLM ENTRY, RAN OUT OF BLANK CLM ENTRIES")
#	return 0

#func index_set_cube(index, cubePosition, setCubeID):
#	var array = data[index]
#	var arrayPos = C0 + (2*cubePosition)
#	array[arrayPos] = setCubeID
#	array[arrayPos+1] = (setCubeID >> 8)
#
#
#func is_blank(array):
#	if array == [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]:
#		return true
#	if array == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]:
#		return true
#	return false
#
#
#func get_orientation(array):
#	return array[ORIENTATION] # is just an 8 bit value
#
#func get_solid_mask(array):
#	return array[SOLID] | (array[SOLID+1] << 8) # 16 bit
#
#func get_height(array):
#	return array[HEIGHT] / 16
#
#func get_lintel(array):
#	var wholeByte = array[LINTEL]
#	var get_height = wholeByte / 16
#	wholeByte -= get_height * 16
#	var get_lintel = wholeByte / 2
#	return get_lintel
#
#func get_permanent(array):
#	var wholeByte = array[PERMANENT]
#	var get_height = wholeByte / 16
#	wholeByte -= get_height * 16
#	var get_lintel = wholeByte / 2
#	wholeByte -= get_lintel * 2
#	var get_permanent = wholeByte
#	return get_permanent
#
#func get_cube(array, cubeNumber):
#	var C = C0 + (2*cubeNumber)
#	return array[C] | (array[C+1] << 8)
#
