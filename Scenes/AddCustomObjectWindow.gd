extends WindowDialog
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oNewObjectSubtypeID = Nodelist.list["oNewObjectSubtypeID"]
onready var oNewObjectName = Nodelist.list["oNewObjectName"]
onready var oNewObjectTab = Nodelist.list["oNewObjectTab"]
onready var oNewObjectType = Nodelist.list["oNewObjectType"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oThingTabs = Nodelist.list["oThingTabs"]
onready var oCustomObjectSystem = Nodelist.list["oCustomObjectSystem"]
onready var oWarningIdInUse = Nodelist.list["oWarningIdInUse"]
onready var oCustomObjectImageFileDialog = Nodelist.list["oCustomObjectImageFileDialog"]
onready var oLabelCustomObjectImagePath = Nodelist.list["oLabelCustomObjectImagePath"]

var tab = Things.TAB_CREATURE

func _ready():
	oWarningIdInUse.visible = false
	var optionButtonIndex = 0
	for tabEnum in oPickThingWindow.tabs:
		oNewObjectTab.add_item(oPickThingWindow.tabs[tabEnum][oPickThingWindow.GRIDCON_PATH].name)
		oNewObjectTab.set_item_metadata(optionButtonIndex, tabEnum)
		optionButtonIndex += 1

func _process(delta):
	if visible == false: return
	
	var value = int(oNewObjectSubtypeID.text)
	oWarningIdInUse.visible = thinglist_has_subtype(get_thingType(), value)

func _on_AddCustomObjectButton_pressed():
	var imgSrc = oLabelCustomObjectImagePath.text
	if imgSrc != "":
		var imgDest = Settings.unearthdata.plus_file("custom-object-images").plus_file(imgSrc.get_file())
		var dir = Directory.new()
		var successOrFailure = dir.copy(imgSrc, imgDest)
		if successOrFailure != OK:
			oMessage.quick("Error " + str(successOrFailure) + ": failed copying image.")
			return
	
	var givenName = oNewObjectName.text
	
	if givenName == "":
		oMessage.quick("Enter a name")
		return
	if oNewObjectSubtypeID.text == "":
		oMessage.quick("Enter an ID")
		return
	
	var tabToPlaceIn = oNewObjectTab.get_item_metadata(oNewObjectTab.selected)
	
	
	
	Settings.unearthdata.plus_file("custom-object-images").plus_file(filename)
	
	oCustomObjectSystem.add_object([
	get_thingType(), # thingType
	int(oNewObjectSubtypeID.text), # subtype
	givenName, # Name
	imgSrc.get_file(), # Image
	imgSrc.get_file(), # Portrait
	tabToPlaceIn,
	])
	
	# Close window
	visible = false
	
	# Switch to show the thing you've added
	oSelector.change_mode(oSelector.MODE_SUBTILE)
	
	
	for i in oThingTabs.get_tab_count():
		if oThingTabs.get_tab_control(i) == oPickThingWindow.tabs[tabToPlaceIn][oPickThingWindow.GRIDCON_PATH]:
			oThingTabs.current_tab = i
	
	# Clear the stuff you set
	oNewObjectName.text = ""
	oNewObjectSubtypeID.text = ""

func _on_NewObjectSubtypeID_focus_exited():
	var value = int(oNewObjectSubtypeID.text)
	value = clamp(value, 0, 255) # Needs to fit within a byte for saving and loading to work correctly.
	oNewObjectSubtypeID.text = str(value)



func _on_NewObjectType_item_selected(index):
	auto_fill_subtype_field()


func _on_AddCustomObjectWindow_visibility_changed():
	if visible == true:
		auto_fill_subtype_field()
	else:
		yield(get_tree(),'idle_frame')
		oLabelCustomObjectImagePath.text = ""

func auto_fill_subtype_field():
	var theNextEmptySubtypeID = get_empty_entry_thinglist(get_thingType())
	oNewObjectSubtypeID.text = str(theNextEmptySubtypeID)



func get_thingType():
	match oNewObjectType.selected:
		0: return Things.TYPE.OBJECT
		1: return Things.TYPE.CREATURE
		2: return Things.TYPE.EFFECT
		3: return Things.TYPE.TRAP
		4: return Things.TYPE.DOOR

func thinglist_has_subtype(thingType, subtype):
	if subtype == 0: return true # Don't allow 0 to be recognized as empty
	
	match thingType:
		Things.TYPE.OBJECT: return Things.DATA_OBJECT.has(subtype)
		Things.TYPE.CREATURE: return Things.DATA_CREATURE.has(subtype)
		Things.TYPE.EFFECT: return Things.DATA_EFFECT.has(subtype)
		Things.TYPE.TRAP: return Things.DATA_TRAP.has(subtype)
		Things.TYPE.DOOR: return Things.DATA_DOOR.has(subtype)
		Things.TYPE.EXTRA: return Things.DATA_EXTRA.has(subtype)

func get_empty_entry_thinglist(thingType):
	var db
	match thingType:
		Things.TYPE.OBJECT:  db = Things.DATA_OBJECT
		Things.TYPE.CREATURE:  db = Things.DATA_CREATURE
		Things.TYPE.EFFECT:  db = Things.DATA_EFFECT
		Things.TYPE.TRAP:  db = Things.DATA_TRAP
		Things.TYPE.DOOR:  db = Things.DATA_DOOR
		Things.TYPE.EXTRA:  db = Things.DATA_EXTRA
	
	var i = 1 # These arrays don't start at 0
	while true:
		if db.has(i) == false:
			return i
		i += 1


func _on_NewObjectImage_pressed():
	Utils.popup_centered(oCustomObjectImageFileDialog)


func _on_CustomObjectImageFileDialog_file_selected(filePath):
	oLabelCustomObjectImagePath.text = filePath
