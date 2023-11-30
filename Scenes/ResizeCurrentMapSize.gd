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
			instance.queue_free()
	
	if deletedInstancesCount > 0:
		oMessage.quick("Deleted " + str(deletedInstancesCount) + " instances that were outside of the new map size.")

func update_editor_appearance():
	oEditor.update_boundaries()
	oOverheadOwnership.start()
	oOverheadGraphics.update_map_overhead_2d_textures()

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
	remove_outside_instances(newWidth, newHeight)
	
	var positionsToUpdate = get_positions_to_update(newWidth, newHeight, previousWidth, previousHeight)
	var removeBorder = remove_old_borders(newWidth, newHeight, previousWidth, previousHeight)
	var addBorder = add_new_borders(newWidth, newHeight)
	for pos in removeBorder:
		positionsToUpdate[pos] = true
	for pos in addBorder:
		positionsToUpdate[pos] = true
	
	set_various_grid_data(newWidth, newHeight, previousWidth, previousHeight)
	
	update_editor_appearance()
	
	oSlabPlacement.generate_slabs_based_on_id(positionsToUpdate.keys(), true) # Important to update surrounding slabs too. For example, rooms that get cut off.

func set_various_grid_data(newWidth, newHeight, previousWidth, previousHeight):
	var newWidthInSubtiles = newWidth * 3
	var newHeightInSubtiles = newHeight * 3
	var prevWidthInSubtiles = previousWidth * 3
	var prevHeightInSubtiles = previousHeight * 3

	for x in prevWidthInSubtiles:
		for y in prevHeightInSubtiles:
			if x >= newWidthInSubtiles or y >= newHeightInSubtiles:
				oDataClmPos.set_cell(x, y, 0)




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



#func _on_ResizeApplyButton_pressed():
#	var newWidth = int(oSettingsXSizeLine.text)
#	var newHeight = int(oSettingsYSizeLine.text)
#
#	var previousWidth = M.xSize
#	var previousHeight = M.ySize
#	M.xSize = newWidth
#	M.ySize = newHeight
#	oMapSizeTextLabel.text = str(M.xSize) + " x " + str(M.ySize)
#
#	var positionsToUpdate = {}
#
#	# Handle width
#	if newWidth > previousWidth:
#		for x in range(previousWidth, newWidth):
#			for y in newHeight:
#				positionsToUpdate[Vector2(x, y)] = true
#	# Handle height
#	if newHeight > previousHeight:
#		for y in range(previousHeight, newHeight):
#			for x in newWidth:
#				positionsToUpdate[Vector2(x, y)] = true
#
#	oEditor.update_boundaries()
#	oOverheadOwnership.start()
#	oOverheadGraphics.update_map_overhead_2d_textures()
#
#	# Apply changes for added positions
#	oSlabPlacement.place_shape_of_slab_id(positionsToUpdate.keys(), Slabs.EARTH, 5)
#
#	var removeBorder = [] # Remove old south and east borders when enlarging the map
#	if newWidth > previousWidth:
#		for y in previousHeight:
#			removeBorder.append(Vector2(previousWidth - 1, y))
#	if newHeight > previousHeight:
#		for x in previousWidth:
#			removeBorder.append(Vector2(x, previousHeight - 1))
#	oSlabPlacement.place_shape_of_slab_id(removeBorder, Slabs.EARTH, 5)
#
#	var addBorder = []
#	for x in newWidth:
#		addBorder.append(Vector2(x, 0))
#		addBorder.append(Vector2(x, newHeight - 1))
#	for y in newHeight:
#		addBorder.append(Vector2(0, y))
#		addBorder.append(Vector2(newWidth - 1, y))
#	oSlabPlacement.place_shape_of_slab_id(addBorder, Slabs.ROCK, 5)
#
#	for pos in addBorder: # Update the appearance of any border alterations
#		positionsToUpdate[pos] = true
#	for pos in removeBorder: # Update the appearance of any border alterations
#		positionsToUpdate[pos] = true
#
#	# Remove instances outside of the new map size
#	var instances = get_tree().get_nodes_in_group("Instance")
#	var deletedInstancesCount = 0
#	var newHeightInSubtiles = newHeight * 3
#	var newWidthInSubtiles =  newWidth * 3
#	for instance in instances:
#		if instance.locationX >= newWidthInSubtiles or instance.locationY >= newHeightInSubtiles:
#			deletedInstancesCount+=1
#			instance.queue_free()
#	if deletedInstancesCount > 0:
#		oMessage.quick("Deleted " + str(deletedInstancesCount) + " instances that were outside of the new map size.")
#
#	# Finalize
#	oSlabPlacement.generate_slabs_based_on_id(positionsToUpdate.keys(), false)



#onready var resizeSegments = [ # These are ColorRects by the way.
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment1,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment2,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment3,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment4,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment5,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment6,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment7,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment8,
#	$MarginContainer/VBoxContainer/GridContainer/ResizeSegment9,
#]
#
#func _ready():
#	for colorRectNode in resizeSegments:
#		colorRectNode.connect("gui_input", self, "_on_Segment_gui_input", [colorRectNode])


#func _on_Segment_gui_input(event, colorRectNode):
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
#		if event.pressed == true:
#			# Reset all segments to the default color
#			for segment in resizeSegments:
#				segment.color = Color(0.26, 0.27, 0.3, 1)
#
#			# Change the clicked segment's color
#			colorRectNode.color = Color(1, 1, 1, 1)


#	var selectedSegment = -1
#	for i in resizeSegments.size():
#		if resizeSegments[i].color == Color(1, 1, 1, 1):
#			selectedSegment = i + 1
#			break
#
#	if selectedSegment == -1:
#		print("No segment selected")
#		return
#
#	var xStart:int
#	var yStart:int
#	var xEnd:int
#	var yEnd:int
#
#	if selectedSegment in [1, 2, 3]:
#		xStart = 0
#	elif selectedSegment in [4, 5, 6]:
#		xStart = (newWidth - previousWidth) / 2
#	else:
#		xStart = previousWidth
#
#	if selectedSegment in [1, 4, 7]:
#		yStart = 0
#	elif selectedSegment in [2, 5, 8]:
#		yStart = (newHeight - previousHeight) / 2
#	else:
#		yStart = previousHeight
#
#	if selectedSegment in [3, 6, 9]:
#		xEnd = previousWidth
#	elif selectedSegment in [4, 5, 6]:
#		xEnd = (newWidth + previousWidth) / 2
#	else:
#		xEnd = newWidth
#
#	if selectedSegment in [7, 8, 9]:
#		yEnd = previousHeight
#	elif selectedSegment in [2, 5, 8]:
#		yEnd = (newHeight + previousHeight) / 2
#	else:
#		yEnd = newHeight
#
#	var newPositionArray = []
#	for x in range(xStart, xEnd):
#		for y in range(yStart, yEnd):
#			if x >= previousWidth or y >= previousHeight:
#				newPositionArray.append(Vector2(x, y))

