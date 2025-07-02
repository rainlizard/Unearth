extends 'res://Class/ClmClass.gd'
onready var oGame = Nodelist.list["oGame"]
onready var oBuffers = Nodelist.list["oBuffers"]

var column_count = 8192
var reserved_columnset = 4096
var highest_columnset_id_from_fxdata = 0

var utilized = []
var orientation = []
var solidMask = []
var permanent = []
var lintel = []
var height = []
var cubes = []
var floorTexture = []

var default_data = {}

var columnsContainingOwnedCubes = {}
var columnsContainingRngCubes = {}

# Strangely, slabs.clm is missing the second 4 bytes.
# map0000x.clm : 49,160 bytes. first 4 bytes contains column_count, second 4 bytes are ???, then comes the column data.
# slabs.clm : 49,156 bytes. first 4 bytes contains column_count, then comes the column data.


func import_toml_columnset(filePath):
	var cfg = ConfigFile.new()
	var err = cfg.load(filePath)
	if err != OK:
		return
	
	var is_from_fxdata = "fxdata" in filePath
	var max_column_id_found = 0
	
	for section in cfg.get_sections():
		if section.begins_with("column"):
			var columnIndex = int(section)
			
			if is_from_fxdata:
				max_column_id_found = max(max_column_id_found, columnIndex)
			
			utilized[columnIndex] = 0 #cfg.get_value(section, "Utilized", 0)
			permanent[columnIndex] = 1 #cfg.get_value(section, "Permanent", 0)
			lintel[columnIndex] = cfg.get_value(section, "Lintel", 0)
			height[columnIndex] = cfg.get_value(section, "Height", 0)
			solidMask[columnIndex] = cfg.get_value(section, "SolidMask", 0)
			floorTexture[columnIndex] = cfg.get_value(section, "FloorTexture", 0)
			orientation[columnIndex] = cfg.get_value(section, "Orientation", 0)
			cubes[columnIndex] = cfg.get_value(section, "Cubes", [0,0,0,0, 0,0,0,0])
	
	if is_from_fxdata:
		highest_columnset_id_from_fxdata = max_column_id_found
		store_default_data()
		update_list_of_columns_that_contain_owned_cubes()
		update_list_of_columns_that_contain_rng_cubes()

func load_default_original_columnset():
	var filePath = Utils.case_insensitive_file(oGame.DK_DATA_DIRECTORY, "SLABS", "CLM")
	var buffer = oBuffers.file_path_to_buffer(filePath)
	
	buffer.seek(0)
	var numberOfClmEntries = buffer.get_u16()
	
	buffer.seek(4) # For reading slabs.clm. (THIS IS DIFFERENT TO READING MAPS)
	for entry in numberOfClmEntries:
		utilized[entry] = buffer.get_u16() # 0-1
		
		var specialByte = buffer.get_u8() # 2
		
		var get_permanent = specialByte & 1
		var get_lintel = (specialByte >> 1) & 7
		var get_height = (specialByte >> 4) & 15
		permanent[entry] = get_permanent
		lintel[entry] = get_lintel
		height[entry] = get_height
		
		solidMask[entry] = buffer.get_u16() # 3-4
		floorTexture[entry] = buffer.get_u16() # 5-6
		orientation[entry] = buffer.get_u8() # 7
		
		for cubeNumber in 8:
			cubes[entry][cubeNumber] = buffer.get_u16() # 8-23
	
	store_default_data()
	update_list_of_columns_that_contain_owned_cubes()
	update_list_of_columns_that_contain_rng_cubes()

func store_default_data():
	default_data["utilized"] = utilized.duplicate(true)
	default_data["orientation"] = orientation.duplicate(true)
	default_data["solidMask"] = solidMask.duplicate(true)
	default_data["permanent"] = permanent.duplicate(true)
	default_data["lintel"] = lintel.duplicate(true)
	default_data["height"] = height.duplicate(true)
	default_data["cubes"] = cubes.duplicate(true)
	default_data["floorTexture"] = floorTexture.duplicate(true)


