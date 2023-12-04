extends Node

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
	var oReadData = Nodelist.list["oReadData"]
	match EXT:
		"LOF" : oReadData.new_keeperfx_lof()
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
	
	print("Attempting to read : "+filePath)
	var CODETIME_START = OS.get_ticks_msec()
	
	var buffer = file_path_to_buffer(filePath)
	
	var oReadData = Nodelist.list["oReadData"]
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
	
	print('.'+EXT+' read success in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func write(filePath, EXT):
	print("Saving : "+filePath)
	var CODETIME_START = OS.get_ticks_msec()
	
	var buffer = StreamPeerBuffer.new()
	var oWriteData = Nodelist.list["oWriteData"]
	match EXT:
		"LOF" : oWriteData.write_keeperfx_lof(buffer)
		"CLM" : oWriteData.write_clm(buffer)
		"DAT" : oWriteData.write_dat(buffer)
		"APT" : oWriteData.write_apt(buffer)
		"APTFX" : oWriteData.write_aptfx(buffer)
		"TNG" : oWriteData.write_tng(buffer)
		"TNGFX" : oWriteData.write_tngfx(buffer)
		"INF" : oWriteData.write_inf(buffer)
		"SLB" : oWriteData.write_slb(buffer)
		"OWN" : oWriteData.write_own(buffer)
		"LIF" : oWriteData.write_lif(buffer,filePath)
		"LGT" : oWriteData.write_lgt(buffer)
		"LGTFX" : oWriteData.write_lgtfx(buffer)
		"WIB" : oWriteData.write_wib(buffer)
		"SLX" : oWriteData.write_slx(buffer)
		"WLB" : oWriteData.write_wlb(buffer)
		"TXT" : oWriteData.write_txt(buffer)
		"UNE" : oWriteData.write_une(buffer)
	
	var file = File.new()
	var err = file.open(filePath,File.WRITE)
	if err == OK:
		file.store_buffer(buffer.data_array)
		print('.'+EXT+' wrote in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	file.close()
	
	return err

func file_path_to_buffer(filePath):
	var buffer = StreamPeerBuffer.new()
	var file = File.new()
	if file.open(filePath, File.READ) == OK:
		buffer.data_array = file.get_buffer(file.get_len())
		file.close()
	return buffer
