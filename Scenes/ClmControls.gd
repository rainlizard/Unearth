extends PanelContainer
onready var oEditor = Nodelist.list["oEditor"]
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
onready var oColumnsetVoxelView = Nodelist.list["oColumnsetVoxelView"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]

onready var oColumnIndexSpinBox = $"%ColumnIndexSpinBox"
onready var oGridAdvancedValues = $"%GridAdvancedValues"

onready var oHeightSpinBox = $"%HeightSpinBox"
onready var oSolidMaskSpinBox = $"%SolidMaskSpinBox"
onready var oPermanentSpinBox = $"%PermanentSpinBox"
onready var oOrientationSpinBox = $"%OrientationSpinBox"
onready var oLintelSpinBox = $"%LintelSpinBox"
onready var oFloorTextureSpinBox = $"%FloorTextureSpinBox"
onready var oUtilizedSpinBox = $"%UtilizedSpinBox"

onready var oColumnFirstUnusedButton = $"%ColumnFirstUnusedButton"
onready var oColumnRevertButton = $"%ColumnRevertButton"
onready var oColumnCopyButton = $"%ColumnCopyButton"
onready var oColumnPasteButton = $"%ColumnPasteButton"

onready var oCube8SpinBox = $"%Cube8SpinBox"
onready var oCube7SpinBox = $"%Cube7SpinBox"
onready var oCube6SpinBox = $"%Cube6SpinBox"
onready var oCube5SpinBox = $"%Cube5SpinBox"
onready var oCube4SpinBox = $"%Cube4SpinBox"
onready var oCube3SpinBox = $"%Cube3SpinBox"
onready var oCube2SpinBox = $"%Cube2SpinBox"
onready var oCube1SpinBox = $"%Cube1SpinBox"

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

var nodeClm
var nodeVoxelView
var isMouseOverFloorTexture = false
var regeneration_timer: Timer

# Clipboard for column data
var clipboard = {
	"height": 0,
	"solidMask": 0,
	"permanent": 0,
	"orientation": 0,
	"lintel": 0,
	"floorTexture": 0,
	"utilized": 0,
	"cubes": []
}

signal cube_value_changed(clmIndex)
signal floor_texture_changed(clmIndex)
signal column_pasted(clmIndex)

func _ready():
	match name:
		"ClmEditorControls":
			nodeClm = oDataClm
			nodeVoxelView = oClmEditorVoxelView
		"ColumnsetControls":
			nodeClm = Columnset
			nodeVoxelView = oColumnsetVoxelView
			
	
	oColumnIndexSpinBox.connect("value_changed", nodeVoxelView, "_on_ColumnIndexSpinBox_value_changed")
	
	oFloorTextureSpinBox.connect("mouse_entered", self, "_on_floortexture_mouse_entered")
	oFloorTextureSpinBox.connect("mouse_exited", self, "_on_floortexture_mouse_exited")
	
	for i in cubeSpinBoxArray.size():
		cubeSpinBoxArray[i].connect("value_changed", self, "_on_cube_value_changed", [i])
		cubeSpinBoxArray[i].connect("mouse_entered", self, "_on_cube_mouse_entered", [i])
		cubeSpinBoxArray[i].connect("mouse_exited", self, "_on_cube_mouse_exited", [i])
	
	regeneration_timer = Timer.new()
	regeneration_timer.wait_time = 0.5
	regeneration_timer.one_shot = true
	regeneration_timer.connect("timeout", self, "_on_regeneration_timer_timeout")
	add_child(regeneration_timer)
	
	oGridAdvancedValues.visible = false
	update_clm_editing_state()

func just_opened():
	match name:
		"ClmEditorControls":
			nodeVoxelView.disable_camera_animation = true
			oColumnIndexSpinBox.min_value = 1
			oColumnIndexSpinBox.max_value = oDataClm.column_count-1
			if oColumnIndexSpinBox.value == 0:
				oColumnIndexSpinBox.value = 1
			nodeVoxelView.disable_camera_animation = false
		"ColumnsetControls":
			nodeVoxelView.disable_camera_animation = true
			oColumnIndexSpinBox.min_value = 1
			oColumnIndexSpinBox.max_value = Columnset.column_count-1
			if oColumnIndexSpinBox.value == 0:
				oColumnIndexSpinBox.value = 1
			nodeVoxelView.disable_camera_animation = false
	update_clm_editing_state()

