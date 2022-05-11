extends ScrollContainer

func connect_all_signals(connectToNode, voxelViewNode):
	$"VBoxContainer/HBoxContainer/ColumnIndexSpinBox".connect("value_changed", voxelViewNode, "_on_ColumnIndexSpinBox_value_changed")
	
	$"VBoxContainer/HBoxContainer/ColumnIndexSpinBox".connect("value_changed", connectToNode, "_on_ColumnIndexSpinBox_value_changed")
	$"VBoxContainer/ColumnFirstUnusedButton".connect("pressed", connectToNode, "_on_ColumnFirstUnusedButton_pressed")
	$"VBoxContainer/ColumnViewDeleteButton".connect("pressed", connectToNode, "_on_ColumnViewDeleteButton_pressed")
	$"VBoxContainer/ColumnGridContainer/Cube7SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [7])
	$"VBoxContainer/ColumnGridContainer/Cube6SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [6])
	$"VBoxContainer/ColumnGridContainer/Cube5SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [5])
	$"VBoxContainer/ColumnGridContainer/Cube4SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [4])
	$"VBoxContainer/ColumnGridContainer/Cube3SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [3])
	$"VBoxContainer/ColumnGridContainer/Cube2SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [2])
	$"VBoxContainer/ColumnGridContainer/Cube1SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [1])
	$"VBoxContainer/ColumnGridContainer/Cube0SpinBox".connect("value_changed", connectToNode, "_on_cube_value_changed", [0])
	$"VBoxContainer/ColumnGridContainer/FloorTextureSpinBox".connect("value_changed", connectToNode, "_on_FloorTextureSpinBox_value_changed")
	$"VBoxContainer/ColumnGridContainer/HeightSpinBox".connect("value_changed", connectToNode, "_on_HeightSpinBox_value_changed")
	$"VBoxContainer/ColumnGridContainer/SolidMaskSpinBox".connect("value_changed", connectToNode, "_on_SolidMaskSpinBox_value_changed")
	$"VBoxContainer/ColumnGridContainer/PermanentSpinBox".connect("value_changed", connectToNode, "_on_PermanentSpinBox_value_changed")
	$"VBoxContainer/ColumnGridContainer/OrientationSpinBox".connect("value_changed", connectToNode, "_on_OrientationSpinBox_value_changed")
	$"VBoxContainer/ColumnGridContainer/LintelSpinBox".connect("value_changed", connectToNode, "_on_LintelSpinBox_value_changed")
