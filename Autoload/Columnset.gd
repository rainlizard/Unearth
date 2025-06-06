extends 'res://Class/ClmClass.gd'
onready var oGame = Nodelist.list["oGame"]
onready var oBuffers = Nodelist.list["oBuffers"]

var column_count = 2048
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
	
	for section in cfg.get_sections():
		if section.begins_with("column"):
			var columnIndex = int(section)
			utilized[columnIndex] = 0 #cfg.get_value(section, "Utilized", 0)
			permanent[columnIndex] = 1 #cfg.get_value(section, "Permanent", 0)
			lintel[columnIndex] = cfg.get_value(section, "Lintel", 0)
			height[columnIndex] = cfg.get_value(section, "Height", 0)
			solidMask[columnIndex] = cfg.get_value(section, "SolidMask", 0)
			floorTexture[columnIndex] = cfg.get_value(section, "FloorTexture", 0)
			orientation[columnIndex] = cfg.get_value(section, "Orientation", 0)
			cubes[columnIndex] = cfg.get_value(section, "Cubes", [0,0,0,0, 0,0,0,0])
	
	if "fxdata" in filePath:
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


func export_toml_columnset(filePath): #"res://columnset.toml"
	var oMessage = Nodelist.list["oMessage"]
	
	# Find differences if not a full export
	var column_diffs = []
	column_diffs = find_all_different_columns()
	if column_diffs.size() == 0:
		oMessage.big("File wasn't saved", "You've made zero changes, so the file wasn't saved.")
		return
	
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) != OK:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")
		return
	
	textFile.store_line('[common]')
	textFile.store_line('ColumnsCount = ' + str(column_count))
	textFile.store_line('\r')
	
	for i in column_count:
		# If this is a partial export, then skip this column if it is the same as default.
		if column_diffs.has(i) == false:
			continue
		
		textFile.store_line('[column' + str(i) +']')
#		textFile.store_line('Utilized = ' + str(Columnset.utilized[i])) #(0-1)
#		textFile.store_line('Permanent = ' + str(Columnset.permanent[i])) #(2)
		textFile.store_line('Lintel = ' + str(Columnset.lintel[i])) #(2)
		textFile.store_line('Height = ' + str(Columnset.height[i])) #(2)
		textFile.store_line('SolidMask = ' + str(Columnset.solidMask[i])) #(3-4)
		textFile.store_line('FloorTexture = ' + str(Columnset.floorTexture[i])) #(5-6)
		textFile.store_line('Orientation = ' + str(Columnset.orientation[i])) #(7)
		textFile.store_line('Cubes = ' + str(Columnset.cubes[i])) #(8-23)
		textFile.store_line('\r')
	
	oMessage.quick("Saved: " + filePath)
	textFile.close()

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
