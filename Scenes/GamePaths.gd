extends Node
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oRayCastBlockMap = Nodelist.list["oRayCastBlockMap"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCmdLineConsole = Nodelist.list["oCmdLineConsole"]
onready var oCmdLineConsoleArg = Nodelist.list["oCmdLineConsoleArg"]
onready var oCmdLineExecute = Nodelist.list["oCmdLineExecute"]
onready var oKeeperFXDetection = Nodelist.list["oKeeperFXDetection"]

var EXECUTABLE_PATH = ""
var GAME_DIRECTORY = ""
var DK_DATA_DIRECTORY = ""
var DK_FXDATA_DIRECTORY = ""
var DK_LEVELS_DIRECTORY = ""
var DK_CAMPGNS_DIRECTORY = ""
var KEEPERFX_VERSION_INT = 0 # This is set in set_paths() when EXECUTABLE_PATH is set.
var KEEPERFX_VERSION_STRING = "0"
const KEEPERFX_VERSION_REQUIRED_INT = 0503372
#var nosound = true
#var cheats = true
#var gameSpeed = 25

var COMMAND_LINE = ""
var COMMAND_LINE_CONSOLE = ""
var COMMAND_LINE_CONSOLE_ARG = ""
var DK_COMMANDS = "-nointro -alex -nocd"

func running_keeperfx():
	if EXECUTABLE_PATH.get_file().to_lower() == "keeperfx.exe":
		return true
	else:
		return false

func _input(event):
	if Input.is_action_just_pressed("SaveAndPlay"):
		menu_play_clicked()

func launch_game(mainCommands):
	var printOutput = []
	OS.execute(COMMAND_LINE_CONSOLE, [COMMAND_LINE_CONSOLE_ARG, mainCommands], false, printOutput) # Make sure "false" is set so Unearth doesn't freeze
	print(printOutput)
	oMessage.quick("Launching...")


func set_paths(path):
	if path == null: path = ""
	EXECUTABLE_PATH = path
	GAME_DIRECTORY = path.get_base_dir()
	set_keeperfx_version()
	
	for i in get_main_subdirectories(GAME_DIRECTORY): # Directories only
		match i.to_upper():
			"DATA": DK_DATA_DIRECTORY = GAME_DIRECTORY.plus_file(i)
			"FXDATA": DK_FXDATA_DIRECTORY = GAME_DIRECTORY.plus_file(i)
			"LEVELS": DK_LEVELS_DIRECTORY = GAME_DIRECTORY.plus_file(i)
			"CAMPGNS": DK_CAMPGNS_DIRECTORY = GAME_DIRECTORY.plus_file(i)
	
	if running_keeperfx() == true:
		oKeeperFXDetection.text = "KeeperFX detected. " + "(Version " + KEEPERFX_VERSION_STRING + ")"
		oKeeperFXDetection.set("custom_colors/font_color", Color(0.5,1.0,0.5,1))
		oKeeperFXDetection.visible = true
	else:
		oKeeperFXDetection.text = "KeeperFX not detected"
		oKeeperFXDetection.set("custom_colors/font_color", Color(1.0,0.5,0.5,1))
		oKeeperFXDetection.visible = true
	reconstruct_command_line()

func _on_CmdLineDkCommands_text_changed(new_text):
	Settings.set_setting("dk_commands", new_text)
	reconstruct_command_line()

func reconstruct_command_line():
	print('Constructing command line...')
	# Keep in mind Linux and Windows both want different quotation marks ' "
	match OS.get_name():
		"Windows":
			COMMAND_LINE_CONSOLE = 'cmd'
			COMMAND_LINE_CONSOLE_ARG = '/C'
		"X11":
			COMMAND_LINE_CONSOLE = "/bin/sh"
			COMMAND_LINE_CONSOLE_ARG = "-c"
	oCmdLineConsole.text = COMMAND_LINE_CONSOLE
	oCmdLineConsoleArg.text = COMMAND_LINE_CONSOLE_ARG
	
	COMMAND_LINE = cmdline(oCurrentMap.path)
	oCmdLineExecute.text = COMMAND_LINE

func cmdline(mapPath):
	# Keep in mind Linux and Windows both want different quotation marks ' "
	var constructString = ""
	match OS.get_name():
		"Windows":
			constructString += 'cd /D '
			constructString += '"' + GAME_DIRECTORY + '"'
			constructString += ' && '
			constructString += '"' + EXECUTABLE_PATH.get_file() + '"'
		"X11":
			constructString += "cd "
			constructString += "'" + GAME_DIRECTORY + "'"
			constructString += " && wine "
			constructString += "'" + EXECUTABLE_PATH.get_file() + "'"
	
	# Delete -level xxx and -campaign xxx from the command line
	var arrayOfWords = constructString.split(" ")
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
	constructString = ""
	for word in arrayOfWords:
		if word != "":
			constructString += " " + word
	
	# Add level and campaign to command line
	
	var newMapNumber = mapPath.get_file().to_upper().trim_prefix("MAP")
	var newCampaignName = mapPath.get_base_dir().get_file()
	constructString += " -level " + newMapNumber
	if newCampaignName != "levels": # The older DK structure stored all their maps in /levels/ folder and did not use campaign command.
		constructString += " -campaign " + newCampaignName
	
	constructString = constructString.strip_edges(true,true)
	
	if DK_COMMANDS != '':
		constructString += ' '
	constructString += DK_COMMANDS
	
	return constructString

func menu_play_clicked():
	if oEditor.mapHasBeenEdited == true:
		oSaveMap.save_map(oCurrentMap.path)
	launch_game(COMMAND_LINE)

func get_main_subdirectories(path):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == true:
				array.append(fileName)
			fileName = dir.get_next()
	return array

func test_write_permissions():
	
	# Test write permissions of DK directory
	var testPath = EXECUTABLE_PATH.get_base_dir().plus_file('testing_write_permissions.test')
	
	print(testPath)
	
	var file = File.new()
	var err = file.open(testPath, File.WRITE)
	file.close()
	
	var dir = Directory.new()
	if dir.file_exists(testPath) == true: # Ensure any files being removed are definitely files and never directories
		dir.remove(testPath)
	
	if err != OK:
		if OS.get_name() == "X11":
			oMessage.big("Error", "There are no write permissions for your Dungeon Keeper directory.")
		if OS.get_name() == "Windows":
			oMessage.big("Error", "There are no write permissions for your Dungeon Keeper directory. Maybe try moving your Dungeon Keeper folder elsewhere, then choose the executable again.")
	return err

func get_precise_filepath(lookInDirectory, lookForFileName):
	var dir = Directory.new()
	if dir.open(lookInDirectory) == OK:
		dir.list_dir_begin(true, false)
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == false:
				if fileName.to_upper() == lookForFileName.to_upper(): # Get file regardless of case (case insensitive)
					return lookInDirectory.plus_file(fileName)
			fileName = dir.get_next()
	return ""

func set_keeperfx_version():
	var output = []
	var getVer = Settings.unearthdata.plus_file("GetVersion.cmd")
	var _exit_code = OS.execute(getVer, [EXECUTABLE_PATH], true, output)
	if output.size() == 1:
		KEEPERFX_VERSION_STRING = output[0].strip_edges()
		KEEPERFX_VERSION_INT = int(KEEPERFX_VERSION_STRING.replace(".",""))
	else:
		KEEPERFX_VERSION_STRING = "Undetected"
		KEEPERFX_VERSION_INT = 0

#func load_command_line_from_settings(COMMAND_LINE):
#	COMMAND_LINE = COMMAND_LINE.replace("%DIR%", GAME_DIRECTORY)
#	COMMAND_LINE = COMMAND_LINE.replace("%EXE%", EXECUTABLE_PATH.get_file())
#
#func EDITED_COMMAND_LINE(lineEditText):
#	COMMAND_LINE = lineEditText.replace(GAME_DIRECTORY, "%DIR%")
#	COMMAND_LINE = lineEditText.replace(EXECUTABLE_PATH.get_file(), "%EXE%")
#	Settings.set_setting("play_command_line", COMMAND_LINE)


#func EDIT_COMMAND_LINE():

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



