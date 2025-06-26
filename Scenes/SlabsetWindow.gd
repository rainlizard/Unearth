extends WindowDialog
onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oSlabsetTabs = Nodelist.list["oSlabsetTabs"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oSlabsetPathsLabel = Nodelist.list["oSlabsetPathsLabel"]
onready var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oTabSlabset = Nodelist.list["oTabSlabset"]
onready var oTabColumnset = Nodelist.list["oTabColumnset"]
onready var oColumnsetPathsLabel = Nodelist.list["oColumnsetPathsLabel"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]

var is_initializing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	oSlabsetTabs.set_tab_title(0, "Slabset") #slabs.dat
	oSlabsetTabs.set_tab_title(1, "Columnset") #slabs.clm
	oSlabsetTabs.set_tab_title(2, "CLM data") #map.clm
	
	oDkSlabsetVoxelView.initialize()
	
	connect("item_rect_changed", self, "_on_SlabsetWindow_item_rect_changed")
	
	# Connect window signals
	connect("visibility_changed", self, "_on_SlabsetWindow_visibility_changed")
	oSlabsetTabs.connect("tab_changed", self, "_on_SlabsetTabs_tab_changed")
	
	oTabSlabset.connect("column_shortcut_pressed", self, "_on_TabSlabset_column_shortcut_pressed")

func _on_SlabsetWindow_item_rect_changed():
	if Settings.haveInitializedAllSettings == false: return
	Settings.set_setting("slabset_window_size", rect_size)
	Settings.set_setting("slabset_window_position", rect_position)

func popup_on_right_side():
	var hasPositionSetting = Settings.cfg_has_setting("slabset_window_position")
	var hasSizeSetting = Settings.cfg_has_setting("slabset_window_size")
	
	if hasPositionSetting == false or hasSizeSetting == false:
		var screenSize = OS.get_screen_size()
		var defaultWidth = 610
		var defaultHeight = 990
		
		if hasSizeSetting == false:
			rect_size = Vector2(defaultWidth, defaultHeight)
		
		if hasPositionSetting == false:
			var rightSideX = screenSize.x - defaultWidth - 50
			var centeredY = (screenSize.y - defaultHeight) / 2
			rect_position = Vector2(rightSideX, centeredY)
	
	visible = true

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			oTabSlabset.update_slabset_delete_button_state()
			oTabColumnset.update_columnset_delete_button_state()

func _on_SlabsetWindow_visibility_changed():
	if visible == true:
		is_initializing = true
		_on_SlabsetTabs_tab_changed(oSlabsetTabs.current_tab)
		
		oSlabsetPathsLabel.start()
		oColumnsetPathsLabel.start()
		
		oTabSlabset.update_slabset_delete_button_state()
		oTabColumnset.update_columnset_delete_button_state()
		
		yield(get_tree(),'idle_frame')
		oDkSlabsetVoxelView.oAllVoxelObjects.visible = true
		is_initializing = false
		update_flash_state()
	elif visible == false:
		oFlashingColumns.stop_column_flash()
		oPickSlabWindow.add_slabs()
		Columnset.update_list_of_columns_that_contain_owned_cubes()
		Columnset.update_list_of_columns_that_contain_rng_cubes()

func _on_SlabsetTabs_tab_changed(tab):
	match tab:
		0: # dat
			oTabSlabset.initialize_tab()
		1: # clm
			oTabColumnset.initialize_tab()
		2: # CLM data
			oTabClmEditor.initialize_tab()
	
	update_flash_state()

func open_from_cursor_position():
	var data = oSlabsetMapRegenerator.calculate_cursor_data()
	
	var columnDetailsVisible = oPropertiesTabs.current_tab == 2
	
	if visible == false:
		popup_on_right_side()
	
	# Use the full variation to determine the correct slabID and local variation
	var actualSlabID = data.fullVariation / 28
	var actualLocalVariation = data.fullVariation % 28
	
	if columnDetailsVisible:
		# When opened from Column mode, just set values without tab switching
		oSlabsetIDSpinBox.value = actualSlabID
		oVariationNumberSpinBox.value = actualLocalVariation
		oTabSlabset._on_SlabsetIDSpinBox_value_changed(actualSlabID)
		oTabSlabset.variation_changed(actualLocalVariation)
		
		oColumnsetControls.oColumnIndexSpinBox.value = data.columnsetIndex
		
		oTabClmEditor.set_clm_column_index(data.clmEntryIndex)
		
		update_flash_state()
	else:
		# When opened from other modes, do the full tab navigation
		oSlabsetIDSpinBox.value = actualSlabID
		oVariationNumberSpinBox.value = actualLocalVariation
		oSlabsetTabs.current_tab = 0
		oTabSlabset._on_SlabsetIDSpinBox_value_changed(actualSlabID)
		oTabSlabset.variation_changed(actualLocalVariation)
		
		yield(get_tree(), 'idle_frame')
		
		oSlabsetTabs.current_tab = 1
		oColumnsetControls.oColumnIndexSpinBox.value = data.columnsetIndex
		
		yield(get_tree(), 'idle_frame')
		
		oSlabsetTabs.current_tab = 2
		oTabClmEditor.set_clm_column_index(data.clmEntryIndex)

func update_flash_state():
	if not is_instance_valid(oFlashingColumns) or is_initializing:
		return
	
	if visible:
		match oSlabsetTabs.current_tab:
			0: # Slabset tab - flash all positions using the same full variation
				oTabClmEditor.disconnect_flash_connection()
				
				oTabSlabset.update_flash_state()
			1: # Columnset tab
				oTabClmEditor.disconnect_flash_connection()
				
				oTabColumnset.update_flash_state()
			2: # CLM data tab
				oTabClmEditor.setup_flash_connection()
				oTabClmEditor.update_clm_flash_state()
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
