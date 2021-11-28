extends Node

var decompressorExeFullPath = ""

func _ready():
	setDecompressorAbsolutePath()

func setDecompressorAbsolutePath():
	var file = File.new()
	var path
	match OS.get_name():
		"Windows": path = Settings.unearthdata.plus_file("rnc-decompressor/dernc.exe")
		"X11": path = Settings.unearthdata.plus_file("rnc-decompressor/dernc.x86_64")
	
	if file.file_exists(path) == true:
		file.open(path,File.READ)
		decompressorExeFullPath = file.get_path_absolute()
		file.close()

func checkForRncCompression(path): # Check if the first 3 bytes are the letters "RNC" and the 4th byte is a "1".
	var isCompressed = false
	
	var file = File.new()
	if file.open(path, File.READ) == OK:
		isCompressed = true
		file.seek(0)
		if file.get_8() != 82: isCompressed = false
		file.seek(1)
		if file.get_8() != 78: isCompressed = false
		file.seek(2)
		if file.get_8() != 67: isCompressed = false
		file.seek(3)
		if file.get_8() != 1: isCompressed = false
		file.close()
	
	return isCompressed

# Remember to be careful with file.open(path, File.READ) if calling decompress() from there it won't let you overwrite when decompressing.
func decompress(path):
	
	var commands = ""
	commands += '"' + decompressorExeFullPath + '"'
	commands += " "
	commands += '"' + path + '"'
	
	var printOutput = []
	
	match OS.get_name():
		"Windows":
			OS.execute("cmd", ["/C", commands], true, printOutput)
		"X11":
			# Warning: won't work on directories with spaces in them
			OS.execute("/bin/sh", ["-c", commands], true, printOutput)
	
	print(printOutput)
