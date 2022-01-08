extends Node2D
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCamera2D = Nodelist.list["oCamera2D"]

var SCRIPT_ICON_SIZE_MAX = 8 setget script_icon_size_max
var SCRIPT_ICON_SIZE_BASE = 0.5 setget script_icon_size_base

var scnScriptHelperObject = preload('res://Scenes/ScriptHelperObject.tscn')

var commandsTileCoords = [
"IF_SLAB_OWNER", #(x,y)  (tiles)
"CHANGE_SLAB_OWNER", #(x,y)  (tiles)
"CHANGE_SLAB_TYPE", #(x,y)  (tiles)
]
var commandsSubtileCoords = [
"REVEAL_MAP_RECT", #(player,x,y)  (subtiles)
"CONCEAL_MAP_RECT", #(player,x,y)  (subtiles)
"CREATE_EFFECT_AT_POS", #(effect,x,y)  (subtiles)
"USE_POWER_AT_POS", #(player,x,y)  (subtiles)
]

func start():
	clear()
	
	var CODETIME_START = OS.get_ticks_msec()
	var scriptLines = oDataScript.data.split('\n',true)
	for lineNumber in scriptLines.size():
		var line = scriptLines[lineNumber]
		
		for i in commandsTileCoords.size():
			if commandsTileCoords[i] + '(' in line.to_upper():
				var argumentsArray = get_arguments_from_line(line)
				if argumentsArray.size() >= 2:
					var x = (int(argumentsArray[0])*96) + 48
					var y = (int(argumentsArray[1])*96) + 48
					create_helper_object(x, y, line, lineNumber+1)
		
		for i in commandsSubtileCoords.size():
			if commandsSubtileCoords[i] + '(' in line.to_upper():
				var argumentsArray = get_arguments_from_line(line)
				if argumentsArray.size() >= 3:
					var x = (int(argumentsArray[1])*32) + 16
					var y = (int(argumentsArray[2])*32) + 16
					create_helper_object(x, y, line, lineNumber+1)
	
	print('Script helpers created ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func clear():
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
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
	#print(argumentsArray)
	var id = scnScriptHelperObject.instance()
	id.position = Vector2(x, y)
	#print(x)
	#print(y)
	id.set_meta('line', line + '\nLine ' + str(lineNumber)+'')
	add_child(id)

func script_icon_size_max(setVal):
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		id._on_zoom_level_changed(oCamera2D.zoom)
	SCRIPT_ICON_SIZE_MAX = setVal
func script_icon_size_base(setVal):
	for id in get_tree().get_nodes_in_group("ScriptHelperObject"):
		id._on_zoom_level_changed(oCamera2D.zoom)
	SCRIPT_ICON_SIZE_BASE = setVal
