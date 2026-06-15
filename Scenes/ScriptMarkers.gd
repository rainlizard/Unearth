extends Node2D
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

var SCRIPT_ICON_SIZE_MAX = 8 setget script_icon_size_max
var SCRIPT_ICON_SIZE_BASE = 0.5 setget script_icon_size_base

var scnScriptHelperObject = preload('res://Scenes/ScriptHelperObject.tscn')
var startQueued = false

enum {
	IS_TILE
	IS_SUBTILE
	IS_LOCATION
}

# [Command Name] [argument slot number] [Tile distance (96 = TILE, 32= SUBTILE)]]
var commandsWithPositions = [
	["IF_SLAB_OWNER", 0, IS_TILE],
	["IF_SLAB_TYPE", 0, IS_TILE],
	["CHANGE_SLAB_OWNER", 0, IS_TILE],
	["CHANGE_SLAB_TYPE", 0, IS_TILE],
	["SET_DOOR", 1, IS_TILE],
	["PLACE_DOOR", 2, IS_TILE],
	
	["REVEAL_MAP_RECT", 1, IS_SUBTILE],
	["CONCEAL_MAP_RECT", 1, IS_SUBTILE],
	["CREATE_EFFECT_AT_POS", 1, IS_SUBTILE],
	["USE_POWER_AT_POS", 1, IS_SUBTILE],
	["ADD_OBJECT_TO_LEVEL_AT_POS", 1, IS_SUBTILE],
	["DISPLAY_INFORMATION_WITH_POS", 1, IS_SUBTILE],
	["DISPLAY_OBJECTIVE_WITH_POS", 1, IS_SUBTILE],
	["DISPLAY_PLAYER_INFORMATION_WITH_POS", 2, IS_SUBTILE],
	["DISPLAY_PLAYER_OBJECTIVE_WITH_POS", 2, IS_SUBTILE],
	["QUICK_INFORMATION_WITH_POS", 2, IS_SUBTILE],
	["QUICK_OBJECTIVE_WITH_POS", 2, IS_SUBTILE],
	["QUICK_PLAYER_INFORMATION_WITH_POS", 3, IS_SUBTILE],
	["QUICK_PLAYER_OBJECTIVE_WITH_POS", 3, IS_SUBTILE],
	["PLACE_TRAP", 2, IS_SUBTILE],
	
	["CREATE_EFFECTS_LINE", 0, IS_LOCATION],
	["USE_POWER_AT_LOCATION", 1, IS_LOCATION],
	["COMPUTER_DIG_TO_LOCATION", 1, IS_LOCATION],
	["REVEAL_MAP_LOCATION", 1, IS_LOCATION],
	["HEART_LOST_OBJECTIVE", 1, IS_LOCATION],
	["CREATE_EFFECT", 1, IS_LOCATION],
	["ADD_OBJECT_TO_LEVEL", 1, IS_LOCATION],
	["DISPLAY_OBJECTIVE", 1, IS_LOCATION],
	["DISPLAY_INFORMATION", 1, IS_LOCATION],
	["HEART_LOST_QUICK_OBJECTIVE", 2, IS_LOCATION],
	["QUICK_OBJECTIVE", 2, IS_LOCATION],
	["QUICK_INFORMATION", 2, IS_LOCATION],
	
	# These original commands are "Action points", not locations. But it probably doesn't matter because a positive number is an action point.
	["RESET_ACTION_POINT", 0, IS_LOCATION],
	["IF_ACTION_POINT", 0, IS_LOCATION],
	["ADD_TUNNELLER_TO_LEVEL", 1, IS_LOCATION],
	["ADD_CREATURE_TO_LEVEL", 2, IS_LOCATION],
	["ADD_TUNNELLER_PARTY_TO_LEVEL", 2, IS_LOCATION],
	["ADD_PARTY_TO_LEVEL", 2, IS_LOCATION],
]

