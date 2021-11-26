extends WindowDialog
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oNewObjectSubtypeID = Nodelist.list["oNewObjectSubtypeID"]
onready var oNewObjectName = Nodelist.list["oNewObjectName"]
onready var oNewObjectTab = Nodelist.list["oNewObjectTab"]
onready var oNewObjectType = Nodelist.list["oNewObjectType"]
onready var oQuickMessage = Nodelist.list["oQuickMessage"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oThingTabs = Nodelist.list["oThingTabs"]
onready var oCustomData = Nodelist.list["oCustomData"]
onready var oWarningIdInUse = Nodelist.list["oWarningIdInUse"]

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
	if value <= thing_list_size(get_thingType()):
		oWarningIdInUse.visible = true
	else:
		oWarningIdInUse.visible = false

func _on_AddCustomObjectButton_pressed():
	if oNewObjectName.text == "":
		oQuickMessage.message("Enter a name")
		return
	if oNewObjectSubtypeID.text == "":
		oQuickMessage.message("Enter an ID")
		return
	
	var array = [
	oNewObjectName.text, # Name
	null, # Image
	null, # Portrait
	oNewObjectTab.get_item_metadata(oNewObjectTab.selected),
	]
	
	var subtype = int(oNewObjectSubtypeID.text)
	
	var thingType = get_thingType()
	
	oCustomData.add_object(thingType, subtype, array)
	
	# Close window
	visible = false
	
	# Switch to show the thing you've added
	oSelector.change_mode(oSelector.MODE_SUBTILE)
	for i in oThingTabs.get_tab_count():
		if oThingTabs.get_tab_control(i) == oPickThingWindow.tabs[oNewObjectTab.get_item_metadata(oNewObjectTab.selected)]:
			oThingTabs.current_tab = i
	
	# Clear the stuff you set
	oNewObjectName.text = ""
	oNewObjectSubtypeID.text = ""

func _on_NewObjectSubtypeID_focus_exited():
	var value = int(oNewObjectSubtypeID.text)
	value = clamp(value, 0, 255) # Needs to fit within a byte for saving and loading to work correctly.
	oNewObjectSubtypeID.text = str(value)


func get_thingType():
	match oNewObjectType.selected:
		0: return Things.TYPE.OBJECT
		1: return Things.TYPE.CREATURE
		2: return Things.TYPE.EFFECT
		3: return Things.TYPE.TRAP
		4: return Things.TYPE.DOOR

func thing_list_size(type):
	match type:
		Things.TYPE.OBJECT: return Things.DATA_OBJECT.size()
		Things.TYPE.CREATURE: return Things.DATA_CREATURE.size()
		Things.TYPE.EFFECT: return Things.DATA_EFFECT.size()
		Things.TYPE.TRAP: return Things.DATA_TRAP.size()
		Things.TYPE.DOOR: return Things.DATA_DOOR.size()
		Things.TYPE.EXTRA: return Things.DATA_EXTRA.size()

func _on_NewObjectType_item_selected(index):
	autoFillSubtypeField()

func autoFillSubtypeField():
	var theNextEmptySubtypeID = thing_list_size(get_thingType()) + 1
	oNewObjectSubtypeID.text = str(theNextEmptySubtypeID)

func _on_AddCustomObjectWindow_visibility_changed():
	if visible == true:
		autoFillSubtypeField()
