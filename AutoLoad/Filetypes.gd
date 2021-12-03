extends Node

const FILE_TYPES = [
	"CLM",
	"DAT",
	"APT",
	"TNG",
	"INF",
	"SLB",
	"OWN",
	"LIF",
	"LGT",
	"WIB",
	"SLX",
	"WLB",
	"TXT",
]

func read(filePath, EXT):
	
	if File.new().file_exists(filePath) == false:
		print("File not found : " + filePath)
		return
	
	print("Attempting to read : "+filePath)
	var CODETIME_START = OS.get_ticks_msec()
	
	var buffer = file_path_to_buffer(filePath)
	
	var oReadData = Nodelist.list["oReadData"]
	match EXT:
		"CLM" : oReadData.read_clm(buffer)
		"DAT" : oReadData.read_dat(buffer)
		"APT" : oReadData.read_apt(buffer)
		"TNG" : oReadData.read_tng(buffer)
		"INF" : oReadData.read_inf(buffer)
		"SLB" : oReadData.read_slb(buffer)
		"OWN" : oReadData.read_own(buffer)
		"LIF" : oReadData.read_lif(buffer)
		"LGT" : oReadData.read_lgt(buffer)
		"WIB" : oReadData.read_wib(buffer)
		"SLX" : oReadData.read_slx(buffer)
		"WLB" : oReadData.read_wlb(buffer)
		"TXT" : oReadData.read_txt(buffer)
	
	print('.'+EXT+' read success in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func write(filePath, EXT):
	print("Saving : "+filePath)
	var CODETIME_START = OS.get_ticks_msec()
	
	var buffer = StreamPeerBuffer.new()
	var oWriteData = Nodelist.list["oWriteData"]
	match EXT:
		"CLM" : oWriteData.write_clm(buffer)
		"DAT" : oWriteData.write_dat(buffer)
		"APT" : oWriteData.write_apt(buffer)
		"TNG" : oWriteData.write_tng(buffer)
		"INF" : oWriteData.write_inf(buffer)
		"SLB" : oWriteData.write_slb(buffer)
		"OWN" : oWriteData.write_own(buffer)
		"LIF" : oWriteData.write_lif(buffer,filePath)
		"LGT" : oWriteData.write_lgt(buffer)
		"WIB" : oWriteData.write_wib(buffer)
		"SLX" : oWriteData.write_slx(buffer)
		"WLB" : oWriteData.write_wlb(buffer)
		"TXT" : oWriteData.write_txt(buffer)
	
	var file = File.new()
	file.open(filePath,File.WRITE)
	file.store_buffer(buffer.data_array)
	file.close()
	print('.'+EXT+' wrote in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func file_path_to_buffer(filePath):
	var buffer = StreamPeerBuffer.new()
	var file = File.new()
	if file.open(filePath, File.READ) == OK:
		buffer.data_array = file.get_buffer(file.get_len())
		file.close()
	return buffer
