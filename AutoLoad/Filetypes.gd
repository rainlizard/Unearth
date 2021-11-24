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
#	"TXT" : ["read_txt", "write_txt"],
]

func read(filePath):
	var EXT = filePath.get_extension().to_upper()
	if Filetypes.FILE_TYPES.has(EXT) == false: return
	
	var file = File.new()
	if file.file_exists(filePath) == false:
		print("File not found : " + filePath)
		return
	
	print("Attempting to read : "+filePath)
	var CODETIME_START = OS.get_ticks_msec()
	var buffer = StreamPeerBuffer.new()
	file.open(filePath,File.READ)
	buffer.data_array = file.get_buffer(file.get_len())
	
#	buffer.seek(0)
#	print(buffer.get_32())
#	file.seek(0)
#	print(file.get_32())
	
	var oReadData = Nodelist.list["oReadData"]
	match EXT:
		"CLM" : oReadData.read_clm(buffer)
		"DAT" : oReadData.read_dat(buffer)
		"APT" : oReadData.read_apt(buffer)
		"TNG" : oReadData.read_tng(buffer)
		"INF" : oReadData.read_inf(buffer)
		"SLB" : oReadData.read_slb(buffer)
		"OWN" : oReadData.read_own(buffer)
		"LIF" : oReadData.read_lif(buffer,file)
		"LGT" : oReadData.read_lgt(buffer)
		"WIB" : oReadData.read_wib(buffer)
		"SLX" : oReadData.read_slx(buffer)
		"WLB" : oReadData.read_wlb(buffer)
		#"TXT" : oReadData.read_txt(buffer)
	file.close()
	print('.'+EXT+' read success in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


func write(filePath):
	var EXT = filePath.get_extension().to_upper()
	if Filetypes.FILE_TYPES.has(EXT) == false: return
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
		#"TXT" : oWriteData.write_txt(file)
	
	var file = File.new()
	file.open(filePath,File.WRITE)
	file.store_buffer(buffer.data_array)
	file.close()
	print('.'+EXT+' wrote in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
