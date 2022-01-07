extends Node

var dictionary = {} # Just two different ways to read the palette, for speed.

func read_palette(path):
	var array = []
	array.resize(256)
	
	var buffer = Filetypes.file_path_to_buffer(path)
	if buffer.get_size() > 0:
		for i in 256: # File has a size of 768 bytes but we get 3 values each loop
			# Multiply by 4 because colors are 0-63 instead of 0-255
			var R = buffer.get_u8()*4
			var G = buffer.get_u8()*4
			var B = buffer.get_u8()*4
			array[i] = Color8(R,G,B)
			dictionary[Color8(R,G,B)] = i
	else:
		print('No palette file found')
		return array
	return array





	
	
#	var save_file = File.new()
#	save_file.open("res://paletteReadableArray.txt", File.WRITE)
#	save_file.store_string(str(array))
#	save_file.close()
