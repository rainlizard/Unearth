extends Node

onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataFakeSlab = Nodelist.list["oDataFakeSlab"]
onready var oDataLof = Nodelist.list["oDataLof"]

onready var oWriteData = Nodelist.list["oWriteData"]
onready var oReadData = Nodelist.list["oReadData"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]

const FILE_TYPES = [
	"LOF", # This must be read first so that MAPSIZE can be used in relation to the rest of the files
	"CLM",
	"DAT",
	"APT",
	"APTFX",
	"TNG",
	"TNGFX",
	"INF",
	"SLB",
	"OWN",
	"LIF",
	"LGT",
	"LGTFX",
	"WIB",
	"SLX",
	"WLB",
	"TXT",
	"LUA",
	"UNE",
]

func new_blank(EXT):
	match EXT:
		"LOF" : oReadData.new_lof()
		"CLM" : oReadData.new_clm()
		"DAT" : oReadData.new_dat()
		"APT" : oReadData.new_apt()
		"APTFX" : oReadData.new_aptfx()
		"TNG" : oReadData.new_tng()
		"TNGFX" : oReadData.new_tngfx()
		"INF" : oReadData.new_inf()
		"SLB" : oReadData.new_slb()
		"OWN" : oReadData.new_own()
		"LIF" : oReadData.new_lif()
		"LGT" : oReadData.new_lgt()
		"LGTFX" : oReadData.new_lgtfx()
		"WIB" : oReadData.new_wib()
		"SLX" : oReadData.new_slx()
		"WLB" : oReadData.new_wlb()
		"TXT" : oReadData.new_txt()
		"LUA" : oReadData.new_lua()
		"UNE" : oReadData.new_une()

func read(filePath, EXT):
	if File.new().file_exists(filePath) == false:
		print("File not found : " + filePath)
		return

	print("Attempting to read : " + filePath)
	var CODETIME_START = OS.get_ticks_msec()
	var buffer = file_path_to_buffer(filePath)
	read_buffer_for_extension(buffer, EXT)
	print('.' + EXT + ' read success in ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func read_buffer_for_extension(buffer, EXT):
	buffer.seek(0) # Important!
	match EXT:
		"LOF" : oReadData.read_lof(buffer)
		"CLM" : oReadData.read_clm(buffer)
		"DAT" : oReadData.read_dat(buffer)
		"APT" : oReadData.read_apt(buffer)
		"APTFX" : oReadData.read_aptfx(buffer)
		"TNG" : oReadData.read_tng(buffer)
		"TNGFX" : oReadData.read_tngfx(buffer)
		"INF" : oReadData.read_inf(buffer)
		"SLB" : oReadData.read_slb(buffer)
		"OWN" : oReadData.read_own(buffer)
		"LIF" : oReadData.read_lif(buffer)
		"LGT" : oReadData.read_lgt(buffer)
		"LGTFX" : oReadData.read_lgtfx(buffer)
		"WIB" : oReadData.read_wib(buffer)
		"SLX" : oReadData.read_slx(buffer)
		"WLB" : oReadData.read_wlb(buffer)
		"TXT" : oReadData.read_txt(buffer)
		"LUA" : oReadData.read_lua(buffer)
		"UNE" : oReadData.read_une(buffer)

func file_path_to_buffer(filePath):
	var buffer = StreamPeerBuffer.new()
	var file = File.new()
	if file.open(filePath, File.READ) == OK:
		buffer.data_array = file.get_buffer(file.get_len())
		file.close()
	return buffer

func write(filePath, EXT):
	print("Saving : " + filePath)
	var CODETIME_START = OS.get_ticks_msec()
	var buffer = get_buffer_for_extension(EXT, filePath)
	var err = write_buffer_to_file(filePath, buffer, EXT, CODETIME_START)
	if err == OK:
		print('.' + EXT + ' wrote in ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	return err

func write_buffer_to_file(filePath, buffer, EXT, CODETIME_START):
	var file = File.new()
	var err = file.open(filePath, File.WRITE)
	if err == OK:
		file.store_buffer(buffer.data_array)
		file.close()
	return err

func get_buffer_for_extension(EXT, filePath):
	match EXT:
		"LOF": return oWriteData.write_keeperfx_lof()
		"CLM": return oWriteData.write_clm()
		"DAT": return oWriteData.write_dat()
		"APT": return oWriteData.write_apt()
		"APTFX": return oWriteData.write_aptfx()
		"TNG": return oWriteData.write_tng()
		"TNGFX": return oWriteData.write_tngfx()
		"INF": return oWriteData.write_inf()
		"SLB": return oWriteData.write_slb()
		"OWN": return oWriteData.write_own()
		"LIF": return oWriteData.write_lif(filePath)
		"LGT": return oWriteData.write_lgt()
		"LGTFX": return oWriteData.write_lgtfx()
		"WIB": return oWriteData.write_wib()
		"SLX": return oWriteData.write_slx()
		"WLB": return oWriteData.write_wlb()
		"TXT": return oWriteData.write_txt()
		"LUA": return oWriteData.write_lua()
		"UNE": return oWriteData.write_une()

func should_process_file_type(EXT):
	if oCurrentFormat.selected == Constants.ClassicFormat:
		if ["LOF", "TNGFX", "APTFX", "LGTFX"].has(EXT):
			return false
	elif oCurrentFormat.selected == Constants.KfxFormat:
		if ["LIF", "TNG", "APT", "LGT"].has(EXT):
			return false
	return true

func resize_all_data_structures(new_width, new_height):
	oDataSlab.resize(new_width, new_height, 0)
	oDataOwnership.resize((new_width*3)+1, (new_height*3)+1, 5)
	oDataClmPos.resize((new_width*3)+1, (new_height*3)+1, 0)
	oDataWibble.resize((new_width*3)+1, (new_height*3)+1, 0)
	oDataLiquid.resize(new_width, new_height, 0)
	oDataFakeSlab.resize(new_width, new_height, 0)
	
	oDataSlx.resize_bottom_right(new_width, new_height, 0)
