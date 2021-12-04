extends WindowDialog
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oScriptNameLabel = Nodelist.list["oScriptNameLabel"]
onready var oBlueAICheckBox = Nodelist.list["oBlueAICheckBox"]
onready var oGreenAICheckBox = Nodelist.list["oGreenAICheckBox"]
onready var oYellowAICheckBox = Nodelist.list["oYellowAICheckBox"]
onready var oWhiteAICheckBox = Nodelist.list["oWhiteAICheckBox"]
onready var oPortalRateField = Nodelist.list["oPortalRateField"]
onready var oGoldField = Nodelist.list["oGoldField"]
onready var oMaxCreaturesField = Nodelist.list["oMaxCreaturesField"]

const disabled = Color(1,1,1,0.25)
const enabled = Color(1,1,1,1)

var scnGenericGridItem = preload('res://Scenes/AvailableButton.tscn')

func _on_EasyScriptWindow_about_to_show():
	reload_script_into_window()
	
	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER1"]) != -1:
		oBlueAICheckBox.pressed = true
	else:
		oBlueAICheckBox.pressed = false
	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER2"]) != -1:
		oGreenAICheckBox.pressed = true
	else:
		oGreenAICheckBox.pressed = false
	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER3"]) != -1:
		oYellowAICheckBox.pressed = true
	else:
		oYellowAICheckBox.pressed = false
	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER_GOOD"]) != -1:
		oWhiteAICheckBox.pressed = true
	else:
		oWhiteAICheckBox.pressed = false
	
	var lineNumber
	
	lineNumber = get_line_containing_text_entries(["SET_GENERATE_SPEED"])
	if lineNumber != -1:
		var lineString = oScriptTextEdit.get_line(lineNumber)
		oPortalRateField.text = get_value_inbetween_brackets(lineString, 0)
	
	lineNumber = get_line_containing_text_entries(["START_MONEY", "ALL_PLAYERS"])
	if lineNumber != -1:
		var lineString = oScriptTextEdit.get_line(lineNumber)
		oGoldField.text = get_value_inbetween_brackets(lineString, 1)
	
	lineNumber = get_line_containing_text_entries(["MAX_CREATURES", "ALL_PLAYERS"])
	if lineNumber != -1:
		var lineString = oScriptTextEdit.get_line(lineNumber)
		oMaxCreaturesField.text = get_value_inbetween_brackets(lineString, 1)

func _ready():
	yield(get_tree(),'idle_frame')
	Utils.popup_centered(self)
	create_room_icons()

func create_room_icons():
	for i in Slabs.roomMenuOrder.size():
		var slabID = Slabs.roomMenuOrder[i]
		if Slabs.icons.has(slabID):
			var btn = scnGenericGridItem.instance()
			btn.expand = false
			btn.texture_normal = Slabs.icons[slabID]
			btn.connect("pressed", self, "_on_available_button_pressed", [slabID, listRoom[i], btn])
			btn.connect("mouse_entered", self, "_on_available_button_mouse_entered", [slabID, listRoom[i], btn])
			btn.connect("mouse_exited", self, "_on_available_button_mouse_exited", [slabID, listRoom[i], btn])
			oRoomsAvailable.add_child(btn)

func _on_ScriptTextEdit_text_changed():
	oDataScript.data = oScriptTextEdit.text



func reload_script_into_window(): # Called from oDataScript
	oScriptTextEdit.text = oDataScript.data
	
	if oCurrentMap.currentFilePaths.has("TXT"):
		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
		oScriptNameLabel.visible = true
	else:
		oScriptNameLabel.text = ""
		oScriptNameLabel.visible = false

func _on_available_button_mouse_entered(slabID, functionInsert, btn):
	btn.get_node("ColorRect").color = Color("#383745").lightened(0.05)
	var foundLine = get_line_containing_text_entries(["ROOM_AVAILABLE", functionInsert])
	goto_line(foundLine)

func get_line_containing_text_entries(lookForArray):
	for lineNumber in oScriptTextEdit.get_line_count():
		# Begin by searching the TextEdit for the first entry of the array
		var lineString = oScriptTextEdit.get_line(lineNumber)
		if lookForArray[0].to_lower() in lineString.to_lower(): # not case-sensitive
			# Then search the line you found for every entry of the "lookForArray"
			var foundArrayEntries = 0
			for lookEntry in lookForArray:
				if lookEntry in lineString:
					foundArrayEntries += 1
			
			if foundArrayEntries == lookForArray.size():
				return lineNumber
	return -1

