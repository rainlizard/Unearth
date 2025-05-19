extends WindowDialog
onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oColumnsetVoxelView = Nodelist.list["oColumnsetVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oSlabsetSlabNameLabel = Nodelist.list["oSlabsetSlabNameLabel"]
onready var oGridContainerDynamicColumns3x3 = Nodelist.list["oGridContainerDynamicColumns3x3"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oExportSlabsetDatDialog = Nodelist.list["oExportSlabsetDatDialog"]
onready var oGame = Nodelist.list["oGame"]
onready var oExportColumnsetTomlDialog = Nodelist.list["oExportColumnsetTomlDialog"]
onready var oExportSlabsetTomlDialog = Nodelist.list["oExportSlabsetTomlDialog"]
onready var oSlabsetTabs = Nodelist.list["oSlabsetTabs"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oExportSlabsetClmDialog = Nodelist.list["oExportSlabsetClmDialog"]
onready var oObjObjectIndexSpinBox = Nodelist.list["oObjObjectIndexSpinBox"]
onready var oObjAddButton = Nodelist.list["oObjAddButton"]
onready var oObjDeleteButton = Nodelist.list["oObjDeleteButton"]
onready var oObjThingTypeSpinBox = Nodelist.list["oObjThingTypeSpinBox"]
onready var oObjSubtypeSpinBox = Nodelist.list["oObjSubtypeSpinBox"]
onready var oObjIsLightCheckBox = Nodelist.list["oObjIsLightCheckBox"]
onready var oObjEffectRangeSpinBox = Nodelist.list["oObjEffectRangeSpinBox"]
onready var oObjSubtileSpinBox = Nodelist.list["oObjSubtileSpinBox"]
onready var oObjRelativeXSpinBox = Nodelist.list["oObjRelativeXSpinBox"]
onready var oObjRelativeYSpinBox = Nodelist.list["oObjRelativeYSpinBox"]
onready var oObjRelativeZSpinBox = Nodelist.list["oObjRelativeZSpinBox"]
onready var oSlabsetObjectSection = Nodelist.list["oSlabsetObjectSection"]
onready var oObjSubtypeLabel = Nodelist.list["oObjSubtypeLabel"]
onready var oObjThingTypeLabel = Nodelist.list["oObjThingTypeLabel"]
onready var oObjNameLabel = Nodelist.list["oObjNameLabel"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oAddCustomSlabWindow = Nodelist.list["oAddCustomSlabWindow"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oSlabsetPathsLabel = Nodelist.list["oSlabsetPathsLabel"]
onready var oColumnsetPathsLabel = Nodelist.list["oColumnsetPathsLabel"]
onready var oSlabsetTextSIDLabel = Nodelist.list["oSlabsetTextSIDLabel"]
onready var oExportSlabsToml = Nodelist.list["oExportSlabsToml"]
onready var oExportColumnsToml = Nodelist.list["oExportColumnsToml"]
onready var oSlabRevertButton = Nodelist.list["oSlabRevertButton"]
onready var oVarRevertButton = Nodelist.list["oVarRevertButton"]
onready var oSlabsetDeleteButton = Nodelist.list["oSlabsetDeleteButton"]
onready var oColumnsetDeleteButton = Nodelist.list["oColumnsetDeleteButton"]
onready var oConfirmDeleteSlabsetFile = Nodelist.list["oConfirmDeleteSlabsetFile"]
onready var oConfirmDeleteColumnsetFile = Nodelist.list["oConfirmDeleteColumnsetFile"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oModifiedListLabel = Nodelist.list["oModifiedListLabel"]
onready var oModifiedListPanelContainer = Nodelist.list["oModifiedListPanelContainer"]

enum {
	ONE_VARIATION,
	ALL_VARIATION,
}

var clipboard = {
	"dat": [],
	"tng": []
}

onready var object_field_nodes = [
	oObjIsLightCheckBox,	# [0] IsLight
	null,					# [1] Variation
	oObjSubtileSpinBox,		# [2] Subtile [0-9]
	oObjRelativeXSpinBox,   # [3] RelativeX
	oObjRelativeYSpinBox,	# [4] RelativeY
	oObjRelativeZSpinBox,	# [5] RelativeZ
	oObjThingTypeSpinBox,	# [6] Thing type
	oObjSubtypeSpinBox,		# [7] Thing subtype
	oObjEffectRangeSpinBox,	# [8] Effect range
]

var scnColumnSetter = preload('res://Scenes/ColumnSetter.tscn')

var columnSettersArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	oSlabsetTabs.set_tab_title(0, "Slabset") #slabs.dat
	oSlabsetTabs.set_tab_title(1, "Columnset") #slabs.clm
	
	for number in 9:
		var id = scnColumnSetter.instance()
		var spinbox = id.get_node("CustomSpinBox")
		var shortcut = id.get_node("ButtonShortcut")
		shortcut.connect("pressed",self,"shortcut_pressed",[id])
		spinbox.min_value = 0
		spinbox.max_value = Columnset.column_count-1
		spinbox.connect("value_changed",oDkSlabsetVoxelView,"_on_Slabset3x3ColumnSpinBox_value_changed")
		spinbox.connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		oGridContainerDynamicColumns3x3.add_child(id)
		columnSettersArray.append(id)
	
	oObjRelativeXSpinBox.step = 1.0 / 256.0
	oObjRelativeYSpinBox.step = 1.0 / 256.0
	oObjRelativeZSpinBox.step = 1.0 / 256.0
	
	oDkSlabsetVoxelView.initialize()

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			update_slabset_delete_button_state()
			update_columnset_delete_button_state()

func shortcut_pressed(id):
	var spinbox = id.get_node("CustomSpinBox")
	var clmIndex = spinbox.value
	oSlabsetTabs.set_current_tab(1)
	oColumnsetControls.oColumnIndexSpinBox.value = clmIndex

func _on_SlabsetWindow_visibility_changed():
	if visible == true:
		_on_SlabsetTabs_tab_changed(oSlabsetTabs.current_tab)
		
		oColumnsetControls.just_opened()
		oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		_on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		
		oSlabsetPathsLabel.start()
		oColumnsetPathsLabel.start()
		
		update_slabset_delete_button_state()
		update_columnset_delete_button_state()
		
		yield(get_tree(),'idle_frame')
		oDkSlabsetVoxelView.oAllVoxelObjects.visible = true
	elif visible == false:
		if is_instance_valid(oPickSlabWindow):
			oPickSlabWindow.add_slabs()
			Columnset.update_list_of_columns_that_contain_owned_cubes()
			Columnset.update_list_of_columns_that_contain_rng_cubes()


func _on_SlabsetTabs_tab_changed(tab):
	match tab:
		0: # dat
			oColumnsetVoxelView.visible = false
			oDkSlabsetVoxelView.visible = true
			oDkSlabsetVoxelView.initialize()
		1: # clm
			oColumnsetVoxelView.visible = true
			oDkSlabsetVoxelView.visible = false
			oColumnsetVoxelView.initialize()


func variation_changed(localVariation):
	localVariation = int(localVariation)
	
	#var slabID = oSlabsetIDSpinBox.value
	#variation
	var constructString = ""
	#var byte = (slabID * 28) + localVariation
	#constructString += "Byte " + str(byte) + ' - ' + str(byte)
	#constructString += '\n'
	
	if localVariation != 27:
		match localVariation % 9:
			0: constructString += "South"
			1: constructString += "West"
			2: constructString += "North"
			3: constructString += "East"
			4: constructString += "South West"
			5: constructString += "North West"
			6: constructString += "North East"
			7: constructString += "South East"
			8: constructString += "All direction"
	else:
		constructString += "Center"
	
	constructString += '\n'
	
	if localVariation < 9:
		constructString += ""
	elif localVariation < 18:
		constructString += "Near lava"
	elif localVariation < 27:
		constructString += "Near water"
	
	oVariationInfoLabel.text = constructString
	update_objects_ui()

func _on_SlabsetIDSpinBox_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oSlabsetSlabNameLabel.text = slabName
	update_column_spinboxes()


func update_columnset_delete_button_state():
	var mapName = oCurrentMap.path.get_file().get_basename()
	var columnsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".columnset.toml")

	var dir = Directory.new()
	if dir.file_exists(columnsetFilePath):
		oColumnsetDeleteButton.disabled = false
	else:
		oColumnsetDeleteButton.disabled = true


func update_slabset_delete_button_state():
	var mapName = oCurrentMap.path.get_file().get_basename()
	var slabsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".slabset.toml")

	var dir = Directory.new()
	if dir.file_exists(slabsetFilePath):
		oSlabsetDeleteButton.disabled = false
	else:
		oSlabsetDeleteButton.disabled = true

func update_modified_label_for_slab_id():
	if Slabset.is_slab_edited(int(oSlabsetIDSpinBox.value)):
		oSlabsetIDSpinBox.modulate = Color(1.4,1.4,1.7)
		oSlabRevertButton.disabled = false
	else:
		oSlabsetIDSpinBox.modulate = Color(1,1,1)
		oSlabRevertButton.disabled = true

func update_modified_label_for_variation():
	var variation = get_current_variation()
	if Slabset.is_dat_variation_different(variation) or Slabset.is_tng_variation_different(variation):
		oVariationNumberSpinBox.modulate = Color(1.4, 1.4, 1.7)
		oVarRevertButton.disabled = false
	else:
		oVariationNumberSpinBox.modulate = Color(1, 1, 1)
		oVarRevertButton.disabled = true

func update_save_slabset_button_availability():
	var list_of_modified_slabs = Slabset.get_all_modified_slabs()
	oModifiedListLabel.text = str(list_of_modified_slabs).replace("[","").replace("]","")
	if oModifiedListLabel.text == "":
		oModifiedListPanelContainer.modulate = Color(1, 1, 1, 1)
		oModifiedListLabel.text = "No modified slabs"
	else:
		oModifiedListPanelContainer.modulate = Color(1.4, 1.4, 1.7, 1.0)
	if list_of_modified_slabs.empty():
		oExportSlabsToml.disabled = true
	else:
		oExportSlabsToml.disabled = false

func update_save_columnset_button_availability():
	var list_of_modified_columns = Columnset.find_all_different_columns()
	if list_of_modified_columns.empty():
		oExportColumnsToml.disabled = true
	else:
		oExportColumnsToml.disabled = false

func _on_VariationNumberSpinBox_value_changed(value):
	
	update_column_spinboxes()

func update_column_spinboxes():
	var variation = get_current_variation()
	
	for subtile in columnSettersArray.size():
		var spinbox = columnSettersArray[subtile].get_node("CustomSpinBox")
		spinbox.disconnect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		var clmIndex = Slabset.fetch_columnset_index(variation, subtile)
		spinbox.value = clmIndex
		spinbox.connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")


func _on_Slabset3x3ColumnSpinBox_value_changed(value):
	var variation = get_current_variation()
	for y in 3:
		for x in 3:
			var i = (y*3) + x
			var id = oGridContainerDynamicColumns3x3.get_child(i)
			var spinbox = id.get_node("CustomSpinBox")
			var clmIndex = spinbox.value
			
			ensure_dat_array_has_space(variation)
			Slabset.dat[variation][i] = int(clmIndex)
			#oSlabPalette.slabPal[variation][i] = clmIndex # This may not be working
	adjust_column_color_if_different(variation)

func ensure_dat_array_has_space(variation):
	while variation >= Slabset.dat.size():
		Slabset.dat.append([0,0,0, 0,0,0, 0,0,0])

func ensure_tng_array_has_space(variation):
	while variation >= Slabset.tng.size():
		Slabset.tng.append([])


func _on_SlabsetCopyValues_pressed():
	oAddCustomSlabWindow.copy_values_from_slabset_and_index_them()
	
	visible = false
	oPickSlabWindow._on_pressed_add_new_custom_slab()


func _on_ExportSlabsToml_pressed():
	Utils.popup_centered(oExportSlabsetTomlDialog)
	oExportSlabsetTomlDialog.current_dir = oCurrentMap.path.get_base_dir().plus_file("")
	oExportSlabsetTomlDialog.current_path = oCurrentMap.path.get_base_dir().plus_file("")
	
	yield(get_tree(),'idle_frame') # Important if there's another toml file there
	oExportSlabsetTomlDialog.get_line_edit().text = oCurrentMap.path.get_file().get_basename()+".slabset.toml"


func _on_ExportColumnsToml_pressed():
	Utils.popup_centered(oExportColumnsetTomlDialog)
	oExportColumnsetTomlDialog.current_dir = oCurrentMap.path.get_base_dir().plus_file("")
	oExportColumnsetTomlDialog.current_path = oCurrentMap.path.get_base_dir().plus_file("")
	
	yield(get_tree(),'idle_frame') # Important if there's another toml file there
	oExportColumnsetTomlDialog.get_line_edit().text = oCurrentMap.path.get_file().get_basename()+".columnset.toml"


func _on_ExportSlabsetTomlDialog_file_selected(filePath):
	Slabset.export_toml_slabset(filePath)
	
	for i in 50:
		yield(get_tree(),'idle_frame')
	
	var dir = Directory.new()
	if dir.file_exists(filePath):
		update_slabset_delete_button_state()
		
		if oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP].has(filePath) == false:
			oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP].append(filePath)
			oSlabsetPathsLabel.start()

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


func get_current_variation():
	return (int(oSlabsetIDSpinBox.value) * 28) + int(oVariationNumberSpinBox.value)

func get_list_of_objects(variation):
	if variation < Slabset.tng.size():
		return Slabset.tng[variation]
	else:
		return []

func adjust_object_color_if_different(variation):
	var objectIndex = oObjObjectIndexSpinBox.value
	for property in 9:
		var id = object_field_nodes[property]
		if id == null: continue
		if id.modulate.a != 0: # ThingType can be zero alpha if Light is checked
			if Slabset.is_tng_object_different(variation, objectIndex, property):
				id.modulate = Color(1.4,1.4,1.7)
			else:
				id.modulate = Color(1, 1, 1) # White color for unedited fields

func adjust_column_color_if_different(variation):
	for subtile in 9:
		var id = columnSettersArray[subtile]
		var spinbox = id.get_node("CustomSpinBox")
		var shortcut = id.get_node("ButtonShortcut")
		if Slabset.is_dat_column_different(variation, subtile) == true:
			spinbox.modulate = Color(1.4,1.4,1.7)
			shortcut.modulate = Color(1.4,1.4,1.5)
		else:
			spinbox.modulate = Color(1,1,1)
			shortcut.modulate = Color(1,1,1)
	
	update_modified_label_for_slab_id()
	update_modified_label_for_variation()
	update_save_slabset_button_availability()



func update_objects_ui():
	var variation = get_current_variation()
	
	adjust_column_color_if_different(variation)
	adjust_object_color_if_different(variation)
	
	var listOfObjects = get_list_of_objects(variation)
	oSlabsetObjectSection.visible = !listOfObjects.empty()
	
	if listOfObjects.empty() == false:
		oObjObjectIndexSpinBox.visible = listOfObjects.size() > 1 # Hide ability to switch object index if there's only one object on this variation
		oObjObjectIndexSpinBox.value = clamp(oObjObjectIndexSpinBox.value, 0, listOfObjects.size() - 1)
		update_object_fields(oObjObjectIndexSpinBox.value)
		update_3D_sprite_visuals()
	else:
		oDkSlabsetVoxelView.clear_attached_3d_objects()

var currently_updating_sprite_visuals = false # this var is for the purpose of only updating once, when called multiple times.
func update_3D_sprite_visuals():
	if currently_updating_sprite_visuals == true: return
	currently_updating_sprite_visuals = true
	
	yield(get_tree(),'idle_frame')
	
	var variation = get_current_variation()
	oDkSlabsetVoxelView.clear_attached_3d_objects()
	
	var listOfObjects = get_list_of_objects(variation)
	for i in listOfObjects:
		var tex = Things.fetch_sprite(int(oObjThingTypeSpinBox.value), int(oObjSubtypeSpinBox.value))
		if oObjIsLightCheckBox.pressed == true:
			tex = null
		var pos = Vector3(0,0,0)
		match int(oObjSubtileSpinBox.value):
			0:
				pos.x = -1.5
				pos.z = -1.5
			1:
				pos.x = -0.5
				pos.z = -1.5
			2:
				pos.x = 0.5
				pos.z = -1.5
			3:
				pos.x = -1.5
				pos.z = -0.5
			4:
				pos.x = -0.5
				pos.z = -0.5
			5:
				pos.x = 0.5
				pos.z = -0.5
			6:
				pos.x = -1.5
				pos.z = 0.5
			7:
				pos.x = -0.5
				pos.z = 0.5
			8:
				pos.x = 0.5
				pos.z = 0.5
		pos.x += oObjRelativeXSpinBox.value
		pos.z += oObjRelativeYSpinBox.value
		pos.y += oObjRelativeZSpinBox.value
		
		oDkSlabsetVoxelView.add_billboard_obj(tex, pos)
	
	yield(get_tree(),'idle_frame')
	currently_updating_sprite_visuals = false


func update_object_fields(index):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	if index >= listOfObjects.size(): return
	
	var obj = listOfObjects[index] # Get first object on variation
	oObjThingTypeSpinBox.value = obj[6]
	oObjSubtypeSpinBox.value = obj[7]
	oObjIsLightCheckBox.pressed = bool(obj[0])
	oObjEffectRangeSpinBox.value = obj[8]
	oObjSubtileSpinBox.value = obj[2]
	oObjRelativeXSpinBox.value = obj[3] / 256.0
	oObjRelativeYSpinBox.value = obj[4] / 256.0
	oObjRelativeZSpinBox.value = obj[5] / 256.0

func _on_ObjObjectIndexSpinBox_value_changed(value):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	var maxIndex = listOfObjects.size() - 1

	if value < 0 and listOfObjects.size() > 0:
		oObjObjectIndexSpinBox.value = maxIndex
		update_object_fields(maxIndex)
	elif value > maxIndex:
		oObjObjectIndexSpinBox.value = 0
		update_object_fields(0)
	else:
		update_object_fields(value)


func update_obj_name():
	if oObjIsLightCheckBox.pressed == true:
		oObjNameLabel.text = "Light"
	else:
		var thingType = int(oObjThingTypeSpinBox.value)
		var subtype = int(oObjSubtypeSpinBox.value)
		oObjNameLabel.text = Things.fetch_id_string(thingType, subtype)

func _on_ObjAddButton_pressed():
	var variation = get_current_variation()
	add_new_object_to_variation(variation)
	update_objects_ui()
	oDkSlabsetVoxelView.update_column_view()

func add_new_object_to_variation(variation):
	#update_object_property(Slabset.obj.VARIATION, variation)
	var randomSubtype = 1 # Barrel #Random.randi_range(1,135)
	var new_object_defaults = [
		0,             # [0] IsLight
		variation,     # [1] Variation
		4,             # [2] Subtile [0-9]
		128,           # [3] RelativeX
		128,           # [4] RelativeY
		256,           # [5] RelativeZ
		1,             # [6] Thing type
		randomSubtype, # [7] Thing subtype
		0,             # [8] Effect range
	]
	
	ensure_tng_array_has_space(variation)
	Slabset.tng[variation].append(new_object_defaults)
	var lastEntryIndex = Slabset.tng[variation].size()-1
	oObjObjectIndexSpinBox.value = lastEntryIndex
	update_object_fields(lastEntryIndex)
	update_obj_name()
	oMessage.quick("Added new object")

func _on_ObjDeleteButton_pressed():
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	var objectIndex = oObjObjectIndexSpinBox.value
	
	if objectIndex < 0 or objectIndex >= listOfObjects.size():
		oMessage.quick("No object to remove")
		return
	
	listOfObjects.remove(objectIndex)
	
	update_objects_ui()
	oDkSlabsetVoxelView.update_column_view()
	oMessage.quick("Deleted object")

func _on_ObjThingTypeSpinBox_value_changed(value:int):
	#oObjThingTypeSpinBox.hint_tooltip = Things.data_structure_name.get(value, "?")
	#yield(get_tree(),'idle_frame')
	
	# Lock value to 1 or 7
	if value in [0, 2, 7]:
		value = 7
	else:
		value = 1
	
	oObjThingTypeSpinBox.disconnect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	oObjThingTypeSpinBox.value = value
	oObjThingTypeSpinBox.connect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	
	update_obj_name()
	update_object_property(Slabset.obj.THING_TYPE, value)
	update_3D_sprite_visuals()

func _on_ObjSubtypeSpinBox_value_changed(value:int):
	value = int(value)
	#yield(get_tree(),'idle_frame')
	update_obj_name()
	update_object_property(Slabset.obj.THING_SUBTYPE, value)
	update_3D_sprite_visuals()

func _on_ObjIsLightCheckBox_toggled(button_pressed:int):
	if button_pressed == 1:
		oObjSubtypeLabel.text = "Intensity"
		oObjThingTypeLabel.modulate.a = 0
		oObjThingTypeSpinBox.modulate.a = 0
	else:
		oObjSubtypeLabel.text = "Subtype"
		oObjThingTypeLabel.modulate.a = 1
		oObjThingTypeSpinBox.modulate.a = 1
	update_obj_name()
	update_object_property(Slabset.obj.IS_LIGHT, button_pressed)
	update_3D_sprite_visuals()

func _on_ObjEffectRangeSpinBox_value_changed(value:int):
	update_object_property(Slabset.obj.EFFECT_RANGE, value)


func _on_ObjSubtileSpinBox_value_changed(value:int):
	update_object_property(Slabset.obj.SUBTILE, value)
	update_3D_sprite_visuals()

func round_float_to_256(f): # Calculate the nearest multiple of 1.0/256.0
	return round(f * 256.0) / 256.0
func ceil_float_to_256(f): # Calculate the nearest multiple of 1.0/256.0
	return ceil(f * 256.0) / 256.0
func floor_float_to_256(f): # Calculate the nearest multiple of 1.0/256.0
	return floor(f * 256.0) / 256.0

# Generic function to snap and update the SpinBox value
func snap_and_update_spinbox_value(spinbox: SpinBox, property: int, float_value: float, method_name: String):
	var nearest_value = round_float_to_256(float_value)
	var new_value = nearest_value
	if float_value > nearest_value:
		new_value = ceil_float_to_256(float_value)
	elif float_value < nearest_value:
		new_value = floor_float_to_256(float_value)

	spinbox.disconnect("value_changed", self, method_name)
	spinbox.value = new_value
	spinbox.connect("value_changed", self, method_name)

	var int_value = round(new_value * 256)
	#spinbox.hint_tooltip = str("Real: " + str(int_value))
	update_object_property(property, int(int_value))

# SpinBox value changed handlers
func _on_ObjRelativeXSpinBox_value_changed(float_value: float): # Spinbox uses floats, it's converted to int later, inside snap_and_update_spinbox_value
	snap_and_update_spinbox_value(oObjRelativeXSpinBox, Slabset.obj.RELATIVE_X, float_value, "_on_ObjRelativeXSpinBox_value_changed")
	update_3D_sprite_visuals()

func _on_ObjRelativeYSpinBox_value_changed(float_value: float):
	snap_and_update_spinbox_value(oObjRelativeYSpinBox, Slabset.obj.RELATIVE_Y, float_value, "_on_ObjRelativeYSpinBox_value_changed")
	update_3D_sprite_visuals()

func _on_ObjRelativeZSpinBox_value_changed(float_value: float):
	snap_and_update_spinbox_value(oObjRelativeZSpinBox, Slabset.obj.RELATIVE_Z, float_value, "_on_ObjRelativeZSpinBox_value_changed")
	update_3D_sprite_visuals()

# Helper method to update the object in Slabset.tng
func update_object_property(the_property, new_value):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	var object_index = oObjObjectIndexSpinBox.value
	if object_index < 0 or object_index >= listOfObjects.size():
		return # Invalid index, nothing to update
	listOfObjects[object_index][the_property] = new_value
	adjust_object_color_if_different(variation)
	update_modified_label_for_slab_id()
	update_modified_label_for_variation()
	update_save_slabset_button_availability()


func _on_SlabCopyButton_pressed():
	copy(ALL_VARIATION)

func _on_VarCopyButton_pressed():
	copy(ONE_VARIATION)

func copy(howMany):
	# Clear previous clipboard data
	clipboard["dat"].clear()
	clipboard["tng"].clear()
	
	var variationsToCopy = []
	if howMany == ALL_VARIATION:
		oMessage.quick("Copied all 28 variations of current slab ID to clipboard")
		var slabBaseId = int(oSlabsetIDSpinBox.value) * 28
		variationsToCopy.resize(28)
		for i in 28:
			variationsToCopy[i] = slabBaseId + i
	else:
		oMessage.quick("Copied current variation to clipboard")
		var current_variation = get_current_variation()
		variationsToCopy = [current_variation]
	
	for variation in variationsToCopy:
		if variation < Slabset.dat.size():
			clipboard["dat"].append(Slabset.dat[variation].duplicate(true))
		if variation < Slabset.tng.size():
			clipboard["tng"].append(Slabset.tng[variation].duplicate(true))


func _on_SlabPasteButton_pressed():
	paste(ALL_VARIATION)
func _on_VarPasteButton_pressed():
	paste(ONE_VARIATION)

func paste(howMany):
	if clipboard["dat"].empty() and clipboard["tng"].empty():
		oMessage.quick("Clipboard is empty.")
		return
	
	var locationsToPasteTo = []
	if howMany == ALL_VARIATION:
		oMessage.quick("Pasted all 28 variations to current slab ID")
		var slab_base_id = int(oSlabsetIDSpinBox.value) * 28
		for i in 28:
			locationsToPasteTo.append(slab_base_id + i)
	else:
		oMessage.quick("Pasted one variation")
		var currentVariation = get_current_variation()
		locationsToPasteTo.append(currentVariation)

	# Assume clipboard["dat"] and clipboard["tng"] have the same size or clipboard["tng"] can be empty.
	var data_size = clipboard["dat"].size()
	var tng_size = clipboard["tng"].size()
	
	for i in locationsToPasteTo:
		var clipboard_index = i % data_size  # Wrap around if there are fewer items in clipboard than locations
		ensure_dat_array_has_space(i)
		Slabset.dat[i] = clipboard["dat"][clipboard_index].duplicate(true)
		
		if clipboard_index < tng_size:  # Ensure we don't go out of bounds for 'tng'
			ensure_tng_array_has_space(i)
			Slabset.tng[i] = clipboard["tng"][clipboard_index].duplicate(true)
	
	# Update the UI after pasting
	update_column_spinboxes()
	update_objects_ui()
	oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)

const ROTATION_MAP = {
	0: 6, 1: 3, 2: 0,
	3: 7, 4: 4, 5: 1,
	6: 8, 7: 5, 8: 2
}

const OBJECT_ROTATION_MAP = {
	0: 2, 1: 5, 2: 8,
	3: 1, 4: 4, 5: 7,
	6: 0, 7: 3, 8: 6
}

func _on_VarRotateButton_pressed():
	var variation = get_current_variation()
	ensure_dat_array_has_space(variation)
	
	# Rotate the 'dat' array by reassigning using the ROTATION_MAP
	var new_dat = []
	for i in 9:
		new_dat.append(Slabset.dat[variation][ROTATION_MAP[i]])
	Slabset.dat[variation] = new_dat
	
	# Rotate the object subtiles and relative positions within the slab
	for obj in Slabset.tng[variation]:
		var old_subtile = obj[Slabset.obj.SUBTILE]
		var new_subtile = OBJECT_ROTATION_MAP[old_subtile]
		obj[Slabset.obj.SUBTILE] = new_subtile
		
		var old_relative_x = obj[Slabset.obj.RELATIVE_X]
		var old_relative_y = obj[Slabset.obj.RELATIVE_Y]
		var new_relative_x = 0
		var new_relative_y = 0
		
		new_relative_x = 256 - old_relative_y
		new_relative_y = old_relative_x
		
		obj[Slabset.obj.RELATIVE_X] = new_relative_x
		obj[Slabset.obj.RELATIVE_Y] = new_relative_y
	
	# Update the UI
	update_column_spinboxes()
	update_objects_ui()
	oMessage.quick("Rotated variation")


func _on_SlabRevertButton_pressed():
	var slabID = int(oSlabsetIDSpinBox.value)
	var variations_to_revert = []
	for i in 28:
		variations_to_revert.append((slabID * 28) + i)
	revert(variations_to_revert)
	oMessage.quick("Reverted all 28 variations of current slab ID")


func _on_VarRevertButton_pressed():
	var variations_to_revert = []
	variations_to_revert.append((int(oSlabsetIDSpinBox.value) * 28) + int(oVariationNumberSpinBox.value))
	revert(variations_to_revert)
	oMessage.quick("Reverted current variation")

func revert(variations_to_revert):
	for variation in variations_to_revert:
		# Revert the 'dat' array for the variation if default data is available
		if variation < Slabset.default_data["dat"].size():
			Slabset.dat[variation] = Slabset.default_data["dat"][variation].duplicate()
		else:
			if variation < Slabset.dat.size():
				Slabset.dat.remove(variation)
		
		# Revert the 'tng' array for the variation if default data is available
		if variation < Slabset.default_data["tng"].size():
			Slabset.tng[variation] = Slabset.default_data["tng"][variation].duplicate(true)  # deep copy if it contains objects
		else:
			if variation < Slabset.tng.size():
				Slabset.tng.remove(variation)
	
	# Update UI for columns and objects
	update_column_spinboxes()
	
	update_objects_ui()
	
	yield(get_tree(),'idle_frame')
	oDkSlabsetVoxelView.refresh_entire_view()



func _on_SlabsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "slabset.toml and columnset.toml affect the appearance of slabs when they're placed. When placing in Unearth AND when placing in-game. \n"
	helptxt += "However keep in mind these files are not automatically saved by Unearth, so you will need to press this 'Save slabset' button whenever you make any changes.\n"
	helptxt += "New entries in terrain.cfg are also required in order to add new Slab IDs to the Slabset.\n"
	helptxt += "\n"
	helptxt += "If you set an object's RelativeX and RelativeY to be inside of a column/cube then it may not appear in-game."
	oMessage.big("Help",helptxt)

func _on_ColumnsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "Be wary not to confuse the Columnset with the Map Columns. Map Columns (.clm) are the appearance of any columns that have already been placed on the map, while the Columnset (.toml) is the appearance of any new columns that are placed in the future. \n"
	helptxt += "\n"
	helptxt += "columnset.toml is a global file in /fxdata/ that is used by all maps in the game, but it can also be saved as a local file to a map or campaign. When you run the game both columnset.toml files will be loaded, but with the local file overwriting any same fields of the file in /fxdata/."
	oMessage.big("Help",helptxt)


func _on_VarButtonsApplyToAllCheckBox_toggled(button_pressed):
	if button_pressed == true:
		oMessage.quick("Copy and paste buttons will affect all variations of current slab ID")
	else:
		oMessage.quick("Copy and paste buttons will affect 1 variation")



func _on_SlabsetDeleteButton_pressed():
	oConfirmDeleteSlabsetFile.dialog_text = "Revert all slabs to default and delete this file?\n"
	
	var mapName = oCurrentMap.path.get_file().get_basename()
	var slabsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".slabset.toml")
	oConfirmDeleteSlabsetFile.dialog_text += slabsetFilePath
	oConfirmDeleteSlabsetFile.rect_min_size.x = 800
	Utils.popup_centered(oConfirmDeleteSlabsetFile)


