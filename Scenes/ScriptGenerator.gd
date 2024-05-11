extends VBoxContainer
onready var oWarlockLevelSpinBox = Nodelist.list["oWarlockLevelSpinBox"]
onready var oWarlockAmountSpinBox = Nodelist.list["oWarlockAmountSpinBox"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oBlueAICheckBox = Nodelist.list["oBlueAICheckBox"]
onready var oGreenAICheckBox = Nodelist.list["oGreenAICheckBox"]
onready var oYellowAICheckBox = Nodelist.list["oYellowAICheckBox"]
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
onready var oResearchables = Nodelist.list["oResearchables"]
onready var oResearchOrderCategory = Nodelist.list["oResearchOrderCategory"]
onready var oAdjustResearchCheckBox = Nodelist.list["oAdjustResearchCheckBox"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oPurpleAICheckBox = Nodelist.list["oPurpleAICheckBox"]
onready var oBlackAICheckBox = Nodelist.list["oBlackAICheckBox"]
onready var oOrangeAICheckBox = Nodelist.list["oOrangeAICheckBox"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]

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
[Things.SPELLBOOK.HAND, "POWER_HAND", 1],
[Things.SPELLBOOK.SLAP, "POWER_SLAP", 1],
[Things.SPELLBOOK.POSSESS, "POWER_POSSESS", 1],
[Things.SPELLBOOK.IMP, "POWER_IMP", 1],
[Things.SPELLBOOK.SIGHT, "POWER_SIGHT", 0],
[Things.SPELLBOOK.SPEED, "POWER_SPEED", 0],
[Things.SPELLBOOK.OBEY, "POWER_OBEY", 0],
[Things.SPELLBOOK.CALL_TO_ARMS, "POWER_CALL_TO_ARMS", 0],
[Things.SPELLBOOK.CONCEAL, "POWER_CONCEAL", 0],
[Things.SPELLBOOK.HOLD_AUDIENCE, "POWER_HOLD_AUDIENCE", 0],
[Things.SPELLBOOK.CAVE_IN, "POWER_CAVE_IN", 0],
[Things.SPELLBOOK.HEAL_CREATURE, "POWER_HEAL_CREATURE", 0],
[Things.SPELLBOOK.LIGHTNING, "POWER_LIGHTNING", 0],
[Things.SPELLBOOK.PROTECT, "POWER_PROTECT", 0],
[Things.SPELLBOOK.CHICKEN, "POWER_CHICKEN", 0],
[Things.SPELLBOOK.DISEASE, "POWER_DISEASE", 0],
[Things.SPELLBOOK.ARMAGEDDON, "POWER_ARMAGEDDON", 0],
[Things.SPELLBOOK.DESTROY_WALLS, "POWER_DESTROY_WALLS", 0],
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
enum {
	IS_MAGIC
	IS_ROOM
}
var listResearchOrder = [
[IS_MAGIC, Things.SPELLBOOK.HAND         ,    250],
[IS_MAGIC, Things.SPELLBOOK.SLAP         ,    500],
[IS_MAGIC, Things.SPELLBOOK.POSSESS      ,    500],
[IS_MAGIC, Things.SPELLBOOK.IMP          ,   1000],
[IS_ROOM , Slabs.TREASURE_ROOM           ,   1000],
[IS_ROOM , Slabs.LAIR                    ,   1000],
[IS_ROOM , Slabs.HATCHERY                ,   1000],
[IS_ROOM , Slabs.TRAINING_ROOM           ,   1000],
[IS_ROOM , Slabs.LIBRARY                 ,   1000],
[IS_MAGIC, Things.SPELLBOOK.SIGHT        ,   3800],
[IS_ROOM , Slabs.BRIDGE                  ,   4600],
[IS_MAGIC, Things.SPELLBOOK.SPEED        ,   5700],
[IS_MAGIC, Things.SPELLBOOK.OBEY         ,   6000],
[IS_ROOM , Slabs.GUARD_POST              ,   6700],
[IS_MAGIC, Things.SPELLBOOK.CALL_TO_ARMS ,   7400],
[IS_ROOM , Slabs.WORKSHOP                ,   9000],
[IS_MAGIC, Things.SPELLBOOK.CONCEAL      ,   9400],
[IS_ROOM , Slabs.BARRACKS                ,  12000],
[IS_MAGIC, Things.SPELLBOOK.HOLD_AUDIENCE,  11000],
[IS_ROOM , Slabs.PRISON                  ,  20000],
[IS_MAGIC, Things.SPELLBOOK.CAVE_IN      ,  25000],
[IS_ROOM , Slabs.TORTURE_CHAMBER         ,  20000],
[IS_MAGIC, Things.SPELLBOOK.HEAL_CREATURE,  14000],
[IS_ROOM , Slabs.TEMPLE                  ,  25000],
[IS_MAGIC, Things.SPELLBOOK.LIGHTNING    ,  15000],
[IS_ROOM , Slabs.GRAVEYARD               ,  25000],
[IS_MAGIC, Things.SPELLBOOK.PROTECT      ,  15000],
[IS_ROOM , Slabs.SCAVENGER_ROOM          ,  27500],
[IS_MAGIC, Things.SPELLBOOK.CHICKEN      ,  20000],
[IS_MAGIC, Things.SPELLBOOK.DISEASE      ,  20000],
[IS_MAGIC, Things.SPELLBOOK.ARMAGEDDON   , 100000],
[IS_MAGIC, Things.SPELLBOOK.DESTROY_WALLS, 750000],
]

func _ready():
	initialize_rooms_available()
	initialize_creatures_available()
	initialize_traps_available()
	initialize_magic_available()
	initialize_doors_available()
	
	initialize_researchables()
	adjust_estimated_time()
	
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	get_parent().current_tab = 1
#	Utils.popup_centered(Nodelist.list["oMapSettingsWindow"])

func update_options_based_on_mapformat():
	if oCurrentFormat.selected == Constants.ClassicFormat:
		oPurpleAICheckBox.visible = false
		oBlackAICheckBox.visible = false
		oOrangeAICheckBox.visible = false
	else:
		oPurpleAICheckBox.visible = true
		oBlackAICheckBox.visible = true
		oOrangeAICheckBox.visible = true


func initialize_researchables():
	var labelNumber = 0
	for i in listResearchOrder:
		
		var what = i[0]
		var subtype = i[1]
		var cost = i[2]
		
		var scene = preload('res://Scenes/ResearchableItem.tscn')
		var idItem = scene.instance()
		
		if what == IS_MAGIC:
			for checkAll in listMagic:
				if checkAll[0] == subtype:
					if Things.DATA_OBJECT.has(subtype):
						var getName = Things.fetch_name(Things.TYPE.OBJECT, subtype)
						idItem.hint_tooltip = getName + ' availability'
						idItem.set_meta("variable",checkAll[1]) # function text
						idItem.set_meta("ID", subtype)
						idItem.type = idItem.MAGIC
						idItem.set_magic_texture(subtype)
					break
		elif what == IS_ROOM:
			for checkAll in listRoom:
				if checkAll[0] == subtype:
					idItem.hint_tooltip = Slabs.data[subtype][Slabs.NAME]
					idItem.set_meta("variable",checkAll[1]) # function text
					idItem.set_meta("ID", subtype)
					idItem.type = idItem.ROOM
					idItem.set_room_texture(subtype)
					break
		
		labelNumber += 1
		idItem.set_label_number(labelNumber)
		idItem.set_research_required(cost)
		
		oResearchables.add_child(idItem)

func initialize_rooms_available():
	for i in listRoom:
		var slabID = i[0]# listRoom[] #Slabs.roomMenuOrder[i]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		
		if Slabs.icons.has(slabID):
			var id = scnAvailableButton.instance()
			id.hint_tooltip = Slabs.data[slabID][Slabs.NAME] + ' availability'
			id.get_node("IconTextureRect").texture = Slabs.icons[slabID]
			id.set_meta("variable", functionVariable)
			id.set_meta("ID", slabID)
			id.get_node("%TextEditableLabel").editable = false
			
			if defaultAvailability == 1:
				id.set_availability_state(id.OPTION_START)
			else:
				id.set_availability_state(id.OPTION_RESEARCH)
			
			oRoomsAvailable.add_child(id)

func initialize_creatures_available(): # oCreaturePool
	for i in listCreature:
		var subtype = i[0]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		var id = scnAvailableButton.instance()
		id.set_meta("variable", functionVariable)
		var getName = Things.fetch_name(Things.TYPE.CREATURE, subtype)
		id.hint_tooltip = getName + ' availability'
		id.get_node("%IconTextureRect").texture = Things.fetch_sprite(Things.TYPE.CREATURE, subtype)
		id.get_node("%TextEditableLabel").hint_tooltip = getName + ' in pool'
		id.get_node("%TextEditableLabel").text = str(defaultAvailability)
		id.get_node("%TextEditableLabel").editable = true
		id.get_node("%TextEditableLabel").mouse_filter = Control.MOUSE_FILTER_PASS
		
		if defaultAvailability > 0:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		#id._on_EditableLabel_text_changed(str(defaultAvailability)) # To initialize the darkening
		if listCreature.find(i) < 16:
			oCreaturePool.add_child(id)
		else:
			oHeroPool.add_child(id)

func initialize_traps_available(): # oTrapsAvailable
	for i in listTrap:
		var subtype = i[0]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		var id = scnAvailableButton.instance()
		var getName = Things.fetch_name(Things.TYPE.TRAP, subtype)
		id.hint_tooltip = getName + ' availability'
		id.get_node("%IconTextureRect").texture = Things.fetch_sprite(Things.TYPE.TRAP, subtype)
		id.set_meta("variable", functionVariable)
		id.get_node("%TextEditableLabel").editable = false
		
		if defaultAvailability == 1:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		oTrapsAvailable.add_child(id)

func initialize_magic_available(): # oMagicAvailable
	for i in listMagic:
		var subtype = i[0]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		var id = scnAvailableButton.instance()
		var getName = Things.fetch_name(Things.TYPE.OBJECT, subtype)
		id.hint_tooltip = getName + ' availability'
		id.get_node("%IconTextureRect").texture = Things.fetch_sprite(Things.TYPE.OBJECT, subtype)
		id.set_meta("variable", functionVariable)
		id.set_meta("ID", subtype)
		id.get_node("%TextEditableLabel").editable = false
		
		if defaultAvailability == 1:
			id.set_availability_state(id.OPTION_START)
		else:
			id.set_availability_state(id.OPTION_RESEARCH)
		
		oMagicAvailable.add_child(id)

func initialize_doors_available(): # oDoorsAvailable
	for i in listDoor:
		var subtype = i[0]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		var id = scnAvailableButton.instance()
		var getName = Things.fetch_name(Things.TYPE.DOOR, subtype)
		id.hint_tooltip = getName + ' availability'
		id.get_node("%IconTextureRect").texture = Things.fetch_sprite(Things.TYPE.DOOR, subtype)
		id.set_meta("variable", functionVariable)
		id.get_node("%TextEditableLabel").editable = false
		
		if defaultAvailability == 1:
			id.set_availability_state(id.ENABLED)
		else:
			id.set_availability_state(id.DISABLED)
		
		oDoorsAvailable.add_child(id)


func _on_PortalRateField_text_changed(new_text):
	var rateInSeconds = float(int(new_text)/20.0)
	oPortalRateInSeconds.text = '('+str(rateInSeconds) + " sec)"


func _on_BlueAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if oInstances.check_for_dungeon_heart(1) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_GreenAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if oInstances.check_for_dungeon_heart(2) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_YellowAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if oInstances.check_for_dungeon_heart(3) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_PurpleAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if oInstances.check_for_dungeon_heart(6) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_BlackAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if oInstances.check_for_dungeon_heart(7) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_OrangeAICheckBox_toggled(button_pressed):
	if button_pressed == true:
		if oInstances.check_for_dungeon_heart(8) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")


func _on_GenerateScriptButton_pressed():
	oMapSettingsTabs.current_tab = 2
	Utils.popup_centered(oConfirmGenerateScript)

func _on_ConfirmGenerateScript_confirmed():
	oScriptTextEdit.text = ""
	var generateString = execute_gen()
	oScriptEditor.load_generated_text(generateString)
	oMessage.quick("Cleared existing script and placed generated script")

func _on_SendToClipboardButton_pressed():
	var generateString = execute_gen()
	OS.set_clipboard(generateString)
	oMessage.quick("Generated script copied to clipboard. Paste it somewhere.")

func execute_gen():
	var generateString = ""
	
	var argumentForCreatureAvailable = ",1,1)"
	
	if oKeeperFXScriptCheckBox.pressed == true:
		generateString += "LEVEL_VERSION(1)" + '\n'
		argumentForCreatureAvailable = ",1,0)"
	
	generateString += "SET_GENERATE_SPEED("+str(int(oPortalRateField.text))+")" + '\n'
	generateString += "START_MONEY(ALL_PLAYERS,"+str(int(oGoldField.text))+")" + '\n'
	generateString += "MAX_CREATURES(ALL_PLAYERS,"+str(int(oMaxCreaturesField.text))+")" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	if oBlueAICheckBox.pressed == true and oBlueAICheckBox.visible == true:
		generateString += "COMPUTER_PLAYER(PLAYER1,0)" + '\n'
	if oGreenAICheckBox.pressed == true and oGreenAICheckBox.visible == true:
		generateString += "COMPUTER_PLAYER(PLAYER2,0)" + '\n'
	if oYellowAICheckBox.pressed == true and oYellowAICheckBox.visible == true:
		generateString += "COMPUTER_PLAYER(PLAYER3,0)" + '\n'
	if oPurpleAICheckBox.pressed == true and oPurpleAICheckBox.visible == true:
		generateString += "COMPUTER_PLAYER(PLAYER4,0)" + '\n'
	if oBlackAICheckBox.pressed == true and oBlackAICheckBox.visible == true:
		generateString += "COMPUTER_PLAYER(PLAYER5,0)" + '\n'
	if oOrangeAICheckBox.pressed == true and oOrangeAICheckBox.visible == true:
		generateString += "COMPUTER_PLAYER(PLAYER6,0)" + '\n'

	generateString = add_one_extra_line(generateString)
	
	for i in oCreaturePool.get_children():
		var variableName = i.get_meta("variable")
		if i.get_integer() > 0:
			generateString += "ADD_CREATURE_TO_POOL(" + variableName + "," + str(i.get_integer()) + ")" + '\n'
	for i in oHeroPool.get_children():
		var variableName = i.get_meta("variable")
		if i.get_integer() > 0:
			generateString += "ADD_CREATURE_TO_POOL(" + variableName + "," + str(i.get_integer()) + ")" + '\n'
	
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
	
	if oAdjustResearchCheckBox.pressed == true:
		for i in oResearchables.get_children():
			if i.visible == false:
				continue
			var variableName = i.get_meta("variable")
			var typeName = "ROOM"
			var costName = str(i.get_research_required())
			if i.type == i.MAGIC:
				typeName = "MAGIC"
			
			var researchFunction = "RESEARCH"
			if oKeeperFXScriptCheckBox.pressed == true:
				researchFunction = "RESEARCH_ORDER"
			
			generateString += researchFunction + "(ALL_PLAYERS," + typeName + "," + variableName + ',' + costName + ')' + '\n'
		
		generateString = add_one_extra_line(generateString)
	
	if oWinConditionCheckBox.pressed == true:
		generateString += "IF(PLAYER0,ALL_DUNGEONS_DESTROYED == 1)" + '\n'
		generateString += "	WIN_GAME" + '\n'
		generateString += "ENDIF" + '\n'
	return generateString

func add_one_extra_line(generateString):
	if generateString.c_unescape().ends_with('\n\n'):
		return generateString
	else:
		return generateString + '\n'


func _on_KeeperFXScriptCheckBox_toggled(button_pressed):
	pass # Replace with function body.


func _on_WarlockAmountSpinBox_value_changed(value):
	adjust_estimated_time()


func _on_WarlockLevelSpinBox_value_changed(value):
	adjust_estimated_time()


func adjust_estimated_time():
	var warlockAmount = oWarlockAmountSpinBox.value
	var warlockLevel = oWarlockLevelSpinBox.value
	var warlockResearchSpeed = 4
	
	#var calculated = floor((warlockResearchSpeed + (warlockResearchSpeed * warlockLevel * 0.35 )) * warlockAmount)
	var speed = 0
	for i in warlockAmount:
		
		speed += warlockResearchSpeed # level 1
		for level in warlockLevel-1: # level 2-10
			speed += floor(warlockResearchSpeed * 0.35)
	
	for id in get_tree().get_nodes_in_group("ResearchableItem"):
		id.set_estimated_time(speed)
	
	# redo label number text
	var markNumber = 0
	for id in oResearchables.get_children():
		if id.visible == true:
			markNumber += 1
			id.set_label_number(markNumber)


func _on_AdjustResearchCheckBox_toggled(button_pressed):
	oResearchOrderCategory.visible = button_pressed
	yield(get_tree(),'idle_frame')
	yield(get_tree(),'idle_frame')
	if oResearchOrderCategory.visible == true:
		oGeneratorContainer.scroll_vertical += 200

