extends Node

func read_palette(path):
	var array = []
	array.resize(256)
	
	var file = File.new()
	if file.open(path, File.READ) == OK:
		for i in 256: # File is actually sized 768 but we get 3 values each loop
			# Multiply by 4 because colors are 0-63 instead of 0-255
			var R = file.get_8()*4
			var G = file.get_8()*4
			var B = file.get_8()*4
			array[i] = Color8(R,G,B)
	else:
		print("Failed to open file.")
	file.close()
	return array
