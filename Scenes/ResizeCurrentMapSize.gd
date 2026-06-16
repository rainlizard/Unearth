extends WindowDialog
onready var oResizeTopSpinBox = Nodelist.list["oResizeTopSpinBox"]
onready var oResizeBottomSpinBox = Nodelist.list["oResizeBottomSpinBox"]
onready var oResizeLeftSpinBox = Nodelist.list["oResizeLeftSpinBox"]
onready var oResizeRightSpinBox = Nodelist.list["oResizeRightSpinBox"]
onready var oResizeMapSizeLabel = Nodelist.list["oResizeMapSizeLabel"]
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
	oResizeTopSpinBox.value = 0
	oResizeBottomSpinBox.value = 0
	oResizeLeftSpinBox.value = 0
	oResizeRightSpinBox.value = 0
	update_resize_map_size_label()
	oMapSettingsWindow.visible = false

func update_resize_map_size_label():
	var newWidth = M.xSize + int(oResizeLeftSpinBox.value) + int(oResizeRightSpinBox.value)
	var newHeight = M.ySize + int(oResizeTopSpinBox.value) + int(oResizeBottomSpinBox.value)
	oResizeMapSizeLabel.text = str(newWidth) + "x" + str(newHeight)

# Function to handle updating the map size
func set_new_map_size(newWidth, newHeight):
	M.xSize = newWidth
	M.ySize = newHeight
	oMapSizeTextLabel.text = str(M.xSize) + " x " + str(M.ySize)


# Function to fill positions newly exposed by moving the old map inside the new size
func fill_new_area(newWidth, newHeight, previousWidth, previousHeight, offsetX, offsetY):
	var positionsToUpdate = {}
	for y in newHeight:
		for x in newWidth:
			var previousX = x - offsetX
			var previousY = y - offsetY
			if previousX < 0 or previousY < 0 or previousX >= previousWidth or previousY >= previousHeight:
				positionsToUpdate[Vector2(x, y)] = true
	oSlabPlacement.place_shape_of_slab_id(positionsToUpdate.keys(), Slabs.EARTH, 5)
	return positionsToUpdate

# Function to remove old borders
func remove_old_borders(previousWidth, previousHeight, offsetX, offsetY, westDelta, northDelta, eastDelta, southDelta):
	var removeBorder = []
	if westDelta > 0:
		for y in previousHeight:
			removeBorder.append(Vector2(offsetX, offsetY + y))
	if eastDelta > 0:
		for y in previousHeight:
			removeBorder.append(Vector2(offsetX + previousWidth - 1, offsetY + y))
	if northDelta > 0:
		for x in previousWidth:
			removeBorder.append(Vector2(offsetX + x, offsetY))
	if southDelta > 0:
		for x in previousWidth:
			removeBorder.append(Vector2(offsetX + x, offsetY + previousHeight - 1))
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
	
	for instance in oInstances.all_instances.duplicate():
		if is_instance_valid(instance) and (instance.locationX < 0 or instance.locationY < 0 or instance.locationX >= newWidthInSubtiles or instance.locationY >= newHeightInSubtiles):
			deletedInstancesCount += 1
			oInstances.kill_instance(instance)
	
	if deletedInstancesCount > 0:
		oMessage.quick("Deleted " + str(deletedInstancesCount) + " instances that were outside of the new map size.")


onready var oDataSlab = Nodelist.list["oDataSlab"]

func shift_instances(offsetX, offsetY, previousWidth, newWidth, newHeight):
	var offsetSubtileX = offsetX * 3
	var offsetSubtileY = offsetY * 3
	for instance in oInstances.all_instances.duplicate():
		if is_instance_valid(instance) == false:
			continue
		var parentTile = instance.get("parentTile")
		if parentTile != null and parentTile != 65535:
			var previousParentTile = int(parentTile)
			var parentX = previousParentTile % previousWidth
			var parentY = int(previousParentTile / previousWidth)
			parentX += offsetX
			parentY += offsetY
			instance.remove_from_group("attachedtotile_" + str(previousParentTile))
			if parentX < 0 or parentY < 0 or parentX >= newWidth or parentY >= newHeight:
				oInstances.kill_instance(instance)
				continue
			instance.parentTile = (parentY * newWidth) + parentX
			instance.add_to_group("attachedtotile_" + str(instance.parentTile))
		instance.locationX += offsetSubtileX
		instance.locationY += offsetSubtileY

# The main function that calls all the helper functions
func _on_ResizeApplyButton_pressed():
	var northDelta = int(oResizeTopSpinBox.value)
	var southDelta = int(oResizeBottomSpinBox.value)
	var westDelta = int(oResizeLeftSpinBox.value)
	var eastDelta = int(oResizeRightSpinBox.value)
	if northDelta == 0 and southDelta == 0 and westDelta == 0 and eastDelta == 0:
		return
	
	if oCurrentFormat.selected == Constants.ClassicFormat:
		oMessage.big("Error", "Cannot resize map because it's in Classic format. Switch to KFX format first.")
		return
	
	var previousWidth = M.xSize
	var previousHeight = M.ySize
	var newWidth = previousWidth + westDelta + eastDelta
	var newHeight = previousHeight + northDelta + southDelta
	var offsetX = westDelta
	var offsetY = northDelta
	
	if newWidth < 1 or newHeight < 1:
		oMessage.big("Error", "Map size must be at least 1 x 1.")
		return
	if newWidth > 170 or newHeight > 170:
		oMessage.big("Error", "Map size cannot be larger than 170 x 170.")
		return
	
	oBuffers.resize_all_data_structures(newWidth, newHeight, offsetX, offsetY)
	shift_instances(offsetX, offsetY, previousWidth, newWidth, newHeight)
	set_new_map_size(newWidth, newHeight)
	remove_outside_instances(newWidth, newHeight)
	
	var positionsToUpdate = fill_new_area(newWidth, newHeight, previousWidth, previousHeight, offsetX, offsetY)
	var removeBorder = remove_old_borders(previousWidth, previousHeight, offsetX, offsetY, westDelta, northDelta, eastDelta, southDelta)
	var addBorder = add_new_borders(newWidth, newHeight)
	for pos in removeBorder:
		positionsToUpdate[pos] = true
	for pos in addBorder:
		positionsToUpdate[pos] = true
	
	update_editor_appearance()
	
	oOverheadGraphics.update_full_overhead_map()
	
	# I need to update every slab on the map, it's bugged otherwise, it clears a diagonal streak of objects for some reason.
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, true)
	
	#yield(oSlabPlacement.generate_slabs_based_on_id(positionsToUpdate.keys(), true), "completed") # Important to update surrounding slabs too. For example, rooms that get cut off.
	
	oResizeTopSpinBox.value = 0
	oResizeBottomSpinBox.value = 0
	oResizeLeftSpinBox.value = 0
	oResizeRightSpinBox.value = 0
	update_resize_map_size_label()


func update_editor_appearance():
	oEditor.update_boundaries()
	oOverheadOwnership.start()
	oGuidelines.update()


func _on_ResizeFillWithID_value_changed(value):
	value = int(value)
	if Slabs.data.has(value):
		oResizeFillWithIDLabel.text = Slabs.fetch_name(value)

func _on_ResizeEdgeSpinBox_value_changed(value):
	update_resize_map_size_label()

#	for pos in positionsToUpdate.keys():
#		var scene = preload('res://t.tscn')
#		var id = scene.instance()
#		id.position = Vector2((pos.x*96)+48, (pos.y*96)+48)
#		oInstances.add_child(id)
