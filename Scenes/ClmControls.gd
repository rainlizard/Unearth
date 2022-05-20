extends ScrollContainer
onready var oEditor = Nodelist.list["oEditor"]
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataClm = Nodelist.list["oDataClm"]


export(NodePath) onready var nodeClm = get_node(nodeClm) as Node
export(NodePath) onready var nodeVoxelView = get_node(nodeVoxelView) as Node

onready var oColumnGridContainer = $"VBoxContainer/ColumnGridContainer"
onready var oColumnIndexSpinBox = $"VBoxContainer/HBoxContainer/ColumnIndexSpinBox"
onready var oColumnFirstUnusedButton = $"VBoxContainer/ColumnFirstUnusedButton"
onready var oColumnViewDeleteButton = $"VBoxContainer/ColumnViewDeleteButton"
onready var oFloorTextureSpinBox = $"VBoxContainer/ColumnGridContainer/FloorTextureSpinBox"
onready var oHeightSpinBox = $"VBoxContainer/ColumnGridContainer/HeightSpinBox"
onready var oSolidMaskSpinBox = $"VBoxContainer/ColumnGridContainer/SolidMaskSpinBox"
onready var oPermanentSpinBox = $"VBoxContainer/ColumnGridContainer/PermanentSpinBox"
onready var oOrientationSpinBox = $"VBoxContainer/ColumnGridContainer/OrientationSpinBox"
onready var oLintelSpinBox = $"VBoxContainer/ColumnGridContainer/LintelSpinBox"
onready var oUtilizedSpinBox = $"VBoxContainer/HBoxContainer2/UtilizedSpinBox"

onready var oCube7SpinBox = $"VBoxContainer/ColumnGridContainer/Cube7SpinBox"
onready var oCube6SpinBox = $"VBoxContainer/ColumnGridContainer/Cube6SpinBox"
onready var oCube5SpinBox = $"VBoxContainer/ColumnGridContainer/Cube5SpinBox"
onready var oCube4SpinBox = $"VBoxContainer/ColumnGridContainer/Cube4SpinBox"
onready var oCube3SpinBox = $"VBoxContainer/ColumnGridContainer/Cube3SpinBox"
onready var oCube2SpinBox = $"VBoxContainer/ColumnGridContainer/Cube2SpinBox"
onready var oCube1SpinBox = $"VBoxContainer/ColumnGridContainer/Cube1SpinBox"
onready var oCube0SpinBox = $"VBoxContainer/ColumnGridContainer/Cube0SpinBox"

func _ready():
	oColumnIndexSpinBox.connect("value_changed", nodeVoxelView, "_on_ColumnIndexSpinBox_value_changed")
	
	oCube7SpinBox.connect("value_changed", self, "_on_cube_value_changed", [7])
	oCube6SpinBox.connect("value_changed", self, "_on_cube_value_changed", [6])
	oCube5SpinBox.connect("value_changed", self, "_on_cube_value_changed", [5])
	oCube4SpinBox.connect("value_changed", self, "_on_cube_value_changed", [4])
	oCube3SpinBox.connect("value_changed", self, "_on_cube_value_changed", [3])
	oCube2SpinBox.connect("value_changed", self, "_on_cube_value_changed", [2])
	oCube1SpinBox.connect("value_changed", self, "_on_cube_value_changed", [1])
	oCube0SpinBox.connect("value_changed", self, "_on_cube_value_changed", [0])

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
	oCube7SpinBox.value = nodeClm.cubes[clmIndex][7]
	oCube6SpinBox.value = nodeClm.cubes[clmIndex][6]
	oCube5SpinBox.value = nodeClm.cubes[clmIndex][5]
	oCube4SpinBox.value = nodeClm.cubes[clmIndex][4]
	oCube3SpinBox.value = nodeClm.cubes[clmIndex][3]
	oCube2SpinBox.value = nodeClm.cubes[clmIndex][2]
	oCube1SpinBox.value = nodeClm.cubes[clmIndex][1]
	oCube0SpinBox.value = nodeClm.cubes[clmIndex][0]
	
	for i in get_incoming_connections():
		var nodeID = i["source"]
		if nodeID is CustomSpinBox or nodeID is CheckBox:
			nodeID.set_block_signals(false)


func _on_cube_value_changed(value, cubeNumber): # signal connected by GDScript
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.cubes[clmIndex][cubeNumber] = int(value)
	nodeVoxelView.update_column_view()
	
	oHeightSpinBox.value = nodeClm.get_real_height(nodeClm.cubes[clmIndex])
	oSolidMaskSpinBox.value = nodeClm.calculate_solid_mask(nodeClm.cubes[clmIndex])


func _on_FloorTextureSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.floorTexture[clmIndex] = int(value)
	nodeVoxelView.update_column_view()

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




#func connect_all_signals(connectToNode, voxelViewNode):
#	$"VBoxContainer/HBoxContainer/ColumnIndexSpinBox".connect("value_changed", voxelViewNode, "_on_ColumnIndexSpinBox_value_changed")
#
#	$"VBoxContainer/HBoxContainer/ColumnIndexSpinBox".connect("value_changed", connectToNode, "_on_ColumnIndexSpinBox_value_changed")
#	$"VBoxContainer/ColumnFirstUnusedButton".connect("pressed", connectToNode, "_on_ColumnFirstUnusedButton_pressed")
#	$"VBoxContainer/ColumnViewDeleteButton".connect("pressed", connectToNode, "_on_ColumnViewDeleteButton_pressed")
#	$"VBoxContainer/ColumnGridContainer/Cube7SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [7])
#	$"VBoxContainer/ColumnGridContainer/Cube6SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [6])
#	$"VBoxContainer/ColumnGridContainer/Cube5SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [5])
#	$"VBoxContainer/ColumnGridContainer/Cube4SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [4])
#	$"VBoxContainer/ColumnGridContainer/Cube3SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [3])
#	$"VBoxContainer/ColumnGridContainer/Cube2SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [2])
#	$"VBoxContainer/ColumnGridContainer/Cube1SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [1])
#	$"VBoxContainer/ColumnGridContainer/Cube0SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [0])
#	$"VBoxContainer/ColumnGridContainer/FloorTextureSpinBox".connect("value_changed", connectToNode, "_on_FloorTextureSpinBox_value_changed")
#	$"VBoxContainer/ColumnGridContainer/HeightSpinBox".connect("value_changed", connectToNode, "_on_HeightSpinBox_value_changed")
#	$"VBoxContainer/ColumnGridContainer/SolidMaskSpinBox".connect("value_changed", connectToNode, "_on_SolidMaskSpinBox_value_changed")
#	$"VBoxContainer/ColumnGridContainer/PermanentSpinBox".connect("value_changed", connectToNode, "_on_PermanentSpinBox_value_changed")
#	$"VBoxContainer/ColumnGridContainer/OrientationSpinBox".connect("value_changed", connectToNode, "_on_OrientationSpinBox_value_changed")
#	$"VBoxContainer/ColumnGridContainer/LintelSpinBox".connect("value_changed", connectToNode, "_on_LintelSpinBox_value_changed")