func goto_line(line):
	if line == -1:
		oScriptTextEdit.deselect()
		#line = 0
		return
	
	oScriptTextEdit.cursor_set_line(line)
	oScriptTextEdit.select(line, 0, line, oScriptTextEdit.get_line(line).length())
	oScriptTextEdit.center_viewport_to_cursor()
	oScriptTextEdit.release_focus()

func _on_available_button_mouse_exited(slabID, functionInsert, btn):
	btn.get_node("ColorRect").color = Color("#383745")




func _on_available_button_pressed(slabID, functionInsert, btn):
#	btn.modulate
#	var setTheValue
#	if btn.modulate == enabled:
#		btn.modulate = disabled
#		setTheValue = ",1,0)"
#	else:
#		btn.modulate = enabled
#		setTheValue = ",1,1)"
	var setTheValue = ",1,1)"
	place_text("ROOM_AVAILABLE(ALL_PLAYERS," + functionInsert + setTheValue)

func place_text(insertString):
	#oScriptTextEdit.cursor_set_line(lineNumber, txt)
	var lineNumber = oScriptTextEdit.cursor_get_line()
	var existingLineString = oScriptTextEdit.get_line(lineNumber)
	
	if oScriptTextEdit.get_line(lineNumber).length() > 0: #If line contains stuff
		oScriptTextEdit.set_line(lineNumber, existingLineString + '\n')
		oScriptTextEdit.set_line(lineNumber+1, insertString)
		
		oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()+1)
	else:
		oScriptTextEdit.set_line(lineNumber, insertString)
	oScriptTextEdit.update()

func _on_MaxCreaturesField_mouse_entered():
	var foundLine = get_line_containing_text_entries(["MAX_CREATURES", "ALL_PLAYERS"])
	goto_line(foundLine)

func _on_GoldField_mouse_entered():
	var foundLine = get_line_containing_text_entries(["START_MONEY", "ALL_PLAYERS"])
	goto_line(foundLine)

func _on_PortalRateField_mouse_entered():
	var foundLine = get_line_containing_text_entries(["SET_GENERATE_SPEED"])
	goto_line(foundLine)

func _on_BlueAICheckBox_mouse_entered():
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER1"])
	goto_line(foundLine)

func _on_GreenAICheckBox_mouse_entered():
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER2"])
	goto_line(foundLine)

func _on_YellowAICheckBox_mouse_entered():
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER3"])
	goto_line(foundLine)

func _on_WhiteAICheckBox_mouse_entered():
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER_GOOD"])
	goto_line(foundLine)

func _on_WinConditionCheckBox_mouse_entered():
	pass


func _on_BlueAICheckBox_toggled(button_pressed):
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER1"])
	if button_pressed == true:
		if foundLine == -1:
			goto_line(foundLine)
			place_text("COMPUTER_PLAYER(PLAYER1,0)")
	else:
		erase_entire_line(foundLine)


func _on_GreenAICheckBox_toggled(button_pressed):
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER2"])
	if button_pressed == true:
		if foundLine == -1:
			goto_line(foundLine)
			place_text("COMPUTER_PLAYER(PLAYER2,0)")
	else:
		erase_entire_line(foundLine)

func _on_YellowAICheckBox_toggled(button_pressed):
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER3"])
	if button_pressed == true:
		if foundLine == -1:
			goto_line(foundLine)
			place_text("COMPUTER_PLAYER(PLAYER3,0)")
	else:
		erase_entire_line(foundLine)

func _on_WhiteAICheckBox_toggled(button_pressed):
	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER_GOOD"])
	if button_pressed == true:
		if foundLine == -1:
			goto_line(foundLine)
			place_text("COMPUTER_PLAYER(PLAYER_GOOD,0)")
	else:
		erase_entire_line(foundLine)

func erase_entire_line(eraseLine):
	if eraseLine == -1:
		return
	
	goto_line(eraseLine)
	oScriptTextEdit.set_line(eraseLine,"")
	oScriptTextEdit.select(eraseLine, 0, eraseLine, oScriptTextEdit.get_line(eraseLine).length())
	oScriptTextEdit.cut()
	oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()-1)

