extends VBoxContainer

onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oConfirmRevertColumnset = Nodelist.list["oConfirmRevertColumnset"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oColumnsetVoxelView = Nodelist.list["oColumnsetVoxelView"]
onready var oColumnsetRevertButton = Nodelist.list["oColumnsetRevertButton"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentlyOpenColumnset = Nodelist.list["oCurrentlyOpenColumnset"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oModifiedColumnsetLabel = Nodelist.list["oModifiedColumnsetLabel"]
onready var oModifiedColumnsetPanelContainer = Nodelist.list["oModifiedColumnsetPanelContainer"]
onready var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]

var flash_update_timer = Timer.new()

func _ready():
	# Setup flash update timer
	add_child(flash_update_timer)
	flash_update_timer.one_shot = true
	flash_update_timer.wait_time = 0.5
	flash_update_timer.connect("timeout", self, "_on_flash_update_timer_timeout")
	
	# Connect to ConfigFileManager signals
	oConfigFileManager.connect("config_file_status_changed", self, "_on_config_status_changed")
	
	# Connect columnset controls
	var ColumnsetRevertButton = get_node("HBoxContainer/VBoxContainer/PanelContainer2/HBoxContainer/ColumnsetRevertButton")
	var columnsetHelpButton = get_node("HBoxContainer/VBoxContainer/PanelContainer2/HBoxContainer/ColumnsetHelpButton")
	ColumnsetRevertButton.connect("pressed", self, "_on_ColumnsetRevertButton_pressed")
	columnsetHelpButton.connect("pressed", self, "_on_ColumnsetHelpButton_pressed")
	oModifiedColumnsetLabel.connect("meta_clicked", self, "_on_ModifiedColumnsetLabel_meta_clicked")
	
	# Connect external dialog connections
	oConfirmRevertColumnset.connect("confirmed", self, "_on_ConfirmRevertColumnset_confirmed")
	
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
	if oSlabsetWindow.flash_ids_on_map == false:
		return
	flash_update_timer.stop()
	flash_update_timer.start()

func _on_flash_update_timer_timeout():
	oSlabsetWindow.update_flash_state()

func update_flash_state():
	if visible and oSlabsetWindow.flash_ids_on_map:
		var columnsetIndex = int(oColumnsetControls.oColumnIndexSpinBox.value)
		oFlashingColumns.start_columnset_flash(columnsetIndex)


func _on_TabColumnset_visibility_changed():
	if visible:
		oColumnsetControls.just_opened()
		oColumnsetVoxelView.initialize()
		update_columnset_revert_button_state()
		oSlabsetWindow.update_flash_state()

func update_columnset_revert_button_state():
	var list_of_modified_columns = Columnset.find_all_different_columns()
	oColumnsetRevertButton.disabled = list_of_modified_columns.empty()
	update_columnset_paths_label(list_of_modified_columns)
	update_modified_label_for_all_columns(list_of_modified_columns)

func update_columnset_paths_label(list_of_modified_columns):
	var file_path = oCurrentMap.existing_columnset_file
	var final_text = ""
	var tooltip_text = ""
	
	if list_of_modified_columns.empty():
		if Columnset.has_changes_since_load() and file_path != "":
			final_text = "Save will delete: " + file_path.get_file()
			tooltip_text = file_path
		else:
			final_text = ""
	elif file_path != "":
		var filename = file_path.get_file()
		if filename == "columnset.toml":
			final_text = "/" + file_path.get_base_dir().get_file() + "/" + filename
		else:
			final_text = filename
		tooltip_text = file_path
	else:
		if oCurrentMap.path == "":
			final_text = "Save map first"
			tooltip_text = "Save the map first to create a local columnset override."
		else:
			var local_file_path = oCurrentMap.path.get_basename() + ".columnset.toml"
			final_text = "Save will create: " + local_file_path.get_file()
			tooltip_text = local_file_path
	
	oCurrentlyOpenColumnset.text = final_text
	oCurrentlyOpenColumnset.hint_tooltip = tooltip_text
	oSlabsetWindow.update_window_title()

func update_modified_label_for_all_columns(list_of_modified_columns):
	Utils.set_id_links_label(list_of_modified_columns, oModifiedColumnsetLabel, oModifiedColumnsetPanelContainer, "No modified columns")

func _on_ModifiedColumnsetLabel_meta_clicked(meta):
	oColumnsetControls.oColumnIndexSpinBox.value = int(meta)

func _on_columnset_timer_timeout():
	update_columnset_revert_button_state()

func _on_ColumnsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "columnset.toml is a global file in /fxdata/ that is used by all maps in the game, but it can also be saved as a local file for a map or campaign. When you run the game both columnset.toml files will be loaded, but with the local file overwriting any same fields of the file in /fxdata/.\n"
	helptxt += "\n"
	helptxt += "When you save the map, Columnset edits are saved to the file shown at the top of this tab. If no Columnset file exists for this map yet, Unearth creates mapname.columnset.toml beside the map.\n"
	helptxt += "\n"
	helptxt += "Be wary not to confuse the Columnset with the CLM data:\n"
	helptxt += "- The Columnset (.toml) represents the appearance of new columns that are yet to be placed in the future.\n"
	helptxt += "- CLM entries (.clm) represent the appearance of all columns that have already been placed on the map.\n"
	
	oMessage.big("Help",helptxt)

func _on_ColumnsetRevertButton_pressed():
	oConfirmRevertColumnset.dialog_text = "Revert all columns to default?"
	oConfirmRevertColumnset.rect_min_size.x = 800
	Utils.popup_centered(oConfirmRevertColumnset)

func _on_ConfirmRevertColumnset_confirmed():
	var list_of_modified_columns = Columnset.find_all_different_columns()
	
	oEditor.mapHasBeenEdited = true
	# Perform the revert operation
	var column_ids = []
	for column_id in Columnset.default_data["cubes"].size():
		column_ids.append(column_id)
	oColumnsetControls.revert_columns(column_ids)
	oMessage.quick("Reverted all columns")
	
	# Update the UI
	oSlabsetWindow.update_column_spinboxes()
	oColumnsetControls._on_ColumnIndexSpinBox_value_changed(oColumnsetControls.oColumnIndexSpinBox.value)
	oColumnsetControls.adjust_ui_color_if_different()
	oColumnsetVoxelView.refresh_entire_view()
	update_columnset_revert_button_state()
	oSlabsetMapRegenerator.regenerate_slabs_using_columnsets(list_of_modified_columns)

func _on_config_status_changed():
	if Columnset.default_data.empty():
		return
	var list_of_modified_columns = Columnset.find_all_different_columns()
	update_columnset_paths_label(list_of_modified_columns)
	update_modified_label_for_all_columns(list_of_modified_columns)
