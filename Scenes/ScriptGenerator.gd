extends VBoxContainer

onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oBlueAICheckBox = Nodelist.list["oBlueAICheckBox"]
onready var oGreenAICheckBox = Nodelist.list["oGreenAICheckBox"]
onready var oYellowAICheckBox = Nodelist.list["oYellowAICheckBox"]
onready var oWhiteAICheckBox = Nodelist.list["oWhiteAICheckBox"]
onready var oPortalRateField = Nodelist.list["oPortalRateField"]
onready var oGoldField = Nodelist.list["oGoldField"]
onready var oMaxCreaturesField = Nodelist.list["oMaxCreaturesField"]
onready var oPortalRateInSeconds = Nodelist.list["oPortalRateInSeconds"]
onready var oWinConditionCheckBox = Nodelist.list["oWinConditionCheckBox"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCreaturePool = Nodelist.list["oCreaturePool"]
onready var oHeroPool = Nodelist.list["oHeroPool"]
onready var oTrapsAvailable = Nodelist.list["oTrapsAvailable"]
onready var oMagicAvailable = Nodelist.list["oMagicAvailable"]
onready var oDoorsAvailable = Nodelist.list["oDoorsAvailable"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oGeneratorContainer = Nodelist.list["oGeneratorContainer"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oMapSettingsTabs = Nodelist.list["oMapSettingsTabs"]
onready var oConfirmGenerateScript = Nodelist.list["oConfirmGenerateScript"]
onready var oKeeperFXScriptCheckBox = Nodelist.list["oKeeperFXScriptCheckBox"]


var scnAvailableButton = preload('res://Scenes/AvailableButton.tscn')


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
#[23, "IMP", 0],
#[31, "FLOATING_SPIRIT", 0],

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
			id.get_node("IconTextureRect").texture = Slabs.icons[slabID]
			id.set_meta("variable", functionVariable)
			id.get_node("TextEditableLabel").editable = false
			
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
		id.set_meta("variable", functionVariable)
		var creatureName = Things.DATA_CREATURE[thingID][Things.NAME]
		id.hint_tooltip = creatureName + ' availability'
		id.get_node("IconTextureRect").texture = Things.DATA_CREATURE[thingID][Things.TEXTURE]
		id.get_node("TextEditableLabel").hint_tooltip = creatureName + ' in pool'
		id.get_node("TextEditableLabel").text = str(defaultValue)
		id.get_node("TextEditableLabel").editable = true
		id.get_node("TextEditableLabel").mouse_filter = Control.MOUSE_FILTER_PASS
		
		if defaultValue > 0:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		#id._on_EditableLabel_text_changed(str(defaultValue)) # To initialize the darkening
		if listCreature.find(i) < 16:
			oCreaturePool.add_child(id)
		else:
			oHeroPool.add_child(id)

func initialize_traps_available(): # oTrapsAvailable
	for i in listTrap:
		var thingID = i[0]
		var functionVariable = i[1]
		var defaultValue = i[2]
		var id = scnAvailableButton.instance()
		id.hint_tooltip = Things.DATA_TRAP[thingID][Things.NAME]
		id.get_node("IconTextureRect").texture = Things.DATA_TRAP[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		id.get_node("TextEditableLabel").editable = false
		
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
		id.get_node("IconTextureRect").texture = Things.DATA_OBJECT[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		id.get_node("TextEditableLabel").editable = false
		
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
		id.get_node("IconTextureRect").texture = Things.DATA_DOOR[thingID][Things.TEXTURE]
		id.set_meta("variable", functionVariable)
		id.get_node("TextEditableLabel").editable = false
		
		if defaultValue == 1:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		oDoorsAvailable.add_child(id)


func _on_PortalRateField_text_changed(new_text):
	var rateInSeconds = float(int(new_text)/20.0)
	oPortalRateInSeconds.text = '('+str(rateInSeconds) + " sec)"


func _on_BlueAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if check_for_dungeon_heart(1) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_GreenAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if check_for_dungeon_heart(2) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_YellowAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if check_for_dungeon_heart(3) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_WhiteAICheckBox_toggled(button_pressed):
	# This player does not require a Dungeon heart.
	pass

func check_for_dungeon_heart(ownership):
	for id in get_tree().get_nodes_in_group("Instance"):
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 5: # Dungeon Heart
			if id.ownership == ownership:
				return true
	return false




func _on_GenerateScriptButton_pressed():
	oMapSettingsTabs.current_tab = 2
	Utils.popup_centered(oConfirmGenerateScript)

func _on_ConfirmGenerateScript_confirmed():
	oScriptTextEdit.text = ""
	
	oMessage.quick("Cleared existing script and placed generated script")
	
	var generateString = ""
	
	var argumentForCreatureAvailable = ",1,1)"
	
	if oKeeperFXScriptCheckBox.pressed == true:
		generateString += "LEVEL_VERSION(1)" + '\n'
		argumentForCreatureAvailable = ",1,0)"
	
	generateString += "SET_GENERATE_SPEED("+str(int(oPortalRateField.text))+")" + '\n'
	generateString += "START_MONEY(ALL_PLAYERS,"+str(int(oGoldField.text))+")" + '\n'
	generateString += "MAX_CREATURES(ALL_PLAYERS,"+str(int(oMaxCreaturesField.text))+")" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	if oBlueAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER1,0)" + '\n'
	if oGreenAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER2,0)" + '\n'
	if oYellowAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER3,0)" + '\n'
	if oWhiteAICheckBox.pressed == true: generateString += "COMPUTER_PLAYER(PLAYER_GOOD,0)" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	for i in oCreaturePool.get_children():
		var variableName = i.get_meta("variable")
		if i.get_integer() > 0:
			generateString += "ADD_CREATURE_TO_POOL(ALL_PLAYERS," + variableName + "," + str(i.get_integer()) + ")" + '\n'
	for i in oHeroPool.get_children():
		var variableName = i.get_meta("variable")
		if i.get_integer() > 0:
			generateString += "ADD_CREATURE_TO_POOL(ALL_PLAYERS," + variableName + "," + str(i.get_integer()) + ")" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	for i in oCreaturePool.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.ENABLED: generateString += "CREATURE_AVAILABLE(ALL_PLAYERS," + variableName + argumentForCreatureAvailable + '\n'
	for i in oHeroPool.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.ENABLED: generateString += "CREATURE_AVAILABLE(ALL_PLAYERS," + variableName + argumentForCreatureAvailable + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	for i in oRoomsAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.OPTION_START:    generateString += "ROOM_AVAILABLE(ALL_PLAYERS," + variableName + ",1,1)" + '\n'
			i.OPTION_RESEARCH: generateString += "ROOM_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	
	for i in oMagicAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.OPTION_START:    generateString += "MAGIC_AVAILABLE(ALL_PLAYERS," + variableName + ",1,1)" + '\n'
			i.OPTION_RESEARCH: generateString += "MAGIC_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	for i in oTrapsAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.ENABLED: generateString += "TRAP_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	for i in oDoorsAvailable.get_children():
		var variableName = i.get_meta("variable")
		match i.availabilityState:
			i.ENABLED: generateString += "DOOR_AVAILABLE(ALL_PLAYERS," + variableName + ",1,0)" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	if oWinConditionCheckBox.pressed == true:
		generateString += "IF(PLAYER0,ALL_DUNGEONS_DESTROYED == 1)" + '\n'
		generateString += "	WIN_GAME" + '\n'
		generateString += "ENDIF" + '\n'
	
	oScriptEditor.set_text(generateString)

func add_one_extra_line(generateString):
	if generateString.c_unescape().ends_with('\n\n'):
		return generateString
	else:
		return generateString + '\n'


func _on_KeeperFXScriptCheckBox_toggled(button_pressed):
	pass # Replace with function body.
