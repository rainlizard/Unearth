extends VBoxContainer
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oAllVoxelObjects = Nodelist.list["oAllVoxelObjects"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oClmEditorControls = Nodelist.list["oClmEditorControls"]
onready var oConfirmClmClearUnused = Nodelist.list["oConfirmClmClearUnused"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMapClmFilenameLabel = Nodelist.list["oMapClmFilenameLabel"]

# When re-opening window or opening for first time
func _on_ColumnEditor_visibility_changed():
	if is_instance_valid(oDataClm) == false: return
	
	if visible == true:
		oClmEditorControls.just_opened()
		oClmEditorVoxelView.initialize()
		oPropertiesTabs.set_current_tab(2)
		
		oMapClmFilenameLabel.text = oCurrentMap.path.get_file().get_basename() + ".clm"
		
		# Refresh controls
		oClmEditorControls._on_ColumnIndexSpinBox_value_changed(oClmEditorControls.oColumnIndexSpinBox.value)
		
	else:
		# Update "Clm entries" in properties window
		yield(get_tree(),'idle_frame')
		oDataClm.count_filled_clm_entries()

func _on_ColumnEditorHelpButton_pressed():
	var helptxt = ""
	helptxt += "- Use middle mouse to zoom in and out, left click and drag to rotate view. You can use the arrow keys to switch between columns faster and also use arrow keys while a field's selected to navigate cubes faster." #Holding left click on a field's little arrows while moving the mouse up or down provides speedy navigation too.
	helptxt += '\n'
	helptxt += "- If your column has multiple gaps then some of the top/bottom cube faces may not display in-game."
	helptxt += '\n'
	helptxt += "- Don't edit column 0's cubes, leave it blank."
	oMessage.big("Help",helptxt)


func _on_ColumnEditorClearUnusedButton_pressed():
	Utils.popup_centered(oConfirmClmClearUnused)

func _on_ConfirmClmClearUnused_confirmed():
	oEditor.mapHasBeenEdited = true
	oDataClm.clear_unused_entries()
	
	# Refresh voxel view
	oClmEditorVoxelView.refresh_entire_view()
	# Refresh controls
	oClmEditorControls._on_ColumnIndexSpinBox_value_changed(oClmEditorControls.oColumnIndexSpinBox.value)
	
	# Refresh "Clm entries" in Properties window
	oDataClm.count_filled_clm_entries()

func _on_ColumnEditorSortButton_pressed():
	oEditor.mapHasBeenEdited = true
	oDataClm.sort_columns_by_utilized()
	
	# Refresh voxel view
	oClmEditorVoxelView.refresh_entire_view()
	# Refresh controls
	oClmEditorControls._on_ColumnIndexSpinBox_value_changed(oClmEditorControls.oColumnIndexSpinBox.value)
