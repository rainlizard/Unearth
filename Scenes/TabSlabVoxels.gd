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
onready var oSlabWibbleOptionButton = Nodelist.list["oSlabWibbleOptionButton"]
onready var oSlabLiquidOptionButton = Nodelist.list["oSlabLiquidOptionButton"]

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
	var newID = 1000 # We'll say custom slabs are ID 1000 and up
	while true: # Find an unused ID within the custom data dictionary
		if oCustomSlabData.data.has(newID) == false:
			break
		else:
			newID += 1
	
	var slabName = oNewSlabName.text
	var bitmaskType = Slabs.BITMASK_TALL
	var isSolid = Slabs.BLOCK_SLAB
	var panelView = Slabs.PANEL_TOP_VIEW
	var sideViewZOffset = 0
	var editorTab = Slabs.TAB_CUSTOM
	var wibbleType = oSlabWibbleOptionButton.get_selected_id()#Slabs.WIBBLE_ON
	var liquidType = oSlabLiquidOptionButton.get_selected_id()#Slabs.NOT_LIQUID
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
	helptext += "With a few exceptions, most custom slabs will reset their appearance when placing on or claiming an adjacent slab. \n"
	helptext += "To avoid this, set 'Recognized as' to one of the following: Slab 50, Impenetrable Rock, Gold, Bridge, Gems, Guard post, Water and Lava (while not marked as liquid), Doors (without door object). Needs further testing.\n"
	helptext += "To remove custom slabs, right click their portrait within the slab picker window."
	oMessage.big("Help",helptext)
