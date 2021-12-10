extends Node

var dictionary = {} # Just two different ways to read the palette, for speed.

func read_palette(path):
	var array = []
	array.resize(256)
	
	var file = File.new()
	if file.open(path, File.READ) == OK:
		for i in 256: # File has a size of 768 bytes but we get 3 values each loop
			# Multiply by 4 because colors are 0-63 instead of 0-255
			var R = file.get_8()*4
			var G = file.get_8()*4
			var B = file.get_8()*4
			array[i] = Color8(R,G,B)
			dictionary[Color8(R,G,B)] = i
	else:
		print("Failed to open file.")
	file.close()
	
	
#	var save_file = File.new()
#	save_file.open("res://paletteReadableArray.txt", File.WRITE)
#	save_file.store_string(str(array))
#	save_file.close()
	
	return array
