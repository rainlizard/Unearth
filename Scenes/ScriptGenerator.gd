extends VBoxContainer
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oBlueAICheckBox = Nodelist.list["oBlueAICheckBox"]
onready var oGreenAICheckBox = Nodelist.list["oGreenAICheckBox"]
onready var oYellowAICheckBox = Nodelist.list["oYellowAICheckBox"]
onready var oBlueAIRoamingCheckBox = Nodelist.list["oBlueAIRoamingCheckBox"]
onready var oGreenAIRoamingCheckBox = Nodelist.list["oGreenAIRoamingCheckBox"]
onready var oYellowAIRoamingCheckBox = Nodelist.list["oYellowAIRoamingCheckBox"]
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
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oConfirmGenerateScript = Nodelist.list["oConfirmGenerateScript"]
onready var oKeeperFXScriptCheckBox = Nodelist.list["oKeeperFXScriptCheckBox"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oPurpleAICheckBox = Nodelist.list["oPurpleAICheckBox"]
onready var oBlackAICheckBox = Nodelist.list["oBlackAICheckBox"]
onready var oOrangeAICheckBox = Nodelist.list["oOrangeAICheckBox"]
onready var oPurpleAIRoamingCheckBox = Nodelist.list["oPurpleAIRoamingCheckBox"]
onready var oBlackAIRoamingCheckBox = Nodelist.list["oBlackAIRoamingCheckBox"]
onready var oOrangeAIRoamingCheckBox = Nodelist.list["oOrangeAIRoamingCheckBox"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oScriptEditorWindow = Nodelist.list["oScriptEditorWindow"]
onready var oScriptGeneratorWindow = Nodelist.list["oScriptGeneratorWindow"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

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

const CLASSIC_TRAP_ORDER = [2, 3, 4, 6, 1, 5]
const CLASSIC_DOOR_ORDER = [1, 2, 3, 4]
const HIDDEN_CREATURES = [23, 31]
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
	
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	get_parent().current_tab = 1
#	Utils.popup_centered(Nodelist.list["oMapSettingsWindow"])

func update_options_based_on_mapformat():
	if oCurrentFormat.selected == Constants.ClassicFormat:
		oPurpleAICheckBox.get_parent().visible = false
		oBlackAICheckBox.get_parent().visible = false
		oOrangeAICheckBox.get_parent().visible = false
	else:
		oPurpleAICheckBox.get_parent().visible = true
		oBlackAICheckBox.get_parent().visible = true
		oOrangeAICheckBox.get_parent().visible = true
	initialize_rooms_available()
	initialize_creatures_available()
	initialize_traps_available()
	initialize_magic_available()
	initialize_doors_available()


func get_computer_player_argument(oRoamingCheckBox):
	if oRoamingCheckBox.pressed == true:
		return "ROAMING"
	return "0"


func add_computer_player_line(generateString, playerString, oCheckBox, oRoamingCheckBox):
	if oCheckBox.pressed == true and oCheckBox.get_parent().visible == true:
		generateString += "COMPUTER_PLAYER(" + playerString + "," + get_computer_player_argument(oRoamingCheckBox) + ")" + '\n'
	return generateString


func has_roaming_computer_player():
	for aiSetting in [
		[oBlueAICheckBox, oBlueAIRoamingCheckBox],
		[oGreenAICheckBox, oGreenAIRoamingCheckBox],
		[oYellowAICheckBox, oYellowAIRoamingCheckBox],
		[oPurpleAICheckBox, oPurpleAIRoamingCheckBox],
		[oBlackAICheckBox, oBlackAIRoamingCheckBox],
		[oOrangeAICheckBox, oOrangeAIRoamingCheckBox],
	]:
		if aiSetting[0].pressed == true and aiSetting[0].get_parent().visible == true and aiSetting[1].pressed == true:
			return true
	return false


func initialize_rooms_available():
	var currentStates = get_existing_states(oRoomsAvailable)
	clear_available_buttons(oRoomsAvailable)
	for i in get_room_list():
		var slabID = i[0]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		var getName = Slabs.fetch_name(slabID)
		var slabName = Slabs.fetch_idname(slabID)
		var id = scnAvailableButton.instance()
		id.hint_tooltip = getName + ' availability'
		set_button_texture(id, Slabs.icons.get(slabName, null), getName)
		id.set_meta("variable", functionVariable)
		id.set_meta("ID", slabID)
		id.get_node("%TextEditableLabel").editable = false
		if currentStates.has(functionVariable):
			id.set_availability_state(currentStates[functionVariable])
		elif defaultAvailability == 1:
			id.set_availability_state(id.OPTION_START)
		else:
			id.set_availability_state(id.OPTION_RESEARCH)
		oRoomsAvailable.add_child(id)

func initialize_creatures_available(): # oCreaturePool
	var currentStates = get_existing_creature_data()
	clear_available_buttons(oCreaturePool)
	clear_available_buttons(oHeroPool)
	for i in get_creature_list():
		var subtype = i[0]
		var functionVariable = i[1]
		var defaultAvailability = i[2]
		var id = scnAvailableButton.instance()
		id.set_meta("variable", functionVariable)
		var getName = Things.fetch_name(Things.TYPE.CREATURE, subtype)
		id.hint_tooltip = getName + ' availability'
		set_button_texture(id, Things.fetch_sprite(Things.TYPE.CREATURE, subtype), getName)
		id.get_node("%TextEditableLabel").hint_tooltip = getName + ' in pool'
		id.get_node("%TextEditableLabel").editable = true
		id.get_node("%TextEditableLabel").mouse_filter = Control.MOUSE_FILTER_PASS
		if currentStates.has(functionVariable):
			id.get_node("%TextEditableLabel").text = currentStates[functionVariable][0]
			id.set_availability_state(currentStates[functionVariable][1])
		elif defaultAvailability > 0:
			id.get_node("%TextEditableLabel").text = str(defaultAvailability)
			id.set_availability_state(id.ENABLED)
		else:
			id.get_node("%TextEditableLabel").text = str(defaultAvailability)
			id.set_availability_state(id.DISABLED)
		if i[3] == true:
			oCreaturePool.add_child(id)
		else:
			oHeroPool.add_child(id)

func initialize_traps_available(): # oTrapsAvailable
	var currentStates = get_existing_states(oTrapsAvailable)
	clear_available_buttons(oTrapsAvailable)
	for subtype in get_trapdoor_subtypes(Things.TYPE.TRAP):
		add_trapdoor_button(oTrapsAvailable, Things.TYPE.TRAP, subtype, currentStates)

func initialize_magic_available(): # oMagicAvailable
	var currentStates = get_existing_states(oMagicAvailable)
	clear_available_buttons(oMagicAvailable)
	for i in get_magic_list():
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
		
		if currentStates.has(functionVariable):
			id.set_availability_state(currentStates[functionVariable])
		elif defaultAvailability == 1:
			id.set_availability_state(id.OPTION_START)
		else:
			id.set_availability_state(id.OPTION_RESEARCH)
		
		oMagicAvailable.add_child(id)

func initialize_doors_available(): # oDoorsAvailable
	var currentStates = get_existing_states(oDoorsAvailable)
	clear_available_buttons(oDoorsAvailable)
	for subtype in get_trapdoor_subtypes(Things.TYPE.DOOR):
		add_trapdoor_button(oDoorsAvailable, Things.TYPE.DOOR, subtype, currentStates)


func get_room_list():
	var roomList = listRoom.duplicate(true)
	if oCurrentFormat.selected == Constants.ClassicFormat:
		return roomList
	if oConfigFileManager.current_data.has("terrain.cfg") == false:
		return roomList
	var roomData = oConfigFileManager.current_data["terrain.cfg"]
	var roomIds = roomData.keys()
	roomIds.sort()
	for roomID in roomIds:
		var room = roomData[roomID]
		var roomName = room.get("Name", "")
		if roomName == "" or roomID in [0, 1, 7] or has_room_function(roomList, roomName):
			continue
		var slabID = find_slab_id(room.get("SlabAssign", ""))
		if slabID != null:
			roomList.append([slabID, roomName, 0])
	return roomList


func get_creature_list():
	var creatureList = []
	for i in listCreature:
		creatureList.append([i[0], i[1], i[2], listCreature.find(i) < 16])
	if oCurrentFormat.selected == Constants.ClassicFormat:
		return creatureList
	var creatureStatsByName = {}
	for file in oConfigFileManager.current_data.get("creature_stats", {}):
		var attributes = oConfigFileManager.current_data["creature_stats"][file].get("attributes", {})
		var creatureName = attributes.get("Name", "")
		if creatureName != "":
			creatureStatsByName[creatureName] = attributes
	var allSubtypes = Things.DATA_CREATURE.keys()
	allSubtypes.sort()
	for subtype in allSubtypes:
		if can_add_creature(creatureList, subtype):
			var creatureName = Things.fetch_id_string(Things.TYPE.CREATURE, subtype)
			creatureList.append([subtype, creatureName, 0, is_creature_evil(creatureName, creatureStatsByName)])
	return creatureList


func is_creature_evil(creatureName, creatureStatsByName):
	if creatureStatsByName.has(creatureName) == false:
		return true
	var creatureProperties = creatureStatsByName[creatureName].get("Properties", [])
	if creatureProperties is Array:
		return creatureProperties.has("EVIL")
	return creatureProperties == "EVIL"


func get_magic_list():
	var magicList = listMagic.duplicate(true)
	if oCurrentFormat.selected == Constants.ClassicFormat:
		return magicList
	if oConfigFileManager.current_data.has("magic.cfg") == false:
		return magicList
	var magicData = oConfigFileManager.current_data["magic.cfg"]
	var powerSections = magicData.keys()
	powerSections.sort()
	for section in powerSections:
		if section.begins_with("power") == false:
			continue
		var powerName = magicData[section].get("Name", "")
		var artifactName = magicData[section].get("Artifact", "")
		if powerName == "" or artifactName == "" or artifactName == "NULL" or has_magic_function(magicList, powerName):
			continue
		var subtype = Things.find_subtype_by_name(Things.TYPE.OBJECT, artifactName)
		if subtype != null and is_spellbook_object(subtype):
			magicList.append([subtype, powerName, 0])
	return magicList


func has_room_function(roomList, functionVariable):
	for room in roomList:
		if room[1] == functionVariable:
			return true
	return false


func has_creature_subtype(creatureList, subtype):
	for creature in creatureList:
		if creature[0] == subtype:
			return true
	return false


func has_magic_function(magicList, functionVariable):
	for magic in magicList:
		if magic[1] == functionVariable:
			return true
	return false


func is_spellbook_object(subtype):
	return Things.DATA_OBJECT.has(subtype) and Things.DATA_OBJECT[subtype][Things.GENRE] == "SPELLBOOK"


func can_add_creature(creatureList, subtype):
	if subtype == 0 or HIDDEN_CREATURES.has(subtype):
		return false
	return has_creature_subtype(creatureList, subtype) == false


func find_slab_id(slabName):
	for slabID in Slabs.data:
		if Slabs.data[slabID][Slabs.NAME] == slabName:
			return slabID
	return null


func get_trapdoor_subtypes(thingType):
	var subtypeList = []
	if thingType == Things.TYPE.TRAP:
		subtypeList = CLASSIC_TRAP_ORDER.duplicate()
	else:
		subtypeList = CLASSIC_DOOR_ORDER.duplicate()
	if oCurrentFormat.selected == Constants.ClassicFormat:
		return subtypeList
	var allSubtypes = Things.data_structure(thingType).keys()
	allSubtypes.sort()
	for subtype in allSubtypes:
		if subtype != 0 and subtypeList.has(subtype) == false:
			subtypeList.append(subtype)
	return subtypeList


func add_trapdoor_button(parent, thingType, subtype, currentStates):
	var functionVariable = Things.fetch_id_string(thingType, subtype)
	var id = scnAvailableButton.instance()
	var getName = Things.fetch_name(thingType, subtype)
	id.hint_tooltip = getName + ' availability'
	set_button_texture(id, Things.fetch_sprite(thingType, subtype), getName)
	id.set_meta("variable", functionVariable)
	id.get_node("%TextEditableLabel").editable = false
	if currentStates.has(functionVariable):
		id.set_availability_state(currentStates[functionVariable])
	else:
		id.set_availability_state(id.ENABLED)
	parent.add_child(id)


func set_button_texture(id, texture, getName):
	id.get_node("%IconTextureRect").texture = texture
	if texture == null:
		add_icon_text(id, getName)


func add_icon_text(id, getName):
	var iconText = Label.new()
	iconText.text = getName
	iconText.align = Label.ALIGN_CENTER
	iconText.valign = Label.VALIGN_CENTER
	iconText.autowrap = true
	iconText.anchor_right = 1.0
	iconText.anchor_bottom = 1.0
	iconText.mouse_filter = Control.MOUSE_FILTER_IGNORE
	id.get_node("%IconTextureRect").add_child(iconText)


func get_existing_states(parent):
	var currentStates = {}
	for id in parent.get_children():
		currentStates[id.get_meta("variable")] = id.availabilityState
	return currentStates


func get_existing_creature_data():
	var currentStates = {}
	for parent in [oCreaturePool, oHeroPool]:
		for id in parent.get_children():
			currentStates[id.get_meta("variable")] = [str(id.get_integer()), id.availabilityState]
	return currentStates


func clear_available_buttons(parent):
	for id in parent.get_children():
		parent.remove_child(id)
		id.queue_free()


func _on_PortalRateField_text_changed(new_text):
	var rateInSeconds = float(int(new_text)/20.0)
	oPortalRateInSeconds.text = '('+str(rateInSeconds) + "s)"


func _on_BlueAICheckBox_toggled(button_pressed):
	if button_pressed == true and oBlueAIRoamingCheckBox.pressed == false:
		if oInstances.check_for_dungeon_heart(1) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_GreenAICheckBox_toggled(button_pressed):
	if button_pressed == true and oGreenAIRoamingCheckBox.pressed == false:
		if oInstances.check_for_dungeon_heart(2) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_YellowAICheckBox_toggled(button_pressed):
	if button_pressed == true and oYellowAIRoamingCheckBox.pressed == false:
		if oInstances.check_for_dungeon_heart(3) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_PurpleAICheckBox_toggled(button_pressed):
	if button_pressed == true and oPurpleAIRoamingCheckBox.pressed == false:
		if oInstances.check_for_dungeon_heart(6) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_BlackAICheckBox_toggled(button_pressed):
	if button_pressed == true and oBlackAIRoamingCheckBox.pressed == false:
		if oInstances.check_for_dungeon_heart(7) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")
func _on_OrangeAICheckBox_toggled(button_pressed):
	if button_pressed == true and oOrangeAIRoamingCheckBox.pressed == false:
		if oInstances.check_for_dungeon_heart(8) == false:
			oMessage.quick("This player requires a Dungeon Heart! Otherwise their creatures will die after a few seconds.")


func _on_GenerateScriptButton_pressed():
	Utils.popup_centered(oScriptEditorWindow)
	Utils.popup_centered(oConfirmGenerateScript)
	oScriptGeneratorWindow.hide()

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
	
	if oKeeperFXScriptCheckBox.pressed == true or has_roaming_computer_player():
		generateString += "LEVEL_VERSION(1)" + '\n'
		argumentForCreatureAvailable = ",1,0)"
	
	generateString += "SET_GENERATE_SPEED("+str(int(oPortalRateField.text))+")" + '\n'
	generateString += "START_MONEY(ALL_PLAYERS,"+str(int(oGoldField.text))+")" + '\n'
	generateString += "MAX_CREATURES(ALL_PLAYERS,"+str(int(oMaxCreaturesField.text))+")" + '\n'
	
	generateString = add_one_extra_line(generateString)
	
	generateString = add_computer_player_line(generateString, "PLAYER1", oBlueAICheckBox, oBlueAIRoamingCheckBox)
	generateString = add_computer_player_line(generateString, "PLAYER2", oGreenAICheckBox, oGreenAIRoamingCheckBox)
	generateString = add_computer_player_line(generateString, "PLAYER3", oYellowAICheckBox, oYellowAIRoamingCheckBox)
	generateString = add_computer_player_line(generateString, "PLAYER4", oPurpleAICheckBox, oPurpleAIRoamingCheckBox)
	generateString = add_computer_player_line(generateString, "PLAYER5", oBlackAICheckBox, oBlackAIRoamingCheckBox)
	generateString = add_computer_player_line(generateString, "PLAYER6", oOrangeAICheckBox, oOrangeAIRoamingCheckBox)

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
