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

enum FIELDS {
	ID
	TYPE
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

func editing_mode_was_switched(modeString):
	if modeString == "Slab":
		oPlacingListData.clear()
	else:
		set_placing_tab_and_update_it()

func _on_PropertiesTabs_tab_changed(tab):
	if tab == 1:
		set_placing_tab_and_update_it()

func set_placing_tab_and_update_it():
	oPropertiesTabs.current_tab = 1
	update_placing_tab()

func update_placing_tab():
	oPlacingListData.clear()
	
	var thingType = oSelection.paintThingType
	var subtype = oSelection.paintSubtype
	
	var availableFields = []
	match thingType:
		Things.TYPE.NONE:
			availableFields = [FIELDS.ID]
		Things.TYPE.OBJECT:
			availableFields = [FIELDS.ID, FIELDS.TYPE]
			if subtype == 133: #Mysterious Box
				availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.CUSTOM_BOX_ID]
			if oCurrentFormat.selected != 0: # Classic format
				availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.CREATURE:
			availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.CREATURE_LEVEL]
			if oCurrentFormat.selected != 0: # Classic format
				availableFields.append(FIELDS.INITIAL_HEALTH)
				availableFields.append(FIELDS.CREATURE_GOLD)
				availableFields.append(FIELDS.CREATURE_NAME)
				#availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.EFFECTGEN:
			availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.EFFECT_RANGE, FIELDS.ORIENTATION]
			if oCurrentFormat.selected != 0: # Classic format
				availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.TRAP:
			availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.ORIENTATION]
			if oCurrentFormat.selected != 0: # Classic format
				availableFields.append(FIELDS.ORIENTATION)
		Things.TYPE.DOOR:
			availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.DOOR_LOCKED]
		Things.TYPE.EXTRA:
			match subtype:
				1:
					availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.POINT_RANGE] # Action point
				2:
					availableFields = [FIELDS.ID, FIELDS.TYPE, FIELDS.LIGHT_RANGE, FIELDS.LIGHT_INTENSITY] # Light
	
	for i in FIELDS.size():
		var description = null
		var value = null
		if i in availableFields:
			match i:
				FIELDS.ID:
					description = "ID"
					value = Things.fetch_name(thingType, subtype)
				FIELDS.TYPE:
					description = "Type"
					value = oThingDetails.retrieve_subtype_value(thingType, subtype)
#				FIELDS.OWNERSHIP:
#					description = "Ownership"
#					value = Constants.ownershipNames[ownership]
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
					description = "Name" #Creature name
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


func _on_FortifyCheckBox_toggled(button_pressed):
	Settings.set_setting("fortify", button_pressed)