func export_toml_columnset(filePath):
	var column_diffs = find_all_different_columns()
	if column_diffs.size() == 0:
		return false
	
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) != OK:
		var oMessage = Nodelist.list["oMessage"]
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")
		return false
	
	textFile.store_line('[common]')
	textFile.store_line('ColumnsCount = ' + str(column_count))
	textFile.store_line('\r')
	
	for i in column_count:
		if column_diffs.has(i) == false:
			continue
		
		textFile.store_line('[column' + str(i) +']')
		textFile.store_line('Lintel = ' + str(lintel[i]))
		textFile.store_line('Height = ' + str(height[i]))
		textFile.store_line('SolidMask = ' + str(solidMask[i]))
		textFile.store_line('FloorTexture = ' + str(floorTexture[i]))
		textFile.store_line('Orientation = ' + str(orientation[i]))
		textFile.store_line('Cubes = ' + str(cubes[i]))
		textFile.store_line('\r')
	
	textFile.close()
	print("Saved: " + filePath)
	return true




func find_all_different_columns():
	var diff_indices = []
	for i in column_count:
		if is_column_different(i):
			diff_indices.append(i)
	return diff_indices

func is_column_different(index):
#	if utilized[index] != default_data["utilized"][index]:
#		return true
#	if permanent[index] != default_data["permanent"][index]:
#		return true
	if lintel[index] != default_data["lintel"][index]:
		return true
	if height[index] != default_data["height"][index]:
		return true
	if solidMask[index] != default_data["solidMask"][index]:
		return true
	if floorTexture[index] != default_data["floorTexture"][index]:
		return true
	if orientation[index] != default_data["orientation"][index]:
		return true
	if cubes[index] != default_data["cubes"][index]:
		return true
	return false


func update_list_of_columns_that_contain_rng_cubes():
	var CODETIME_START = OS.get_ticks_msec()
	columnsContainingRngCubes.clear()
	
	var reverseRngCubeLookup = {}
	for key in Cube.rngCube.keys():
		for cubeID in Cube.rngCube[key]:
			reverseRngCubeLookup[cubeID] = key
	
	for clmIndex in column_count:
		var rngCubeTypesInColumn = {}
		
		for cubeID in cubes[clmIndex]:
			if reverseRngCubeLookup.has(cubeID):
				var stringNameOfRngType = reverseRngCubeLookup[cubeID]
				rngCubeTypesInColumn[stringNameOfRngType] = true
		
		if rngCubeTypesInColumn:
			columnsContainingRngCubes[clmIndex] = rngCubeTypesInColumn.keys()
	
	print('update_list_of_columns_that_contain_rng_cubes: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func clear_all_column_data():
	.clear_all_column_data()
	highest_columnset_id_from_fxdata = 0


func update_list_of_columns_that_contain_owned_cubes():
	var CODETIME_START = OS.get_ticks_msec()
	columnsContainingOwnedCubes.clear()
	
	var reverseOwnedCubeLookup = {}
	for key in Cube.ownedCube.keys():
		for cubeID in Cube.ownedCube[key]:
			reverseOwnedCubeLookup[cubeID] = key
	
	for clmIndex in column_count:
		var ownedCubeTypesInColumn = {}
		
		for cubeID in cubes[clmIndex]:
			if reverseOwnedCubeLookup.has(cubeID):
				var stringNameOfOwnedType = reverseOwnedCubeLookup[cubeID]
				ownedCubeTypesInColumn[stringNameOfOwnedType] = true
		
		if ownedCubeTypesInColumn:
			columnsContainingOwnedCubes[clmIndex] = ownedCubeTypesInColumn.keys()
	
	print('update_list_of_columns_that_contain_owned_cubes: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func is_valid_column_id_for_navigation(columnID):
	if highest_columnset_id_from_fxdata <= 0:
		return true
	return columnID <= highest_columnset_id_from_fxdata or columnID >= reserved_columnset
