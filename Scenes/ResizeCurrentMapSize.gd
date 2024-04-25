extends WindowDialog
onready var oSettingsXSizeLine = Nodelist.list["oSettingsXSizeLine"]
onready var oSettingsYSizeLine = Nodelist.list["oSettingsYSizeLine"]
onready var oMapSizeTextLabel = Nodelist.list["oMapSizeTextLabel"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oResizeFillWithID = Nodelist.list["oResizeFillWithID"]
onready var oResizeFillWithIDLabel = Nodelist.list["oResizeFillWithIDLabel"]
onready var oResizeMapApplyBorderCheckbox = Nodelist.list["oResizeMapApplyBorderCheckbox"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oGuidelines = Nodelist.list["oGuidelines"]
onready var oBuffers = Nodelist.list["oBuffers"]


func _on_ResizeCurrentMapSizeButton_pressed():
	Utils.popup_centered(self)

func _on_ResizeCurrentMapSize_about_to_show():
	oSettingsXSizeLine.text = str(M.xSize)
	oSettingsYSizeLine.text = str(M.ySize)
	oMapSettingsWindow.visible = false

# Function to handle updating the map size
func set_new_map_size(newWidth, newHeight):
	M.xSize = newWidth
	M.ySize = newHeight
	oMapSizeTextLabel.text = str(M.xSize) + " x " + str(M.ySize)
	
	
# Function to get positions that need to be updated
func get_positions_to_update(newWidth, newHeight, previousWidth, previousHeight):
	var positionsToUpdate = {}
	if newWidth > previousWidth:
		for x in range(previousWidth, newWidth):
			for y in newHeight:
				positionsToUpdate[Vector2(x, y)] = true
	if newHeight > previousHeight:
		for y in range(previousHeight, newHeight):
			for x in newWidth:
				positionsToUpdate[Vector2(x, y)] = true
	oSlabPlacement.place_shape_of_slab_id(positionsToUpdate.keys(), Slabs.EARTH, 5)
	return positionsToUpdate

# Function to remove old borders
func remove_old_borders(newWidth, newHeight, previousWidth, previousHeight):
	var removeBorder = []
	if newWidth > previousWidth:
		for y in previousHeight:
			removeBorder.append(Vector2(previousWidth - 1, y))
	if newHeight > previousHeight:
		for x in previousWidth:
			removeBorder.append(Vector2(x, previousHeight - 1))
	oSlabPlacement.place_shape_of_slab_id(removeBorder, Slabs.EARTH, 5)
	return removeBorder

# Function to add new borders
func add_new_borders(newWidth, newHeight):
	var addBorder = []
	for x in newWidth:
		addBorder.append(Vector2(x, 0))
		addBorder.append(Vector2(x, newHeight - 1))
	for y in newHeight:
		addBorder.append(Vector2(0, y))
		addBorder.append(Vector2(newWidth - 1, y))
	oSlabPlacement.place_shape_of_slab_id(addBorder, Slabs.ROCK, 5)
	return addBorder

# Function to remove instances outside of the new map size
func remove_outside_instances(newWidth, newHeight):
	var deletedInstancesCount = 0
	var newHeightInSubtiles = newHeight * 3
	var newWidthInSubtiles =  newWidth * 3
	
	for instance in get_tree().get_nodes_in_group("Instance"):
		if instance.locationX >= newWidthInSubtiles or instance.locationY >= newHeightInSubtiles:
			deletedInstancesCount += 1
			oInstances.kill_instance(instance)
	
	if deletedInstancesCount > 0:
		oMessage.quick("Deleted " + str(deletedInstancesCount) + " instances that were outside of the new map size.")


onready var oDataSlab = Nodelist.list["oDataSlab"]

# The main function that calls all the helper functions
func _on_ResizeApplyButton_pressed():
	if oCurrentFormat.selected == 0: # Classic format
		oMessage.big("Error", "Cannot resize your map, because is in Classic format. Switch to KFX format first.")
		return
	
	var newWidth = int(oSettingsXSizeLine.text)
	var newHeight = int(oSettingsYSizeLine.text)
	var previousWidth = M.xSize
	var previousHeight = M.ySize
	set_new_map_size(newWidth, newHeight)
	oBuffers.resize_all_data_structures(newWidth, newHeight)
	remove_outside_instances(newWidth, newHeight)
	
	var positionsToUpdate = get_positions_to_update(newWidth, newHeight, previousWidth, previousHeight)
	var removeBorder = remove_old_borders(newWidth, newHeight, previousWidth, previousHeight)
	var addBorder = add_new_borders(newWidth, newHeight)
	for pos in removeBorder:
		positionsToUpdate[pos] = true
	for pos in addBorder:
		positionsToUpdate[pos] = true
	
	update_editor_appearance()
	
	oOverheadGraphics.update_full_overhead_map(oOverheadGraphics.SINGLE_THREADED)
	
	# I need to update every slab on the map, it's bugged otherwise, it clears a diagonal streak of objects for some reason.
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, true)
	
	#yield(oSlabPlacement.generate_slabs_based_on_id(positionsToUpdate.keys(), true), "completed") # Important to update surrounding slabs too. For example, rooms that get cut off.


func update_editor_appearance():
	oEditor.update_boundaries()
	oOverheadOwnership.start()
	oGuidelines.update()


func _on_SettingsXSizeLine_focus_exited():
	if int(oSettingsXSizeLine.text) > 170:
		oSettingsXSizeLine.text = "170"

func _on_SettingsYSizeLine_focus_exited():
	if int(oSettingsYSizeLine.text) > 170:
		oSettingsYSizeLine.text = "170"

func _on_ResizeFillWithID_value_changed(value):
	value = int(value)
	if Slabs.data.has(value):
		oResizeFillWithIDLabel.text = Slabs.data[value][Slabs.NAME]

#	for pos in positionsToUpdate.keys():
#		var scene = preload('res://t.tscn')
#		var id = scene.instance()
#		id.position = Vector2((pos.x*96)+48, (pos.y*96)+48)
#		oInstances.add_child(id)
