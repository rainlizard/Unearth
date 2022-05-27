extends 'res://Class/ClmClass.gd'
onready var oGame = Nodelist.list["oGame"]
onready var oDkDat = Nodelist.list["oDkDat"]

var utilized = []
var orientation = []
var solidMask = []
var permanent = []
var lintel = []
var height = []
var cubes = []
var floorTexture = []

# Strangely, slabs.clm is missing the second 4 bytes.
# map0000x.clm : 49,160 bytes. first 4 bytes contains 2048, second 4 bytes are ???, then comes the column data.
# slabs.clm : 49,156 bytes. first 4 bytes contains 2048, then comes the column data.

func clm_load_slabset():
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
	
	print('Created CLM asset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
