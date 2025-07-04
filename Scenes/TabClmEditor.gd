extends VBoxContainer
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oClmEditorControls = Nodelist.list["oClmEditorControls"]
onready var oConfirmClmClearUnused = Nodelist.list["oConfirmClmClearUnused"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMapClmFilenameLabel = Nodelist.list["oMapClmFilenameLabel"]
onready var oColumnEditorClearUnusedButton = Nodelist.list["oColumnEditorClearUnusedButton"]
onready var oColumnEditorSortButton = Nodelist.list["oColumnEditorSortButton"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]

var overhead_update_timer = Timer.new()
var pending_clm_index = -1

func _ready():
	overhead_update_timer.one_shot = true
	overhead_update_timer.wait_time = 0.25
	overhead_update_timer.connect("timeout", self, "_on_overhead_update_timer_timeout")
	add_child(overhead_update_timer)
	
	if is_instance_valid(oClmEditorControls):
		oClmEditorControls.connect("cube_value_changed", self, "_on_cube_value_changed")
		oClmEditorControls.connect("floor_texture_changed", self, "_on_floor_texture_changed")
		oClmEditorControls.connect("column_pasted", self, "_on_column_pasted")
		oClmEditorControls.connect("column_reverted", self, "_on_column_reverted")
	
	# Connect TabClmEditor controls
	var columnEditorClearUnusedButton = get_node("HBoxContainer/VBoxContainer2/PanelContainer2/HBoxContainer/ColumnEditorClearUnusedButton")
	var columnEditorSortButton = get_node("HBoxContainer/VBoxContainer2/PanelContainer2/HBoxContainer/ColumnEditorSortButton")
	var columnEditorHelpButton = get_node("HBoxContainer/VBoxContainer2/PanelContainer2/HBoxContainer/ColumnEditorHelpButton")
	connect("visibility_changed", self, "_on_ColumnEditor_visibility_changed")
	
	columnEditorClearUnusedButton.connect("pressed", self, "_on_ColumnEditorClearUnusedButton_pressed")
	columnEditorSortButton.connect("pressed", self, "_on_ColumnEditorSortButton_pressed")
	columnEditorHelpButton.connect("pressed", self, "_on_ColumnEditorHelpButton_pressed")
	
	# Connect ConfirmClmClearUnused
	if is_instance_valid(oConfirmClmClearUnused):
		oConfirmClmClearUnused.connect("confirmed", self, "_on_ConfirmClmClearUnused_confirmed")

func _on_cube_value_changed(clmIndex):
	if clmIndex > 0:
		update_overhead_for_clm_changes(clmIndex)

func _on_floor_texture_changed(clmIndex):
	if clmIndex > 0:
		update_overhead_for_clm_changes(clmIndex)

func _on_column_pasted(clmIndex):
	if clmIndex > 0:
		update_overhead_for_clm_changes(clmIndex)

func _on_column_reverted(clmIndex):
	if clmIndex > 0:
		update_overhead_for_clm_changes(clmIndex)

func update_overhead_for_clm_changes(clmIndex):
	pending_clm_index = clmIndex
	overhead_update_timer.stop()
	overhead_update_timer.start()

func _on_overhead_update_timer_timeout():
	if pending_clm_index == -1:
		return
	var shapePositionArray = []
	for y in range(M.ySize * 3):
		for x in range(M.xSize * 3):
			var currentClmIndex = oDataClmPos.get_cell_clmpos(x, y)
			if currentClmIndex == pending_clm_index:
				var tilePos = Vector2(x / 3, y / 3)
				if shapePositionArray.find(tilePos) == -1:
					shapePositionArray.append(tilePos)
	if shapePositionArray.size() > 0:
		oOverheadGraphics.call_deferred("overhead2d_update_rect_single_threaded", shapePositionArray)
	pending_clm_index = -1

func set_clm_column_index(clmEntryIndex):
	oClmEditorControls.oColumnIndexSpinBox.value = clmEntryIndex

func get_clm_column_index():
	return oClmEditorControls.oColumnIndexSpinBox.value

func setup_flash_connection():
	if not oClmEditorControls.oColumnIndexSpinBox.is_connected("value_changed", self, "_on_clm_column_index_changed"):
		oClmEditorControls.oColumnIndexSpinBox.connect("value_changed", self, "_on_clm_column_index_changed")

func disconnect_flash_connection():
	if oClmEditorControls.oColumnIndexSpinBox.is_connected("value_changed", self, "_on_clm_column_index_changed"):
		oClmEditorControls.oColumnIndexSpinBox.disconnect("value_changed", self, "_on_clm_column_index_changed")

func _on_clm_column_index_changed(value):
	oSlabsetWindow.update_flash_state()

func update_flash_state():
	var columnIndex = int(oClmEditorControls.oColumnIndexSpinBox.value)
	oFlashingColumns.start_column_flash(columnIndex)

# When re-opening window or opening for first time
func _on_ColumnEditor_visibility_changed():
	if visible == true:
		oClmEditorControls.just_opened()
		oClmEditorVoxelView.initialize()
		if oCurrentMap.path == "":
			oMapClmFilenameLabel.text = "No saved file"
			oMapClmFilenameLabel.hint_tooltip = ""
		else:
			oMapClmFilenameLabel.text = oCurrentMap.path.get_file().get_basename() + ".clm"
			oMapClmFilenameLabel.hint_tooltip = oCurrentMap.path.get_base_dir() + "/" + oCurrentMap.path.get_file().get_basename() + ".clm"
		oClmEditorControls._on_ColumnIndexSpinBox_value_changed(oClmEditorControls.oColumnIndexSpinBox.value)
		update_clm_editing_buttons()
		oSlabsetWindow.update_flash_state()
	else:
		# Update "Clm entries" in properties window
		yield(get_tree(),'idle_frame')
		oDataClm.count_filled_clm_entries()

func update_clm_editing_buttons():
	var allowEditing = Settings.get_setting("allow_clm_data_editing")
	if allowEditing == null or not Settings.haveInitializedAllSettings:
		allowEditing = false
	
	oColumnEditorClearUnusedButton.disabled = not allowEditing
	oColumnEditorSortButton.disabled = not allowEditing

func _on_ColumnEditorHelpButton_pressed():
	var helptxt = ""
	helptxt += "- To edit CLM data, enable 'Allow CLM data editing' in Preferences > UI."
	helptxt += '\n'
	helptxt += "- Use middle mouse to zoom in and out, left click and drag to rotate view. You can use the arrow keys to switch between columns faster and also use arrow keys while a field's selected to navigate cubes faster." #Holding left click on a field's little arrows while moving the mouse up or down provides speedy navigation too.
	helptxt += '\n'
	helptxt += "- If your column has multiple gaps then some of the top/bottom cube faces may not display in-game."
	oMessage.big("Help",helptxt)


func _on_ColumnEditorClearUnusedButton_pressed():
	Utils.popup_centered(oConfirmClmClearUnused)

func _on_ConfirmClmClearUnused_confirmed():
	oEditor.mapHasBeenEdited = true
	oDataClm.clear_unused_entries()
	oFlashingColumns.generate_clmdata_texture()
	
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
