extends HBoxContainer
onready var oColumnIndexSpinBox = Nodelist.list["oColumnIndexSpinBox"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oColumnVoxelView = Nodelist.list["oColumnVoxelView"]
onready var oCubesGridContainer = Nodelist.list["oCubesGridContainer"]
onready var oOrientationSpinBox = Nodelist.list["oOrientationSpinBox"]
onready var oPermanentSpinBox = Nodelist.list["oPermanentSpinBox"]
onready var oLintelSpinBox = Nodelist.list["oLintelSpinBox"]
onready var oHeightSpinBox = Nodelist.list["oHeightSpinBox"]
onready var oFloorTextureSpinBox = Nodelist.list["oFloorTextureSpinBox"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oSolidMaskSpinBox = Nodelist.list["oSolidMaskSpinBox"]

var cubeSpinBoxArray = []
#var solidCheckBoxArray = []

func _ready():
	for i in range(7, -1, -1): # Goes from 7 to 0
		
		var cubeLabel = Label.new()
		cubeLabel.text = "Cube " + str(i) + ":"
		oCubesGridContainer.add_child(cubeLabel)
		
		var cubeSpinBox = CustomSpinBox.new()
		cubeSpinBoxArray.append(cubeSpinBox)
		cubeSpinBox.connect("value_changed",self,"_on_cube_value_changed",[i])
		cubeSpinBox.max_value = Cube.tex.size()-1
		cubeSpinBox.size_flags_horizontal = Control.SIZE_SHRINK_END + Control.SIZE_EXPAND#
		oCubesGridContainer.add_child(cubeSpinBox)
		
#		var cubeSolid = CheckBox.new()
#		solidCheckBoxArray.append(cubeSolid)
#
#		cubeSolid.connect("toggled",self,"_on_cube_solid_checkbox_toggled",[i])
#		cubeSolid.text = "Solid"
#		cubeSolid.set_meta("bitmask", pow(2,i))
#		oCubesGridContainer.add_child(cubeSolid)
	
	cubeSpinBoxArray.invert()

func _on_ColumnIndexSpinBox_value_changed(value):
	var clmIndex = int(value)
	
	for i in get_incoming_connections():
		var nodeID = i["source"]
		if nodeID is CustomSpinBox or nodeID is CheckBox:
			nodeID.set_block_signals(true)
	
	oFloorTextureSpinBox.value = oDataClm.floorTexture[clmIndex]
	oOrientationSpinBox.value = oDataClm.orientation[clmIndex]
	oPermanentSpinBox.value = oDataClm.permanent[clmIndex]
	oLintelSpinBox.value = oDataClm.lintel[clmIndex]
	oHeightSpinBox.value = oDataClm.height[clmIndex]
	oSolidMaskSpinBox.value = oDataClm.solidMask[clmIndex]
	
	for i in cubeSpinBoxArray.size():
		cubeSpinBoxArray[i].value = oDataClm.cubes[clmIndex][i]
	
	
#	var maskVar = oDataClm.solidMask[clmIndex]
#	for i in solidCheckBoxArray:
#		if maskVar >= i.get_meta("bitmask"):
#			maskVar -= i.get_meta("bitmask")
#			i.pressed = true
#		else:
#			i.pressed = false
	
	for i in get_incoming_connections():
		var nodeID = i["source"]
		if nodeID is CustomSpinBox or nodeID is CheckBox:
			nodeID.set_block_signals(false)


func _on_cube_value_changed(value, cubeNumber):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.cubes[clmIndex][cubeNumber] = int(value)
	oColumnVoxelView.update_column_view()
	
	oHeightSpinBox.value = oDataClm.get_real_height(oDataClm.cubes[clmIndex])
	oSolidMaskSpinBox.value = oDataClm.calculate_solid_mask(oDataClm.cubes[clmIndex])
#func _on_cube_solid_checkbox_toggled(toggled, cubeNumber):
#	oEditor.mapHasBeenEdited = true
#	var clmIndex = int(oColumnIndexSpinBox.value)
#
#	oDataClm.solidMask[clmIndex] = 0
#	for i in solidCheckBoxArray:
#		if i.pressed == true:
#			oDataClm.solidMask[clmIndex] += i.get_meta("bitmask")
#
#	oColumnVoxelView.update_column_view()

func _on_FloorTextureSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.floorTexture[clmIndex] = int(value)
	oColumnVoxelView.update_column_view()

func _on_LintelSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.lintel[clmIndex] = int(value)
	oColumnVoxelView.update_column_view()

func _on_PermanentSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.permanent[clmIndex] = int(value)
	oColumnVoxelView.update_column_view()


func _on_OrientationSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.orientation[clmIndex] = int(value)
	oColumnVoxelView.update_column_view()

func _on_HeightSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.height[clmIndex] = int(value)
	oColumnVoxelView.update_column_view()

func _on_SolidMaskSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	oDataClm.solidMask[clmIndex] = int(value)
	oColumnVoxelView.update_column_view()




func _on_ColumnEditorHelpButton_pressed():
	var helptxt = ""
	helptxt += "Use middle mouse to zoom in and out, left click and drag to rotate view. You can use the arrow keys to switch between columns faster and also use arrow keys while a field's selected to navigate cubes faster." #Holding left click on a field's little arrows while moving the mouse up or down provides speedy navigation too.
	helptxt += '\n'
	helptxt += '\n'
	helptxt += "If your column has multiple gaps then some of the top/bottom cube faces may not display in-game."
	oMessage.big("Help",helptxt)


#onready var oUtilizedSpinBox = Nodelist.list["oUtilizedSpinBox"]
#oUtilizedSpinBox.value = oDataClm.utilized[clmIndex]
#func _on_UtilizedSpinBox_value_changed(value):
#	oEditor.mapHasBeenEdited = true
#	var clmIndex = int(oColumnIndexSpinBox.value)
#	oDataClm.utilized[clmIndex] = int(value)
#	oColumnVoxelView.update_column_view()


func _on_ColumnFirstUnusedButton_pressed():
	var findUnusedIndex = oDataClm.find_cubearray_index([0,0,0,0, 0,0,0,0], 0)
	
	#var findUnusedIndex = oDataClm.cubes.find(, 1)
	#if findUnusedIndex != 0:
	oColumnIndexSpinBox.value = findUnusedIndex


