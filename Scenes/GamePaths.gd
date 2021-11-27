extends Node
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oRayCastBlockMap = Nodelist.list["oRayCastBlockMap"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oMessage = Nodelist.list["oMessage"]

var EXECUTABLE_PATH = ""
var SAVE_AS_DIRECTORY = ""
var GAME_DIRECTORY = ""
var DK_DATA_DIRECTORY = ""

#var nosound = true
#var cheats = true
#var gameSpeed = 25

var COMMAND_LINE = "-nointro -alex" # Default command line for everyone

func _input(event):
	if Input.is_action_just_pressed("SaveAndPlay"):
		menu_play_clicked()

func add_map_to_command_line():
	print(COMMAND_LINE)
	
	# Delete -level xxx and -campaign xxx from the command line
	var arrayOfWords = COMMAND_LINE.split(" ")
	for i in arrayOfWords.size():
		match arrayOfWords[i]:
			"-level":
				arrayOfWords[i] = ""
				if i+1 < arrayOfWords.size():
					arrayOfWords[i+1] = ""
			"-campaign":
				arrayOfWords[i] = ""
				if i+1 < arrayOfWords.size():
					arrayOfWords[i+1] = ""
	COMMAND_LINE = ""
	for word in arrayOfWords:
		if word != "":
			COMMAND_LINE += " " + word
	
	# Add level and campaign to command line
	
	var newMapNumber = oCurrentMap.path.get_file().to_upper().trim_prefix("MAP")
	var newCampaignName = oCurrentMap.path.get_base_dir().get_file()
	COMMAND_LINE += " -level " + newMapNumber
	if newCampaignName != "levels": # The older DK structure stored all their maps in /levels/ folder and did not use campaign command.
		COMMAND_LINE += " -campaign " + newCampaignName
	
	COMMAND_LINE = COMMAND_LINE.strip_edges(true,true)
	print(COMMAND_LINE)

func set_paths(path):
	if path == null: path = ""
	EXECUTABLE_PATH = path
	GAME_DIRECTORY = path.get_base_dir()
	
	for i in get_subdirs(GAME_DIRECTORY):
		if i.to_upper() == "DATA":
			DK_DATA_DIRECTORY = GAME_DIRECTORY.plus_file(i)

func set_SAVE_AS_DIRECTORY(path):
	if path == null: path = ""
	SAVE_AS_DIRECTORY = path

func menu_play_clicked():
	if oEditor.mapHasBeenEdited == true:
		oSaveMap.save_map(oCurrentMap.path)
	launch_game()

func launch_game():
	# Basic stuff to launch the executable properly
	var executeCmd = 'cd /D ' + '"' + GAME_DIRECTORY + '"' + " && " + EXECUTABLE_PATH.get_file() + ' '
	
	# Specific DK commands
	executeCmd += COMMAND_LINE
	
	OS.execute('cmd', ['/C', executeCmd], false)

func get_subdirs(path):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == true:
				array.append(fileName)
			fileName = dir.get_next()
	return array

func test_write_permissions():
	if EXECUTABLE_PATH == "": return OK # Don't provide an error when an executable hasn't even been set
	
	# Test write permissions of DK directory
	var testPath = EXECUTABLE_PATH.get_base_dir().plus_file('testing_write_permissions')
	
	var file = File.new()
	var err = file.open(testPath, File.WRITE)
	
	file.close()
	
	var removeFile = Directory.new()
	removeFile.remove(testPath) # Be careful with this
	
	if err != OK:
		oMessage.big("Error", "There are no write permissions for your Dungeon Keeper directory. Please exit the editor and move your entire Dungeon Keeper folder elsewhere, then choose the executable again.")
	
	return err

#
#	var arguments = ""
#	if cheats == true:
#		arguments += " -alex"
#	if nosound == true:
#		arguments += " -nosound"
#	arguments += " -fps " + str(gameSpeed)
#	arguments += " -nointro"
#	arguments += ' -level ' + levelNumber
#
#	var commands = ""
#	commands += 'cd /D ' + '"' + GAME_DIRECTORY + '"'
#	commands += " && "
#	commands += EXECUTABLE_PATH.get_file() + arguments
#
#	print(commands)
#	OS.execute('cmd', ['/C', commands], false)
	
	#OS.execute('cmd', ['/C', ], false)

#"-nointro -altinput -alex"
#F:\Games\Dungeon Keeper\

