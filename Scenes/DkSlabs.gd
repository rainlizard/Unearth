extends Node
var CODETIME_START

var dat = [] # 1304 sets of 9 column indexes

var use = []
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

func clm_asset():
	CODETIME_START = OS.get_ticks_msec()
	
	var buffer = Filetypes.file_path_to_buffer(Settings.unearthdata.plus_file("slabs.clm"))
	
	buffer.seek(0)
	var numberOfClmEntries = buffer.get_u16()
	buffer.seek(4) # For reading slabs.clm. (THIS IS DIFFERENT TO READING MAPS)
	for entry in numberOfClmEntries:
		use.append(buffer.get_u16()) # 0-1
		
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

func dat_asset():
	CODETIME_START = OS.get_ticks_msec()
	
	var buffer = Filetypes.file_path_to_buffer(Settings.unearthdata.plus_file("slabs.dat"))
	buffer.seek(2)
	var numberOfSets = 1304
	dat.resize(numberOfSets)
	for i in dat.size():
		dat[i] = []
		dat[i].resize(9)
		for subtile in 9:
			var value = 65536 - buffer.get_u16()
			dat[i][subtile] = value
	
	print('Created DAT asset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
