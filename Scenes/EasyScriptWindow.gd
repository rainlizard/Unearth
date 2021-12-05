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
onready var oPortalRateInSeconds = Nodelist.list["oPortalRateInSeconds"]
onready var oWinConditionCheckBox = Nodelist.list["oWinConditionCheckBox"]
onready var oClearExistingScriptCheckBox = Nodelist.list["oClearExistingScriptCheckBox"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCreaturePool = Nodelist.list["oCreaturePool"]
onready var oTrapsAvailable = Nodelist.list["oTrapsAvailable"]
onready var oMagicAvailable = Nodelist.list["oMagicAvailable"]
onready var oDoorsAvailable = Nodelist.list["oDoorsAvailable"]
onready var oMessage = Nodelist.list["oMessage"]

var scnAvailableButton = preload('res://Scenes/AvailableButton.tscn')

func _ready():
	initialize_rooms_available()
	initialize_creatures_available()
	initialize_traps_available()
	initialize_magic_available()
	initialize_doors_available()

func initialize_rooms_available():
	for i in listRoom:
		var slabID = i[0]# listRoom[] #Slabs.roomMenuOrder[i]
		var functionVariable = i[1]
		var defaultValue = i[2]
		
		if Slabs.icons.has(slabID):
			var id = scnAvailableButton.instance()
			id.hint_tooltip = Slabs.data[slabID][Slabs.NAME]
			id.get_node("TextureRect").texture = Slabs.icons[slabID]
			id.set_meta("variable", functionVariable)
			
			id.get_node("Label").visible = true
			id.get_node("LineEdit").visible = false
			
			if defaultValue == 1:
				id.set_availability_state(id.OPTION_START)
			else:
				id.set_availability_state(id.OPTION_RESEARCH)
			
			oRoomsAvailable.add_child(id)

func initialize_creatures_available(): # oCreaturePool
	for i in listCreature:
		var thingID = i[0]
		var functionVariable = i[1]
		var defaultValue = i[2]
		var id = scnAvailableButton.instance()
		id.hint_tooltip = Things.DATA_CREATURE[thingID][Things.NAME]
		id.get_node("TextureRect").texture = Things.DATA_CREATURE[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		id.get_node("Label").visible = false
		id.get_node("LineEdit").visible = true
		id.get_node("LineEdit").text = str(defaultValue)
		id._on_LineEdit_text_changed(str(defaultValue)) # To initialize the darkening
		oCreaturePool.add_child(id)

func initialize_traps_available(): # oTrapsAvailable
	for i in listTrap:
		var thingID = i[0]
		var functionVariable = i[1]
		var defaultValue = i[2]
		var id = scnAvailableButton.instance()
		id.hint_tooltip = Things.DATA_TRAP[thingID][Things.NAME]
		id.get_node("TextureRect").texture = Things.DATA_TRAP[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		
		id.get_node("Label").visible = true
		id.get_node("LineEdit").visible = false
		
		if defaultValue == 1:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		oTrapsAvailable.add_child(id)

func initialize_magic_available(): # oMagicAvailable
	for i in listMagic:
		var thingID = i[0]
		var functionVariable = i[1]
		var defaultValue = i[2]
		var id = scnAvailableButton.instance()
		id.hint_tooltip = Things.DATA_OBJECT[thingID][Things.NAME]
		id.get_node("TextureRect").texture = Things.DATA_OBJECT[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		
		id.get_node("Label").visible = true
		id.get_node("LineEdit").visible = false
		
		if defaultValue == 1:
			id.set_availability_state(id.OPTION_START)
		else:
			id.set_availability_state(id.OPTION_RESEARCH)
		
		oMagicAvailable.add_child(id)

func initialize_doors_available(): # oDoorsAvailable
	for i in listDoor:
		var thingID = i[0]
		var functionVariable = i[1]
		var defaultValue = i[2]
		var id = scnAvailableButton.instance()
		id.hint_tooltip = Things.DATA_DOOR[thingID][Things.NAME]
		id.get_node("TextureRect").texture = Things.DATA_DOOR[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		
		id.get_node("Label").visible = true
		id.get_node("LineEdit").visible = false
		
		if defaultValue == 1:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		oDoorsAvailable.add_child(id)


func _on_ScriptGeneratorWindow_about_to_show():
	reload_script_into_window()
	_on_PortalRateField_text_changed("400") # to updatate the "in seconds" text


func reload_script_into_window(): # Called from oDataScript
	oScriptTextEdit.text = oDataScript.data
	
	if oCurrentMap.currentFilePaths.has("TXT"):
		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
	else:
		oScriptNameLabel.text = "No script file loaded"

func _on_ScriptTextEdit_text_changed():
	oEditor.mapHasBeenEdited = true
	oDataScript.data = oScriptTextEdit.text


func _on_PortalRateField_text_changed(new_text):
	var rateInSeconds = float(int(new_text)/20.0)
	oPortalRateInSeconds.text = '('+str(rateInSeconds) + " sec)"


func _on_GenerateScriptButton_pressed():
	if oClearExistingScriptCheckBox.pressed == true:
		oScriptTextEdit.text = ""
	
	var generateString = ""
	generateString += "SET_GENERATE_SPEED("+str(int(oPortalRateField.text))+")" + '\n'
	generateString += "START_MONEY(ALL_PLAYERS,"+str(int(oGoldField.text))+")" + '\n'
	generateString += "MAX_CREATURES(ALL_PLAYERS,"+str(int(oMaxCreaturesField.text))+")" + '\n'
	
	generateString += '\n'
	
	if oBlueAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER1,0)" + '\n'
	if oGreenAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER2,0)" + '\n'
	if oYellowAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER3,0)" + '\n'
	if oWhiteAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER_GOOD,0)" + '\n'
	
	generateString += '\n'
	
	for i in oCreaturePool.get_children():
		var variableName = i.get_meta("variable")
		if i.get_integer() > 0:
			generateString += "ADD_CREATURE_TO_POOL(ALL_PLAYERS," + variableName + "," + str(i.get_integer()) + ")" + '\n'
	
	generateString += '\n'
	
	for i in oCreaturePool.get_children():
		var variableName = i.get_meta("variable")
		if i.get_integer() > 0:
			generateString += "CREATURE_AVAILABLE(ALL_PLAYERS," + variableName + ",1,1)" + '\n'
	
	generateString += '\n'
	
	for i in oRoomsAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.OPTION_START:    generateString += "ROOM_AVAILABLE(ALL_PLAYERS," + variableName + ",1,1)" + '\n'
			i.OPTION_RESEARCH: generateString += "ROOM_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString += '\n'
	
	
	for i in oMagicAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.OPTION_START:    generateString += "MAGIC_AVAILABLE(ALL_PLAYERS," + variableName + ",1,1)" + '\n'
			i.OPTION_RESEARCH: generateString += "MAGIC_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString += '\n'
	
	for i in oTrapsAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.ENABLED: generateString += "TRAP_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString += '\n'
	
	for i in oDoorsAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.ENABLED: generateString += "DOOR_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString += '\n'
	
	if oWinConditionCheckBox.pressed == true:
		generateString += "IF(PLAYER0,ALL_DUNGEONS_DESTROYED == 1)" + '\n'
		generateString += "	WIN_GAME" + '\n'
		generateString += "ENDIF" + '\n'
	
	var lineNumber = oScriptTextEdit.cursor_get_line()
	
	place_text(generateString) # This also calls "_on_ScriptTextEdit_text_changed" because it changes the text

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

var listCreature = [
[19, "FLY", 20],
[24, "BUG", 20],
[18, "DEMONSPAWN", 20],
[16, "TROLL", 20],
[26, "SPIDER", 20],
[27, "HELL_HOUND", 20],
[29, "TENTACLE", 20],
[21, "SORCEROR", 20],
[30, "ORC", 20],
[22, "BILE_DEMON", 20],
[17, "DRAGON", 20],
[20, "DARK_MISTRESS", 20],
[28, "GHOST", 0],
[15, "SKELETON", 0],
[25, "VAMPIRE", 0],
[14, "HORNY", 0],
[23, "IMP", 0],
[31, "FLOATING_SPIRIT", 0],
[12, "THIEF", 0],
[8, "TUNNELLER", 0],
[5, "DWARFA", 0],
[3, "ARCHER", 0],
[2, "BARBARIAN", 0],
[4, "MONK", 0],
[11, "FAIRY", 0],
[9, "WITCH", 0],
[1, "WIZARD", 0],
[10, "GIANT", 0],
[13, "SAMURAI", 0],
[6, "KNIGHT", 0],
[7, "AVATAR", 0],
]

var listMagic = [
[11, "POWER_HAND", 1],
[14, "POWER_SLAP", 1],
[135, "POWER_POSSESS", 1],
[12, "POWER_IMP", 1],
[15, "POWER_SIGHT", 0],
[21, "POWER_SPEED", 0],
[13, "POWER_OBEY", 0],
[16, "POWER_CALL_TO_ARMS", 0],
[23, "POWER_CONCEAL", 0],
[19, "POWER_HOLD_AUDIENCE", 0],
[17, "POWER_CAVE_IN", 0],
[18, "POWER_HEAL_CREATURE", 0],
[20, "POWER_LIGHTNING", 0],
[22, "POWER_PROTECT", 0],
[46, "POWER_CHICKEN", 0],
[45, "POWER_DISEASE", 0],
[134, "POWER_ARMAGEDDON", 0],
[47, "POWER_DESTROY_WALLS", 0],
]

var listTrap = [
[2, "ALARM", 1],
[3, "POISON_GAS", 1],
[4, "LIGHTNING", 1],
[6, "LAVA", 1],
[1, "BOULDER", 1],
[5, "WORD_OF_POWER", 1],
]
var listDoor = [
[1, "WOOD", 1],
[2, "BRACED", 1],
[3, "STEEL", 1],
[4, "MAGIC", 1],
]
var listRoom = [
[Slabs.TREASURE_ROOM, "TREASURE", 1],
[Slabs.LAIR, "LAIR", 1],
[Slabs.HATCHERY, "GARDEN", 1],
[Slabs.TRAINING_ROOM, "TRAINING", 1],
[Slabs.LIBRARY, "RESEARCH", 1],
[Slabs.BRIDGE, "BRIDGE", 0],
[Slabs.GUARD_POST, "GUARD_POST", 0],
[Slabs.WORKSHOP, "WORKSHOP", 0],
[Slabs.PRISON, "PRISON", 0],
[Slabs.TORTURE_CHAMBER, "TORTURE", 0],
[Slabs.BARRACKS, "BARRACKS", 0],
[Slabs.TEMPLE, "TEMPLE", 0],
[Slabs.GRAVEYARD, "GRAVEYARD", 0],
[Slabs.SCAVENGER_ROOM, "SCAVENGER", 0],
]

#const disabled = Color(1,1,1,0.25)
#const enabled = Color(1,1,1,1)
#
#var scnGenericGridItem = preload('res://Scenes/AvailableButton.tscn')
#
#func _on_ScriptGeneratorWindow_about_to_show():
#	reload_script_into_window()
#
#	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER1"]) != -1:
#		oBlueAICheckBox.pressed = true
#	else:
#		oBlueAICheckBox.pressed = false
#	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER2"]) != -1:
#		oGreenAICheckBox.pressed = true
#	else:
#		oGreenAICheckBox.pressed = false
#	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER3"]) != -1:
#		oYellowAICheckBox.pressed = true
#	else:
#		oYellowAICheckBox.pressed = false
#	if get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER_GOOD"]) != -1:
#		oWhiteAICheckBox.pressed = true
#	else:
#		oWhiteAICheckBox.pressed = false
#
#	var lineNumber
#
#	lineNumber = get_line_containing_text_entries(["SET_GENERATE_SPEED"])
#	if lineNumber != -1:
#		var lineString = oScriptTextEdit.get_line(lineNumber)
#		oPortalRateField.text = get_value_inbetween_brackets(lineString, 0)
#
#	lineNumber = get_line_containing_text_entries(["START_MONEY", "ALL_PLAYERS"])
#	if lineNumber != -1:
#		var lineString = oScriptTextEdit.get_line(lineNumber)
#		oGoldField.text = get_value_inbetween_brackets(lineString, 1)
#
#	lineNumber = get_line_containing_text_entries(["MAX_CREATURES", "ALL_PLAYERS"])
#	if lineNumber != -1:
#		var lineString = oScriptTextEdit.get_line(lineNumber)
#		oMaxCreaturesField.text = get_value_inbetween_brackets(lineString, 1)
#
#func _ready():
#	yield(get_tree(),'idle_frame')
#	Utils.popup_centered(self)
#	create_room_icons()
#
#func create_room_icons():
#	for i in Slabs.roomMenuOrder.size():
#		var slabID = Slabs.roomMenuOrder[i]
#		if Slabs.icons.has(slabID):
#			var btn = scnGenericGridItem.instance()
#			btn.expand = false
#			btn.texture_normal = Slabs.icons[slabID]
#			btn.connect("pressed", self, "_on_available_button_pressed", [slabID, listRoom[i], btn])
#			btn.connect("mouse_entered", self, "_on_available_button_mouse_entered", [slabID, listRoom[i], btn])
#			btn.connect("mouse_exited", self, "_on_available_button_mouse_exited", [slabID, listRoom[i], btn])
#			oRoomsAvailable.add_child(btn)
#
#func _on_ScriptTextEdit_text_changed():
#	oDataScript.data = oScriptTextEdit.text
#
#
#
#func reload_script_into_window(): # Called from oDataScript
#	oScriptTextEdit.text = oDataScript.data
#
#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
#		oScriptNameLabel.visible = true
#	else:
#		oScriptNameLabel.text = ""
#		oScriptNameLabel.visible = false
#
#func _on_available_button_mouse_entered(slabID, functionInsert, btn):
#	btn.get_node("ColorRect").color = Color("#383745").lightened(0.05)
#	var foundLine = get_line_containing_text_entries(["ROOM_AVAILABLE", functionInsert])
#	goto_line(foundLine)
#
#func get_line_containing_text_entries(lookForArray):
#	for lineNumber in oScriptTextEdit.get_line_count():
#		# Begin by searching the TextEdit for the first entry of the array
#		var lineString = oScriptTextEdit.get_line(lineNumber)
#		if lookForArray[0].to_lower() in lineString.to_lower(): # not case-sensitive
#			# Then search the line you found for every entry of the "lookForArray"
#			var foundArrayEntries = 0
#			for lookEntry in lookForArray:
#				if lookEntry in lineString:
#					foundArrayEntries += 1
#
#			if foundArrayEntries == lookForArray.size():
#				return lineNumber
#	return -1
#
#func goto_line(line):
#	if line == -1:
#		oScriptTextEdit.deselect()
#		#line = 0
#		return
#
#	oScriptTextEdit.cursor_set_line(line)
#	oScriptTextEdit.select(line, 0, line, oScriptTextEdit.get_line(line).length())
#	oScriptTextEdit.center_viewport_to_cursor()
#	oScriptTextEdit.release_focus()
#
#func _on_available_button_mouse_exited(slabID, functionInsert, btn):
#	btn.get_node("ColorRect").color = Color("#383745")
#
#
#
#
#func _on_available_button_pressed(slabID, functionInsert, btn):
##	btn.modulate
##	var setTheValue
##	if btn.modulate == enabled:
##		btn.modulate = disabled
##		setTheValue = ",1,0)"
##	else:
##		btn.modulate = enabled
##		setTheValue = ",1,1)"
#	var setTheValue = ",1,1)"
#	place_text("ROOM_AVAILABLE(ALL_PLAYERS," + functionInsert + setTheValue)
#
#func place_text(insertString):
#	#oScriptTextEdit.cursor_set_line(lineNumber, txt)
#	var lineNumber = oScriptTextEdit.cursor_get_line()
#	var existingLineString = oScriptTextEdit.get_line(lineNumber)
#
#	if oScriptTextEdit.get_line(lineNumber).length() > 0: #If line contains stuff
#		oScriptTextEdit.set_line(lineNumber, existingLineString + '\n')
#		oScriptTextEdit.set_line(lineNumber+1, insertString)
#
#		oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()+1)
#	else:
#		oScriptTextEdit.set_line(lineNumber, insertString)
#	oScriptTextEdit.update()
#
#func _on_MaxCreaturesField_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["MAX_CREATURES", "ALL_PLAYERS"])
#	goto_line(foundLine)
#
#func _on_GoldField_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["START_MONEY", "ALL_PLAYERS"])
#	goto_line(foundLine)
#
#func _on_PortalRateField_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["SET_GENERATE_SPEED"])
#	goto_line(foundLine)
#
#func _on_BlueAICheckBox_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER1"])
#	goto_line(foundLine)
#
#func _on_GreenAICheckBox_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER2"])
#	goto_line(foundLine)
#
#func _on_YellowAICheckBox_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER3"])
#	goto_line(foundLine)
#
#func _on_WhiteAICheckBox_mouse_entered():
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER_GOOD"])
#	goto_line(foundLine)
#
#func _on_WinConditionCheckBox_mouse_entered():
#	pass
#
#
#func _on_BlueAICheckBox_toggled(button_pressed):
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER1"])
#	if button_pressed == true:
#		if foundLine == -1:
#			goto_line(foundLine)
#			place_text("COMPUTER_PLAYER(PLAYER1,0)")
#	else:
#		erase_entire_line(foundLine)
#
#
#func _on_GreenAICheckBox_toggled(button_pressed):
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER2"])
#	if button_pressed == true:
#		if foundLine == -1:
#			goto_line(foundLine)
#			place_text("COMPUTER_PLAYER(PLAYER2,0)")
#	else:
#		erase_entire_line(foundLine)
#
#func _on_YellowAICheckBox_toggled(button_pressed):
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER3"])
#	if button_pressed == true:
#		if foundLine == -1:
#			goto_line(foundLine)
#			place_text("COMPUTER_PLAYER(PLAYER3,0)")
#	else:
#		erase_entire_line(foundLine)
#
#func _on_WhiteAICheckBox_toggled(button_pressed):
#	var foundLine = get_line_containing_text_entries(["COMPUTER_PLAYER", "PLAYER_GOOD"])
#	if button_pressed == true:
#		if foundLine == -1:
#			goto_line(foundLine)
#			place_text("COMPUTER_PLAYER(PLAYER_GOOD,0)")
#	else:
#		erase_entire_line(foundLine)
#
#func erase_entire_line(eraseLine):
#	if eraseLine == -1:
#		return
#
#	goto_line(eraseLine)
#	oScriptTextEdit.set_line(eraseLine,"")
#	oScriptTextEdit.select(eraseLine, 0, eraseLine, oScriptTextEdit.get_line(eraseLine).length())
#	oScriptTextEdit.cut()
#	oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()-1)
#
#func get_value_inbetween_brackets(string, argNumber):
#	var bracketPositionBegin = string.find("(")
#	string.erase(0, bracketPositionBegin+1)
#	var bracketPositionEnd = string.find(")")
#	string.erase(bracketPositionEnd, string.length())
#
#	var array = string.split(",")
#	return array[argNumber]
#
#func set_value_inbetween_brackets(string, argNumber, setToValue):
#	var firstThird = string.split("(")
#	var lastThird = firstThird[1].split(")")
#	var betweenBrackets = lastThird[0]
#
#	var array = betweenBrackets.split(",")
#	if argNumber < array.size():
#		array[argNumber] = str(setToValue)
#	else:
#		print('Error: outside of array')
#
#	betweenBrackets = ""
#	for i in array.size():
#		betweenBrackets += array[i]
#		if i < array.size()-1:
#			betweenBrackets += ','
#
#	return firstThird[0] + "(" + betweenBrackets + ")" + lastThird[1]
#
#
#func _on_PortalRateField_text_changed(new_text):
#	edit_script_by_lineedit(new_text, ["SET_GENERATE_SPEED"], "SET_GENERATE_SPEED(400)", 0)
#func _on_GoldField_text_changed(new_text):
#	edit_script_by_lineedit(new_text, ["START_MONEY", "ALL_PLAYERS"], "START_MONEY(ALL_PLAYERS,2500)", 1)
#func _on_MaxCreaturesField_text_changed(new_text):
#	edit_script_by_lineedit(new_text, ["MAX_CREATURES", "ALL_PLAYERS"], "MAX_CREATURES(ALL_PLAYERS,25)", 1)
#
#func edit_script_by_lineedit(new_text, lookForArray, generateText, slot):
#	new_text = int(new_text)
#
#	var foundLine = get_line_containing_text_entries(lookForArray)
#	goto_line(foundLine)
#
#	if foundLine == -1:
#		var placeTxt = set_value_inbetween_brackets(generateText, slot, new_text)
#		place_text(placeTxt)
#	else:
#		var existingLineString = oScriptTextEdit.get_line(foundLine)
#		var placeTxt = set_value_inbetween_brackets(existingLineString, slot, new_text)
#		oScriptTextEdit.set_line(foundLine, placeTxt)


func _on_BlueAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if check_for_dungeon_heart(1) == false:
			oMessage.quick("Requires a Dungeon Heart! Otherwise this player's creatures will die after a few seconds.")
func _on_GreenAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if check_for_dungeon_heart(2) == false:
			oMessage.quick("Requires a Dungeon Heart! Otherwise this player's creatures will die after a few seconds.")
func _on_YellowAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if check_for_dungeon_heart(3) == false:
			oMessage.quick("Requires a Dungeon Heart! Otherwise this player's creatures will die after a few seconds.")
func _on_WhiteAICheckBox_toggled(button_pressed):
	# This player does not require a Dungeon heart.
	pass

func check_for_dungeon_heart(ownership):
	for id in get_tree().get_nodes_in_group("Instance"):
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 5: # Dungeon Heart
			if id.ownership == ownership:
				return true
	return false
