extends ViewportContainer
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oVoxelGen = Nodelist.list["oVoxelGen"]
onready var oDataClm = Nodelist.list["oDataClm"]

onready var oAllVoxelObjects = $"VoxelViewport/VoxelCreator/AllVoxelObjects"
onready var oSelectedVoxelObject = $"VoxelViewport/VoxelCreator/SelectedPivotPoint/SelectedVoxelObject"
onready var oSelectedPivotPoint = $"VoxelViewport/VoxelCreator/SelectedPivotPoint"
onready var oVoxelCameraPivotPoint = $"VoxelViewport/VoxelCameraPivotPoint"
onready var oHighlightBaseColumn = $"VoxelViewport/VoxelCreator/HighlightBaseColumn"
onready var oColumnViewSpinBox = Nodelist.list["oColumnViewSpinBox"]


var viewObject = 0 setget set_object

#func _ready():
#	yield(get_tree(),'idle_frame')
#	connect("visibility_changed", self, "_on_VoxelObjectViewer_visibility_changed")


func initialize():
	if is_instance_valid(oDataClm) == false: return
	if oDataClm.cubes.empty() == true: return
	
	
	if visible == true:
		var CODETIME_START = OS.get_ticks_msec()
		
		do_all()
		do_one()
		
		print('Columns generated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func _unhandled_input(event):
	if visible == false: return
	
	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_object(viewObject-1)
		
	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_object(viewObject+1)

func set_object(setVal):
	setVal = clamp(setVal,0,2047)
	
	viewObject = setVal
	
	oColumnViewSpinBox.value = setVal #!!!!!!!!
	
	do_one()
	oColumnDetails.update_details()
	oAllVoxelObjects.visible = true
	oSelectedVoxelObject.visible = false
	 # Reset camera back
	oVoxelCameraPivotPoint.rotation_degrees.z = -28.125
	oSelectedPivotPoint.rotation_degrees.y = 0
	oHighlightBaseColumn.visible = true
	oHighlightBaseColumn.translation.z = viewObject*2
	oHighlightBaseColumn.translation.x = viewObject*2


func do_all():
	var genArray = oVoxelGen.blankArray.duplicate(true)
	var surrClmIndex = [-1,-1,-1,-1]
	
	# Columns
	for clmIndex in 2048:
		var x = clmIndex*2
		var y = clmIndex*2
		oVoxelGen.column_gen(genArray, x, y, clmIndex, surrClmIndex, true)
	
	oAllVoxelObjects.mesh = oVoxelGen.complete_mesh(genArray)
	oAllVoxelObjects.translation.z = -0.5
	oAllVoxelObjects.translation.x = -0.5


func do_one():
	var genArray = oVoxelGen.blankArray.duplicate(true)
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
