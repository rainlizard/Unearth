extends HBoxContainer
onready var oColumnViewSpinBox = Nodelist.list["oColumnViewSpinBox"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oColumnVoxelView = Nodelist.list["oColumnVoxelView"]
onready var oCubesGridContainer = Nodelist.list["oCubesGridContainer"]

func _ready():
	for i in range(7, -1, -1): # Goes from 7 to 0
		
		var cubeLabel = Label.new()
		cubeLabel.text = "Cube " + str(i) + ":"
		oCubesGridContainer.add_child(cubeLabel)
		
		var cubeSpinBox = SpinBox.new()
		cubeSpinBox.connect("value_changed",self,"_on_cube_value_changed",[i])
		cubeSpinBox.connect("toggled",self,"_on_cube_solid_checkbox_toggled",[i])
		cubeSpinBox.max_value = Cube.tex.size()-1
		oCubesGridContainer.add_child(cubeSpinBox)
		
		var cubeSolid = CheckBox.new()
		cubeSolid.pressed = true
		cubeSolid.text = "Solid"
		oCubesGridContainer.add_child(cubeSolid)
		

func _on_cube_value_changed(value, cubeNumber):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.cubes[clmIndex][cubeNumber] = value
	oColumnVoxelView.update_column_view()

func _on_cube_solid_checkbox_toggled(toggled, cubeNumber):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.solidMask[clmIndex] = 1000000
	oColumnVoxelView.update_column_view()

func _on_FloorTextureSpinBox_value_changed(value):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.floorTexture[clmIndex] = value
	oColumnVoxelView.update_column_view()

func _on_UtilizedSpinBox_value_changed(value):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.utilized[clmIndex] = value
	oColumnVoxelView.update_column_view()

func _on_LintelSpinBox_value_changed(value):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.lintel[clmIndex] = value
	oColumnVoxelView.update_column_view()

func _on_PermanentSpinBox_value_changed(value):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.permanent[clmIndex] = value
	oColumnVoxelView.update_column_view()


func _on_OrientationSpinBox_value_changed(value):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.orientation[clmIndex] = value
	oColumnVoxelView.update_column_view()

func _on_HeightSpinBox_value_changed(value):
	var clmIndex = oColumnViewSpinBox.value
	oDataClm.height[clmIndex] = value
	oColumnVoxelView.update_column_view()
