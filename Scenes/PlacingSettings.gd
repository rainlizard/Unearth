extends VBoxContainer
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oPlacingListData = Nodelist.list["oPlacingListData"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oPlacingTipsButton = Nodelist.list["oPlacingTipsButton"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oLimitThing = Nodelist.list["oLimitThing"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPlaceLockedCheckBox = $EditingTools/PlaceLockedCheckBox
onready var oDoodadsSeparatorTop = Nodelist.list["oDoodadsSeparatorTop"]
onready var oDoodadsLabel = Nodelist.list["oDoodadsLabel"]
onready var oDoodadsSeparatorBottom = Nodelist.list["oDoodadsSeparatorBottom"]
onready var oDoodadsList = Nodelist.list["oDoodadsList"]
onready var oDoodadWindow = Nodelist.list["oDoodadWindow"]
onready var oDoodadSlabNameLabel = Nodelist.list["oDoodadSlabNameLabel"]
onready var oDoodadThingTypeOptionButton = Nodelist.list["oDoodadThingTypeOptionButton"]
onready var oDoodadSubtypeSpinBox = Nodelist.list["oDoodadSubtypeSpinBox"]
onready var oDoodadNameLabel = Nodelist.list["oDoodadNameLabel"]
onready var oDoodadChanceSpinBox = Nodelist.list["oDoodadChanceSpinBox"]
onready var oDoodadOrientationOptionButton = Nodelist.list["oDoodadOrientationOptionButton"]
onready var oDoodadAttachedCheckBox = Nodelist.list["oDoodadAttachedCheckBox"]
onready var oDoodadDeleteButton = Nodelist.list["oDoodadDeleteButton"]

# Default values for placement
var effectRange = 5
var creatureLevel = 1
var doorLocked = 0
var ownership = 0
var lightRange = 10
var lightIntensity = 32
var pointRange = 5
var boxNumber = 0
var creatureName = ""
var creatureGold = 0
var creatureInitialHealth = 100
var orientation = 0
var goldValue = 0
var doodad_edit_index = -1
var have_opened_doodad_window = false

enum FIELDS {
	SUBTYPE
	NAME_ID
	THINGTYPE
	OWNERSHIP
	EFFECT_RANGE
	CREATURE_LEVEL
	DOOR_LOCKED
	POINT_RANGE
	LIGHT_RANGE
	LIGHT_INTENSITY
	CUSTOM_BOX_ID
	INITIAL_HEALTH
	CREATURE_GOLD
	CREATURE_NAME
	ORIENTATION
}

func _ready():
	get_parent().set_tab_title(1, "Create")
	oPlaceLockedCheckBox.connect("toggled", self, "_on_PlaceLockedCheckBox_toggled")
	for orientationName in Constants.orientationNames:
		oDoodadOrientationOptionButton.add_item(orientationName)
	oDoodadOrientationOptionButton.add_item("Random")
	update_doodads()


func _input(event):
	if (event is InputEventKey) == false or event.pressed == false or event.echo == true: return
	if event.scancode != KEY_SPACE or is_visible_in_tree() == false: return
	if oPropertiesTabs.current_tab != 1 or (get_focus_owner() is LineEdit): return
	if oMapSettingsWindow.visible == true: return
	var inputHandled = oPlaceLockedCheckBox.visible
	if oPlaceLockedCheckBox.visible == true:
		oPlaceLockedCheckBox.pressed = oPlaceLockedCheckBox.pressed == false
	if toggle_cursor_door() == true:
		inputHandled = true
	if inputHandled == true:
		get_tree().set_input_as_handled()


func toggle_cursor_door():
	if oSelector.visible == false: return false
	var cursorTile = oSelector.cursorTile
	if Slabs.is_door(oSelector.get_slabID_at_pos(cursorTile)) == false: return false
	var doorNode = oInstances.get_node_on_subtile((cursorTile.x * 3) + 1.5, (cursorTile.y * 3) + 1.5, "Door")
	if is_instance_valid(doorNode) == false: return false
	doorNode.doorLocked = int(doorNode.doorLocked == 0)
	doorNode.update_spinning_key()
	oInstances.mirror_adjusted_value(doorNode, "doorLocked", Vector2(doorNode.locationX, doorNode.locationY))
	oEditor.mapHasBeenEdited = true
	oThingDetails.update_details()
	return true


func editing_mode_was_switched(modeString):
	if modeString == "Slab":
		update_placing_tab()
	else:
		set_placing_tab_and_update_it()

func _on_PropertiesTabs_tab_changed(tab):
	if tab == 1:
		set_placing_tab_and_update_it()


func update_doodads():
	var slabID = oSelection.paintSlab
	var doodads = []
	if oSelector.mode == oSelector.MODE_TILE and slabID != null:
		doodads = Settings.slabDoodads.get(slabID, [])
	var showDoodads = doodads.empty() == false
	oDoodadsSeparatorTop.visible = showDoodads
	oDoodadsLabel.visible = showDoodads
	oDoodadsSeparatorBottom.visible = showDoodads
	oDoodadsList.visible = showDoodads
	if showDoodads:
		update_doodads_list(doodads)
	if oDoodadWindow.visible == true and slabID != null: # The window was open while the selected slab changed
		doodad_edit_index = -1
		oDoodadWindow.window_title = "Add random doodad"
		oDoodadDeleteButton.visible = false
		oDoodadSlabNameLabel.text = Slabs.fetch_name(slabID)


func update_doodads_list(doodads):
	for child in oDoodadsList.get_children():
		oDoodadsList.remove_child(child)
		child.queue_free()
	
	for index in doodads.size():
		var doodad = doodads[index]
		var button = Button.new()
		button.text = Things.fetch_name(doodad[0], doodad[1]) + ' - ' + str(doodad[2]) + "%"
		button.align = Button.ALIGN_LEFT
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.connect("pressed", self, "open_doodad_window", [index])
		oDoodadsList.add_child(button)


func open_doodad_window(index):
	var slabID = oSelection.paintSlab
	if slabID == null:
		oMessage.quick("Select a slab first")
		return
	doodad_edit_index = index
	oDoodadWindow.window_title = "Edit random doodad" if index != -1 else "Add random doodad"
	oDoodadSlabNameLabel.text = Slabs.fetch_name(slabID)
	if index != -1:
		var doodad = Settings.slabDoodads[slabID][index]
		oDoodadThingTypeOptionButton.select(max(0, oDoodadThingTypeOptionButton.get_item_index(doodad[0])))
		oDoodadSubtypeSpinBox.value = doodad[1]
		oDoodadChanceSpinBox.value = doodad[2]
		var orientIndex = Constants.listOrientations.find(doodad[3])
		oDoodadOrientationOptionButton.select(orientIndex if orientIndex != -1 else Constants.listOrientations.size())
		oDoodadAttachedCheckBox.pressed = doodad[4]
	elif have_opened_doodad_window == false: # Defaults for the first time opening the window
		oDoodadThingTypeOptionButton.select(oDoodadThingTypeOptionButton.get_item_index(Things.TYPE.OBJECT))
		oDoodadSubtypeSpinBox.value = 1
		oDoodadChanceSpinBox.value = 0.25
		oDoodadOrientationOptionButton.select(0)
		oDoodadAttachedCheckBox.pressed = true
	have_opened_doodad_window = true
	oDoodadDeleteButton.visible = index != -1
	update_doodad_name()
	Utils.popup_centered(oDoodadWindow)


func update_doodad_name():
	oDoodadNameLabel.text = Things.fetch_name(oDoodadThingTypeOptionButton.get_selected_id(), int(oDoodadSubtypeSpinBox.value))


func _on_DoodadThingTypeOptionButton_item_selected(index):
	update_doodad_name()

func _on_DoodadSubtypeSpinBox_value_changed(value):
	update_doodad_name()

func _on_DoodadConfirmButton_pressed():
	var slabID = oSelection.paintSlab
	if Settings.slabDoodads.has(slabID) == false:
		Settings.slabDoodads[slabID] = []
	var orientation = -1
	if oDoodadOrientationOptionButton.selected < Constants.listOrientations.size():
		orientation = Constants.listOrientations[oDoodadOrientationOptionButton.selected]
	var doodad = [oDoodadThingTypeOptionButton.get_selected_id(), int(oDoodadSubtypeSpinBox.value), oDoodadChanceSpinBox.value, orientation, oDoodadAttachedCheckBox.pressed]
	if doodad_edit_index == -1:
		Settings.slabDoodads[slabID].append(doodad)
	else:
		Settings.slabDoodads[slabID][doodad_edit_index] = doodad
	Settings.save_slab_doodads()
	oDoodadWindow.hide()
	update_doodads()


func _on_DoodadDeleteButton_pressed():
	var slabID = oSelection.paintSlab
	Settings.slabDoodads[slabID].remove(doodad_edit_index)
	Settings.save_slab_doodads()
	oDoodadWindow.hide()
	update_doodads()


func replicate_instance_settings(aNode):
	var propertiesToReplicate = [
		"effectRange", "creatureLevel", "doorLocked", "ownership",
		"lightRange", "lightIntensity", "pointRange", "boxNumber",
		"creatureName", "creatureGold", "creatureInitialHealth",
		"orientation", "goldValue"
	]
	
	for propertyName in propertiesToReplicate:
		var valueFromNode = aNode.get(propertyName)
		if valueFromNode != null:
			set(propertyName, valueFromNode)
	
	if aNode.thingType == Things.TYPE.DOOR:
		oPlaceLockedCheckBox.pressed = bool(aNode.doorLocked)


func set_placing_tab_and_update_it():
	oPropertiesTabs.current_tab = 1
	update_placing_tab()

func update_placing_tab():
	oPlacingListData.clear()
	update_doodads()
	
	var thingType = oSelection.paintThingType
	var subtype = oSelection.paintSubtype
	
	var availableFields = []
	match thingType:
		Things.TYPE.NONE:
			availableFields = [FIELDS.SUBTYPE]
		Things.TYPE.OBJECT:
			availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE]
			if Things.is_custom_special_box(subtype) == true: # Custom Special Box
				availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.CUSTOM_BOX_ID]
			if oCurrentFormat.selected != Constants.OldFormat:
				availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.CREATURE:
			availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.CREATURE_LEVEL]
			if oCurrentFormat.selected != Constants.OldFormat:
				availableFields.append(FIELDS.INITIAL_HEALTH)
				availableFields.append(FIELDS.CREATURE_GOLD)
				availableFields.append(FIELDS.CREATURE_NAME)
				#availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.EFFECTGEN:
			availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.EFFECT_RANGE, FIELDS.ORIENTATION]
			if oCurrentFormat.selected != Constants.OldFormat:
				availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.TRAP:
			availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.ORIENTATION]
			if oCurrentFormat.selected != Constants.OldFormat:
				availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.DOOR:
			availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.DOOR_LOCKED]
		Things.TYPE.EXTRA:
			match subtype:
				1:
					availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.POINT_RANGE] # Action point
				2:
					availableFields = [FIELDS.SUBTYPE, FIELDS.NAME_ID, FIELDS.THINGTYPE, FIELDS.LIGHT_RANGE, FIELDS.LIGHT_INTENSITY] # Light
	
	for i in FIELDS.size():
		var description = null
		var value = null
		if i in availableFields:
			match i:
				FIELDS.SUBTYPE:
					description = "Name"
					value = Things.fetch_name(thingType, subtype)
				FIELDS.NAME_ID:
					description = "ID"
					value = Things.fetch_id_string(thingType, subtype)
				FIELDS.THINGTYPE:
					description = "Type"
					value = Things.data_structure_name.get(thingType, "Unknown") + " : " + str(subtype)
				FIELDS.EFFECT_RANGE:
					description = "Effect range" # 9-10
					value = effectRange
				FIELDS.CREATURE_LEVEL:
					description = "Level" # 14
					value = creatureLevel
				FIELDS.DOOR_LOCKED:
					description = "Door locked" # 14
					value = doorLocked
				FIELDS.POINT_RANGE:
					description = "Point range"
					value = pointRange
				FIELDS.LIGHT_RANGE:
					description = "Light range" # 9-10
					value = lightRange
				FIELDS.LIGHT_INTENSITY:
					description = "Intensity" # 9-10
					value = lightIntensity
				FIELDS.CUSTOM_BOX_ID:
					description = "Custom box" # 14
					value = boxNumber
				FIELDS.CREATURE_NAME:
					description = "Unique name"
					value = creatureName
				FIELDS.CREATURE_GOLD:
					description = "Gold held"
					value = creatureGold
				FIELDS.INITIAL_HEALTH:
					description = "Health %"
					value = creatureInitialHealth
				FIELDS.ORIENTATION:
					description = "Orientation"
					value = orientation

		if value != null:
			oPlacingListData.add_item(description, str(value))

