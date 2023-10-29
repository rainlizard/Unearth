extends WindowDialog
onready var oSettingsXSizeLine = Nodelist.list["oSettingsXSizeLine"]
onready var oSettingsYSizeLine = Nodelist.list["oSettingsYSizeLine"]
onready var oMapSizeTextLabel = Nodelist.list["oMapSizeTextLabel"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]

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
	
	
	# Allow new area
	for xSlab in M.ySize:
		for ySlab in M.xSize:
			if oDataOwnership.get_cell(xSlab,ySlab) == 255:
				oDataOwnership.set_cell(xSlab,ySlab,5)
	oEditor.update_boundaries()
	oOverheadOwnership.start()
	oOverheadGraphics.update_map_overhead_2d_textures()
	
	yield(get_tree(),'idle_frame')
	
	var shapePositionArray = []
	# Iterate through the new rows added
	for x in range(previousWidth, newWidth):
		for y in range(newHeight):
			shapePositionArray.append(Vector2(x, y))
	# Iterate through the new columns added
	for y in range(previousHeight, newHeight):
		for x in range(previousWidth):  # Note: we use previousWidth here to avoid duplicate entries
			shapePositionArray.append(Vector2(x, y))
	
	var useOwner = 5
	var paintSlab = 0
	oSlabPlacement.place_shape_of_slab_id(shapePositionArray, paintSlab, useOwner)
	oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, false)


func _on_SettingsXSizeLine_focus_exited():
	if int(oSettingsXSizeLine.text) > 170:
		oSettingsXSizeLine.text = "170"

func _on_SettingsYSizeLine_focus_exited():
	if int(oSettingsYSizeLine.text) > 170:
		oSettingsYSizeLine.text = "170"
