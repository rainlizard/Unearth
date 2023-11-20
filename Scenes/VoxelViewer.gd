extends ViewportContainer
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oVoxelGen = Nodelist.list["oVoxelGen"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oGridContainerCustomColumns3x3 = Nodelist.list["oGridContainerCustomColumns3x3"]
onready var oGridContainerDynamicColumns3x3 = Nodelist.list["oGridContainerDynamicColumns3x3"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oColumnEditorControls = Nodelist.list["oColumnEditorControls"]


onready var oVoxelCamera = $"VoxelViewport/VoxelCameraPivotPoint/VoxelCamera"
onready var oAllVoxelObjects = $"VoxelViewport/VoxelCreator/AllVoxelObjects"
onready var oSelectedVoxelObject = $"VoxelViewport/VoxelCreator/SelectedPivotPoint/SelectedVoxelObject"
onready var oSelectedPivotPoint = $"VoxelViewport/VoxelCreator/SelectedPivotPoint"
onready var oVoxelCameraPivotPoint = $"VoxelViewport/VoxelCameraPivotPoint"
onready var oHighlightBase = $"VoxelViewport/VoxelCreator/HighlightBase"

export(int, "MAP_CUSTOM_SLAB", "MAP_COLUMN", "DK_SLABSET", "DK_COLUMN") var displayingType
enum {
	MAP_CUSTOM_SLAB
	MAP_COLUMN
	DK_SLABSET
	DK_COLUMN
}

var viewObject = 0 setget set_object

var previousObject = 0

func initialize():
	if is_instance_valid(oDataClm) == false: return
	if oDataClm.cubes.empty() == true: return
	
	#if visible == true:
	var CODETIME_START = OS.get_ticks_msec()
	
	if displayingType == MAP_COLUMN or displayingType == DK_COLUMN:
		do_all()
	if displayingType == DK_SLABSET:
		do_all()
	
	do_one()
	
	print('Columns generated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	if displayingType == DK_SLABSET or displayingType == MAP_CUSTOM_SLAB:
		oHighlightBase.mesh.size = Vector2(4,4)
	if displayingType == MAP_COLUMN or displayingType == DK_COLUMN:
		oHighlightBase.mesh.size = Vector2(2,2)

func _input(event):
	if is_visible_in_tree() == false: return

	if displayingType == MAP_CUSTOM_SLAB:
		return

	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_object(viewObject-1)

	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_object(viewObject+1)


func set_object(setVal):
	if displayingType == DK_SLABSET:
		setVal = clamp(setVal,0,27)
	if displayingType == MAP_COLUMN or displayingType == DK_COLUMN:
		setVal = clamp(setVal,0,2047)
	previousObject = viewObject
	viewObject = setVal
	
	# Speed up camera movement speed if you change the object value by a lot, to get there quicker
	oVoxelCamera.cameraShiftSpeed = clamp(0.02 * abs(previousObject-viewObject), 0.02, 0.3)
	
	do_one()
	
	if displayingType == DK_SLABSET:
		oVariationNumberSpinBox.value = setVal
		oSlabsetWindow.variation_changed(setVal)
	
	if displayingType == MAP_CUSTOM_SLAB:
		pass
	
	if displayingType == MAP_COLUMN:
		oColumnEditorControls.oColumnIndexSpinBox.value = setVal
		oColumnDetails.update_details()
	if displayingType == DK_COLUMN:
		oColumnsetControls.oColumnIndexSpinBox.value = setVal
	
	 # Reset camera back
	oVoxelCameraPivotPoint.rotation_degrees.z = -28.125
	oSelectedPivotPoint.rotation_degrees.y = 0
	oHighlightBase.visible = true
	
	if displayingType == DK_SLABSET:
		oHighlightBase.translation.z = viewObject*4
		oHighlightBase.translation.x = viewObject*4
	else:
		oHighlightBase.translation.z = viewObject*2
		oHighlightBase.translation.x = viewObject*2


func do_all():
	var genArray = oVoxelGen.blankArray.duplicate(true)
	
	if displayingType == MAP_COLUMN or displayingType == DK_COLUMN:
		var surrClmIndex = [-1,-1,-1,-1]
		
		match displayingType:
			MAP_COLUMN:
				for clmIndex in 2048:
					var x = clmIndex*2
					var y = clmIndex*2
					oVoxelGen.column_gen(genArray, x, y, clmIndex, surrClmIndex, true, oDataClm)
			DK_COLUMN:
				for clmIndex in 2048:
					var x = clmIndex*2
					var y = clmIndex*2
					oVoxelGen.column_gen(genArray, x, y, clmIndex, surrClmIndex, true, Columnset)
		
		oAllVoxelObjects.mesh = oVoxelGen.complete_mesh(genArray)
		oAllVoxelObjects.translation.z = -0.5
		oAllVoxelObjects.translation.x = -0.5
	var CODETIME_START = OS.get_ticks_msec()
	
	
	
	if displayingType == DK_SLABSET: # This is not for fake slab, this is for slabset slabs
		var slabID = oSlabsetIDSpinBox.value
		var separation = 0
		var variationStart = slabID * 28
		for variation in 28:
			var surrClmIndex = [-1,-1,-1,-1]
			for ySubtile in 3:
				for xSubtile in 3:
					var subtile = (ySubtile*3) + xSubtile
					
					var x = (variation*3) + xSubtile + separation
					var z = (variation*3) + ySubtile + separation
					
					var clmIndex = Slabset.fetch_column_index(variationStart+variation, subtile)
					
					oVoxelGen.column_gen(genArray, x-1.5, z-1.5, clmIndex, surrClmIndex, true, Columnset)
			
			separation += 1
		
		oAllVoxelObjects.mesh = oVoxelGen.complete_mesh(genArray)
		
	print('Codetime DYNAMIC: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func do_one():
	
	var genArray = oVoxelGen.blankArray.duplicate(true)
	
	if displayingType == MAP_CUSTOM_SLAB:
		var surrClmIndex = [-1,-1,-1,-1]
		for y in 3:
			for x in 3:
				var i = (y*3) + x
				var id = oGridContainerCustomColumns3x3.get_child(i)
				var spinbox = id.get_node("CustomSpinBox")
				var clmIndex = spinbox.value
				
				oVoxelGen.column_gen(genArray, x-1.5, y-1.5, clmIndex, surrClmIndex, true, oDataClm)
		oSelectedVoxelObject.mesh = oVoxelGen.complete_mesh(genArray)
		oSelectedVoxelObject.translation.z = 0.0
		oSelectedVoxelObject.translation.x = 0.0
		oSelectedPivotPoint.translation.z = 0.0
		oSelectedPivotPoint.translation.x = 0.0
	
	if displayingType == MAP_COLUMN or displayingType == DK_COLUMN:
		var surrClmIndex = [-1,-1,-1,-1]
		
		match displayingType:
			MAP_COLUMN: oVoxelGen.column_gen(genArray, 0, 0, viewObject, surrClmIndex, true, oDataClm)
			DK_COLUMN: oVoxelGen.column_gen(genArray, 0, 0, viewObject, surrClmIndex, true, Columnset)
		
		oSelectedVoxelObject.mesh = oVoxelGen.complete_mesh(genArray)
		oSelectedPivotPoint.translation.z = (viewObject * 2)
		oSelectedPivotPoint.translation.x = (viewObject * 2)
	
	if displayingType == DK_SLABSET: # This is not for fake slab, this is for slabset slabs
		
#		var slabID = oSlabsetIDSpinBox.value
#		var variationStart = (slabID * 28)
#		var variation = variationStart+viewObject
		
		var surrClmIndex = [-1,-1,-1,-1]
		for y in 3:
			for x in 3:
				var i = (y*3) + x
				var id = oGridContainerDynamicColumns3x3.get_child(i)
				var spinbox = id.get_node("CustomSpinBox")
				var clmIndex = spinbox.value
				
				oVoxelGen.column_gen(genArray, x-1.5, y-1.5, clmIndex, surrClmIndex, true, Columnset)
		
		oSelectedVoxelObject.mesh = oVoxelGen.complete_mesh(genArray)
		oSelectedPivotPoint.translation.z = (viewObject * 4)
		oSelectedPivotPoint.translation.x = (viewObject * 4)
		oSelectedVoxelObject.translation.z = 0
		oSelectedVoxelObject.translation.x = 0

#func _process(delta):
#	print(viewObject)




func _on_CustomSlabSpinBox_value_changed(value):
	do_one()
	oColumnDetails.update_details()

	if oAllVoxelObjects.visible == false: # If was previously invisible (meaning you were editing "one") then update ALL
		oAllVoxelObjects.visible = true
		do_all()


func update_column_view():
	oAllVoxelObjects.visible = false
	oSelectedVoxelObject.visible = true
	do_one()
	oColumnDetails.update_details()

func _on_ColumnIndexSpinBox_value_changed(value):
	
	if oAllVoxelObjects.visible == false: # If was previously invisible (meaning you were editing "one") then update ALL
		oAllVoxelObjects.visible = true
		do_all()
	
	match displayingType:
		MAP_COLUMN:
			oColumnEditorControls.oColumnIndexSpinBox.disconnect("value_changed",self,"_on_ColumnIndexSpinBox_value_changed")
			set_object(value)
			oColumnEditorControls.oColumnIndexSpinBox.connect("value_changed",self,"_on_ColumnIndexSpinBox_value_changed")
		DK_COLUMN:
			oColumnsetControls.oColumnIndexSpinBox.disconnect("value_changed",self,"_on_ColumnIndexSpinBox_value_changed")
			set_object(value)
			oColumnsetControls.oColumnIndexSpinBox.connect("value_changed",self,"_on_ColumnIndexSpinBox_value_changed")




var skip3x3function = false
func _on_Slabset3x3ColumnSpinBox_value_changed(value): # Runs 9 times when switching variation or ID. First.
	yield(get_tree(),'idle_frame') # Important so that it runs after _on_VariationNumberSpinBox_value_changed()
	if skip3x3function == true: return
	do_one()
	oColumnDetails.update_details()
	oAllVoxelObjects.visible = false
	oSelectedVoxelObject.visible = true
func _on_VariationNumberSpinBox_value_changed(value):
	set_object(value)
	if oAllVoxelObjects.visible == false:
		oAllVoxelObjects.visible = true
		do_all()
	skip3x3function = true
	yield(get_tree(),'idle_frame')
	skip3x3function = false


func _on_SlabsetIDSpinBox_value_changed(value):
	oAllVoxelObjects.visible = true
	oSelectedVoxelObject.visible = false
	do_all()
	set_object(viewObject) #for clamping the selection
	
	skip3x3function = true
	yield(get_tree(),'idle_frame')
	skip3x3function = false

func refresh_entire_view():
	do_all()
	do_one()
	oAllVoxelObjects.visible = true
	oSelectedVoxelObject.visible = false
