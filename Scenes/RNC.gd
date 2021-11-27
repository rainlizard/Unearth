extends Node

var decompressorExeFullPath = ""

func _ready():
	setDecompressorAbsolutePath()
#	var inputFile = File.new()
#	inputFile.open("res://unearthdata/TMAPA000.DAT",File.READ)
#	var inData = inputFile.get_buffer(inputFile.get_len())
#	inputFile.close()
#
#	var outputFile = File.new()
#	outputFile.open("res://unearthdata/TMAPA0000.DAT",File.WRITE)
#	var outData = outputFile.get_buffer(outputFile.get_len())
#	outputFile.close()
#
#
#	#inputFile.get_buffer
#
#	#var aaa = oCSHARPRNC.ReadRnc(inputFile.get_as_text(),outputFile.get_as_text())
##	print('blah')
#	var aaa = oCSHARPRNC.ReadRnc(inData,outData) #inputBuffer #outputBuffer
#	print('done')
#
#	print(aaa)
#	print(aaa)
	

func setDecompressorAbsolutePath():
	var file = File.new()
	var path
	match OS.get_name():
		"Windows": path = Settings.unearthdata.plus_file("rnc-decompressor/dernc.exe")
		"X11": path = Settings.unearthdata.plus_file("rnc-decompressor/dernc.x86_64")
	
	#var path = Settings.unearthdata.plus_file("rnc-decompressor/ancient.exe")
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
func decompress(input_path, output_path):
	
	var commands = ""
	commands += '"' + decompressorExeFullPath + '" '
	commands += '-o ' # dernc
	#commands += 'decompress ' # ancient
	commands += '"' + input_path + '" '
	commands += '"' + output_path + '"'
	
	print(commands)
	
	OS.execute("cmd", ["/C", commands], true)
	
	# Renaming to lowercase looks a bit messy anyway.
	# To make the file lowercase, it must be renamed to a new file
	#dir.rename(output_path, output_path.to_lower()+'tmp')
	#dir.rename(output_path+'tmp', output_path.to_lower())
