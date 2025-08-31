extends WindowDialog
onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oSlabsetTabs = Nodelist.list["oSlabsetTabs"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oTabSlabset = Nodelist.list["oTabSlabset"]
onready var oTabColumnset = Nodelist.list["oTabColumnset"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

var is_initializing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	oSlabsetTabs.set_tab_title(0, "Slabset") #slabs.dat
	oSlabsetTabs.set_tab_title(1, "Columnset") #slabs.clm
	oSlabsetTabs.set_tab_title(2, "CLM data") #map.clm
	
	# Hide or show the CLM data tab according to user preference
	var show_clm_tab = Settings.get_setting("show_clm_data_tab")
	oSlabsetTabs.set_tab_hidden(2, !show_clm_tab)
	if show_clm_tab == false and oSlabsetTabs.current_tab == 2:
		oSlabsetTabs.current_tab = 0
	
	oDkSlabsetVoxelView.initialize()
	

	
	# Connect window signals
	connect("visibility_changed", self, "_on_SlabsetWindow_visibility_changed")
	
	oSlabsetTabs.connect("tab_changed", self, "_on_SlabsetTabs_tab_changed")
	oTabSlabset.connect("column_shortcut_pressed", self, "_on_TabSlabset_column_shortcut_pressed")


func update_window_title():
	match oSlabsetTabs.current_tab:
		0: # Slabset tab
			var file_path = oCurrentMap.current_filepath_for_slabset
			if file_path != "":
				if "/" in file_path:
					window_title = "Slabset - campaign"
				else:
					window_title = "Slabset - local"
			else:
				window_title = "Slabset"
		1: # Columnset tab
			var file_path = oCurrentMap.current_filepath_for_columnset
			if file_path != "":
				if "/" in file_path:
					window_title = "Columnset - campaign"
				else:
					window_title = "Columnset - local"
			else:
				window_title = "Columnset"
		2: # CLM data tab (map.clm)
			if oCurrentMap.path != "":
				window_title = "CLM data - local"
			else:
				window_title = "CLM data"


func _on_SlabsetTabs_tab_changed(tab):
	match tab:
		0: # dat
			oTabSlabset._on_TabSlabset_visibility_changed()
		1: # clm
			oTabColumnset._on_TabColumnset_visibility_changed()
		2: # CLM data
			oTabClmEditor._on_ColumnEditor_visibility_changed()
	
	update_window_title()



func popup_on_right_side():
	var oUi = Nodelist.list["oUi"]
	var desiredPosition = oUi.get_desired_window_position(name)
	var desiredSize = oUi.get_desired_window_size(name)
	
	if desiredPosition == Vector2.ZERO or desiredSize == Vector2.ZERO:
		var screenSize = OS.get_screen_size()
		var defaultWidth = 610
		var defaultHeight = 990
		
		if desiredSize == Vector2.ZERO:
			rect_size = Vector2(defaultWidth, defaultHeight)
			oUi.set_desired_window_size(name, rect_size)
		else:
			rect_size = desiredSize
		
		if desiredPosition == Vector2.ZERO:
			var rightSideX = screenSize.x - defaultWidth - 50
			var centeredY = (screenSize.y - defaultHeight) / 2
			rect_position = Vector2(rightSideX, centeredY)
			oUi.set_desired_window_position(name, rect_position)
		else:
			rect_position = desiredPosition
	else:
		rect_position = desiredPosition
		rect_size = desiredSize
	
	visible = true

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			if oCurrentMap.path != "":
				oTabSlabset.update_slabset_revert_button_state()
				oTabColumnset.update_columnset_revert_button_state()

func _on_SlabsetWindow_visibility_changed():
	if visible == true:
		is_initializing = true
		
		oTabSlabset.update_slabset_revert_button_state()
		oTabColumnset.update_columnset_revert_button_state()
		
		update_window_title()
		
		yield(get_tree(),'idle_frame')
		oDkSlabsetVoxelView.oAllVoxelObjects.visible = true
		is_initializing = false
		update_flash_state()
	elif visible == false:
		oFlashingColumns.stop_column_flash()
		oPickSlabWindow.add_slabs()
		Columnset.update_list_of_columns_that_contain_owned_cubes()
		Columnset.update_list_of_columns_that_contain_rng_cubes()

func open_from_cursor_position():
	var data = oSlabsetMapRegenerator.calculate_cursor_data()
	
	if visible == false:
		popup_on_right_side()
	
	# Use the full variation to determine the correct slabID and local variation
	var actualSlabID = data.fullVariation / 28
	var actualLocalVariation = data.fullVariation % 28
	
	# Validate slab ID for navigation restrictions
	if not Slabset.is_valid_slab_id_for_navigation(actualSlabID):
		if actualSlabID > Slabset.highest_slabset_id_from_fxdata and actualSlabID < Slabset.reserved_slabset:
			actualSlabID = Slabset.highest_slabset_id_from_fxdata
			actualLocalVariation = 0
	
	# When opened from Column mode, just set values without tab switching
	oSlabsetIDSpinBox.value = actualSlabID
	oVariationNumberSpinBox.value = actualLocalVariation
	oTabSlabset._on_SlabsetIDSpinBox_value_changed(actualSlabID)
	oTabSlabset.variation_changed(actualLocalVariation)
	
	oColumnsetControls.oColumnIndexSpinBox.value = data.columnsetIndex
	
	oTabClmEditor.set_clm_column_index(data.clmEntryIndex)
	
	update_flash_state()

func update_flash_state():
	if not is_instance_valid(oFlashingColumns) or is_initializing:
		return
	
	if visible:
		update_window_title()
		match oSlabsetTabs.current_tab:
			0: # Slabset tab - flash all positions using the same full variation
				oTabClmEditor.disconnect_flash_connection()
				var currentVariation = oTabSlabset.get_current_variation()
				var slabID = int(oSlabsetIDSpinBox.value)
				oFlashingColumns.start_variation_flash(currentVariation, slabID)
			1: # Columnset tab
				oTabClmEditor.disconnect_flash_connection()
				var columnsetIndex = int(oColumnsetControls.oColumnIndexSpinBox.value)
				oFlashingColumns.start_columnset_flash(columnsetIndex)
			2: # CLM data tab
				oTabClmEditor.setup_flash_connection()
				var columnIndex = int(oTabClmEditor.get_clm_column_index())
				oFlashingColumns.start_column_flash(columnIndex)
			_:
				oTabClmEditor.disconnect_flash_connection()
				oFlashingColumns.stop_column_flash()
	else:
		oTabClmEditor.disconnect_flash_connection()
		oFlashingColumns.stop_column_flash()

# Helper methods that delegate to TabSlabset
func update_column_spinboxes():
	oTabSlabset.update_column_spinboxes()

func variation_changed(localVariation):
	oTabSlabset.variation_changed(localVariation)

func _on_TabSlabset_column_shortcut_pressed(clmIndex):
	oSlabsetTabs.current_tab = 1
	oColumnsetControls.oColumnIndexSpinBox.value = clmIndex

func update_slabset_and_columnset_widgets():
	oTabSlabset.update_slabset_revert_button_state()
	oTabColumnset.update_columnset_revert_button_state()
	update_window_title()
