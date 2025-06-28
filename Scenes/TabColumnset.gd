extends VBoxContainer

onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oConfirmDeleteColumnsetFile = Nodelist.list["oConfirmDeleteColumnsetFile"]
onready var oExportColumnsetTomlDialog = Nodelist.list["oExportColumnsetTomlDialog"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oColumnsetPathsLabel = Nodelist.list["oColumnsetPathsLabel"]
onready var oColumnsetVoxelView = Nodelist.list["oColumnsetVoxelView"]
onready var oExportColumnsToml = Nodelist.list["oExportColumnsToml"]
onready var oColumnsetDeleteButton = Nodelist.list["oColumnsetDeleteButton"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]
onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]

var flash_update_timer = Timer.new()

func _ready():
	# Setup flash update timer
	add_child(flash_update_timer)
	flash_update_timer.one_shot = true
	flash_update_timer.wait_time = 0.5
	flash_update_timer.connect("timeout", self, "_on_flash_update_timer_timeout")
	
	# Connect columnset controls
	var columnsetDeleteButton = get_node("HBoxContainer/VBoxContainer/PanelContainer2/GridContainer/ColumnsetDeleteButton")
	var exportColumnsToml = get_node("HBoxContainer/VBoxContainer/PanelContainer2/GridContainer/ExportColumnsToml")
	var columnsetHelpButton = get_node("HBoxContainer/VBoxContainer/PanelContainer2/GridContainer/ColumnsetHelpButton")
	columnsetDeleteButton.connect("pressed", self, "_on_ColumnsetDeleteButton_pressed")
	exportColumnsToml.connect("pressed", self, "_on_ExportColumnsToml_pressed")
	columnsetHelpButton.connect("pressed", self, "_on_ColumnsetHelpButton_pressed")
	
	# Connect external dialog connections
	oConfirmDeleteColumnsetFile.connect("confirmed", self, "_on_ConfirmDeleteColumnsetFile_confirmed")
	oExportColumnsetTomlDialog.connect("file_selected", self, "_on_ExportColumnsetTomlDialog_file_selected")
	
	# Connect to columnset controls to update save button availability
	var timer = oColumnsetControls.regeneration_timer
	timer.connect("timeout", self, "_on_columnset_timer_timeout")
	
	# Connect visibility changed
	connect("visibility_changed", self, "_on_TabColumnset_visibility_changed")
	
	# Connect flash update for columnset controls
	connect_columnset_flash_update()

func connect_columnset_flash_update():
	# Connect Columnset controls (delayed flash update)
	if oColumnsetControls.oColumnIndexSpinBox.is_connected("value_changed", self, "on_delayed_spinbox_value_changed") == false:
		oColumnsetControls.oColumnIndexSpinBox.connect("value_changed", self, "on_delayed_spinbox_value_changed")

func on_delayed_spinbox_value_changed(value):
	flash_update_timer.stop()
	flash_update_timer.start()

func _on_flash_update_timer_timeout():
	update_flash_state()

func update_flash_state():
	if visible:
		var columnsetIndex = int(oColumnsetControls.oColumnIndexSpinBox.value)
		oFlashingColumns.start_columnset_flash(columnsetIndex)

func initialize_tab():
	oColumnsetVoxelView.visible = true
	oDkSlabsetVoxelView.visible = false
	oColumnsetVoxelView.initialize()

func _on_TabColumnset_visibility_changed():
	if visible:
		update_columnset_delete_button_state()
		update_save_columnset_button_availability()
		
		# Initialize columnset controls when becoming visible
		oColumnsetControls.just_opened()
		
		# Update flash state when becoming visible
		update_flash_state()

func update_columnset_delete_button_state():
	var mapName = oCurrentMap.path.get_file().get_basename()
	var columnsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".columnset.toml")
	
	var dir = Directory.new()
	if dir.file_exists(columnsetFilePath):
		oColumnsetDeleteButton.disabled = false
	else:
		oColumnsetDeleteButton.disabled = true

func update_save_columnset_button_availability():
	var list_of_modified_columns = Columnset.find_all_different_columns()
	if list_of_modified_columns.empty():
		oExportColumnsToml.disabled = true
	else:
		oExportColumnsToml.disabled = false

func _on_columnset_timer_timeout():
	update_save_columnset_button_availability()

func _on_ExportColumnsToml_pressed():
	Utils.popup_centered(oExportColumnsetTomlDialog)
	oExportColumnsetTomlDialog.current_dir = oCurrentMap.path.get_base_dir().plus_file("")
	oExportColumnsetTomlDialog.current_path = oCurrentMap.path.get_base_dir().plus_file("")
	
	yield(get_tree(),'idle_frame') # Important if there's another toml file there
	oExportColumnsetTomlDialog.get_line_edit().text = oCurrentMap.path.get_file().get_basename()+".columnset.toml"

func _on_ExportColumnsetTomlDialog_file_selected(filePath):
	Columnset.export_toml_columnset(filePath)
	for i in 50:
		yield(get_tree(),'idle_frame')
	
	var dir = Directory.new()
	if dir.file_exists(filePath):
		update_columnset_delete_button_state()
		
		if oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP].has(filePath) == false:
			oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP].append(filePath)
			oColumnsetPathsLabel.start()

func _on_ColumnsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "columnset.toml is a global file in /fxdata/ that is used by all maps in the game, but it can also be saved as a local file for a map or campaign. When you run the game both columnset.toml files will be loaded, but with the local file overwriting any same fields of the file in /fxdata/.\n"
	helptxt += "\n"
	helptxt += "Be wary not to confuse the Columnset with the CLM data:\n"
	helptxt += "- The Columnset (.toml) represents the appearance of new columns that are yet to be placed in the future.\n"
	helptxt += "- CLM entries (.clm) represent the appearance of all columns that have already been placed on the map.\n"
	
	oMessage.big("Help",helptxt)

func _on_ColumnsetDeleteButton_pressed():
	oConfirmDeleteColumnsetFile.dialog_text = "Revert all columns to default and delete this file?\n"
	var mapName = oCurrentMap.path.get_file().get_basename()
	var columnsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".columnset.toml")
	oConfirmDeleteColumnsetFile.dialog_text += columnsetFilePath
	oConfirmDeleteColumnsetFile.rect_min_size.x = 800
	Utils.popup_centered(oConfirmDeleteColumnsetFile)

func _on_ConfirmDeleteColumnsetFile_confirmed():
	var mapName = oCurrentMap.path.get_file().get_basename()
	var columnsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".columnset.toml")
	
	var dir = Directory.new()
	if dir.file_exists(columnsetFilePath):
		var err = dir.remove(columnsetFilePath)
		if err == OK:
			oMessage.quick("Deleted: " + columnsetFilePath)
			oMessage.quick("Reverted all columns")
			
			# Revert every column to its default state
			var column_ids = []
			for column_id in Columnset.default_data["cubes"].size():
				column_ids.append(column_id)
			oColumnsetControls.revert_columns(column_ids)
			
			# Remove from the little box thing of currently loaded files
			oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP].erase(columnsetFilePath)
			oColumnsetPathsLabel.start()
			
			# Update the UI
			oSlabsetWindow.update_column_spinboxes()
			oColumnsetControls._on_ColumnIndexSpinBox_value_changed(oColumnsetControls.oColumnIndexSpinBox.value)
			oColumnsetControls.adjust_ui_color_if_different()
			oColumnsetVoxelView.refresh_entire_view()
			
			update_columnset_delete_button_state()
		else:
			oMessage.big("Error", "Failed to delete the file.")
	else:
		oMessage.big("Error", "The columnset file doesn't exist.")
