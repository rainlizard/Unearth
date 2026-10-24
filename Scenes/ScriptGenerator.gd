extends VBoxContainer
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oAIOption = Nodelist.list["oAIOption"]
onready var oPortalRateField = Nodelist.list["oPortalRateField"]
onready var oGoldField = Nodelist.list["oGoldField"]
onready var oMaxCreaturesField = Nodelist.list["oMaxCreaturesField"]
onready var oPortalRateInSeconds = Nodelist.list["oPortalRateInSeconds"]
onready var oCreaturePool = Nodelist.list["oCreaturePool"]
onready var oHeroPool = Nodelist.list["oHeroPool"]
onready var oTrapsAvailable = Nodelist.list["oTrapsAvailable"]
onready var oMagicAvailable = Nodelist.list["oMagicAvailable"]
onready var oDoorsAvailable = Nodelist.list["oDoorsAvailable"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oScriptGeneratorWindow = Nodelist.list["oScriptGeneratorWindow"]
onready var oUi = Nodelist.list["oUi"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oBasicNotice = Nodelist.list["oBasicNotice"]
onready var oBasicOptions = Nodelist.list["oBasicOptions"]
onready var oTrapsCard = Nodelist.list["oTrapsCard"]
onready var oDoorsCard = Nodelist.list["oDoorsCard"]
onready var oBasicPlayerTabs = Nodelist.list["oBasicPlayerTabs"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oCreateScriptButton = Nodelist.list["oCreateScriptButton"]
onready var oScriptPathLinkButton = Nodelist.list["oScriptPathLinkButton"]
onready var oMessage = Nodelist.list["oMessage"]

onready var numberFields = [[oPortalRateField, "SET_GENERATE_SPEED", "400"], [oGoldField, "START_MONEY", "2500"], [oMaxCreaturesField, "MAX_CREATURES", "25"]]
onready var availableParents = [oCreaturePool, oHeroPool, oRoomsAvailable, oMagicAvailable, oTrapsAvailable, oDoorsAvailable]

var scnAvailableButton = preload('res://Scenes/AvailableButton.tscn')
var patcher = BasicScriptPatcher.new()

const PLAYERS = ["PLAYER0", "PLAYER1", "PLAYER2", "PLAYER3", "PLAYER4", "PLAYER5", "PLAYER6"]
const TAB_TARGETS = ["ALL_PLAYERS"] + PLAYERS
const MODIFIED = Color(1.4, 1.4, 1.7) # Tints what a keeper has lines of its own for, like the Slabset window
var playerTabs = ButtonGroup.new()
const AI_HEART_OWNERS = [0, 1, 2, 3, 6, 7, 8]
var scriptPreview # A copy of the script editor, so previews never enter the editor's undo history
var previewText = "" # Drawn faded in the gap left for it, since TextEdit can't fade a single line

const CLASSIC_CREATURES = [19, 24, 18, 16, 26, 27, 29, 21, 30, 22, 17, 20, 28, 15, 25, 14, 12, 8, 5, 3, 2, 4, 11, 9, 1, 10, 13, 6, 7]

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
const ICON_SIZE = Vector2(76, 64)
const CREATURE_ICON_SCALE = 2.5
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
	for label in ["All players", "Red", "Blue", "Green", "Yellow", "Purple", "Black", "Orange"]: # Buttons rather than Tabs, so each can be tinted
		var tab = Button.new()
		tab.text = label
		tab.icon = null if label == "All players" else load("res://images_ui/plyrsym_32/symbol_player_" + label.to_lower() + "_std.png")
		tab.toggle_mode = true
		tab.group = playerTabs
		tab.hint_tooltip = oBasicPlayerTabs.hint_tooltip
		for style in [["normal", "tab_bg", "font_color", "font_color_bg"], ["hover", "tab_bg", "font_color_hover", "font_color_bg"], ["pressed", "tab_fg", "font_color_pressed", "font_color_fg"], ["disabled", "tab_disabled", "font_color_disabled", "font_color_disabled"]]: # Drawn like Tabs
			tab.add_stylebox_override(style[0], oBasicPlayerTabs.get_stylebox(style[1], "Tabs").duplicate())
			tab.add_color_override(style[2], oBasicPlayerTabs.get_color(style[3], "Tabs"))
		tab.connect("pressed", self, "refresh")
		oBasicPlayerTabs.add_child(tab)
	oBasicPlayerTabs.get_child(0).pressed = true
	for control in [oPortalRateField, oGoldField, oMaxCreaturesField, oAIOption]:
		var row = control.get_parent()
		for node in [row] + row.get_children():
			node.connect("mouse_entered", self, "_on_setting_mouse_entered", [row])
	scriptPreview = oScriptTextEdit.duplicate(0) # Without the editor's signals
	scriptPreview.hide()
	scriptPreview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scriptPreview.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	scriptPreview.connect("draw", self, "_on_scriptPreview_draw")
	oScriptTextEdit.add_child(scriptPreview)
	update_options_based_on_mapformat()


func update_options_based_on_mapformat():
	oAIOption.set_item_disabled(2, oCurrentFormat.selected == Constants.OldFormat) # Roaming requires LEVEL_VERSION(1)
	for index in [5, 6, 7]:
		oBasicPlayerTabs.get_child(index).disabled = oCurrentFormat.selected == Constants.OldFormat
	if playerTabs.get_pressed_button().disabled:
		oBasicPlayerTabs.get_child(0).pressed = true
	patcher.order = {} # New lines are written in the order of the tabs, then of the buttons
	for target in TAB_TARGETS:
		patcher.order[target] = patcher.order.size()
	for parent in availableParents:
		for button in parent.get_children():
			parent.remove_child(button)
			button.queue_free()
	for i in get_room_list():
		add_available_button(oRoomsAvailable, "ROOM_AVAILABLE", i[1], Slabs.icons.get(Slabs.fetch_idname(i[0]), null), Slabs.fetch_name(i[0]), i[2] == 1)
	for i in get_magic_list():
		add_available_button(oMagicAvailable, "MAGIC_AVAILABLE", i[1], Things.fetch_icon_sprite(Things.TYPE.OBJECT, i[0], ICON_SIZE, CREATURE_ICON_SCALE), Things.fetch_name(Things.TYPE.OBJECT, i[0]), i[2] == 1)
	for i in get_creature_list():
		var button = add_available_button(oCreaturePool if i[3] else oHeroPool, "CREATURE_AVAILABLE", i[1], Things.fetch_icon_sprite(Things.TYPE.CREATURE, i[0], ICON_SIZE, CREATURE_ICON_SCALE), Things.fetch_name(Things.TYPE.CREATURE, i[0]), i[2] > 0)
		var poolLabel = button.get_node("%TextEditableLabel")
		poolLabel.hint_tooltip = button.hint_tooltip + " in portal pool"
		poolLabel.connect("mouse_entered", self, "_on_setting_mouse_entered", [poolLabel])
		button.set_meta("default_pool", i[2])
	for section in [[oTrapsAvailable, Things.TYPE.TRAP, "TRAP_AVAILABLE"], [oDoorsAvailable, Things.TYPE.DOOR, "DOOR_AVAILABLE"]]:
		for subtype in get_trapdoor_subtypes(section[1]):
			add_available_button(section[0], section[2], Things.fetch_id_string(section[1], subtype), Things.fetch_sprite(section[1], subtype), Things.fetch_name(section[1], subtype), true)
	oTrapsCard.size_flags_stretch_ratio = oTrapsAvailable.get_child_count() # Traps and doors share a row in proportion to their icons
	oDoorsCard.size_flags_stretch_ratio = oDoorsAvailable.get_child_count()
	refresh()


func get_room_list():
	var roomList = listRoom.duplicate(true)
	if oCurrentFormat.selected == Constants.OldFormat or oConfigFileManager.current_data.has("terrain.cfg") == false:
		return roomList
	var roomData = oConfigFileManager.current_data["terrain.cfg"]
	var roomIds = roomData.keys()
	roomIds.sort()
	for roomID in roomIds:
		var room = roomData[roomID]
		var roomName = room.get("Name", "")
		if roomName == "" or roomID in [0, 1, 7] or has_value(roomList, 1, roomName):
			continue
		var slabID = room.get("SlabAssign", "")
		if typeof(slabID) == TYPE_STRING:
			slabID = Slabs.find_slab_id_by_name(slabID)
		if Slabs.data.has(slabID):
			roomList.append([slabID, roomName, 0])
	return roomList


func get_creature_list():
	var creatureList = []
	for index in CLASSIC_CREATURES.size():
		var subtype = CLASSIC_CREATURES[index]
		creatureList.append([subtype, Things.fetch_id_string(Things.TYPE.CREATURE, subtype), 20 if index < 12 else 0, index < 16])
	if oCurrentFormat.selected == Constants.OldFormat:
		return creatureList
	var creatureStatsByName = {}
	for file in oConfigFileManager.current_data.get("creature_stats", {}):
		var attributes = oConfigFileManager.current_data["creature_stats"][file].get("attributes", {})
		creatureStatsByName[file.get_basename().to_upper()] = attributes
	var allSubtypes = Things.DATA_CREATURE.keys()
	allSubtypes.sort()
	for subtype in allSubtypes:
		if subtype == 0 or HIDDEN_CREATURES.has(subtype) or has_value(creatureList, 0, subtype):
			continue
		var creatureName = Things.fetch_id_string(Things.TYPE.CREATURE, subtype)
		var evil = true
		if creatureStatsByName.has(creatureName):
			var properties = creatureStatsByName[creatureName].get("Properties", [])
			evil = properties.has("EVIL") if properties is Array else properties == "EVIL"
		creatureList.append([subtype, creatureName, 0, evil])
	return creatureList


func get_magic_list():
	var magicList = listMagic.duplicate(true)
	if oCurrentFormat.selected == Constants.OldFormat or oConfigFileManager.current_data.has("magic.cfg") == false:
		return magicList
	var magicData = oConfigFileManager.current_data["magic.cfg"]
	var powerSections = magicData.keys()
	powerSections.sort()
	for section in powerSections:
		if section.begins_with("power") == false:
			continue
		var powerName = magicData[section].get("Name", "")
		var artifactName = magicData[section].get("Artifact", "")
		if powerName == "" or artifactName == "" or artifactName == "NULL" or has_value(magicList, 1, powerName):
			continue
		var subtype = Things.find_subtype_by_name(Things.TYPE.OBJECT, artifactName)
		if subtype != null and Things.DATA_OBJECT.has(subtype) and Things.DATA_OBJECT[subtype][Things.GENRE] == "SPELLBOOK":
			magicList.append([subtype, powerName, 0])
	return magicList


func has_value(items, index, value):
	for item in items:
		if item[index] == value:
			return true
	return false


func get_trapdoor_subtypes(thingType):
	var subtypeList = (CLASSIC_TRAP_ORDER if thingType == Things.TYPE.TRAP else CLASSIC_DOOR_ORDER).duplicate()
	if oCurrentFormat.selected == Constants.OldFormat:
		return subtypeList
	var allSubtypes = Things.data_structure(thingType).keys()
	allSubtypes.sort()
	for subtype in allSubtypes:
		if subtype != 0 and subtypeList.has(subtype) == false:
			subtypeList.append(subtype)
	return subtypeList


# availableByDefault is used by add_default_setup(). Rooms and spells that aren't available by default are researchable.
func add_available_button(parent, command, variable, texture, display_name, availableByDefault):
	var button = scnAvailableButton.instance()
	button.hint_tooltip = display_name
	button.set_meta("command", command)
	button.set_meta("variable", variable)
	patcher.order[variable.to_upper()] = patcher.order.size()
	button.get_node("%IconTextureRect").texture = texture
	button.get_node("%IconLabel").text = display_name if texture == null else ""
	var cycle = [button.START, button.RESEARCH, button.DISABLED] if command in ["ROOM_AVAILABLE", "MAGIC_AVAILABLE"] else [button.ENABLED, button.DISABLED]
	button.set_meta("cycle", cycle)
	button.set_meta("default", cycle[0 if availableByDefault else 1])
	parent.add_child(button)
	button.connect("mouse_entered", self, "_on_setting_mouse_entered", [button])
	button.connect("mouse_exited", scriptPreview, "hide")
	return button


func open():
	oScriptEditor.set_editing(false)
	Utils.popup_centered(oScriptGeneratorWindow)
	oScriptGeneratorWindow.rect_position = Vector2(0, oUi.topMargin) # Full screen, below the menu bar
	oScriptGeneratorWindow.rect_size = get_viewport().size / Settings.UI_SCALE - oScriptGeneratorWindow.rect_position
	# Start on the tab the script's availability lines are written for, such as Red in campaign maps
	oBasicPlayerTabs.get_child(0).pressed = true
	for call in patcher.parse(oDataScript.data).calls:
		var target = TAB_TARGETS.find(call.args[0])
		if call.command.ends_with("_AVAILABLE") and call.line.depth == 0 and target >= 0:
			oBasicPlayerTabs.get_child(target).pressed = true
			break
	refresh() # Opening never edits the script, victory blocks are only updated by the options that affect them


# Reads every control's value back from the script, so the script is always the only source of truth.
func refresh():
	if is_visible_in_tree() == false:
		return
	var scriptPath = oCurrentMap.currentFilePaths.get("TXT", [""])[0]
	oScriptEditor.visible = oCurrentMap.DKScript_enabled
	oScriptPathLinkButton.text = scriptPath.get_file() if scriptPath != "" else "Unsaved"
	oScriptPathLinkButton.hint_tooltip = scriptPath
	var parsed = patcher.parse(oDataScript.data)
	var editing = oScriptTextEdit.readonly == false
	var empty = oDataScript.data.strip_edges() == ""
	oCreateScriptButton.visible = editing == false and empty # Also once a script's text was deleted
	oBasicOptions.visible = editing == false and parsed.error_line == 0
	oBasicNotice.visible = editing == false and (parsed.error_line != 0 or empty)
	if parsed.error_line != 0:
		oBasicNotice.text = "Line " + str(parsed.error_line) + " has an IF without an ENDIF, or an ENDIF without an IF. Fix it with Edit to use the basic options."
		highlight_script_line(parsed.error_line)
	else:
		oBasicNotice.text = "This script is empty. The default setup makes the map playable."
	if oBasicOptions.visible == false:
		return
	var targets = []
	for call in parsed.calls:
		if call.line.depth == 0:
			targets.append(call.args[0])
	for tab in oBasicPlayerTabs.get_children():
		for style in ["normal", "hover", "pressed", "disabled"]: # Only the background, so the keeper's symbol keeps its colour
			tab.get_stylebox(style).modulate_color = MODIFIED if tab.get_index() > 0 and targets.has(TAB_TARGETS[tab.get_index()]) else Color(1, 1, 1)
	for field in numberFields:
		var finds = [patcher.find(parsed, field[1])] if field[1] == "SET_GENERATE_SPEED" else find_for_selected(parsed, field[1], [])
		var texts = []
		for found in finds:
			texts.append(found.back().args.back() if found.empty() == false else "")
		var mixed = texts.count(texts[0]) < texts.size()
		field[0].text = "" if mixed else texts[0]
		field[0].placeholder_text = "mixed" if mixed else "unset"
		field[0].set_meta("value", field[0].text)
		set_script_line(field[0].get_parent(), finds[0])
		field[0].modulate = MODIFIED if is_own(finds[0]) else Color(1, 1, 1)
	_on_PortalRateField_text_changed(oPortalRateField.text)
	var player = selected_player()
	oPortalRateField.get_parent().visible = player == "ALL_PLAYERS" # SET_GENERATE_SPEED has no player
	var computer = patcher.find(parsed, "COMPUTER_PLAYER", [player])
	oAIOption.set_item_text(0, "Lobby decides" if oDataLof.KIND == "MULTI" else "Idle")
	oAIOption.selected = {"OFF": 0, "ROAMING": 2}.get(computer.back().args[1] if computer.empty() == false else "OFF", 1)
	oAIOption.get_parent().visible = player != "ALL_PLAYERS" and (player != "PLAYER0" or oDataLof.KIND == "MULTI" or computer.empty() == false) # COMPUTER_PLAYER has no ALL_PLAYERS, and solo games always give the human Red
	set_script_line(oAIOption.get_parent(), computer)
	for parent in availableParents:
		for button in parent.get_children():
			var finds = find_for_selected(parsed, button.get_meta("command"), [button.get_meta("variable")])
			var states = []
			for found in finds:
				states.append(read_availability(button, found, parsed.version))
			button.set_availability_state(states[0] if states.count(states[0]) == states.size() else button.MIXED)
			button.get_node("%KeeperSymbol").texture = playerTabs.get_pressed_button().icon if is_own(finds[0]) else null
			set_script_line(button, finds[0])
			if button.has_meta("default_pool"):
				var poolLabel = button.get_node("%TextEditableLabel")
				var disabled = button.availabilityState == button.DISABLED # Says so like other items, rather than showing its pool
				poolLabel.editable = player == "ALL_PLAYERS" and disabled == false # The portal pool is shared by every keeper, like SET_GENERATE_SPEED
				poolLabel.mouse_filter = Control.MOUSE_FILTER_PASS if poolLabel.editable else Control.MOUSE_FILTER_IGNORE
				var pool = patcher.find(parsed, "ADD_CREATURE_TO_POOL", [button.get_meta("variable")])
				var total = 0
				for found in pool: # KeeperFX adds up every line
					total += int(found.args[1])
				if disabled == false:
					poolLabel.text = str(total)
				set_script_line(poolLabel, pool)


# Before LEVEL_VERSION(1), KeeperFX reads a creature's availability from the last argument.
func read_availability(button, found, version):
	var args = found.back().args if found.empty() == false else ["", "", "0", "0"]
	match button.get_meta("command"):
		"ROOM_AVAILABLE", "MAGIC_AVAILABLE":
			return button.START if int(args[3]) != 0 else (button.RESEARCH if int(args[2]) != 0 else button.DISABLED)
		"CREATURE_AVAILABLE":
			return button.ENABLED if int(args[3 if version == 0 else 2]) != 0 else button.DISABLED
	return button.ENABLED if int(args[2]) != 0 else button.DISABLED


func availability_values(button, state, version):
	match state:
		button.START: return ["1", "1"]
		button.RESEARCH: return ["1", "0"]
		button.ENABLED: return ["1", "1" if button.get_meta("command") == "CREATURE_AVAILABLE" and version == 0 else "0"]
	return ["0", "0"]


func selected_player():
	return TAB_TARGETS[playerTabs.get_pressed_button().get_index()]


func keepers(): # Old format maps only have the first four
	return PLAYERS.slice(0, 3) if oCurrentFormat.selected == Constants.OldFormat else PLAYERS


# The lines that apply to each selected keeper. The All players tab selects every keeper, so it shows what they all get.
# KeeperFX runs top-level commands in order, so whichever of the ALL_PLAYERS and the keeper's own line comes last applies.
func find_for_selected(parsed, command, rest):
	var shared = patcher.find(parsed, command, ["ALL_PLAYERS"] + rest)
	var finds = []
	for player in keepers() if selected_player() == "ALL_PLAYERS" else [selected_player()]:
		var own = patcher.find(parsed, command, [player] + rest)
		finds.append(own if own.empty() == false and (shared.empty() or own.back().line.number > shared.back().line.number) else shared)
	return finds


# On a keeper's tab, whether it has a line of its own rather than following All players.
func is_own(found):
	return selected_player() != "ALL_PLAYERS" and found.empty() == false and found.back().args[0] == selected_player()


# On the All players tab, or once every other keeper has the same value of its own, the ALL_PLAYERS line is written and every keeper's own line removed.
# Otherwise only the keeper's own line is written, and only while it differs from what the keeper inherits from ALL_PLAYERS.
# Empty values remove the line, as does an ALL_PLAYERS line that would only repeat the default of having no line.
# Resets are reported by apply() rather than here, so previewing one stays quiet.
func set_player_call(text, command, rest, values, inherited, default = []):
	var parsed = patcher.parse(text)
	var everyone = values.empty() == false
	for player in keepers():
		if player != selected_player():
			var own = patcher.find(parsed, command, [player] + rest)
			everyone = everyone and own.empty() == false and str(own.back().args) == str([player] + rest + values).to_upper()
	var target = "ALL_PLAYERS" if everyone else selected_player()
	var before = text
	for player in PLAYERS if target == "ALL_PLAYERS" else [target]:
		text = patcher.remove_call(text, command, [player] + rest).text
	var result = {}
	if values.empty() or values == (default if target == "ALL_PLAYERS" else inherited):
		result = patcher.remove_call(text, command, [target] + rest)
	else:
		result = patcher.set_call(text, command, [target] + rest + values)
	result.reset = selected_player() == "ALL_PLAYERS" and text != before
	return result


func set_script_line(control, found):
	control.set_meta("script_line", found.back().line.number if found.empty() == false else 0)


# Hovering an item the script has no line for previews the line a click would add
func _on_setting_mouse_entered(control):
	highlight_script_line(control.get_meta("script_line", 0))
	var result = availability_result(control, control.next_state(1)) if control.has_meta("cycle") and control.get_meta("script_line", 0) == 0 else {"line": 0}
	scriptPreview.visible = result.line > 0
	if result.line == 0:
		return
	var lines = result.text.split("\n")
	previewText = lines[result.line - 1].strip_edges()
	lines[result.line - 1] = ""
	scriptPreview.text = lines.join("\n")
	scriptPreview.add_font_override("font", oScriptTextEdit.get_font("font")) # Follows the editor's font size
	scriptPreview.cursor_set_line(result.line - 1)
	scriptPreview.center_viewport_to_cursor()


# A line's position is only known once it's drawn, so the preview line is drawn along with the others
func _on_scriptPreview_draw():
	var font = scriptPreview.get_font("font")
	var rect = scriptPreview.get_rect_at_line_column(scriptPreview.cursor_get_line(), 0)
	scriptPreview.draw_string(font, rect.position + Vector2(0, (rect.size.y - font.get_height()) / 2 + font.get_ascent()), previewText, Color(1, 1, 1, 0.25))


func highlight_script_line(line):
	if line <= 0:
		return
	oScriptTextEdit.cursor_set_line(line - 1)
	oScriptTextEdit.select(line - 1, 0, line - 1, oScriptTextEdit.get_line(line - 1).length())
	oScriptTextEdit.center_viewport_to_cursor()


func apply(result):
	if result.get("reset", false):
		oMessage.quick("Individual player settings were reset")
	if result.text != oDataScript.data and patcher.parse(oDataScript.data).error_line == 0: # Scripts with unmatched IF/ENDIF are never edited
		oScriptEditor.load_generated_text(result.text)
	refresh()
	highlight_script_line(result.line)


func _on_PortalRateField_text_changed(new_text):
	oPortalRateInSeconds.text = "" if new_text == "" else "(" + str(int(new_text) / 20.0) + "s)"


# An empty field removes its command
func _on_NumberField_apply(_new_text = ""):
	var result = {"text": oDataScript.data, "line": 0}
	for field in numberFields:
		var value = field[0].text.strip_edges()
		if value == field[0].get_meta("value", ""): # Rewriting an unedited field would clear the keepers' own lines
			continue
		var values = [] if value == "" else [str(int(value))]
		if field[1] == "SET_GENERATE_SPEED":
			result = patcher.remove_call(result.text, field[1], []) if values.empty() else patcher.set_call(result.text, field[1], values)
		else:
			var shared = patcher.find(patcher.parse(result.text), field[1], ["ALL_PLAYERS"])
			result = set_player_call(result.text, field[1], [], values, [str(int(shared.back().args.back()))] if shared.empty() == false else [])
	apply(result)


func _on_AIOption_item_selected(index):
	var player = selected_player()
	var result = {}
	match index:
		0: result = patcher.remove_call(oDataScript.data, "COMPUTER_PLAYER", [player])
		1: result = patcher.set_call(oDataScript.data, "COMPUTER_PLAYER", [player, "0"])
		2: result = patcher.set_call(patcher.set_level_version(oDataScript.data).text, "COMPUTER_PLAYER", [player, "ROAMING"])
	result.text = set_victory(result.text)
	apply(result)


# Every colour a human can play wins once all other dungeon hearts are destroyed, like KeeperFX's multiplayer maps.
# Without an enemy heart ALL_DUNGEONS_DESTROYED is true from the start, so the blocks are removed rather than winning instantly.
# The heroes always exist in KeeperFX, so their heart counts without a COMPUTER_PLAYER line.
func set_victory(text):
	var parsed = patcher.parse(text)
	var humans = human_slots(text)
	var opposed = humans > 1 or oInstances.check_for_dungeon_heart(Constants.PLAYER_WHITE)
	for index in range(humans, PLAYERS.size()):
		opposed = opposed or (patcher.find(parsed, "COMPUTER_PLAYER", [PLAYERS[index]]).empty() == false and oInstances.check_for_dungeon_heart(AI_HEART_OWNERS[index]))
	var wins = 0
	for line in parsed.lines:
		wins += int(patcher.squash(line.text).begins_with("WIN_GAME"))
	var result = text
	for index in 4:
		var block = ["IF(" + PLAYERS[index] + ",ALL_DUNGEONS_DESTROYED == 1)", "\tWIN_GAME", "ENDIF"]
		wins -= patcher.find_block(parsed, block).size()
		result = patcher.set_block(result, block, opposed and index < humans).text
	return text if wins > 0 else result # A script with a victory of its own is left alone


# KeeperFX seats humans on Red, Blue, Green then Yellow and a computer takes any seat with COMPUTER_PLAYER,
# so they get the run of "Lobby decides" keepers from Red. Saved as the map's Players, which caps the lobby.
func human_slots(text):
	var parsed = patcher.parse(text)
	var count = 0
	while oDataLof.KIND == "MULTI" and count < 4 and oInstances.check_for_dungeon_heart(count) and patcher.find(parsed, "COMPUTER_PLAYER", [PLAYERS[count]]).empty():
		count += 1
	return max(1, count)


# The script once the button is given this state, which a click applies and hovering previews
func availability_result(button, state):
	var parsed = patcher.parse(oDataScript.data)
	var rest = [button.get_meta("variable")]
	var inherited = read_availability(button, patcher.find(parsed, button.get_meta("command"), ["ALL_PLAYERS"] + rest), parsed.version)
	return set_player_call(oDataScript.data, button.get_meta("command"), rest, availability_values(button, state, parsed.version), availability_values(button, inherited, parsed.version), ["0", "0"]) # KeeperFX clears every dungeon on load, so nothing starts available


# KeeperFX adds up every line, so repeated lines are merged into one rather than each given the total
func _on_available_quantity_changed(button):
	var identity = [button.get_meta("variable")]
	var result = {"text": oDataScript.data, "line": 0}
	if button.get_integer() == 0 or patcher.find(patcher.parse(result.text), "ADD_CREATURE_TO_POOL", identity).size() > 1:
		result = patcher.remove_call(result.text, "ADD_CREATURE_TO_POOL", identity)
	if button.get_integer() > 0:
		result = patcher.set_call(result.text, "ADD_CREATURE_TO_POOL", identity + [str(button.get_integer())])
	apply(result)


func add_default_setup():
	var text = oDataScript.data
	if oCurrentFormat.selected == Constants.KfxFormat:
		text = patcher.set_level_version(text).text
	var version = patcher.parse(text).version
	for field in numberFields:
		text = patcher.set_call(text, field[1], ([] if field[1] == "SET_GENERATE_SPEED" else ["ALL_PLAYERS"]) + [field[2]]).text
	for index in range(human_slots(text), PLAYERS.size()):
		if oInstances.check_for_dungeon_heart(AI_HEART_OWNERS[index]):
			text = patcher.set_call(text, "COMPUTER_PLAYER", [PLAYERS[index], "0"]).text
	for parent in availableParents:
		for button in parent.get_children():
			if button.get_meta("default") != button.DISABLED:
				text = patcher.set_call(text, button.get_meta("command"), ["ALL_PLAYERS", button.get_meta("variable")] + availability_values(button, button.get_meta("default"), version)).text
			if button.get_meta("default_pool", 0) > 0:
				text = patcher.set_call(text, "ADD_CREATURE_TO_POOL", [button.get_meta("variable"), str(button.get_meta("default_pool"))]).text
	apply({"text": set_victory(text), "line": 0})
