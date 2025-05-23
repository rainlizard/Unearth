extends Node2D
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

var SCRIPT_ICON_SIZE_MAX = 8 setget script_icon_size_max
var SCRIPT_ICON_SIZE_BASE = 0.5 setget script_icon_size_base

var scnScriptHelperObject = preload('res://Scenes/ScriptHelperObject.tscn')

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
	["QUICK_INFORMATION_WITH_POS", 2, IS_SUBTILE],
	["QUICK_OBJECTIVE_WITH_POS", 2, IS_SUBTILE],
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
	yield(get_tree(),'idle_frame') # This is necessary to fix an issue (with positions) when switching maps
	clear()
	
	var CODETIME_START = OS.get_ticks_msec()
	var scriptLines = oDataScript.data.split('\n',true)
	for lineNumber in scriptLines.size():
		var line = scriptLines[lineNumber]
		
		# Ignore commented lines (REM)
		if line.to_upper().strip_edges(true,true).begins_with("REM") == false:
			for commandAttributes in commandsWithPositions:
				var cmdName = commandAttributes[0]
				var argNumber = commandAttributes[1]
				var positionType = commandAttributes[2]
				
				if cmdName + '(' in line.to_upper():
					var argumentsArray = get_arguments_from_line(line)
					var x = null
					var y = null
					match positionType:
						IS_TILE:
							var tileDistance = 96
							if argumentsArray.size() > argNumber:
								x = (int(argumentsArray[argNumber])*tileDistance) + (tileDistance*0.5)
							if argumentsArray.size() > argNumber+1:
								y = (int(argumentsArray[argNumber+1])*tileDistance) + (tileDistance*0.5)
						IS_SUBTILE:
							var tileDistance = 32
							if argumentsArray.size() > argNumber:
								x = (int(argumentsArray[argNumber])*tileDistance) + (tileDistance*0.5)
							if argumentsArray.size() > argNumber+1:
								y = (int(argumentsArray[argNumber+1])*tileDistance) + (tileDistance*0.5)
						IS_LOCATION:
							if argumentsArray.size() > argNumber:
								# PLAYERx - zoom to player's dungeon heart
								var heartID = null
								if "PLAYER0" in argumentsArray[argNumber].to_upper(): heartID = oInstances.return_dungeon_heart(0)
								if "PLAYER1" in argumentsArray[argNumber].to_upper(): heartID = oInstances.return_dungeon_heart(1)
								if "PLAYER2" in argumentsArray[argNumber].to_upper(): heartID = oInstances.return_dungeon_heart(2)
								if "PLAYER3" in argumentsArray[argNumber].to_upper(): heartID = oInstances.return_dungeon_heart(3)
								if "PLAYER_GOOD" in argumentsArray[argNumber].to_upper(): heartID = oInstances.return_dungeon_heart(4)
								if is_instance_valid(heartID):
									x = heartID.position.x
									y = heartID.position.y
								else:
									var positiveOrNegative = sign(float(argumentsArray[argNumber]))
									match int(positiveOrNegative): # int() required for 'match' to work for negative integers
										1: # Positive integer - zoom to Action Point of given number
											var actionPointID = oInstances.return_action_point(int(argumentsArray[argNumber]))
											if is_instance_valid(actionPointID):
												x = actionPointID.position.x
												y = actionPointID.position.y
										-1: # Negative integer - zoom to Hero Gate of given number
											var heroGateID = oInstances.return_hero_gate(abs(int(argumentsArray[argNumber])))
											if is_instance_valid(heroGateID):
												x = heroGateID.position.x
												y = heroGateID.position.y
					
					if x != null and y != null:
						create_helper_object(x, y, line, lineNumber+1)
	
	print('Script helpers created ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func clear():
	oCustomTooltip.set_text("") #Fixes an issue when deleting an action point while mouse is hovering a script helper
	
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		id.position = Vector2(-100,-100)
		id.queue_free()

func get_arguments_from_line(line):
	var leftBracketPos = line.find('(')
	if leftBracketPos == -1: return []
	
	var lineArgumentsOnly = line
	lineArgumentsOnly.erase(0,leftBracketPos+1) #include erasing bracket
	var rightBracketPos = lineArgumentsOnly.find(')')
	if rightBracketPos == -1: return []
	lineArgumentsOnly.erase(rightBracketPos,lineArgumentsOnly.length())
	
	lineArgumentsOnly = Array(lineArgumentsOnly.split(',',false))
	
	return lineArgumentsOnly # Note: this may return non-english characters depending on the script

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