func _on_regeneration_timer_timeout():
	if name == "ColumnsetControls" and is_instance_valid(Nodelist.list.get("oSlabsetMapRegenerator")):
		var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]
		var clmIndex = int(oColumnIndexSpinBox.value)
		oSlabsetMapRegenerator.regenerate_slabs_using_columnset(clmIndex)

func restart_regeneration_timer():
	if name == "ColumnsetControls":
		regeneration_timer.stop()
		regeneration_timer.start()

func update_clm_editing_state():
	var currentColumn = int(oColumnIndexSpinBox.value)
	var canEditCurrentColumn = true
	
	# For CLM Editor, check both the setting and column 0 restriction
	if name == "ClmEditorControls":
		var allowEditing = Settings.get_setting("allow_clm_data_editing")
		if allowEditing == null or not Settings.haveInitializedAllSettings:
			allowEditing = false
		canEditCurrentColumn = allowEditing and currentColumn != 0
	# For Columnset, only check column 0 restriction
	elif name == "ColumnsetControls":
		canEditCurrentColumn = currentColumn != 0
	
	oHeightSpinBox.editable = canEditCurrentColumn
	oSolidMaskSpinBox.editable = canEditCurrentColumn
	oPermanentSpinBox.editable = canEditCurrentColumn
	oOrientationSpinBox.editable = canEditCurrentColumn
	oLintelSpinBox.editable = canEditCurrentColumn
	oFloorTextureSpinBox.editable = canEditCurrentColumn
	
	for cubeSpinBox in cubeSpinBoxArray:
		cubeSpinBox.editable = canEditCurrentColumn
	
	oColumnRevertButton.disabled = not canEditCurrentColumn
	oColumnCopyButton.disabled = not canEditCurrentColumn
	oColumnPasteButton.disabled = not canEditCurrentColumn
	
	# First unused button logic depends on the context
	if name == "ClmEditorControls":
		var allowEditing = Settings.get_setting("allow_clm_data_editing")
		if allowEditing == null or not Settings.haveInitializedAllSettings:
			allowEditing = false
		oColumnFirstUnusedButton.disabled = not allowEditing
	elif name == "ColumnsetControls":
		oColumnFirstUnusedButton.disabled = false

func establish_maximum_cube_field_values():
	for i in cubeSpinBoxArray.size():
		cubeSpinBoxArray[i].max_value = Cube.CUBES_COUNT

func _on_floortexture_mouse_entered():
	isMouseOverFloorTexture = true
	oCustomTooltip.set_floortexture(oFloorTextureSpinBox.value)


func _on_floortexture_mouse_exited():
	isMouseOverFloorTexture = false
	oCustomTooltip.set_text("")


func _on_cube_mouse_entered(cubeNumber):
	var cubeIndex = int(cubeSpinBoxArray[cubeNumber].value)
	if cubeIndex < Cube.names.size():
		oCustomTooltip.set_text(Cube.names[cubeIndex])


func _on_cube_mouse_exited(cubeNumber):
	oCustomTooltip.set_text("")




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
	adjust_ui_color_if_different()
	update_clm_editing_state()

func _on_cube_value_changed(value, cubeNumber): # signal connected by GDScript
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		return
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
		emit_signal("cube_value_changed", clmIndex)
	nodeClm.cubes[clmIndex][cubeNumber] = int(value)
	
	# Auto-calculate height, solid mask, and lintel based on cube data
	var calculatedHeight = nodeClm.get_height_from_bottom(nodeClm.cubes[clmIndex])
	var calculatedSolidMask = nodeClm.calculate_solid_mask(nodeClm.cubes[clmIndex])
	var calculatedLintel = nodeClm.calculate_lintel(nodeClm.cubes[clmIndex])
	
	# Update both the data arrays and UI
	nodeClm.height[clmIndex] = calculatedHeight
	nodeClm.solidMask[clmIndex] = calculatedSolidMask
	nodeClm.lintel[clmIndex] = calculatedLintel
	
	oHeightSpinBox.value = calculatedHeight
	oSolidMaskSpinBox.value = calculatedSolidMask
	oLintelSpinBox.value = calculatedLintel
	
	nodeVoxelView.update_column_view()
	
	_on_cube_mouse_entered(cubeNumber) # Update tooltip
	adjust_ui_color_if_different()
	restart_regeneration_timer()




