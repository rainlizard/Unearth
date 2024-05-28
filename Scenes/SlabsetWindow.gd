extends WindowDialog
onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oColumnsetVoxelView = Nodelist.list["oColumnsetVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oSlabsetIDLabel = Nodelist.list["oSlabsetIDLabel"]
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
onready var oVarButtonsApplyToAllCheckBox = Nodelist.list["oVarButtonsApplyToAllCheckBox"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oAddCustomSlabWindow = Nodelist.list["oAddCustomSlabWindow"]

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

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var columnSettersArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	oSlabsetTabs.set_tab_title(0, "Slabset") #slabs.dat
	oSlabsetTabs.set_tab_title(1, "Columnset") #slabs.clm
	
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	Utils.popup_centered(self)
	
	for number in 9:
		var id = scnColumnSetter.instance()
		var spinbox = id.get_node("CustomSpinBox")
		var shortcut = id.get_node("ButtonShortcut")
		shortcut.connect("pressed",self,"shortcut_pressed",[id])
		spinbox.max_value = 2047
		spinbox.connect("value_changed",oDkSlabsetVoxelView,"_on_Slabset3x3ColumnSpinBox_value_changed")
		spinbox.connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		oGridContainerDynamicColumns3x3.add_child(id)
		columnSettersArray.append(id)
	
	oDkSlabsetVoxelView.initialize()
	
	#yield(get_tree(),'idle_frame')
	#_on_SlabsetIDSpinBox_value_changed(0)
	
	#variation_changed(0)

func shortcut_pressed(id):
	var spinbox = id.get_node("CustomSpinBox")
	var clmIndex = spinbox.value
	oSlabsetTabs.set_current_tab(1)
	oColumnsetControls.oColumnIndexSpinBox.value = clmIndex

func _on_SlabsetWindow_visibility_changed():
	if visible == true:
		_on_SlabsetTabs_tab_changed(oSlabsetTabs.current_tab)
		
		oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		_on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		
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

#enum dir {
#	s = 0
#	w = 1
#	n = 2
#	e = 3
#	sw = 4
#	nw = 5
#	ne = 6
#	se = 7
#	all = 8
#	center = 27
#}

func _on_SlabsetIDSpinBox_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oSlabsetIDLabel.text = slabName
	update_columns_ui()

func _on_VariationNumberSpinBox_value_changed(value):
	update_columns_ui()

func update_columns_ui():
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


#func _on_ExportSlabsDat_pressed():
#	Utils.popup_centered(oExportSlabsetDatDialog)
#	oExportSlabsetDatDialog.current_dir = oGame.GAME_DIRECTORY.plus_file("")
#	oExportSlabsetDatDialog.current_path = oGame.GAME_DIRECTORY.plus_file("")
#	oExportSlabsetDatDialog.current_file = "slabs.dat"
#func _on_ExportSlabsClm_pressed():
#	Utils.popup_centered(oExportSlabsetClmDialog)
#	oExportSlabsetClmDialog.current_dir = oGame.GAME_DIRECTORY.plus_file("")
#	oExportSlabsetClmDialog.current_path = oGame.GAME_DIRECTORY.plus_file("")
#	oExportSlabsetClmDialog.current_file = "slabs.clm"

func _on_ExportSlabsToml_pressed():
	Utils.popup_centered(oExportSlabsetTomlDialog)
	oExportSlabsetTomlDialog.current_dir = oGame.GAME_DIRECTORY.plus_file("")
	oExportSlabsetTomlDialog.current_path = oGame.GAME_DIRECTORY.plus_file("")
	oExportSlabsetTomlDialog.current_file = "slabset.toml"

func _on_ExportColumnsToml_pressed():
	Utils.popup_centered(oExportColumnsetTomlDialog)
	oExportColumnsetTomlDialog.current_dir = oGame.GAME_DIRECTORY.plus_file("")
	oExportColumnsetTomlDialog.current_path = oGame.GAME_DIRECTORY.plus_file("")
	oExportColumnsetTomlDialog.current_file = "columnset.toml"


func _on_ExportSlabsetTomlDialog_file_selected(filePath):
	var fullExport = false
	Slabset.export_toml_slabset(filePath, fullExport)

func _on_ExportColumnsetTomlDialog_file_selected(filePath):
	var fullExport = false
	Columnset.export_toml_columnset(filePath, fullExport)


#func _on_ImportSlabsetTomlDialog_file_selected(filePath):
#	var fullImport = false
#	Slabset.import_toml_slabset(filePath, fullImport, true)
#	update_columns_ui()
#	update_objects_ui()
#
#func _on_ImportColumnsetTomlDialog_file_selected(filePath):
#	var fullImport = false
#	Columnset.import_toml_columnset(filePath, fullImport, true)
#	# Update columnset visuals here
#	oColumnsetVoxelView.refresh_entire_view()

func _on_ExportSlabsetDatDialog_file_selected(filePath):
	var buffer = StreamPeerBuffer.new()
	
	buffer.put_u16(1304)
	for slab in 1304:
		for subtile in 9:
			var value = 65536 - Slabset.dat[slab][subtile]
			buffer.put_u16(value)
	
	var file = File.new()
	if file.open(filePath,File.WRITE) == OK:
		file.store_buffer(buffer.data_array)
		file.close()
		oMessage.quick("Saved: " + filePath)
	else:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")


#func _on_ExportSlabsetClmDialog_file_selected(filePath):
#	var buffer = StreamPeerBuffer.new()
#
#	var numberOfClmEntries = 2048
#	buffer.put_16(numberOfClmEntries)
#	buffer.put_16(0)
##	buffer.put_16(numberOfClmEntries)
##	buffer.put_data([0,0])
##	buffer.put_16(0)
##	buffer.put_data([0,0])
#
#	for entry in numberOfClmEntries:
#		buffer.put_16(Columnset.utilized[entry]) # 0-1
#		buffer.put_8((Columnset.permanent[entry] & 1) + ((Columnset.lintel[entry] & 7) << 1) + ((Columnset.height[entry] & 15) << 4))
#		buffer.put_16(Columnset.solidMask[entry]) # 3-4
#		buffer.put_16(Columnset.floorTexture[entry]) # 5-6
#		buffer.put_8(Columnset.orientation[entry]) # 7
#
#		for cubeNumber in 8:
#			buffer.put_16(Columnset.cubes[entry][cubeNumber]) # 8-23
#
#	var file = File.new()
#	if file.open(filePath,File.WRITE) == OK:
#		file.store_buffer(buffer.data_array)
#		file.close()
#		oMessage.quick("Saved: " + filePath)
#	else:
#		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")

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

func update_objects_ui():
	var variation = get_current_variation()
	
	adjust_column_color_if_different(variation)
	adjust_object_color_if_different(variation)
	
	var listOfObjects = get_list_of_objects(variation)
	oSlabsetObjectSection.visible = !listOfObjects.empty()
	
	if listOfObjects.empty(): return
	
	oObjObjectIndexSpinBox.visible = listOfObjects.size() > 1 # Hide ability to switch object index if there's only one object on this variation
	oObjObjectIndexSpinBox.value = clamp(oObjObjectIndexSpinBox.value, 0, listOfObjects.size() - 1)
	
	update_object_fields(oObjObjectIndexSpinBox.value)


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
		oObjNameLabel.text = Things.fetch_name(thingType, subtype)

func _on_ObjAddButton_pressed():
	var variation = get_current_variation()
	add_new_object_to_variation(variation)
	update_objects_ui()

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
	oMessage.quick("Deleted object")

func _on_ObjThingTypeSpinBox_value_changed(value:int):
	#oObjThingTypeSpinBox.hint_tooltip = Things.data_structure_name.get(value, "?")
	#yield(get_tree(),'idle_frame')
	update_obj_name()
	update_object_property(Slabset.obj.THING_TYPE, value)

func _on_ObjSubtypeSpinBox_value_changed(value:int):
	value = int(value)
	#yield(get_tree(),'idle_frame')
	update_obj_name()
	update_object_property(Slabset.obj.THING_SUBTYPE, value)

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


func _on_ObjEffectRangeSpinBox_value_changed(value:int):
	update_object_property(Slabset.obj.EFFECT_RANGE, value)

func _on_ObjSubtileSpinBox_value_changed(value:int):
	update_object_property(Slabset.obj.SUBTILE, value)

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

func _on_ObjRelativeYSpinBox_value_changed(float_value: float):
	snap_and_update_spinbox_value(oObjRelativeYSpinBox, Slabset.obj.RELATIVE_Y, float_value, "_on_ObjRelativeYSpinBox_value_changed")

func _on_ObjRelativeZSpinBox_value_changed(float_value: float):
	snap_and_update_spinbox_value(oObjRelativeZSpinBox, Slabset.obj.RELATIVE_Z, float_value, "_on_ObjRelativeZSpinBox_value_changed")


# Helper method to update the object in Slabset.tng
func update_object_property(the_property, new_value):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	var object_index = oObjObjectIndexSpinBox.value
	if object_index < 0 or object_index >= listOfObjects.size():
		return # Invalid index, nothing to update
	listOfObjects[object_index][the_property] = new_value
	adjust_object_color_if_different(variation)

func _on_VarCopyButton_pressed():
	# Clear previous clipboard data
	clipboard["dat"].clear()
	clipboard["tng"].clear()
	
	var variationsToCopy = []
	if oVarButtonsApplyToAllCheckBox.pressed == true:
		oMessage.quick("Copied 28 variations to clipboard")
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


func _on_VarPasteButton_pressed():
	if clipboard["dat"].empty() and clipboard["tng"].empty():
		oMessage.quick("Clipboard is empty.")
		return
	
	var locationsToPasteTo = []
	if oVarButtonsApplyToAllCheckBox.pressed:
		oMessage.quick("Pasted 28 variations")
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
	update_columns_ui()
	update_objects_ui()
	oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)



const ROTATION_POSITIONS = [ # New positions for subtiles after rotation
	6, 3, 0,
	7, 4, 1,
	8, 5, 2,
]

const ROTATION_MAP = {
	0: 6, 1: 3, 2: 0,
	3: 7, 4: 4, 5: 1,
	6: 8, 7: 5, 8: 2
}

func _on_VarRotateButton_pressed():
	var variation = get_current_variation()
	ensure_dat_array_has_space(variation)
	
	# Rotate the 'dat' array by reassigning using the ROTATION_MAP
	var new_dat = []
	for i in range(9):
		new_dat.append(Slabset.dat[variation][ROTATION_MAP[i]])
	Slabset.dat[variation] = new_dat
	
	# Rotate the object positions within the slab
	for obj in Slabset.tng[variation]:
		var new_x = obj[Slabset.obj.RELATIVE_Y]
		var new_y = -obj[Slabset.obj.RELATIVE_X]
		obj[Slabset.obj.RELATIVE_X] = new_x
		obj[Slabset.obj.RELATIVE_Y] = new_y
		obj[Slabset.obj.SUBTILE] = ROTATION_MAP[obj[Slabset.obj.SUBTILE]]
	
	# Update the UI
	update_columns_ui()
	update_objects_ui()
	oMessage.quick("Rotated variation")

func _on_VarRevertButton_pressed():
	var variation = get_current_variation()
	
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
	
	update_columns_ui()  # Update UI for columns
	update_objects_ui()  # Update UI for objects
	oMessage.quick("Variation reverted")



#func _on_VarDuplicateButton_pressed():
#	# Find the next free variation space
#	var current_variation = get_current_variation()
#	var next_free_variation = find_next_free_variation(current_variation)
#
#	if next_free_variation == -1:
#		oMessage.quick("No free variation spaces available.")
#		return
#
#	# Duplicate the 'dat' for the current variation
#	ensure_dat_array_has_space(next_free_variation)
#	Slabset.dat[next_free_variation] = Slabset.dat[current_variation].duplicate()
#
#	# Duplicate the 'tng' for the current variation
#	ensure_tng_array_has_space(next_free_variation)
#	Slabset.tng[next_free_variation] = Slabset.tng[current_variation].duplicate(true) # true for deep copy if needed
#
#	# Update UI to reflect the new duplicated variation
#	update_columns_ui()  # Assuming this updates the UI with new column data
#	update_objects_ui()  # Assuming this updates the UI with new things/objects
#	oMessage.quick("Variation duplicated into SlabID: " + str(next_free_variation/28) + ", Variation: " + str(next_free_variation % 28))
#
#	oSlabsetIDSpinBox.value = next_free_variation/28
#	oVariationNumberSpinBox.value = next_free_variation % 28
#	oDkSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
#
#func find_next_free_variation(current_variation):
#	for i in range(current_variation+1, 255*28):
#		if (i >= Slabset.dat.size() or Slabset.dat[i].empty() or Slabset.dat[i] == [0,0,0, 0,0,0, 0,0,0]) and (i >= Slabset.tng.size() or Slabset.tng[i].empty()):
#			return i
##		if Slabset.dat[i] == [0,0,0, 0,0,0, 0,0,0] and Slabset.tng[i].empty():
##			return i
#	return -1  # Return -1 if no free space is found

func _on_SlabsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "slabset.toml and columnset.toml affect the appearance of slabs when they're placed. \n"
	helptxt += "While these files are automatically loaded when you open your map, they're not automatically saved, so you will need to press this 'Save slabset' button whenever you make any changes.\n"
	helptxt += "Also, new entries in terrain.cfg are required for adding new slabs.\n"
	oMessage.big("Help",helptxt)

func _on_ColumnsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "Be wary not to confuse the Columnset with the Map Columns. \n"
	helptxt += "Map Columns are read from the map's local file such as map00001.clm \n"
	helptxt += "Whereas Columnset is a global file loaded from /fxdata/columnset.toml \n"
	helptxt += "However you can export a columnset.toml file to use for your own mappack/campaign."
	oMessage.big("Help",helptxt)


func _on_VarButtonsApplyToAllCheckBox_toggled(button_pressed):
	if button_pressed == true:
		oMessage.quick("Copy and paste buttons will affect 28 variations")
	else:
		oMessage.quick("Copy and paste buttons will affect 1 variation")