func start():
	if startQueued == true:
		return
	startQueued = true
	yield(get_tree(),'idle_frame') # This is necessary to fix an issue (with positions) when switching maps
	startQueued = false
	clear()
	
	var CODETIME_START = OS.get_ticks_msec()
	var scriptLines = oDataScript.data.split('\n',true)
	for lineNumber in scriptLines.size():
		var line = scriptLines[lineNumber]
		var parsedCommand = get_command_from_line(line)
		if parsedCommand.empty():
			continue
		
		var commandAttributes = get_position_command_attributes(parsedCommand["name"])
		if commandAttributes == null:
			continue

		var markerPosition = get_marker_position(parsedCommand["arguments"], commandAttributes)
		if markerPosition != null:
			create_helper_object(markerPosition.x, markerPosition.y, line, lineNumber+1)
	
	print('Script helpers created ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func clear():
	oCustomTooltip.set_text("") #Fixes an issue when deleting an action point while mouse is hovering a script helper
	
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		id.position = Vector2(-100,-100)
		id.queue_free()

func get_command_from_line(line):
	var trimmedLine = line.strip_edges(true, false)
	if trimmedLine.to_upper().begins_with("REM"):
		return {}

	var leftBracketPos = trimmedLine.find('(')
	if leftBracketPos == -1:
		return {}

	return {
		"name": trimmedLine.substr(0, leftBracketPos).strip_edges().to_upper(),
		"arguments": get_arguments_from_line(trimmedLine, leftBracketPos)
	}

func get_arguments_from_line(line, leftBracketPos):
	var argumentsArray = []
	var currentArgument = ""
	var insideQuotes = false
	var escaped = false
	for i in range(leftBracketPos+1, line.length()):
		var character = line.substr(i, 1)
		if character == '"' and escaped == false:
			insideQuotes = !insideQuotes
		if character == ',' and insideQuotes == false:
			argumentsArray.append(currentArgument.strip_edges())
			currentArgument = ""
		elif character == ')' and insideQuotes == false:
			argumentsArray.append(currentArgument.strip_edges())
			return argumentsArray # Note: this may return non-english characters depending on the script
		else:
			currentArgument += character
		escaped = character == "\\" and escaped == false

	return []

func get_position_command_attributes(commandName):
	for commandAttributes in commandsWithPositions:
		if commandAttributes[0] == commandName:
			return commandAttributes
	return null

func line_may_affect_position_markers(line):
	var parsedCommand = get_command_from_line(line)
	if parsedCommand.empty() == false:
		return get_position_command_attributes(parsedCommand["name"]) != null
	
	var upperLine = line.to_upper()
	for commandAttributes in commandsWithPositions:
		if commandAttributes[0] in upperLine:
			return true
	return false

func get_marker_position(argumentsArray, commandAttributes):
	var argNumber = commandAttributes[1]
	match commandAttributes[2]:
		IS_TILE:
			return get_coordinate_position(argumentsArray, argNumber, 96)
		IS_SUBTILE:
			return get_coordinate_position(argumentsArray, argNumber, 32)
		IS_LOCATION:
			return get_location_position(argumentsArray, argNumber)
	return null

func get_coordinate_position(argumentsArray, argNumber, tileDistance):
	var coordinateX = get_integer_argument(argumentsArray, argNumber)
	var coordinateY = get_integer_argument(argumentsArray, argNumber+1)
	if coordinateX == null or coordinateY == null:
		return null
	return Vector2((coordinateX*tileDistance) + (tileDistance*0.5), (coordinateY*tileDistance) + (tileDistance*0.5))

func get_location_position(argumentsArray, argNumber):
	if argumentsArray.size() <= argNumber:
		return null
	
	var locationArgument = argumentsArray[argNumber].strip_edges()
	# PLAYERx - zoom to player's dungeon heart
	var heartID = null
	if "PLAYER0" in locationArgument.to_upper(): heartID = oInstances.return_dungeon_heart(0)
	if "PLAYER1" in locationArgument.to_upper(): heartID = oInstances.return_dungeon_heart(1)
	if "PLAYER2" in locationArgument.to_upper(): heartID = oInstances.return_dungeon_heart(2)
	if "PLAYER3" in locationArgument.to_upper(): heartID = oInstances.return_dungeon_heart(3)
	if "PLAYER_GOOD" in locationArgument.to_upper(): heartID = oInstances.return_dungeon_heart(4)
	if is_instance_valid(heartID):
		return heartID.position
	
	var location = get_integer_argument(argumentsArray, argNumber)
	if location == null:
		return null
	match int(sign(location)): # int() required for 'match' to work for negative integers
		1: # Positive integer - zoom to Action Point of given number
			var actionPointID = oInstances.return_action_point(location)
			if is_instance_valid(actionPointID):
				return actionPointID.position
		-1: # Negative integer - zoom to Hero Gate of given number
			var heroGateID = oInstances.return_hero_gate(abs(location))
			if is_instance_valid(heroGateID):
				return heroGateID.position
	return null

func get_integer_argument(argumentsArray, argNumber):
	if argumentsArray.size() <= argNumber:
		return null
	
	var argument = argumentsArray[argNumber].strip_edges()
	if argument.is_valid_integer() == false:
		return null
	return int(argument)

func create_helper_object(x,y,line,lineNumber):
	
	var newString = 'Line ' + str(lineNumber) + ': ' + line
	
	# Merge with existing if there's already a ScriptHelperObject at that position
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		if id.position == Vector2(x,y):
			var constructString = id.get_meta('line') + '\n' + newString
			id.set_meta('line', constructString)
			return
	
	# Create new
	var id = scnScriptHelperObject.instance()
	id.position = Vector2(x, y)
	id.set_meta('line', newString)
	add_child(id)

func script_icon_size_max(setVal):
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		id._on_zoom_level_changed(oCamera2D.zoom)
	SCRIPT_ICON_SIZE_MAX = setVal
func script_icon_size_base(setVal):
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		id._on_zoom_level_changed(oCamera2D.zoom)
	SCRIPT_ICON_SIZE_BASE = setVal


func update_action_point_markers(actionPointInstance):
	if is_instance_valid(actionPointInstance) == false:
		return
	start()
