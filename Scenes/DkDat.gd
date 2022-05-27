extends Node
onready var oGame = Nodelist.list["oGame"]

var dat = [] # 1304 sets of 9 column indexes

func dat_load_slabset():
	var CODETIME_START = OS.get_ticks_msec()
	
	var filePath = oGame.get_precise_filepath(oGame.DK_DATA_DIRECTORY, "SLABS.DAT")
	var buffer = Filetypes.file_path_to_buffer(filePath)
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
