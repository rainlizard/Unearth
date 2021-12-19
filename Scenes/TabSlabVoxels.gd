extends HBoxContainer
onready var oGridContainerForChoosing3x3 = Nodelist.list["oGridContainerForChoosing3x3"]
onready var oSlabVoxelView = Nodelist.list["oSlabVoxelView"]
onready var oSlabRecognizedAs = Nodelist.list["oSlabRecognizedAs"]
onready var oSlabRecognizedAsName = Nodelist.list["oSlabRecognizedAsName"]
onready var oCustomSlabsTab = Nodelist.list["oCustomSlabsTab"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oCustomSlabData = Nodelist.list["oCustomSlabData"]
onready var oNewSlabName = Nodelist.list["oNewSlabName"]
onready var oSlabTabs = Nodelist.list["oSlabTabs"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataClm = Nodelist.list["oDataClm"]

var cssb = preload('res://Scenes/CustomSlabSpinBox.tscn')

func _ready():
	for number in 9:
		var id = cssb.instance()
		id.connect("value_changed",oSlabVoxelView,"_on_CustomSlabSpinBox_value_changed")
		oGridContainerForChoosing3x3.add_child(id)
	
	_on_SlabRecognizedAs_value_changed(oSlabRecognizedAs.value)


func _on_SlabRecognizedAs_value_changed(value):
	var slabName = "Unrecognized Slab ID"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oSlabRecognizedAsName.text = slabName


func _on_AddCustomSlabButton_pressed():
	var newID = 61+oCustomSlabData.data.size() #we'll consider 0-60 as taken by the game
	
	var slabName = oNewSlabName.text
	var bitmaskType = Slabs.BITMASK_TALL
	var isSolid = Slabs.BLOCK_SLAB
	var panelView = Slabs.PANEL_TOP_VIEW
	var sideViewZOffset = 0
	var editorTab = Slabs.TAB_CUSTOM
	var wibbleType = Slabs.WIBBLE_ON
	var liquidType = Slabs.NOT_LIQUID
	var isOwnable = Slabs.OWNABLE
	
	var generalArray = [slabName, isSolid, bitmaskType, panelView, sideViewZOffset, editorTab, wibbleType, liquidType, isOwnable]
	
	var slabCubeData = []
	var slabFloorData = []
	for i in oGridContainerForChoosing3x3.get_children():
		var clmIndex = i.value
		slabCubeData.append(oDataClm.cubes[clmIndex])
		slabFloorData.append(oDataClm.floorTexture[clmIndex])
	
	oCustomSlabData.add_custom_slab(newID, generalArray, oSlabRecognizedAs.value, slabCubeData, slabFloorData)
	
	oPickSlabWindow.add_slabs()
	oSlabTabs.current_tab = Slabs.TAB_CUSTOM


func _on_HelpCustomSlabsButton_pressed():
	var helptext = "\n"
	helptext += "In both editor and game, placing/claiming slabs next to a custom slab may reset the slab's appearance to the value of 'Recognized as'.\n"
	helptext += "With the following exceptions: Slab 50, Impenetrable Rock, Water, Lava, Gold, Bridge, Gems, Guard post, Doors without door object. (may need further testing)\n"
	oMessage.big("Help",helptext)
	pass # Replace with function body.
