extends 'res://Class/ClmClass.gd'
onready var oMessage = Nodelist.list["oMessage"]
onready var oTimerUpdateColumnEntries = Nodelist.list["oTimerUpdateColumnEntries"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oUniversalDetails = Nodelist.list["oUniversalDetails"]

var column_count = 8192

# Storing these values outside of main array so I can do array comparisons
var utilized = []
var orientation = []
var solidMask = []
var permanent = []
var lintel = []
var height = []
var cubes = []
var floorTexture = []

var default_data = {}

func store_default_data():
	default_data["utilized"] = utilized.duplicate(true)
	default_data["orientation"] = orientation.duplicate(true)
	default_data["solidMask"] = solidMask.duplicate(true)
	default_data["permanent"] = permanent.duplicate(true)
	default_data["lintel"] = lintel.duplicate(true)
	default_data["height"] = height.duplicate(true)
	default_data["cubes"] = cubes.duplicate(true)
	default_data["floorTexture"] = floorTexture.duplicate(true)

#var testingSpecialByte = []


func clm_data_exists():
	if cubes.empty() == true:
		return false # Nothing in arrays, so column data doesn't exist
	else:
		return true # Something in arrays, so column data exists


func count_filled_clm_entries():
	var CODETIME_START = OS.get_ticks_msec()
	var numberOfFilledEntries = 0
	for entry in column_count:
		if cubes[entry] != [0,0,0,0, 0,0,0,0]:
			numberOfFilledEntries += 1
	oUniversalDetails.clmEntryCount = numberOfFilledEntries
	print('count_filled_clm_entries: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	return numberOfFilledEntries

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
		lintel[index] = calculate_lintel(cubeArray)
		height[index] = get_height_from_bottom(cubeArray)
		cubes[index] = cubeArray
		floorTexture[index] = setFloorID
		
		oTimerUpdateColumnEntries.start()
		return index

	oMessage.big("Error", "Clm entries are full. Try the 'Clear Unused' button in the Map Columns window.")
	return 0

var a_column_has_changed_since_last_updating_utilized = false
func update_all_utilized():
	if a_column_has_changed_since_last_updating_utilized == false:
		return
	a_column_has_changed_since_last_updating_utilized = false
	
	var CODETIME_START = OS.get_ticks_msec()
	for clearIndex in column_count:
		utilized[clearIndex] = 0
	for y in (M.ySize*3):
		for x in (M.xSize*3):
			var value = oDataClmPos.get_cell_clmpos(x,y)
			utilized[value] += 1
	
	print('All CLM utilized updated in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func update_all_solid_mask():
	var CODETIME_START = OS.get_ticks_msec()
	for index in column_count:
		solidMask[index] = calculate_solid_mask(cubes[index])
	print('All CLM solid bitmask updated in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func calculate_lintel(cubeArray):
	var holeCount = 0
	# Scan from top to bottom (index 7 to 0)
	for cubeNumber in range(7, -1, -1):
		if cubeArray[cubeNumber] == 0:
			holeCount += 1
			if holeCount == 2:
				# Found the 2nd hole, return the position of the cube above it
				# The cube above this hole is at cubeNumber + 1
				var cubePosition = cubeNumber + 1
				var reversedCubePosition = 7 - cubePosition
				return reversedCubePosition
	# If we don't find a 2nd hole, return 0 as default
	return 0

func clear_unused_entries():
	update_all_utilized()
	for clmIndex in column_count:
		if utilized[clmIndex] == 0:
			delete_column(clmIndex)





func sort_columns_by_utilized():
	oMessage.quick("Sorted columns by utilized value")
	
	var array = []
	var dictSrcDest = {}
	
	utilized[0] = 999999 # Pretend that the utilized value is maximum for column 0, so it's placed first when sorted. Set it back to 0 afterwards.
	
	var CODETIME_START = OS.get_ticks_msec()
	for i in column_count:
		array.append([
			i,
			utilized[i],
			orientation[i],
			solidMask[i],
			permanent[i],
			lintel[i],
			height[i],
			cubes[i].duplicate(true),
			floorTexture[i]
		])
	
	# Sort
	array.sort_custom(self, "sorter_utilized")
	
	for i in column_count:
		var sourceIndex = array[i][0]
		dictSrcDest[sourceIndex] = i # for swapping the column indexes easier in oDataClmPos
		utilized[i] = array[i][1]
		orientation[i] = array[i][2]
		solidMask[i] = array[i][3]
		permanent[i] = array[i][4]
		lintel[i] = array[i][5]
		height[i] = array[i][6]
		cubes[i] = array[i][7]
		floorTexture[i] = array[i][8]
	
	for y in (M.ySize*3):
		for x in (M.xSize*3):
			var clmIndex = oDataClmPos.get_cell_clmpos(x,y)
			oDataClmPos.set_cell_clmpos(x, y, dictSrcDest[clmIndex])
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	
	oOverheadGraphics.overhead2d_update_rect_single_threaded(shapePositionArray)
	
	utilized[0] = 0 # Pretend that the utilized value is maximum for column 0, so it's placed first. Set it back to 0 afterwards.
	
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

static func sorter_utilized(a, b):
	if a[1] == b[1]:
		if a[1] == 0:
			return a[7] != [0,0,0,0, 0,0,0,0] or a[8] != 0
		return false
	return a[1] > b[1]

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


