extends Node
onready var oGame = Nodelist.list["oGame"]

var dat = [] # 1304 sets of 9 column indexes

func dat_asset():
	var CODETIME_START = OS.get_ticks_msec()
	
	var filePath = dk_data_get_filepath("SLABS.DAT")
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

func dk_data_get_filepath(lookForFileName):
	var dir = Directory.new()
	if dir.open(oGame.DK_DATA_DIRECTORY) == OK:
		dir.list_dir_begin(true, false)
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == false:
				if fileName.to_upper() == lookForFileName.to_upper(): # Get file regardless of case (case insensitive)
					return oGame.DK_DATA_DIRECTORY.plus_file(fileName)
			fileName = dir.get_next()
	return ""
