extends VBoxContainer

onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oSlabsetSlabNameLabel = Nodelist.list["oSlabsetSlabNameLabel"]
onready var oGridContainerDynamicColumns3x3 = Nodelist.list["oGridContainerDynamicColumns3x3"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
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
onready var oAddCustomSlabWindow = Nodelist.list["oAddCustomSlabWindow"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oSlabRevertButton = Nodelist.list["oSlabRevertButton"]
onready var oVarRevertButton = Nodelist.list["oVarRevertButton"]
onready var oSlabsetRevertButton = Nodelist.list["oSlabsetRevertButton"]
onready var oConfirmRevertSlabset = Nodelist.list["oConfirmRevertSlabset"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oModifiedSlabsetLabel = Nodelist.list["oModifiedSlabsetLabel"]
onready var oModifiedSlabsetPanelContainer = Nodelist.list["oModifiedSlabsetPanelContainer"]
onready var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]
onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentlyOpenSlabset = Nodelist.list["oCurrentlyOpenSlabset"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

signal column_shortcut_pressed(clmIndex)

enum {
	ONE_VARIATION,
	ALL_VARIATION,
}

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

var clipboard = {"dat": [], "tng": []}
var scnColumnSetter = preload('res://Scenes/ColumnSetter.tscn')
var regeneration_timer = Timer.new()
var flash_update_timer = Timer.new()
var is_initializing = false
var columnSettersArray = []
var _previous_slab_id = 0
var _previous_thing_type = 1
var pending_regeneration_slab_ids = []

onready var object_field_nodes = [
	oObjIsLightCheckBox, null, oObjSubtileSpinBox,
	oObjRelativeXSpinBox, oObjRelativeYSpinBox, oObjRelativeZSpinBox,
	oObjThingTypeSpinBox, oObjSubtypeSpinBox, oObjEffectRangeSpinBox,
]

func _ready():
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
	
	for spinbox in [oObjRelativeXSpinBox, oObjRelativeYSpinBox, oObjRelativeZSpinBox]:
		spinbox.step = 1.0 / 256.0
	
	add_child(regeneration_timer)
	regeneration_timer.one_shot = true
	regeneration_timer.wait_time = 0.25
	regeneration_timer.connect("timeout", self, "_on_regeneration_timer_timeout")
	add_child(flash_update_timer)
	flash_update_timer.one_shot = true
	flash_update_timer.wait_time = 0.5
	flash_update_timer.connect("timeout", self, "_on_flash_update_timer_timeout")
	
	oSlabsetIDSpinBox.connect("value_changed", self, "_on_SlabsetIDSpinBox_value_changed")
	oSlabsetIDSpinBox.connect("value_changed", oDkSlabsetVoxelView, "_on_SlabsetIDSpinBox_value_changed")
	
	var slabCopyButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer2/VBoxContainer/GridContainer2/SlabCopyButton")
	var slabPasteButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer2/VBoxContainer/GridContainer2/SlabPasteButton")
	var slabRevertButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer2/VBoxContainer/GridContainer2/SlabRevertButton")
	slabCopyButton.connect("pressed", self, "_on_SlabCopyButton_pressed")
	slabPasteButton.connect("pressed", self, "_on_SlabPasteButton_pressed")
	slabRevertButton.connect("pressed", self, "_on_SlabRevertButton_pressed")
	
	oVariationNumberSpinBox.connect("value_changed", self, "_on_VariationNumberSpinBox_value_changed")
	oVariationNumberSpinBox.connect("value_changed", oDkSlabsetVoxelView, "_on_VariationNumberSpinBox_value_changed")
	
	var varCopyButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer5/VBoxContainer/GridContainer2/VarCopyButton")
	var varPasteButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer5/VBoxContainer/GridContainer2/VarPasteButton")
	var varRevertButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer5/VBoxContainer/GridContainer2/VarRevertButton")
	var varRotateButton = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/PanelContainer5/VBoxContainer/GridContainer2/VarRotateButton")
	varCopyButton.connect("pressed", self, "_on_VarCopyButton_pressed")
	varPasteButton.connect("pressed", self, "_on_VarPasteButton_pressed")
	varRevertButton.connect("pressed", self, "_on_VarRevertButton_pressed")
	varRotateButton.connect("pressed", self, "_on_VarRotateButton_pressed")
	
	oObjAddButton.connect("pressed", self, "_on_ObjAddButton_pressed")
	oObjDeleteButton.connect("pressed", self, "_on_ObjDeleteButton_pressed")
	oObjObjectIndexSpinBox.connect("value_changed", self, "_on_ObjObjectIndexSpinBox_value_changed")
	oObjThingTypeSpinBox.connect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	oObjSubtypeSpinBox.connect("value_changed", self, "_on_ObjSubtypeSpinBox_value_changed")
	oObjSubtileSpinBox.connect("value_changed", self, "_on_ObjSubtileSpinBox_value_changed")
	oObjRelativeXSpinBox.connect("value_changed", self, "_on_ObjRelativeXSpinBox_value_changed")
	oObjRelativeYSpinBox.connect("value_changed", self, "_on_ObjRelativeYSpinBox_value_changed")
	oObjRelativeZSpinBox.connect("value_changed", self, "_on_ObjRelativeZSpinBox_value_changed")
	oObjEffectRangeSpinBox.connect("value_changed", self, "_on_ObjEffectRangeSpinBox_value_changed")
	oObjIsLightCheckBox.connect("toggled", self, "_on_ObjIsLightCheckBox_toggled")
	
	var slabsetCopyValues = get_node("HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/SlabsetCopyValues")
	slabsetCopyValues.connect("pressed", self, "_on_SlabsetCopyValues_pressed")
	
	var slabsetHelpButton = get_node("HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/SlabsetHelpButton")
	var SlabsetRevertButton = get_node("HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/SlabsetRevertButton")
	slabsetHelpButton.connect("pressed", self, "_on_SlabsetHelpButton_pressed")
	SlabsetRevertButton.connect("pressed", self, "_on_SlabsetRevertButton_pressed")
	
	oConfirmRevertSlabset.connect("confirmed", self, "_on_ConfirmRevertSlabset_confirmed")
	connect("visibility_changed", self, "_on_TabSlabset_visibility_changed")
	
	# Connect to ConfigFileManager signals
	oConfigFileManager.connect("config_file_status_changed", self, "_on_config_status_changed")

func _on_TabSlabset_visibility_changed():
	if visible:
		oDkSlabsetVoxelView.initialize()
		is_initializing = true
		_previous_slab_id = int(oSlabsetIDSpinBox.value)
		update_slabset_revert_button_state()
		oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		_on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		yield(get_tree(),'idle_frame')
		oDkSlabsetVoxelView.oAllVoxelObjects.visible = true
		is_initializing = false
		oSlabsetWindow.update_flash_state()
	else:
		oPickSlabWindow.add_slabs()
		Columnset.update_list_of_columns_that_contain_owned_cubes()
		Columnset.update_list_of_columns_that_contain_rng_cubes()

func shortcut_pressed(id):
	var spinbox = id.get_node("CustomSpinBox")
	var clmIndex = spinbox.value
	emit_signal("column_shortcut_pressed", clmIndex)

func variation_changed(localVariation):
	localVariation = int(localVariation)
	var slabID = int(oSlabsetIDSpinBox.value)
	var constructString = ""
	
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
	
	var isRoomWall = Slabs.rooms_that_have_walls.has(slabID - 1)
	
	if localVariation < 9:
		constructString += ""
	elif localVariation < 18:
		constructString += "Room face" if isRoomWall else "Near lava"
	elif localVariation < 27:
		constructString += "Room face" if isRoomWall else "Near water"
	
	oVariationInfoLabel.text = constructString
	update_objects_ui()
	if is_initializing == false:
		flash_update_timer.stop()
		flash_update_timer.start()

func _on_SlabsetIDSpinBox_value_changed(value):
	value = int(value)
	var direction = value - _previous_slab_id

	# Handle jumps for single-step changes (keyboard or spinbox buttons)
	if not Settings.get_setting("allow_reserved_id_editing"):
		if abs(direction) == 1 and Slabset.highest_slabset_id_from_fxdata > 0:
			if direction == 1 and _previous_slab_id == Slabset.highest_slabset_id_from_fxdata:
				oSlabsetIDSpinBox.value = Slabset.reserved_slabset
				return
			elif direction == -1 and _previous_slab_id == Slabset.reserved_slabset:
				oSlabsetIDSpinBox.value = Slabset.highest_slabset_id_from_fxdata
				return

		# Handle direct text input into invalid range
		if not Slabset.is_valid_slab_id_for_navigation(value):
			var mid_point = (Slabset.highest_slabset_id_from_fxdata + Slabset.reserved_slabset) / 2.0
			if value < mid_point:
				oSlabsetIDSpinBox.value = Slabset.highest_slabset_id_from_fxdata
			else:
				oSlabsetIDSpinBox.value = Slabset.reserved_slabset
			return

	_previous_slab_id = value
	var slabName = Slabs.data[value][Slabs.NAME] if Slabs.data.has(value) else "Unknown"
	oSlabsetSlabNameLabel.text = slabName
	update_column_spinboxes()
	if is_initializing == false:
		flash_update_timer.stop()
		flash_update_timer.start()

func update_slabset_revert_button_state():
	update_slabset_paths_label()

func update_slabset_paths_label():
	var list_of_modified_slabs = Slabset.get_all_modified_slabs()
	var file_path = oCurrentMap.existing_slabset_file
	var final_text = ""
	var tooltip_text = ""
	
	if file_path != "":
		var filename = file_path.get_file()
		if filename == "slabset.toml":
			# Campaign file - show parent folder + filename
			final_text = "/" + file_path.get_base_dir().get_file() + "/" + filename
		else:
			# Local file (map00001.slabset.toml) - show just filename
			final_text = filename
		tooltip_text = file_path
	else:
		final_text = "No saved file"
		tooltip_text = "No saved file"
	
	oCurrentlyOpenSlabset.text = final_text
	oCurrentlyOpenSlabset.hint_tooltip = tooltip_text
	
	# Handle modified slabs label
	oModifiedSlabsetLabel.text = str(list_of_modified_slabs).replace("[","").replace("]","")
	if oModifiedSlabsetLabel.text == "":
		oModifiedSlabsetPanelContainer.modulate = Color(1, 1, 1, 1)
		oModifiedSlabsetLabel.text = "No modified slabs"
	else:
		oModifiedSlabsetPanelContainer.modulate = Color(1.4, 1.4, 1.7, 1.0)
	
	oSlabsetRevertButton.disabled = list_of_modified_slabs.empty()

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

func _on_VariationNumberSpinBox_value_changed(value):
	update_column_spinboxes()
	if is_initializing == false:
		flash_update_timer.stop()
		flash_update_timer.start()
	update_modified_label_for_slab_id()
	update_modified_label_for_variation()
	update_slabset_revert_button_state()

func update_column_spinboxes():
	var variation = get_current_variation()
	for subtile in columnSettersArray.size():
		var spinbox = columnSettersArray[subtile].get_node("CustomSpinBox")
		spinbox.disconnect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		spinbox.disconnect("value_changed",oDkSlabsetVoxelView,"_on_Slabset3x3ColumnSpinBox_value_changed")
		var clmIndex = Slabset.fetch_columnset_index(variation, subtile)
		spinbox.value = clmIndex
		spinbox.connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		spinbox.connect("value_changed",oDkSlabsetVoxelView,"_on_Slabset3x3ColumnSpinBox_value_changed")

func _on_Slabset3x3ColumnSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	var variation = get_current_variation()
	for y in 3:
		for x in 3:
			var i = (y*3) + x
			var id = oGridContainerDynamicColumns3x3.get_child(i)
			var spinbox = id.get_node("CustomSpinBox")
			var clmIndex = spinbox.value
			ensure_dat_array_has_space(variation)
			Slabset.dat[variation][i] = int(clmIndex)
	adjust_column_color_if_different(variation)
	restart_regeneration_timer()
	oFlashingColumns.invalidate_columnset_texture()
	oFlashingColumns.invalidate_variation_texture()
	oSlabsetWindow.update_flash_state()

func _on_regeneration_timer_timeout():
	var all_slab_ids_to_process = []
	for slabId in pending_regeneration_slab_ids:
		all_slab_ids_to_process.append(slabId)
		if Slabs.rooms_that_have_walls.has(slabId+1):
			for aw_id in Slabs.auto_wall_updates_these.keys():
				if all_slab_ids_to_process.find(aw_id) == -1:
					all_slab_ids_to_process.append(aw_id)
	for id in all_slab_ids_to_process:
		oSlabsetMapRegenerator.regenerate_slabs_using_slab_id(id)
	pending_regeneration_slab_ids.clear()

func queue_slab_for_regeneration(slabId):
	if pending_regeneration_slab_ids.find(slabId) == -1:
		pending_regeneration_slab_ids.append(slabId)
	regeneration_timer.stop()
	regeneration_timer.start()

func restart_regeneration_timer():
	var currentSlabId = int(oSlabsetIDSpinBox.value)
	queue_slab_for_regeneration(currentSlabId)

func ensure_dat_array_has_space(variation):
	while variation >= Slabset.dat.size():
		Slabset.dat.append([0,0,0, 0,0,0, 0,0,0])

func ensure_tng_array_has_space(variation):
	while variation >= Slabset.tng.size():
		Slabset.tng.append([])

func _on_SlabsetCopyValues_pressed():
	oAddCustomSlabWindow.copy_values_from_slabset_and_index_them()
	oSlabsetWindow.visible = false
	oPickSlabWindow._on_pressed_add_new_custom_slab()

func get_current_variation():
	return (int(oSlabsetIDSpinBox.value) * 28) + int(oVariationNumberSpinBox.value)

func get_list_of_objects(variation):
	return Slabset.tng[variation] if variation < Slabset.tng.size() else []

func adjust_object_color_if_different(variation):
	var objectIndex = oObjObjectIndexSpinBox.value
	for property in 9:
		var id = object_field_nodes[property]
		if id == null: continue
		if id.modulate.a != 0:
			if Slabset.is_tng_object_different(variation, objectIndex, property):
				id.modulate = Color(1.4,1.4,1.7)
			else:
				id.modulate = Color(1, 1, 1)

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
	update_slabset_revert_button_state()

func update_objects_ui():
	var variation = get_current_variation()
	adjust_column_color_if_different(variation)
	adjust_object_color_if_different(variation)
	var listOfObjects = get_list_of_objects(variation)
	oSlabsetObjectSection.visible = !listOfObjects.empty()
	if listOfObjects.empty() == false:
		oObjObjectIndexSpinBox.visible = listOfObjects.size() > 1
		oObjObjectIndexSpinBox.value = clamp(oObjObjectIndexSpinBox.value, 0, listOfObjects.size() - 1)
		update_object_fields(oObjObjectIndexSpinBox.value)
		update_3D_sprite_visuals()
	else:
		oDkSlabsetVoxelView.clear_attached_3d_objects()
	update_modified_label_for_slab_id()
	update_modified_label_for_variation()
	update_slabset_revert_button_state()

func update_3D_sprite_visuals():
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
			0: pos = Vector3(-1.5, 0, -1.5)
			1: pos = Vector3(-0.5, 0, -1.5)
			2: pos = Vector3(0.5, 0, -1.5)
			3: pos = Vector3(-1.5, 0, -0.5)
			4: pos = Vector3(-0.5, 0, -0.5)
			5: pos = Vector3(0.5, 0, -0.5)
			6: pos = Vector3(-1.5, 0, 0.5)
			7: pos = Vector3(-0.5, 0, 0.5)
			8: pos = Vector3(0.5, 0, 0.5)
		pos.x += oObjRelativeXSpinBox.value
		pos.z += oObjRelativeYSpinBox.value
		pos.y += oObjRelativeZSpinBox.value
		oDkSlabsetVoxelView.add_billboard_obj(tex, pos)

func update_object_fields(index):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	if index >= listOfObjects.size(): return
	var obj = listOfObjects[index]

	oObjThingTypeSpinBox.disconnect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	oObjSubtypeSpinBox.disconnect("value_changed", self, "_on_ObjSubtypeSpinBox_value_changed")
	oObjIsLightCheckBox.disconnect("toggled", self, "_on_ObjIsLightCheckBox_toggled")
	oObjEffectRangeSpinBox.disconnect("value_changed", self, "_on_ObjEffectRangeSpinBox_value_changed")
	oObjSubtileSpinBox.disconnect("value_changed", self, "_on_ObjSubtileSpinBox_value_changed")
	oObjRelativeXSpinBox.disconnect("value_changed", self, "_on_ObjRelativeXSpinBox_value_changed")
	oObjRelativeYSpinBox.disconnect("value_changed", self, "_on_ObjRelativeYSpinBox_value_changed")
	oObjRelativeZSpinBox.disconnect("value_changed", self, "_on_ObjRelativeZSpinBox_value_changed")
	
	if obj[0] == 1:
		obj[6] = 0
	else:
		_previous_thing_type = obj[6]
	oObjThingTypeSpinBox.value = obj[6]
	oObjSubtypeSpinBox.value = obj[7]
	oObjIsLightCheckBox.pressed = bool(obj[0])
	oObjEffectRangeSpinBox.value = obj[8]
	oObjSubtileSpinBox.value = obj[2]
	oObjRelativeXSpinBox.value = obj[3] / 256.0
	oObjRelativeYSpinBox.value = obj[4] / 256.0
	oObjRelativeZSpinBox.value = obj[5] / 256.0

	oObjThingTypeSpinBox.connect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	oObjSubtypeSpinBox.connect("value_changed", self, "_on_ObjSubtypeSpinBox_value_changed")
	oObjIsLightCheckBox.connect("toggled", self, "_on_ObjIsLightCheckBox_toggled")
	oObjEffectRangeSpinBox.connect("value_changed", self, "_on_ObjEffectRangeSpinBox_value_changed")
	oObjSubtileSpinBox.connect("value_changed", self, "_on_ObjSubtileSpinBox_value_changed")
	oObjRelativeXSpinBox.connect("value_changed", self, "_on_ObjRelativeXSpinBox_value_changed")
	oObjRelativeYSpinBox.connect("value_changed", self, "_on_ObjRelativeYSpinBox_value_changed")
	oObjRelativeZSpinBox.connect("value_changed", self, "_on_ObjRelativeZSpinBox_value_changed")
	
	if obj[0] == 1:
		oObjSubtypeLabel.text = "Intensity"
		oObjThingTypeLabel.modulate.a = 0
		oObjThingTypeSpinBox.modulate.a = 0
	else:
		oObjSubtypeLabel.text = "Subtype"
		oObjThingTypeLabel.modulate.a = 1
		oObjThingTypeSpinBox.modulate.a = 1
	update_obj_name()

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
	oEditor.mapHasBeenEdited = true
	var variation = get_current_variation()
	add_new_object_to_variation(variation)
	update_objects_ui()
	oDkSlabsetVoxelView.update_column_view()
	restart_regeneration_timer()

func add_new_object_to_variation(variation):
	var randomSubtype = 1
	var new_object_defaults = [0, variation, 4, 128, 128, 256, 1, randomSubtype, 0]
	ensure_tng_array_has_space(variation)
	Slabset.tng[variation].append(new_object_defaults)
	var lastEntryIndex = Slabset.tng[variation].size()-1
	oObjObjectIndexSpinBox.value = lastEntryIndex
	update_object_fields(lastEntryIndex)
	update_obj_name()
	oMessage.quick("Added new object")

func _on_ObjDeleteButton_pressed():
	oEditor.mapHasBeenEdited = true
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
	restart_regeneration_timer()

func _on_ObjThingTypeSpinBox_value_changed(value:int):
	oEditor.mapHasBeenEdited = true
	if oObjIsLightCheckBox.pressed == true:
		value = 0
	else:
		value = 7 if value in [0, 2, 7] else 1
		_previous_thing_type = value
	oObjThingTypeSpinBox.disconnect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	oObjThingTypeSpinBox.value = value
	oObjThingTypeSpinBox.connect("value_changed", self, "_on_ObjThingTypeSpinBox_value_changed")
	update_obj_name()
	update_object_property(Slabset.obj.THING_TYPE, value)
	update_3D_sprite_visuals()

func _on_ObjSubtypeSpinBox_value_changed(value:int):
	oEditor.mapHasBeenEdited = true
	value = int(value)
	update_obj_name()
	update_object_property(Slabset.obj.THING_SUBTYPE, value)
	update_3D_sprite_visuals()

func _on_ObjIsLightCheckBox_toggled(button_pressed:int):
	oEditor.mapHasBeenEdited = true
	if button_pressed == 1:
		_previous_thing_type = int(oObjThingTypeSpinBox.value)
		oObjSubtypeLabel.text = "Intensity"
		oObjThingTypeLabel.modulate.a = 0
		oObjThingTypeSpinBox.modulate.a = 0
		update_object_property(Slabset.obj.THING_TYPE, 0)
		oObjThingTypeSpinBox.value = 0
	else:
		oObjSubtypeLabel.text = "Subtype"
		oObjThingTypeLabel.modulate.a = 1
		oObjThingTypeSpinBox.modulate.a = 1
		update_object_property(Slabset.obj.THING_TYPE, _previous_thing_type)
		oObjThingTypeSpinBox.value = _previous_thing_type
	update_obj_name()
	update_object_property(Slabset.obj.IS_LIGHT, button_pressed)
	update_3D_sprite_visuals()

func _on_ObjEffectRangeSpinBox_value_changed(value:int):
	oEditor.mapHasBeenEdited = true
	update_object_property(Slabset.obj.EFFECT_RANGE, value)

func _on_ObjSubtileSpinBox_value_changed(value:int):
	oEditor.mapHasBeenEdited = true
	update_object_property(Slabset.obj.SUBTILE, value)
	update_3D_sprite_visuals()

func snap_to_256(floatValue):
	return round(floatValue * 256.0) / 256.0

func _on_ObjRelativeXSpinBox_value_changed(floatValue: float):
	oEditor.mapHasBeenEdited = true
	var newValue = snap_to_256(floatValue)
	oObjRelativeXSpinBox.disconnect("value_changed", self, "_on_ObjRelativeXSpinBox_value_changed")
	oObjRelativeXSpinBox.value = newValue
	oObjRelativeXSpinBox.connect("value_changed", self, "_on_ObjRelativeXSpinBox_value_changed")
	update_object_property(Slabset.obj.RELATIVE_X, int(newValue * 256))
	update_3D_sprite_visuals()

func _on_ObjRelativeYSpinBox_value_changed(floatValue: float):
	oEditor.mapHasBeenEdited = true
	var newValue = snap_to_256(floatValue)
	oObjRelativeYSpinBox.disconnect("value_changed", self, "_on_ObjRelativeYSpinBox_value_changed")
	oObjRelativeYSpinBox.value = newValue
	oObjRelativeYSpinBox.connect("value_changed", self, "_on_ObjRelativeYSpinBox_value_changed")
	update_object_property(Slabset.obj.RELATIVE_Y, int(newValue * 256))
	update_3D_sprite_visuals()

func _on_ObjRelativeZSpinBox_value_changed(floatValue: float):
	oEditor.mapHasBeenEdited = true
	var newValue = snap_to_256(floatValue)
	oObjRelativeZSpinBox.disconnect("value_changed", self, "_on_ObjRelativeZSpinBox_value_changed")
	oObjRelativeZSpinBox.value = newValue
	oObjRelativeZSpinBox.connect("value_changed", self, "_on_ObjRelativeZSpinBox_value_changed")
	update_object_property(Slabset.obj.RELATIVE_Z, int(newValue * 256))
	update_3D_sprite_visuals()

func update_object_property(the_property, new_value):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	var object_index = oObjObjectIndexSpinBox.value
	if object_index < 0 or object_index >= listOfObjects.size():
		return
	listOfObjects[object_index][the_property] = new_value
	adjust_object_color_if_different(variation)
	update_modified_label_for_slab_id()
	update_modified_label_for_variation()
	update_slabset_revert_button_state()
	restart_regeneration_timer()

func _on_SlabCopyButton_pressed():
	copy(ALL_VARIATION)

func _on_VarCopyButton_pressed():
	copy(ONE_VARIATION)

func copy(howMany):
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
	oEditor.mapHasBeenEdited = true
	paste(ALL_VARIATION)

func _on_VarPasteButton_pressed():
	oEditor.mapHasBeenEdited = true
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
	var data_size = clipboard["dat"].size()
	var tng_size = clipboard["tng"].size()
	for i in locationsToPasteTo:
		var clipboard_index = i % data_size
		ensure_dat_array_has_space(i)
		Slabset.dat[i] = clipboard["dat"][clipboard_index].duplicate(true)
		if clipboard_index < tng_size:
			ensure_tng_array_has_space(i)
			Slabset.tng[i] = clipboard["tng"][clipboard_index].duplicate(true)
	update_column_spinboxes()
	update_objects_ui()
	oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
	restart_regeneration_timer()

func _on_VarRotateButton_pressed():
	oEditor.mapHasBeenEdited = true
	var variation = get_current_variation()
	ensure_dat_array_has_space(variation)
	var new_dat = []
	for i in 9:
		new_dat.append(Slabset.dat[variation][ROTATION_MAP[i]])
	Slabset.dat[variation] = new_dat
	for obj in Slabset.tng[variation]:
		var old_subtile = obj[Slabset.obj.SUBTILE]
		var new_subtile = OBJECT_ROTATION_MAP[old_subtile]
		obj[Slabset.obj.SUBTILE] = new_subtile
		var old_relative_x = obj[Slabset.obj.RELATIVE_X]
		var old_relative_y = obj[Slabset.obj.RELATIVE_Y]
		obj[Slabset.obj.RELATIVE_X] = 256 - old_relative_y
		obj[Slabset.obj.RELATIVE_Y] = old_relative_x
	update_column_spinboxes()
	update_objects_ui()
	oDkSlabsetVoxelView.refresh_entire_view()
	oMessage.quick("Rotated variation")
	restart_regeneration_timer()

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
		var setToDat = Slabset.EMPTY_SLAB.duplicate()
		var setToTng = []
		
		if Slabset.default_data.has("dat") and variation < Slabset.default_data["dat"].size():
			setToDat = Slabset.default_data["dat"][variation].duplicate()
		
		if Slabset.default_data.has("tng") and variation < Slabset.default_data["tng"].size():
			setToTng = Slabset.default_data["tng"][variation].duplicate(true)
		
		Slabset.dat[variation] = setToDat
		Slabset.tng[variation] = setToTng
	update_column_spinboxes()
	update_objects_ui()
	yield(get_tree(),'idle_frame')
	oDkSlabsetVoxelView.refresh_entire_view()
	restart_regeneration_timer()

func _on_SlabsetHelpButton_pressed():
	var helptxt = "slabset.toml and columnset.toml affect the appearance of slabs when they're placed; when placing in Unearth AND when placing in-game. \nHowever keep in mind these files are not automatically saved by Unearth, so you will need to press this 'Save slabset' button whenever you make any changes.\nNew entries in terrain.cfg are also required in order to add new Slab IDs to the Slabset.\n\nIf you set an object's RelativeX and RelativeY to be inside of a column/cube then it may not appear in-game."
	oMessage.big("Help",helptxt)

func _on_SlabsetRevertButton_pressed():
	oConfirmRevertSlabset.dialog_text = "Revert all slabs to default?"
	oConfirmRevertSlabset.rect_min_size.x = 800
	Utils.popup_centered(oConfirmRevertSlabset)

func _on_ConfirmRevertSlabset_confirmed():
	var list_of_modified_slabs = Slabset.get_all_modified_slabs()
	oEditor.mapHasBeenEdited = true
	
	var variations_to_revert = []
	for slabID in list_of_modified_slabs:
		for i in 28:
			variations_to_revert.append((slabID * 28) + i)
	revert(variations_to_revert)
	oMessage.quick("Reverted all slabs")
	
	# Update UI
	update_column_spinboxes()
	update_objects_ui()
	oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
	update_slabset_revert_button_state()
	
	for id in list_of_modified_slabs:
		oSlabsetMapRegenerator.regenerate_slabs_using_slab_id(id)

func update_flash_state():
	if is_initializing:
		return
	if visible and oSlabsetWindow.visible:
		var currentVariation = get_current_variation()
		var slabID = int(oSlabsetIDSpinBox.value)
		oFlashingColumns.start_variation_flash(currentVariation, slabID)

func _on_flash_update_timer_timeout():
	oSlabsetWindow.update_flash_state()

func _on_config_status_changed():
	update_slabset_paths_label()
