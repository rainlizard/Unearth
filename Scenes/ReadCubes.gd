extends Node
onready var oGame = Nodelist.list["oGame"]

var names = []

func _ready():
	while true:
		yield(get_tree(),'idle_frame')
		if Settings.haveInitializedAllSettings == true: break
	
	var path = oGame.get_precise_filepath(oGame.DK_FXDATA_DIRECTORY, "CUBES.CFG")
	if path == "":
		return
	
	var file = File.new()
	file.open(path, File.READ)
	
	var CODETIME_START = OS.get_ticks_msec()
	while true:
		var a = file.get_csv_line(" ")
		if a[0] == "Name":
			names.append(a[2].capitalize())#.to_lower().replace("_"," "))
		
		if file.eof_reached() == true:
			break
	
	file.close()
	print('Cube names read in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