func _on_PlacingTipsButton_pressed():
	var buildPlacingString = ""
	buildPlacingString += "- Right click on a Slab or Thing on the map to quickly pick its type. This is much faster than choosing it within the Slab window or Thing window."
	buildPlacingString += "\n"
	buildPlacingString += "- Hold CTRL while left clicking on a Thing to place overlapping Things. Things are never placed overlapped unless you do this."
	buildPlacingString += "\n"
	buildPlacingString += "- Press the DELETE key to quickly delete Things under cursor."
	buildPlacingString += "\n\n"
	buildPlacingString += "Check the controls in Help -> Controls for more."
	oMessage.big("Placing tips", buildPlacingString)
	Settings.set_setting("placing_tutorial", false)


func _on_DoodadHelpButton_pressed():
	var helptext = ""
	helptext += "Doodads are a decoration randomly placed on your slabs.\n\n"
	helptext += "If you're having trouble removing a doodad from existing slabs, try setting its chance to 0% instead of removing the doodad entry. Then place again."
	oMessage.big("Help", helptext)


func _on_FortifyCheckBox_toggled(button_pressed):
	Settings.set_setting("fortify", button_pressed)


func _on_PlaceLockedCheckBox_toggled(button_pressed):
	Settings.set_setting("place_locked", button_pressed)
