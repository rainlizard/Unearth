extends Node

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
		"UNE": return oWriteData.write_une()

func should_process_file_type(EXT):
	if oCurrentFormat.selected == 0: # Classic format
		if ["LOF", "TNGFX", "APTFX", "LGTFX"].has(EXT):
			return false
	elif oCurrentFormat.selected == 1: # KFX format
		if ["LIF", "TNG", "APT", "LGT"].has(EXT):
			return false
	return true
