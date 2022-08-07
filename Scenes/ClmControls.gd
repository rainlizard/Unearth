extends ScrollContainer
onready var oEditor = Nodelist.list["oEditor"]
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

export(NodePath) onready var nodeClm = get_node(nodeClm) as Node
export(NodePath) onready var nodeVoxelView = get_node(nodeVoxelView) as Node

onready var oHeightSpinBox = $"VBoxContainer/GridAdvancedValues/HeightSpinBox"
onready var oSolidMaskSpinBox = $"VBoxContainer/GridAdvancedValues/SolidMaskSpinBox"
onready var oPermanentSpinBox = $"VBoxContainer/GridAdvancedValues/PermanentSpinBox"
onready var oOrientationSpinBox = $"VBoxContainer/GridAdvancedValues/OrientationSpinBox"
onready var oLintelSpinBox = $"VBoxContainer/GridAdvancedValues/LintelSpinBox"
onready var oGridAdvancedValues = $"VBoxContainer/GridAdvancedValues"
onready var oGridSimpleValues = $"VBoxContainer/GridSimpleValues"
onready var oColumnIndexSpinBox = $"VBoxContainer/HBoxContainer/ColumnIndexSpinBox"
onready var oColumnFirstUnusedButton = $"VBoxContainer/ColumnFirstUnusedButton"
onready var oColumnViewDeleteButton = $"VBoxContainer/ColumnViewDeleteButton"
onready var oFloorTextureSpinBox = $"VBoxContainer/GridSimpleValues/FloorTextureSpinBox"

onready var oUtilizedSpinBox = $"VBoxContainer/HBoxContainer2/UtilizedSpinBox"
onready var oCube8SpinBox = $"VBoxContainer/GridSimpleValues/Cube8SpinBox"
onready var oCube7SpinBox = $"VBoxContainer/GridSimpleValues/Cube7SpinBox"
onready var oCube6SpinBox = $"VBoxContainer/GridSimpleValues/Cube6SpinBox"
onready var oCube5SpinBox = $"VBoxContainer/GridSimpleValues/Cube5SpinBox"
onready var oCube4SpinBox = $"VBoxContainer/GridSimpleValues/Cube4SpinBox"
onready var oCube3SpinBox = $"VBoxContainer/GridSimpleValues/Cube3SpinBox"
onready var oCube2SpinBox = $"VBoxContainer/GridSimpleValues/Cube2SpinBox"
onready var oCube1SpinBox = $"VBoxContainer/GridSimpleValues/Cube1SpinBox"

onready var cubeSpinBoxArray = [
	oCube1SpinBox,
	oCube2SpinBox,
	oCube3SpinBox,
	oCube4SpinBox,
	oCube5SpinBox,
	oCube6SpinBox,
	oCube7SpinBox,
	oCube8SpinBox,
]

func _ready():
	oColumnIndexSpinBox.connect("value_changed", nodeVoxelView, "_on_ColumnIndexSpinBox_value_changed")
	
	oFloorTextureSpinBox.connect("mouse_entered", self, "_on_floortexture_mouse_entered")
	oFloorTextureSpinBox.connect("mouse_exited", self, "_on_floortexture_mouse_exited")
	
	for i in cubeSpinBoxArray.size():
		cubeSpinBoxArray[i].connect("value_changed", self, "_on_cube_value_changed", [i])
		cubeSpinBoxArray[i].connect("mouse_entered", self, "_on_cube_mouse_entered", [i])
		cubeSpinBoxArray[i].connect("mouse_exited", self, "_on_cube_mouse_exited", [i])
	
	oGridAdvancedValues.visible = false

func establish_maximum_cube_field_values():
	for i in cubeSpinBoxArray.size():
		cubeSpinBoxArray[i].max_value = Cube.CUBES_COUNT

func _on_floortexture_mouse_entered():
	oCustomTooltip.set_floortexture(oFloorTextureSpinBox.value)


func _on_floortexture_mouse_exited():
	oCustomTooltip.set_text("")


func _on_cube_mouse_entered(cubeNumber):
	var cubeIndex = int(cubeSpinBoxArray[cubeNumber].value)
	if cubeIndex < Cube.names.size():
		oCustomTooltip.set_text(Cube.names[cubeIndex])


func _on_cube_mouse_exited(cubeNumber):
	oCustomTooltip.set_text("")


