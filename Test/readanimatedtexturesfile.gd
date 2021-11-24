extends Node2D

func _ready():
	var array = []
	var file = File.new()
	file.open("res://tmapanimDECOMPRESSED.dat",File.READ)
	
	var dataWidth = 1000 # ???
	for i in dataWidth:
		file.seek(i*2)
		var value = file.get_16()
		array.append(value)
	
	save_text_file(str(array), "res://animbytelist.txt")


func save_text_file(text, path):
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		printerr("Could not write file, error code ", err)
		return
	f.store_string(text)
	f.close()
