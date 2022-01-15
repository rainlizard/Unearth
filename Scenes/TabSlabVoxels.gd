extends HBoxContainer
onready var oGridContainerForChoosing3x3 = Nodelist.list["oGridContainerForChoosing3x3"]
onready var oSlabVoxelView = Nodelist.list["oSlabVoxelView"]
onready var oSlabRecognizedAs = Nodelist.list["oSlabRecognizedAs"]
onready var oSlabRecognizedAsName = Nodelist.list["oSlabRecognizedAsName"]
onready var oCustomSlabsTab = Nodelist.list["oCustomSlabsTab"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
onready var oNewSlabName = Nodelist.list["oNewSlabName"]
onready var oSlabTabs = Nodelist.list["oSlabTabs"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oSlabWibbleOptionButton = Nodelist.list["oSlabWibbleOptionButton"]
onready var oSlabLiquidOptionButton = Nodelist.list["oSlabLiquidOptionButton"]
onready var oWibbleEdgesCheckBox = Nodelist.list["oWibbleEdgesCheckBox"]
onready var oWibbleEdgesSpacing = Nodelist.list["oWibbleEdgesSpacing"]

func _ready():
	for number in 9:
		var id = CustomSpinBox.new()
		id.max_value = 2047
		id.connect("value_changed",oSlabVoxelView,"_on_CustomSlabSpinBox_value_changed")
		
		oGridContainerForChoosing3x3.add_child(id)
	
	_on_SlabRecognizedAs_value_changed(oSlabRecognizedAs.value)


func _on_SlabRecognizedAs_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oSlabRecognizedAsName.text = slabName


func _on_AddCustomSlabButton_pressed():
	var newID = 1000 # We'll say custom slabs are ID 1000 and up
	while true: # Find an unused ID within the custom data dictionary
		if oCustomSlabSystem.data.has(newID) == false:
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
	var liquidType = oSlabLiquidOptionButton.get_selected_id()
	var isOwnable = Slabs.OWNABLE
	
	
	var generalArray = [slabName, isSolid, bitmaskType, panelView, sideViewZOffset, editorTab, wibbleType, liquidType, isOwnable]
	
	var slabCubeData = []
	var slabFloorData = []
	for i in oGridContainerForChoosing3x3.get_children():
		var clmIndex = i.value
		slabCubeData.append(oDataClm.cubes[clmIndex])
		slabFloorData.append(oDataClm.floorTexture[clmIndex])
	
	oCustomSlabSystem.add_custom_slab(newID, generalArray, oSlabRecognizedAs.value, slabCubeData, slabFloorData, oWibbleEdgesCheckBox.pressed)
	
	oPickSlabWindow.add_slabs()
	oSlabTabs.current_tab = Slabs.TAB_CUSTOM
	oPickSlabWindow.set_selection(newID)

func _on_HelpCustomSlabsButton_pressed():
	var helptext = ""
	helptext += "With a few exceptions, most custom slabs will reset their appearance in-game when placing or claiming an adjacent slab. To avoid this, set 'Recognized as' to one of the following: Slab 50, Impenetrable Rock, Gold, Bridge, Gems, Guard post, Doors (without door object). Needs further testing."
	helptext += "\n\n"
	helptext += "Right click their portrait within the slab picker window to remove custom slabs from the editor."
	#helptext += "\n\n"
	#helptext += "For now, placing a custom slab on a new/different map than the one you created it on, will not carry over the exact same column data."
	oMessage.big("Help",helptext)


func _on_SlabWibbleOptionButton_item_selected(index):
	if index != 1:
		oWibbleEdgesSpacing.visible = true
		oWibbleEdgesCheckBox.visible = true
	else:
		oWibbleEdgesSpacing.visible = false
		oWibbleEdgesCheckBox.visible = false
