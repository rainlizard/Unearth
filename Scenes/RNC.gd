extends Node

var decompressorExeFullPath = ""

func _ready():
	set_decompressor_path()

func set_decompressor_path():
	var file = File.new()
	var path
	match OS.get_name():
		"Windows": path = Settings.unearthdata.plus_file("rnc-decompressor/dernc.exe")
		"X11":
			path = Settings.unearthdata.plus_file("rnc-decompressor/dernc.x86_64")
			# Checks in permissions: "Allow executing file as program"
			OS.execute("/bin/sh", ["-c", "chmod +x '" + path + "'"], true)
	
	if file.file_exists(path) == true:
		file.open(path,File.READ)
		decompressorExeFullPath = file.get_path_absolute()
		file.close()

func check_for_RNC_compression(path): # Check if the first 3 bytes are the letters "RNC" and the 4th byte is a "1".
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
	
	# Windows and Linux want different quotations for dernc
	# Linux dernc won't allow spaces in directory paths unless using the small quotation: '
	# Windows dernc only works with the big quotation: "
	
	var printOutput = []
	
	match OS.get_name():
		"Windows":
			var commands = ''
			commands += '"' + decompressorExeFullPath + '"'
			commands += ' '
			commands += '"' + path + '"'
			
			OS.execute("cmd", ["/C", commands], true, printOutput)
		"X11":
			var commands = ""
			commands += "'" + decompressorExeFullPath + "'"
			commands += " "
			commands += "'" + path + "'"
			
			# dernc.x86_64 file permissions must be set to "Allow executing file as program"
			OS.execute("/bin/sh", ["-c", commands], true, printOutput)
	
	print(printOutput)
