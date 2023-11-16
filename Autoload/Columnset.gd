extends 'res://Class/ClmClass.gd'
onready var oGame = Nodelist.list["oGame"]

var utilized = []
var orientation = []
var solidMask = []
var permanent = []
var lintel = []
var height = []
var cubes = []
var floorTexture = []

var default_data = {}

# Strangely, slabs.clm is missing the second 4 bytes.
# map0000x.clm : 49,160 bytes. first 4 bytes contains 2048, second 4 bytes are ???, then comes the column data.
# slabs.clm : 49,156 bytes. first 4 bytes contains 2048, then comes the column data.

func load_default_columnset():
	var CODETIME_START = OS.get_ticks_msec()
	clear_all_column_data() # Important, for reloading/refreshing slabs.clm
	
	var filePath = oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.CLM")
	var buffer = Filetypes.file_path_to_buffer(filePath)
	
	buffer.seek(0)
	var numberOfClmEntries = buffer.get_u16()
	
	buffer.seek(4) # For reading slabs.clm. (THIS IS DIFFERENT TO READING MAPS)
	for entry in numberOfClmEntries:
		utilized.append(buffer.get_u16()) # 0-1
		
		var specialByte = buffer.get_u8() # 2
		
		var get_permanent = specialByte & 1
		var get_lintel = (specialByte >> 1) & 7
		var get_height = (specialByte >> 4) & 15
		permanent.append(get_permanent)
		lintel.append(get_lintel)
		height.append(get_height)
		
		solidMask.append(buffer.get_u16()) # 3-4
		floorTexture.append(buffer.get_u16()) # 5-6
		orientation.append(buffer.get_u8()) # 7
		
		cubes.append([])
		cubes[entry].resize(8)
		for cubeNumber in 8:
			cubes[entry][cubeNumber] = buffer.get_u16() # 8-23
	
	print('Created Columnset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	store_default_data()

func store_default_data():
	default_data["utilized"] = utilized.duplicate(true)
	default_data["orientation"] = orientation.duplicate(true)
	default_data["solidMask"] = solidMask.duplicate(true)
	default_data["permanent"] = permanent.duplicate(true)
	default_data["lintel"] = lintel.duplicate(true)
	default_data["height"] = height.duplicate(true)
	default_data["cubes"] = cubes.duplicate(true)
	default_data["floorTexture"] = floorTexture.duplicate(true)

func create_cfg_columns(filePath): #"res://columns.cfg"
	var oMessage = Nodelist.list["oMessage"]
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) == OK:
	
		textFile.store_line('[common]')
		textFile.store_line('ColumnsCount = 2048')
		textFile.store_line('\r')
		
		for i in Columnset.utilized.size():
			textFile.store_line('[column' + str(i) +']')
			textFile.store_line('Utilized = ' + str(Columnset.utilized[i])) #(0-1)
			textFile.store_line('Permanent = ' + str(Columnset.permanent[i])) #(2)
			textFile.store_line('Lintel = ' + str(Columnset.lintel[i])) #(2)
			textFile.store_line('Height = ' + str(Columnset.height[i])) #(2)
			textFile.store_line('SolidMask = ' + str(Columnset.solidMask[i])) #(3-4)
			textFile.store_line('FloorTexture = ' + str(Columnset.floorTexture[i])) #(5-6)
			textFile.store_line('Orientation = ' + str(Columnset.orientation[i])) #(7)
			textFile.store_line('Cubes = ' + str(Columnset.cubes[i])) #(8-23)
			textFile.store_line('\r')
		oMessage.quick("Saved: " + filePath)
	else:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")
