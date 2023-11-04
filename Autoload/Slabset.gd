extends Node
onready var oGame = Nodelist.list["oGame"]

# dat[slabID][variation][subtile]
var dat = []

func dat_load_slabset():
	var CODETIME_START = OS.get_ticks_msec()
	
	var filePath = oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.DAT")
	var buffer = Filetypes.file_path_to_buffer(filePath)
	buffer.seek(2)
	
	var totalSlabs = 42 + 16
	dat.resize(totalSlabs)
	for slabID in totalSlabs:
		dat[slabID] = []
		dat[slabID].resize(28) # Ensure each slab has space for 28 variations
		for variation in 28:
			dat[slabID][variation] = []
			dat[slabID][variation].resize(9)
			if slabID < 42 or variation < 8: # Only fill the data for the first 42 slabs and the first 8 variations of the next 16 slabs
				for subtile in 9:
					var value = 65536 - buffer.get_u16()
					dat[slabID][variation][subtile] = value
			else:
				for subtile in 9:
					dat[slabID][variation][subtile] = 0
	
	print('Created DAT asset : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
