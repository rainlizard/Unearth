extends ViewportContainer
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oVoxelGen = Nodelist.list["oVoxelGen"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oColumnViewSpinBox = Nodelist.list["oColumnViewSpinBox"]

onready var oAllVoxelObjects = $"VoxelViewport/VoxelCreator/AllVoxelObjects"
onready var oSelectedVoxelObject = $"VoxelViewport/VoxelCreator/SelectedPivotPoint/SelectedVoxelObject"
onready var oSelectedPivotPoint = $"VoxelViewport/VoxelCreator/SelectedPivotPoint"
onready var oVoxelCameraPivotPoint = $"VoxelViewport/VoxelCameraPivotPoint"
onready var oHighlightBase = $"VoxelViewport/VoxelCreator/HighlightBase"
export(int, "SLAB", "COLUMN", "CUBE") var displayingType
enum {
	SLAB
	COLUMN
	CUBE
}

var viewObject = 0 setget set_object

func initialize():
	if is_instance_valid(oDataClm) == false: return
	if oDataClm.cubes.empty() == true: return
	
	#if visible == true:
	var CODETIME_START = OS.get_ticks_msec()
	
	if displayingType == COLUMN: do_all()
	
	do_one()
	
	print('Columns generated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	if displayingType == SLAB:
		oHighlightBase.mesh.size = Vector2(4,4)

func _unhandled_input(event):
	if visible == false: return
	
	if displayingType == SLAB:
		return
	
	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_object(viewObject-1)
		
	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_object(viewObject+1)

func set_object(setVal):
	setVal = clamp(setVal,0,2047)
	viewObject = setVal
	do_one()
	
	
	if displayingType == CUBE:
		pass
	if displayingType == SLAB:
		pass
	if displayingType == COLUMN:
		oColumnViewSpinBox.value = setVal
		oColumnDetails.update_details()
	
	oAllVoxelObjects.visible = true
	oSelectedVoxelObject.visible = false
	 # Reset camera back
	oVoxelCameraPivotPoint.rotation_degrees.z = -28.125
	oSelectedPivotPoint.rotation_degrees.y = 0
	oHighlightBase.visible = true
	oHighlightBase.translation.z = viewObject*2
	oHighlightBase.translation.x = viewObject*2


func do_all():
	var genArray = oVoxelGen.blankArray.duplicate(true)
	
	if displayingType == COLUMN:
		var surrClmIndex = [-1,-1,-1,-1]
		for clmIndex in 2048:
			var x = clmIndex*2
			var y = clmIndex*2
			oVoxelGen.column_gen(genArray, x, y, clmIndex, surrClmIndex, true)
		oAllVoxelObjects.mesh = oVoxelGen.complete_mesh(genArray)
		oAllVoxelObjects.translation.z = -0.5
		oAllVoxelObjects.translation.x = -0.5


func do_one():
	var genArray = oVoxelGen.blankArray.duplicate(true)
	
	
	if displayingType == SLAB:
		var surrClmIndex = [-1,-1,-1,-1] # Code this properly later for a slight performance boost
		var clmIndex = 1
		for x in 3:
			for y in 3:
				oVoxelGen.column_gen(genArray, x-1.5, y-1.5, clmIndex, surrClmIndex, true)
		oSelectedVoxelObject.mesh = oVoxelGen.complete_mesh(genArray)
		oSelectedVoxelObject.translation.z = 0.0
		oSelectedVoxelObject.translation.x = 0.0
		oSelectedPivotPoint.translation.z = 0.0
		oSelectedPivotPoint.translation.x = 0.0
	
	if displayingType == COLUMN:
		var surrClmIndex = [-1,-1,-1,-1]
		
		oVoxelGen.column_gen(genArray, 0, 0, viewObject, surrClmIndex, true)
		
		oSelectedVoxelObject.mesh = oVoxelGen.complete_mesh(genArray)
		oSelectedPivotPoint.translation.z = (viewObject * 2)
		oSelectedPivotPoint.translation.x = (viewObject * 2)


func _on_ColumnViewDeleteButton_pressed():
	oDataClm.delete_column(viewObject)
	oColumnDetails.update_details()
	do_all()


func _on_ColumnViewSpinBox_value_changed(value):
	set_object(value)
