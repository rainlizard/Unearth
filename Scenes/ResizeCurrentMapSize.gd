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

func _on_ResizeCurrentMapSizeButton_pressed():
	Utils.popup_centered(self)

func _on_ResizeCurrentMapSize_about_to_show():
	oSettingsXSizeLine.text = str(M.xSize)
	oSettingsYSizeLine.text = str(M.ySize)

func _on_ResizeApplyButton_pressed():
	var newWidth = int(oSettingsXSizeLine.text)
	var newHeight = int(oSettingsYSizeLine.text)

	var previousWidth = M.xSize
	var previousHeight = M.ySize
	M.xSize = newWidth
	M.ySize = newHeight
	oMapSizeTextLabel.text = str(M.xSize) + " x " + str(M.ySize)

	var positionsToUpdate = {}
	
	# Handle width
	if newWidth > previousWidth:
		for x in range(previousWidth, newWidth):
			for y in range(newHeight):
				positionsToUpdate[Vector2(x, y)] = true
	# Handle height
	if newHeight > previousHeight:
		for y in range(previousHeight, newHeight):
			for x in range(newWidth):
				positionsToUpdate[Vector2(x, y)] = true

	oEditor.update_boundaries()
	oOverheadOwnership.start()
	oOverheadGraphics.update_map_overhead_2d_textures()

	# Apply changes for added positions
	var newlyAddedPositions = positionsToUpdate.keys()
	oSlabPlacement.place_shape_of_slab_id(newlyAddedPositions, int(oResizeFillWithID.value), 5)
	
	if oResizeMapApplyBorderCheckbox.pressed == true:
		var borderPositions = []
		for x in range(newWidth):
			positionsToUpdate[Vector2(x, 0)] = true
			positionsToUpdate[Vector2(x, newHeight - 1)] = true
			borderPositions.append(Vector2(x, 0))  # Top border
			borderPositions.append(Vector2(x, newHeight - 1))  # Bottom border
		for y in range(newHeight):
			positionsToUpdate[Vector2(0, y)] = true
			positionsToUpdate[Vector2(newWidth - 1, y)] = true
			borderPositions.append(Vector2(0, y))  # Left border
			borderPositions.append(Vector2(newWidth - 1, y))  # Right border
		oSlabPlacement.place_shape_of_slab_id(borderPositions, Slabs.ROCK, 5)
	
	# Finalize
	oSlabPlacement.generate_slabs_based_on_id(positionsToUpdate.keys(), false)

func _on_SettingsXSizeLine_focus_exited():
	if int(oSettingsXSizeLine.text) > 170:
		oSettingsXSizeLine.text = "170"

func _on_SettingsYSizeLine_focus_exited():
	if int(oSettingsYSizeLine.text) > 170:
		oSettingsYSizeLine.text = "170"


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

func _on_ResizeFillWithID_value_changed(value):
	value = int(value)
	if Slabs.data.has(value):
		oResizeFillWithIDLabel.text = Slabs.data[value][Slabs.NAME]