func _on_ColumnsetDeleteButton_pressed():
	oConfirmDeleteColumnsetFile.dialog_text = "Revert all columns to default and delete this file?\n"
	var mapName = oCurrentMap.path.get_file().get_basename()
	var columnsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".columnset.toml")
	oConfirmDeleteColumnsetFile.dialog_text += columnsetFilePath
	oConfirmDeleteColumnsetFile.rect_min_size.x = 800
	Utils.popup_centered(oConfirmDeleteColumnsetFile)


func _on_ConfirmDeleteSlabsetFile_confirmed():
	var mapName = oCurrentMap.path.get_file().get_basename()
	var slabsetFilePath = oCurrentMap.path.get_base_dir().plus_file(mapName + ".slabset.toml")

	var dir = Directory.new()
	if dir.file_exists(slabsetFilePath):
		var err = dir.remove(slabsetFilePath)
		if err == OK:
			oMessage.quick("Deleted: " + slabsetFilePath)
			oMessage.quick("Reverted all slabs")
			# Revert every slab ID to its default state
			var totalSlabs = max(Slabset.dat.size(), Slabset.tng.size()) / 28
			var variations_to_revert = []
			for slabID in totalSlabs:
				for i in 28:
					variations_to_revert.append((slabID * 28) + i)
			revert(variations_to_revert)
			
			# Remove from the little box thing of currently loaded files
			oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP].erase(slabsetFilePath)
			oSlabsetPathsLabel.start()
			
			# Update the UI
			update_column_spinboxes()
			update_objects_ui()
			oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
			update_slabset_delete_button_state()
		else:
			oMessage.big("Error", "Failed to delete the file.")
	else:
		oMessage.big("Error", "The slabset file doesn't exist.")


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
			update_column_spinboxes()
			oColumnsetControls._on_ColumnIndexSpinBox_value_changed(oColumnsetControls.oColumnIndexSpinBox.value)
			oColumnsetControls.adjust_ui_color_if_different()
			oColumnsetVoxelView.refresh_entire_view()
			
			update_columnset_delete_button_state()
		else:
			oMessage.big("Error", "Failed to delete the file.")
	else:
		oMessage.big("Error", "The columnset file doesn't exist.")