func _on_ColumnDuplicateButton_pressed():
	var clmIndex = int(oColumnIndexSpinBox.value)
	
	var findUnusedIndex = nodeClm.find_cubearray_index([0,0,0,0, 0,0,0,0], 0)
	
	if findUnusedIndex != -1:
		if nodeClm == oDataClm:
			oEditor.mapHasBeenEdited = true
			oDataClm.count_filled_clm_entries() # Refresh "Clm entries" in Properties window
		nodeClm.copy_column(clmIndex, findUnusedIndex)
		oMessage.quick('Copied ' + str(clmIndex) + ' --> ' + str(findUnusedIndex))
		
		nodeVoxelView.do_all()
		nodeVoxelView.do_one()
		nodeVoxelView.oAllVoxelObjects.visible = true
		nodeVoxelView.oSelectedVoxelObject.visible = false
		
		oColumnIndexSpinBox.value = findUnusedIndex
	else:
		oMessage.quick("There are no empty columns to copy to")


func _on_ColumnIndexSpinBox_value_changed(value):
	var clmIndex = int(value)
	
	for i in get_incoming_connections():
		var nodeID = i["source"]
		if nodeID is CustomSpinBox or nodeID is CheckBox:
			nodeID.set_block_signals(true)
	
	oFloorTextureSpinBox.value = nodeClm.floorTexture[clmIndex]
	oOrientationSpinBox.value = nodeClm.orientation[clmIndex]
	oPermanentSpinBox.value = nodeClm.permanent[clmIndex]
	oLintelSpinBox.value = nodeClm.lintel[clmIndex]
	oUtilizedSpinBox.value = nodeClm.utilized[clmIndex]
	oHeightSpinBox.value = nodeClm.height[clmIndex]
	oSolidMaskSpinBox.value = nodeClm.solidMask[clmIndex]
	oCube8SpinBox.value = nodeClm.cubes[clmIndex][7]
	oCube7SpinBox.value = nodeClm.cubes[clmIndex][6]
	oCube6SpinBox.value = nodeClm.cubes[clmIndex][5]
	oCube5SpinBox.value = nodeClm.cubes[clmIndex][4]
	oCube4SpinBox.value = nodeClm.cubes[clmIndex][3]
	oCube3SpinBox.value = nodeClm.cubes[clmIndex][2]
	oCube2SpinBox.value = nodeClm.cubes[clmIndex][1]
	oCube1SpinBox.value = nodeClm.cubes[clmIndex][0]
	
	for i in get_incoming_connections():
		var nodeID = i["source"]
		if nodeID is CustomSpinBox or nodeID is CheckBox:
			nodeID.set_block_signals(false)
	
	oCustomTooltip.visible = false # Tooltip becomes incorrect when changing column index so just turn it off until you hover your mouse over it again

func _on_cube_value_changed(value, cubeNumber): # signal connected by GDScript
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.cubes[clmIndex][cubeNumber] = int(value)
	nodeVoxelView.update_column_view()
	
	oHeightSpinBox.value = nodeClm.get_real_height(nodeClm.cubes[clmIndex])
	oSolidMaskSpinBox.value = nodeClm.calculate_solid_mask(nodeClm.cubes[clmIndex])
	
	_on_cube_mouse_entered(cubeNumber) # Update tooltip

func _on_FloorTextureSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.floorTexture[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	
	_on_floortexture_mouse_entered() # Update tooltip

func _on_LintelSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.lintel[clmIndex] = int(value)
	nodeVoxelView.update_column_view()

func _on_PermanentSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.permanent[clmIndex] = int(value)
	nodeVoxelView.update_column_view()


func _on_OrientationSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.orientation[clmIndex] = int(value)
	nodeVoxelView.update_column_view()

func _on_HeightSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.height[clmIndex] = int(value)
	nodeVoxelView.update_column_view()

func _on_SolidMaskSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.solidMask[clmIndex] = int(value)
	nodeVoxelView.update_column_view()


func _on_UtilizedSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.utilized[clmIndex] = int(value)
	nodeVoxelView.update_column_view()

func _on_ColumnFirstUnusedButton_pressed():
	var findUnusedIndex = nodeClm.find_cubearray_index([0,0,0,0, 0,0,0,0], 0)
	
	if findUnusedIndex != -1:
		oColumnIndexSpinBox.value = findUnusedIndex
	else:
		oMessage.quick("There are no empty columns")

func _on_ColumnViewDeleteButton_pressed():
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oDataClm.count_filled_clm_entries() # Refresh "Clm entries" in Properties window
	
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.delete_column(clmIndex)
	oColumnDetails.update_details()
	_on_ColumnIndexSpinBox_value_changed(clmIndex) # Update controls to show "0"
	
	nodeVoxelView.do_all()
	nodeVoxelView.do_one()
	nodeVoxelView.oAllVoxelObjects.visible = true
	nodeVoxelView.oSelectedVoxelObject.visible = false

func _on_CheckboxShowAll_toggled(checkboxValue):
	oGridAdvancedValues.visible = checkboxValue
