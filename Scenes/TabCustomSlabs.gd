extends HBoxContainer
onready var oGridContainerCustomColumns3x3 = Nodelist.list["oGridContainerCustomColumns3x3"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
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
onready var oColumnEditorTabs = Nodelist.list["oColumnEditorTabs"]
onready var oColumnEditorControls = Nodelist.list["oColumnEditorControls"]
onready var oDkClm = Nodelist.list["oDkClm"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]

var scnColumnSetter = preload('res://Scenes/ColumnSetter.tscn')
var customSlabArrayOfSpinbox = []

func _ready():
	for number in 9:
		var id = scnColumnSetter.instance()
		var spinbox = id.get_node("CustomSpinBox")
		var shortcut = id.get_node("ButtonShortcut")
		shortcut.connect("pressed",self,"shortcut_pressed",[id])
		spinbox.max_value = 2047
		spinbox.connect("value_changed",oCustomSlabVoxelView,"_on_CustomSlabSpinBox_value_changed")
		customSlabArrayOfSpinbox.append(spinbox)
		oGridContainerCustomColumns3x3.add_child(id)
	
	_on_SlabRecognizedAs_value_changed(oSlabRecognizedAs.value)

func shortcut_pressed(id):
	var spinbox = id.get_node("CustomSpinBox")
	var clmIndex = spinbox.value
	oColumnEditorTabs.set_current_tab(0)
	oColumnEditorControls.oColumnIndexSpinBox.value = clmIndex

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
	var recognizedAs = oSlabRecognizedAs.value
	var liquidType = oSlabLiquidOptionButton.get_selected_id()
	var wibbleType = oSlabWibbleOptionButton.get_selected_id() #Slabs.WIBBLE_ON
	var wibbleEdges = oWibbleEdgesCheckBox.pressed
	
	var slabCubeData = []
	var slabFloorData = []
	for id in oGridContainerCustomColumns3x3.get_children():
		var spinbox = id.get_node("CustomSpinBox")
		var clmIndex = spinbox.value
		slabCubeData.append(oDataClm.cubes[clmIndex])
		slabFloorData.append(oDataClm.floorTexture[clmIndex])
	
	oCustomSlabSystem.add_custom_slab(newID, slabName, recognizedAs, liquidType, wibbleType, wibbleEdges, slabCubeData, slabFloorData)
	
	oPickSlabWindow.add_slabs()
	oSlabTabs.current_tab = Slabs.TAB_CUSTOM
	oPickSlabWindow.set_selection(newID)

func _on_HelpCustomSlabsButton_pressed():
	var helptext = ""
	helptext += "With a few exceptions, most custom slabs will reset their appearance in-game when placing or claiming an adjacent slab. To avoid this, set 'Recognized as' to one of the following: Slab 50, Impenetrable Rock, Gold, Bridge, Gems, Guard post, Doors (without door object). Needs further testing."
	helptext += "\n\n"
	helptext += "After adding one, right click on its portrait within the slab picker window to remove custom slabs from the editor."
	helptext += "\n\n"
	helptext += "Right click on the map while the custom slab menu is open to copy column index numbers into the window."
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

func copy_values_from_slabset_and_index_them():
	for i in 9:
		var srcClmIndex = oSlabsetWindow.columnSettersArray[i].get_node("CustomSpinBox").value
		var cubeArray = oDkClm.cubes[srcClmIndex]
		var setFloorID = oDkClm.floorTexture[srcClmIndex]
		var newIndex = oDataClm.index_entry(cubeArray, setFloorID)
		customSlabArrayOfSpinbox[i].value = newIndex
	
	#oMessage.big("", "Columns in your map's .clm file have been found that match the columns from slabs.clm/dat. Any that weren't found were added.")

func get_column_indexes_on_tile(cursorTile):
	for ySubtile in 3:
		for xSubtile in 3:
			var newIndex = oDataClmPos.get_cell((cursorTile.x*3)+xSubtile, (cursorTile.y*3)+ySubtile)
			var i = (ySubtile*3) + xSubtile
			customSlabArrayOfSpinbox[i].value = newIndex