func get_value_inbetween_brackets(string, argNumber):
	var bracketPositionBegin = string.find("(")
	string.erase(0, bracketPositionBegin+1)
	var bracketPositionEnd = string.find(")")
	string.erase(bracketPositionEnd, string.length())
	
	var array = string.split(",")
	return array[argNumber]

func set_value_inbetween_brackets(string, argNumber, setToValue):
	var firstThird = string.split("(")
	var lastThird = firstThird[1].split(")")
	var betweenBrackets = lastThird[0]
	
	var array = betweenBrackets.split(",")
	if argNumber < array.size():
		array[argNumber] = str(setToValue)
	else:
		print('Error: outside of array')
	
	betweenBrackets = ""
	for i in array.size():
		betweenBrackets += array[i]
		if i < array.size()-1:
			betweenBrackets += ','
	
	return firstThird[0] + "(" + betweenBrackets + ")" + lastThird[1]


func _on_PortalRateField_text_changed(new_text):
	edit_script_by_lineedit(new_text, ["SET_GENERATE_SPEED"], "SET_GENERATE_SPEED(400)", 0)
func _on_GoldField_text_changed(new_text):
	edit_script_by_lineedit(new_text, ["START_MONEY", "ALL_PLAYERS"], "START_MONEY(ALL_PLAYERS,2500)", 1)
func _on_MaxCreaturesField_text_changed(new_text):
	edit_script_by_lineedit(new_text, ["MAX_CREATURES", "ALL_PLAYERS"], "MAX_CREATURES(ALL_PLAYERS,25)", 1)

func edit_script_by_lineedit(new_text, lookForArray, generateText, slot):
	new_text = int(new_text)
	
	var foundLine = get_line_containing_text_entries(lookForArray)
	goto_line(foundLine)
	
	if foundLine == -1:
		var placeTxt = set_value_inbetween_brackets(generateText, slot, new_text)
		place_text(placeTxt)
	else:
		var existingLineString = oScriptTextEdit.get_line(foundLine)
		var placeTxt = set_value_inbetween_brackets(existingLineString, slot, new_text)
		oScriptTextEdit.set_line(foundLine, placeTxt)


var listCreature = [
"BILE_DEMON",
"BUG",
"DARK_MISTRESS",
"DEMONSPAWN",
"DRAGON",
"FLY",
"HELL_HOUND",
"ORC",
"SORCEROR",
"SPIDER",
"TENTACLE",
"TROLL",
"FLOATING_SPIRIT",
"GHOST",
"HORNY",
"IMP",
"REAPER",
"SKELETON",
"VAMPIRE",
"ARCHER",
"BARBARIAN",
"DWARFA",
"FAIRY",
"GIANT",
"KNIGHT",
"MONK",
"SAMURAI",
"THIEF",
"TUNNELLER",
"WITCH",
"WIZARD",
]
var listMagic = [
"POWER_HAND",
"POWER_SLAP",
"POWER_POSSESS",
"POWER_IMP",
"POWER_SIGHT",
"POWER_SPEED",
"POWER_OBEY",
"POWER_CALL_TO_ARMS",
"POWER_CONCEAL",
"POWER_HOLD_AUDIENCE",
"POWER_CAVE_IN",
"POWER_HEAL_CREATURE",
"POWER_LIGHTNING",
"POWER_PROTECT",
"POWER_CHICKEN",
"POWER_DISEASE",
"POWER_ARMAGEDDON",
"POWER_DESTROY_WALLS",
]
var listTrap = [
"ALARM",
"POISON_GAS",
"LIGHTNING",
"LAVA",
"BOULDER",
"WORD_OF_POWER",
]
var listDoor = [
"WOOD",
"BRACED",
"STEEL",
"MAGIC",
]
var listRoom = [
"TREASURE",
"LAIR",
"GARDEN",
"TRAINING",
"RESEARCH",
"BRIDGE",
"GUARD_POST",
"WORKSHOP",
"PRISON",
"TORTURE",
"BARRACKS",
"TEMPLE",
"GRAVEYARD",
"SCAVENGER",
]
