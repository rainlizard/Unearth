extends WindowDialog
onready var oAddCustomSlabWindow = Nodelist.list["oAddCustomSlabWindow"]
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
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
onready var oClmEditorControls = Nodelist.list["oClmEditorControls"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oFakeCustomColumnsPanelContainer = Nodelist.list["oFakeCustomColumnsPanelContainer"]
onready var oSlabBitmaskOptionButton = Nodelist.list["oSlabBitmaskOptionButton"]
onready var oSlabIsSolidOptionButton = Nodelist.list["oSlabIsSolidOptionButton"]
onready var oSlabOwnableOptionButton = Nodelist.list["oSlabOwnableOptionButton"]
onready var oPassageLabel = Nodelist.list["oPassageLabel"]
onready var oSlabsetTabs = Nodelist.list["oSlabsetTabs"]

onready var oCustomDoorThingLabel = Nodelist.list["oCustomDoorThingLabel"]
onready var oCustomDoorThing = Nodelist.list["oCustomDoorThing"]
onready var oCustomDoorThingEmptySpace = Nodelist.list["oCustomDoorThingEmptySpace"]
onready var oCustomDoorThingIDNameLabel = Nodelist.list["oCustomDoorThingIDNameLabel"]

var scnColumnSetter = preload('res://Scenes/ColumnSetter.tscn')
var customSlabArrayOfSpinbox = []


func _ready():
	for number in 9:
		var id = scnColumnSetter.instance()
		var spinbox = id.get_node("CustomSpinBox")
		var shortcut = id.get_node("ButtonShortcut")
		shortcut.connect("pressed",self,"shortcut_pressed",[id])
		spinbox.min_value = 1
		spinbox.max_value = oDataClm.column_count-1
		spinbox.value = 1
		spinbox.connect("value_changed",oCustomSlabVoxelView,"_on_CustomSlabSpinBox_value_changed")
		customSlabArrayOfSpinbox.append(spinbox)
		id.size_flags_vertical = Control.SIZE_EXPAND_FILL
		oGridContainerCustomColumns3x3.add_child(id)
	
	_on_CustomSlabID_value_changed(oCustomSlabID.value)
	_on_SlabBitmaskOptionButton_item_selected(0)

func _on_AddCustomSlabWindow_visibility_changed():
	if visible == true:
		update_type()
		oCustomSlabVoxelView.initialize()
		
		# Due to a strange bug I don't understand, the oCustomSlabVoxelView is skewed until I resize the window. This fixes that.
		rect_size += Vector2(1,1)
		yield(get_tree(),'idle_frame')
		rect_size -= Vector2(1,1)
		

func shortcut_pressed(id):
	var spinbox = id.get_node("CustomSpinBox")
	var clmIndex = spinbox.value
	
	oSlabsetWindow.popup_on_right_side()
	oSlabsetTabs.current_tab = 2
	
	oClmEditorControls.oColumnIndexSpinBox.value = clmIndex


func _on_CustomSlabID_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.fetch_name(value)
	oCustomSlabNameLabel.text = slabName


func _on_AddCustomSlabButton_pressed():
	var newID = 1000 # We'll say fake slabs are ID 1000 and up
	# Find an unused ID within the fake data dictionary
	while Slabs.data.has(newID):
		newID += 1
	
	var slabCubeData = []
	var slabFloorData = []
	for id in oGridContainerCustomColumns3x3.get_children():
		var spinbox = id.get_node("CustomSpinBox")
		var clmIndex = spinbox.value
		slabCubeData.append(oDataClm.cubes[clmIndex])
		slabFloorData.append(oDataClm.floorTexture[clmIndex])
		
		if oDataClm.floorTexture[clmIndex] == 0 and oDataClm.cubes[clmIndex] == [0,0,0,0, 0,0,0,0]:
			oMessage.quick("You should not use blank columns")
			# Blank columns get indexed by other columns after a while
			return
	
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
	if oSlabBitmaskOptionButton.get_selected_id() == Slabs.BITMASK_DOOR1:
		slab_dict["door_thing"] = int(oCustomDoorThing.value)
		slab_dict["door_orientation"] = 1
	
	oCustomSlabSystem.add_custom_slab(slab_dict)
	
	# Add DOOR 2 automatically
	if oSlabBitmaskOptionButton.get_selected_id() == Slabs.BITMASK_DOOR1:
		var second_slab_dict = slab_dict.duplicate(true)
		var IdOfDoor2 = int(oCustomSlabID.value+1)
		second_slab_dict["header_id"] = newID+1
		second_slab_dict["recognized_as"] = IdOfDoor2
		second_slab_dict["door_orientation"] = 0
		second_slab_dict["bitmask"] = Slabs.BITMASK_DOOR2
		oCustomSlabSystem.add_custom_slab(second_slab_dict)
		oMessage.big("Note", "Slab ID: " + str(IdOfDoor2) + " was also added internally, it's assumed to be the other door direction.")
	
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
			var newIndex = oDataClmPos.get_cell_clmpos((cursorTile.x*3)+xSubtile, (cursorTile.y*3)+ySubtile)
			var i = (ySubtile*3) + xSubtile
			customSlabArrayOfSpinbox[i].value = newIndex




func update_type():
	oFakeCustomColumnsPanelContainer.visible = true
	oCustomSlabVoxelView.modulate.a = 1




func _on_FakeSlabHelpButton_pressed():
	var helptext = ""
	helptext += "Fake slabs will work in any solo map.\n"
	helptext += "They typically reset their appearance when placing or claiming an adjacent slab.\n"
	helptext += "Set 'Slab ID' to Slab 50 to prevent the appearance from changing.\n"
	helptext += "There's a few other IDs you can use which may not reset: Impenetrable Rock, Gold, Bridge, Gems, Guard post. But this needs further testing.\n\n"
	helptext += "Right click on the map while the Fake slab menu is open to copy column index numbers into the window."
	oMessage.big("Help",helptext)


func _on_HelpCustomSlabsButton_pressed():
	var helptext = ""
	helptext += "After adding a fake slab, right click on its portrait within the slab selection window to remove it from the editor."
	oMessage.big("Help",helptext)


func _on_SlabBitmaskOptionButton_item_selected(index):
	if index == Slabs.BITMASK_DOOR1:
		oSlabIsSolidOptionButton.selected = 0 # Empty
		
		oSlabIsSolidOptionButton.visible = false
		oPassageLabel.visible = false
		
		oCustomDoorThingLabel.visible = true
		oCustomDoorThing.visible = true
		oCustomDoorThingEmptySpace.visible = true
		oCustomDoorThingIDNameLabel.visible = true
	else:
		oSlabIsSolidOptionButton.visible = true
		oPassageLabel.visible = true
		
		oCustomDoorThingLabel.visible = false
		oCustomDoorThing.visible = false
		oCustomDoorThingEmptySpace.visible = false
		oCustomDoorThingIDNameLabel.visible = false

func _on_CustomDoorThing_value_changed(value):
	var doorIDName = "Unknown"
	value = int(value)
	if Things.DATA_DOOR.has(value):
		doorIDName = Things.DATA_DOOR[value][Slabs.NAME]
	oCustomDoorThingIDNameLabel.text = doorIDName
