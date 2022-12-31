extends VBoxContainer
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oPlacingListData = Nodelist.list["oPlacingListData"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oPlacingTipsButton = Nodelist.list["oPlacingTipsButton"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oLimitThing = Nodelist.list["oLimitThing"]

# Default values for placement
var effectRange = 5
var creatureLevel = 1
var doorLocked = 0
var ownership = 0
var lightRange = 10
var lightIntensity = 32
var pointRange = 5
var boxNumber = 0

enum FIELDS {
	NAME = 0
	TYPE = 1
	OWNERSHIP = 2
	EFFECT_RANGE = 3
	CREATURE_LEVEL = 4
	DOOR_LOCKED = 5
	POINT_RANGE = 6
	LIGHT_RANGE = 7
	LIGHT_INTENSITY = 8
	CUSTOM_BOX_ID = 9
}

func _ready():
	get_parent().set_tab_title(1, "Create")

func editing_mode_was_switched(modeString):
	if modeString == "Slab":
		oPlacingListData.clear()
	else:
		update_and_set_placing_tab()

func _on_PropertiesTabs_tab_changed(tab):
	if tab == 1:
		update_and_set_placing_tab()

func update_and_set_placing_tab():
	oPropertiesTabs.current_tab = 1
	oPlacingListData.clear()
	
	var thingType = oSelection.paintThingType
	var subtype = oSelection.paintSubtype
	
	var availableFields = []
	match thingType:
		Things.TYPE.NONE:
			availableFields = [FIELDS.NAME]
		Things.TYPE.OBJECT:
			availableFields = [FIELDS.NAME, FIELDS.TYPE]
			if subtype == 133: #Mysterious Box
				availableFields = [FIELDS.NAME, FIELDS.TYPE, FIELDS.CUSTOM_BOX_ID]
		Things.TYPE.CREATURE:
			availableFields = [FIELDS.NAME, FIELDS.TYPE, FIELDS.CREATURE_LEVEL]
		Things.TYPE.EFFECTGEN:
			availableFields = [FIELDS.NAME, FIELDS.TYPE, FIELDS.EFFECT_RANGE]
		Things.TYPE.TRAP:
			availableFields = [FIELDS.NAME, FIELDS.TYPE]
		Things.TYPE.DOOR:
			availableFields = [FIELDS.NAME, FIELDS.TYPE, FIELDS.DOOR_LOCKED]
		Things.TYPE.EXTRA:
			match subtype:
				1:
					availableFields = [FIELDS.NAME, FIELDS.TYPE, FIELDS.POINT_RANGE] # Action point
				2:
					availableFields = [FIELDS.NAME, FIELDS.TYPE, FIELDS.LIGHT_RANGE, FIELDS.LIGHT_INTENSITY] # Light
	
	
	
	for i in FIELDS.size():
		var description = null
		var value = null
		if i in availableFields:
			match i:
				FIELDS.NAME:
					description = "Name"
					value = oThingDetails.retrieve_thing_name(thingType, subtype)
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
					match doorLocked:
						0: value = "False"
						1: value = "True"
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
