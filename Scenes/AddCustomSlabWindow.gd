extends WindowDialog
onready var oColumnEditorVoxelView = Nodelist.list["oColumnEditorVoxelView"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oGridContainerCustomColumns3x3 = Nodelist.list["oGridContainerCustomColumns3x3"]
onready var oCustomSlabID = Nodelist.list["oCustomSlabID"]
onready var oCustomSlabNameLabel = Nodelist.list["oCustomSlabNameLabel"]
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
onready var oColumnEditorControls = Nodelist.list["oColumnEditorControls"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oColumnEditor = Nodelist.list["oColumnEditor"]
onready var oFakeSlabCheckBox = Nodelist.list["oFakeSlabCheckBox"]
onready var oFakeCustomColumnsPanelContainer = Nodelist.list["oFakeCustomColumnsPanelContainer"]
onready var oSlabBitmaskOptionButton = Nodelist.list["oSlabBitmaskOptionButton"]
onready var oSlabIsSolidOptionButton = Nodelist.list["oSlabIsSolidOptionButton"]
onready var oSlabOwnableOptionButton = Nodelist.list["oSlabOwnableOptionButton"]


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
	
	_on_CustomSlabID_value_changed(oCustomSlabID.value)


func _on_AddCustomSlabWindow_visibility_changed():
	if visible == true:
		update_type()
		oCustomSlabVoxelView.initialize()

func shortcut_pressed(id):
	var spinbox = id.get_node("CustomSpinBox")
	var clmIndex = spinbox.value
	
	Utils.popup_centered(oColumnEditor)
	oColumnEditorControls.oColumnIndexSpinBox.value = clmIndex


func _on_CustomSlabID_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oCustomSlabNameLabel.text = slabName


func _on_AddCustomSlabButton_pressed():
	var is_fake = oFakeSlabCheckBox.pressed
	var newID
	if is_fake:
		newID = 1000 # We'll say fake slabs are ID 1000 and up
		# Find an unused ID within the fake data dictionary
		while Slabs.data.has(newID):
			newID += 1
	else:
		newID = int(oCustomSlabID.value) # For slabset, use the value from the UI
		if Slabs.data.has(newID):
			oMessage.big("Error", "For Slabset slabs you must use a unique ID. You may need to first delete the existing one.")
			return
	
	var slabCubeData = []
	var slabFloorData = []
	if is_fake: # For fake slabs, gather cube and floor data from the UI elements
		for id in oGridContainerCustomColumns3x3.get_children():
			var spinbox = id.get_node("CustomSpinBox")
			var clmIndex = spinbox.value
			slabCubeData.append(oDataClm.cubes[clmIndex])
			slabFloorData.append(oDataClm.floorTexture[clmIndex])
	
	var slab_dict = {
		"header_id": newID,
		"name": oNewSlabName.text,
		"recognized_as": int(oCustomSlabID.value),
		"liquid_type": oSlabLiquidOptionButton.get_selected_id(),
		"wibble_type": oSlabWibbleOptionButton.get_selected_id(),
		"wibble_edges": oWibbleEdgesCheckBox.pressed,
		"cube_data": slabCubeData,
		"floor_data": slabFloorData,
		"bitmask": oSlabBitmaskOptionButton.get_selected_id(),
		"is_solid": bool(oSlabIsSolidOptionButton.get_selected_id()),
		"ownable": bool(oSlabOwnableOptionButton.get_selected_id()),
	}
	oCustomSlabSystem.add_custom_slab(slab_dict)
	
	if oSlabBitmaskOptionButton.get_selected_id() == Slabs.BITMASK_DOOR1:
		var second_slab_dict = slab_dict.duplicate(true)
		var IdOfDoor2 = int(oCustomSlabID.value+1)
		second_slab_dict.header_id = newID+1
		second_slab_dict.recognized_as = IdOfDoor2
		oCustomSlabSystem.add_custom_slab(second_slab_dict)
		oMessage.big("Note", "ID: " + str(IdOfDoor2) + " was also added, it's assumed to be the other door direction.")
	
	oPickSlabWindow.add_slabs()
	oSlabTabs.current_tab = Slabs.TAB_CUSTOM
	oPickSlabWindow.set_selection(newID)


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
		var cubeArray = Columnset.cubes[srcClmIndex]
		var setFloorID = Columnset.floorTexture[srcClmIndex]
		var newIndex = oDataClm.index_entry(cubeArray, setFloorID)
		customSlabArrayOfSpinbox[i].value = newIndex
	
	#oMessage.big("", "Columns in your map's .clm file have been found that match the columns from slabs.clm/dat. Any that weren't found were added.")

func get_column_indexes_on_tile(cursorTile):
	for ySubtile in 3:
		for xSubtile in 3:
			var newIndex = oDataClmPos.get_cell((cursorTile.x*3)+xSubtile, (cursorTile.y*3)+ySubtile)
			var i = (ySubtile*3) + xSubtile
			customSlabArrayOfSpinbox[i].value = newIndex



func update_type():
	if oFakeSlabCheckBox.pressed == true:
		oFakeCustomColumnsPanelContainer.visible = true
		oCustomSlabVoxelView.modulate.a = 1
	else:
		oFakeCustomColumnsPanelContainer.visible = false
		oCustomSlabVoxelView.modulate.a = 0


func _on_SlabsetSlabCheckBox_pressed():
	update_type()

func _on_FakeSlabCheckBox_pressed():
	update_type()


func _on_FakeSlabHelpButton_pressed():
	var helptext = ""
	helptext += "Fake slabs will work in any solo map.\n"
	helptext += "They typically reset their appearance when placing or claiming an adjacent slab.\n"
	helptext += "Set 'Slab ID' to Slab 50 to prevent the appearance from changing.\n"
	helptext += "There's a few other IDs you can use which may not reset: Impenetrable Rock, Gold, Bridge, Gems, Guard post. But this needs further testing.\n\n"
	helptext += "Right click on the map while the Fake slab menu is open to copy column index numbers into the window."
	oMessage.big("Help",helptext)

func _on_SlabsetSlabHelpButton_pressed():
	var helptext = ""
	helptext += "Slabset slabs will only work in a campaign/mappack. It requires the slabset.cfg and columnset.cfg files to be in the correct place."
	oMessage.big("Help",helptext)

func _on_HelpCustomSlabsButton_pressed():
	var helptext = ""
	helptext += "After adding a custom slab, right click on its portrait within the slab selection window to remove it from the editor."
	oMessage.big("Help",helptext)