func _on_FloorTextureSpinBox_value_changed(value):
	var clmIndex = int(oColumnIndexSpinBox.value)
	
	# Update tooltip regardless of column index if mouse is over floor texture
	if isMouseOverFloorTexture:
		oCustomTooltip.set_floortexture(value)
	
	# Column 0 is reserved and cannot be edited
	if clmIndex == 0:
		return
		
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
		emit_signal("floor_texture_changed", clmIndex)
	nodeClm.floorTexture[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	
	adjust_ui_color_if_different()
	restart_regeneration_timer()

func _on_LintelSpinBox_value_changed(value):
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		return
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
	nodeClm.lintel[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	adjust_ui_color_if_different()
	restart_regeneration_timer()

func _on_PermanentSpinBox_value_changed(value):
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		return
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
	nodeClm.permanent[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	adjust_ui_color_if_different()
	restart_regeneration_timer()

func _on_OrientationSpinBox_value_changed(value):
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		return
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
	nodeClm.orientation[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	adjust_ui_color_if_different()
	restart_regeneration_timer()

func _on_HeightSpinBox_value_changed(value):
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		return
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
	nodeClm.height[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	adjust_ui_color_if_different()
	restart_regeneration_timer()

func _on_SolidMaskSpinBox_value_changed(value):
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		return
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
	nodeClm.solidMask[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	adjust_ui_color_if_different()
	restart_regeneration_timer()

func _on_UtilizedSpinBox_value_changed(value):
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
	var clmIndex = int(oColumnIndexSpinBox.value)
	nodeClm.utilized[clmIndex] = int(value)
	nodeVoxelView.update_column_view()
	adjust_ui_color_if_different()

func find_consecutive_blank_columns_with_floor_texture_1():
	for i in range(1, nodeClm.column_count - 1):
		var currentCubes = nodeClm.cubes[i]
		var nextCubes = nodeClm.cubes[i + 1]
		var emptyArray = [0,0,0,0, 0,0,0,0]
		if currentCubes == emptyArray and nextCubes == emptyArray and nodeClm.floorTexture[i] == 1 and nodeClm.floorTexture[i + 1] == 1:
			return i
	return -1


func _on_ColumnFirstUnusedButton_pressed():
	var findUnusedIndex = nodeClm.find_cubearray_index([0,0,0,0, 0,0,0,0], 0)
	
	if findUnusedIndex != -1:
		oColumnIndexSpinBox.value = findUnusedIndex
	else:
		var consecutiveBlankIndex = find_consecutive_blank_columns_with_floor_texture_1()
		if consecutiveBlankIndex != -1:
			oColumnIndexSpinBox.value = consecutiveBlankIndex
		else:
			oMessage.quick("There are no empty columns")

func _on_CheckboxShowAll_toggled(checkboxValue):
	oGridAdvancedValues.visible = checkboxValue

# Main function to adjust the color of UI elements for a specific column index
func adjust_ui_color_if_different():
	
	var column_index = int(oColumnIndexSpinBox.value)
	adjust_spinbox_color(oUtilizedSpinBox, is_property_different("utilized", column_index))
	adjust_spinbox_color(oOrientationSpinBox, is_property_different("orientation", column_index))
	adjust_spinbox_color(oSolidMaskSpinBox, is_property_different("solidMask", column_index))
	adjust_spinbox_color(oPermanentSpinBox, is_property_different("permanent", column_index))
	adjust_spinbox_color(oLintelSpinBox, is_property_different("lintel", column_index))
	adjust_spinbox_color(oHeightSpinBox, is_property_different("height", column_index))
	adjust_spinbox_color(oFloorTextureSpinBox, is_property_different("floorTexture", column_index))
	
	# Adjust the color for each cube SpinBox
	for i in range(8):
		var cube_spinbox = cubeSpinBoxArray[i]
		var cube_is_different = nodeClm["cubes"][column_index][i] != nodeClm.default_data["cubes"][column_index][i]
		adjust_spinbox_color(cube_spinbox, cube_is_different)
	
	if nodeClm == Columnset:
		var oTabColumnset = Nodelist.list.get("oTabColumnset")
		if is_instance_valid(oTabColumnset):
			oTabColumnset.update_save_columnset_button_availability()


# Function to check if a property is different from its default value
func is_property_different(property_name, column_index):
	return nodeClm[property_name][column_index] != nodeClm.default_data[property_name][column_index]

# Function to adjust the color of a SpinBox based on property differences
func adjust_spinbox_color(spinbox, is_different):
	if is_different == true:
		spinbox.modulate = Color(1.4,1.4,1.7)
	else:
		spinbox.modulate = Color(1,1,1)


func _on_ColumnCopyButton_pressed():
	var clmIndex = int(oColumnIndexSpinBox.value)
	clipboard = {
		"height": nodeClm.height[clmIndex],
		"solidMask": nodeClm.solidMask[clmIndex],
		"permanent": nodeClm.permanent[clmIndex],
		"orientation": nodeClm.orientation[clmIndex],
		"lintel": nodeClm.lintel[clmIndex],
		"floorTexture": nodeClm.floorTexture[clmIndex],
		"utilized": nodeClm.utilized[clmIndex],
		"cubes": nodeClm.cubes[clmIndex].duplicate(true)
	}
	oMessage.quick("Column copied to clipboard")

func _on_ColumnPasteButton_pressed():
	if clipboard["cubes"].empty():
		oMessage.quick("Clipboard is empty. Copy a column first.")
		return
	
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		oMessage.quick("Cannot paste to column 0")
		return
		
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
		emit_signal("column_pasted", clmIndex)
	
	nodeClm.permanent[clmIndex] = clipboard["permanent"]
	nodeClm.orientation[clmIndex] = clipboard["orientation"]
	nodeClm.floorTexture[clmIndex] = clipboard["floorTexture"]
	nodeClm.utilized[clmIndex] = clipboard["utilized"]
	nodeClm.cubes[clmIndex] = clipboard["cubes"].duplicate(true)
	
	# Auto-calculate height, solid mask, and lintel based on pasted cube data
	nodeClm.height[clmIndex] = nodeClm.get_height_from_bottom(nodeClm.cubes[clmIndex])
	nodeClm.solidMask[clmIndex] = nodeClm.calculate_solid_mask(nodeClm.cubes[clmIndex])
	nodeClm.lintel[clmIndex] = nodeClm.calculate_lintel(nodeClm.cubes[clmIndex])
	
	_on_ColumnIndexSpinBox_value_changed(clmIndex) # Update the UI to reflect the pasted values
	oMessage.quick("Pasted column from clipboard")
	nodeVoxelView.refresh_entire_view()



func revert_columns(column_ids):
	for column_id in column_ids:
		nodeClm.permanent[column_id] = nodeClm.default_data["permanent"][column_id]
		nodeClm.orientation[column_id] = nodeClm.default_data["orientation"][column_id]
		nodeClm.floorTexture[column_id] = nodeClm.default_data["floorTexture"][column_id]
		nodeClm.utilized[column_id] = nodeClm.default_data["utilized"][column_id]
		nodeClm.cubes[column_id] = nodeClm.default_data["cubes"][column_id].duplicate(true)
		
		# Auto-calculate height, solid mask, and lintel based on reverted cube data
		nodeClm.height[column_id] = nodeClm.get_height_from_bottom(nodeClm.cubes[column_id])
		nodeClm.solidMask[column_id] = nodeClm.calculate_solid_mask(nodeClm.cubes[column_id])
		nodeClm.lintel[column_id] = nodeClm.calculate_lintel(nodeClm.cubes[column_id])

func _on_ColumnRevertButton_pressed():
	var clmIndex = int(oColumnIndexSpinBox.value)
	if clmIndex == 0:
		oMessage.quick("Cannot revert column 0")
		return
		
	if nodeClm == oDataClm:
		oEditor.mapHasBeenEdited = true
		oFlashingColumns.generate_clmdata_texture()
	revert_columns([clmIndex])
	
	_on_ColumnIndexSpinBox_value_changed(clmIndex)  # Refresh UI
	oMessage.quick("Reverted column to default")
	nodeVoxelView.refresh_entire_view()
