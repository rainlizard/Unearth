extends WindowDialog
onready var oDkSlabsetVoxelView = Nodelist.list["oDkSlabsetVoxelView"]
onready var oColumnsetVoxelView = Nodelist.list["oColumnsetVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oSlabsetIDLabel = Nodelist.list["oSlabsetIDLabel"]
onready var oGridContainerDynamicColumns3x3 = Nodelist.list["oGridContainerDynamicColumns3x3"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oExportSlabsetDatDialog = Nodelist.list["oExportSlabsetDatDialog"]
onready var oGame = Nodelist.list["oGame"]
onready var oExportColumnCfgDialog = Nodelist.list["oExportColumnCfgDialog"]
onready var oExportSlabsetCfgDialog = Nodelist.list["oExportSlabsetCfgDialog"]
onready var oSlabsetTabs = Nodelist.list["oSlabsetTabs"]
onready var oColumnsetControls = Nodelist.list["oColumnsetControls"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oTabCustomSlabs = Nodelist.list["oTabCustomSlabs"]
onready var oExportSlabsetClmDialog = Nodelist.list["oExportSlabsetClmDialog"]
onready var oExportSlabsFullCheckBox = Nodelist.list["oExportSlabsFullCheckBox"]
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
	update_slabthings()

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
		var clmIndex = Slabset.fetch_column_index(variation, subtile)
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
	adjust_color_if_different(variation)

func ensure_dat_array_has_space(variation):
	while variation >= Slabset.dat.size():
		Slabset.dat.append([0,0,0, 0,0,0, 0,0,0])

func ensure_tng_array_has_space(variation):
	while variation >= Slabset.tng.size():
		Slabset.tng.append([])

func _on_SlabsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "Slabset is loaded from /data/slabs.dat \n"
	helptxt += "Columnset is loaded from /data/slabs.clm \n"
	helptxt += "The attached objects are loaded from /data/slabs.tng \n"
	helptxt += "These sets determine the slab's appearance when placed. \n"
	helptxt += "To mod the slabs that are placed in-game you'll need to export .cfg files and use them in a mappack/campaign."
	
	#helptxt += '\n'
	#helptxt += '\n'
	#helptxt += ""
	oMessage.big("Help",helptxt)


func _on_SlabsetCopyValues_pressed():
	oTabCustomSlabs.copy_values_from_slabset_and_index_them()
	
	visible = false
	oPickSlabWindow._on_pressed_add_new_custom_slab()


func _on_ExportSlabsDat_pressed():
	Utils.popup_centered(oExportSlabsetDatDialog)
	oExportSlabsetDatDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetDatDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetDatDialog.current_file = "slabs.dat"
func _on_ExportSlabsClm_pressed():
	Utils.popup_centered(oExportSlabsetClmDialog)
	oExportSlabsetClmDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetClmDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetClmDialog.current_file = "slabs.clm"
func _on_ExportSlabsCfg_pressed():
	Utils.popup_centered(oExportSlabsetCfgDialog)
	#oExportSlabsetCfgDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	#oExportSlabsetCfgDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetCfgDialog.current_file = "slabset.cfg"
func _on_ExportColumnsCfg_pressed():
	Utils.popup_centered(oExportColumnCfgDialog)
	#oExportColumnCfgDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	#oExportColumnCfgDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportColumnCfgDialog.current_file = "columns.cfg"

func _on_ExportSlabsetCfgDialog_file_selected(filePath):
	var fullExport = oExportSlabsFullCheckBox.pressed
	Slabset.create_cfg_slabset(filePath, fullExport)

func _on_ExportColumnCfgDialog_file_selected(filePath):
	Columnset.create_cfg_columns(filePath)

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


func _on_ExportSlabsetClmDialog_file_selected(filePath):
	var buffer = StreamPeerBuffer.new()
	
	var numberOfClmEntries = 2048
	buffer.put_16(numberOfClmEntries)
	buffer.put_16(0)
#	buffer.put_16(numberOfClmEntries)
#	buffer.put_data([0,0])
#	buffer.put_16(0)
#	buffer.put_data([0,0])
	
	for entry in numberOfClmEntries:
		buffer.put_16(Columnset.utilized[entry]) # 0-1
		buffer.put_8((Columnset.permanent[entry] & 1) + ((Columnset.lintel[entry] & 7) << 1) + ((Columnset.height[entry] & 15) << 4))
		buffer.put_16(Columnset.solidMask[entry]) # 3-4
		buffer.put_16(Columnset.floorTexture[entry]) # 5-6
		buffer.put_8(Columnset.orientation[entry]) # 7
		
		for cubeNumber in 8:
			buffer.put_16(Columnset.cubes[entry][cubeNumber]) # 8-23
	
	var file = File.new()
	if file.open(filePath,File.WRITE) == OK:
		file.store_buffer(buffer.data_array)
		file.close()
		oMessage.quick("Saved: " + filePath)
	else:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")

func get_current_variation():
	return (int(oSlabsetIDSpinBox.value) * 28) + int(oVariationNumberSpinBox.value)

func get_list_of_objects(variation):
	if variation < Slabset.tng.size():
		return Slabset.tng[variation]
	else:
		return []

func adjust_color_if_different(variation):
	for subtile in 9:
		var id = columnSettersArray[subtile]
		var spinbox = id.get_node("CustomSpinBox")
		var shortcut = id.get_node("ButtonShortcut")
		if Slabset.is_dat_column_different(variation, subtile) == true:
			spinbox.modulate = Color(1.8,1.8,1.9)
			shortcut.modulate = Color(1.4,1.4,1.5)
		else:
			spinbox.modulate = Color(1,1,1)
			shortcut.modulate = Color(1,1,1)

func update_slabthings():
	var variation = get_current_variation()
	
	adjust_color_if_different(variation)
	
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
	oObjRelativeXSpinBox.value = obj[3]
	oObjRelativeYSpinBox.value = obj[4]
	oObjRelativeZSpinBox.value = obj[5]

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
		var dataStruct = Things.data_structure(int(oObjThingTypeSpinBox.value))
		var subtype = int(oObjSubtypeSpinBox.value)
		if dataStruct.has(subtype):
			var newName = dataStruct[subtype][Things.NAME]
			if newName is String:
				oObjNameLabel.text = newName
		else:
			oObjNameLabel.text = "Name not found"

func _on_ObjAddButton_pressed():
	var variation = get_current_variation()
	add_new_object_to_variation(variation)
	update_slabthings()

func add_new_object_to_variation(variation):
	#update_object_property(Slabset.obj.VARIATION, variation)
	var randomSubtype = Random.randi_range(1,135)
	var new_object = [0,variation,4, 0,0,0, 1,randomSubtype,0]
	
	ensure_tng_array_has_space(variation)
	Slabset.tng[variation].append(new_object)
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
	
	update_slabthings()
	oMessage.quick("Deleted object")

func _on_ObjThingTypeSpinBox_value_changed(value:int):
	oObjThingTypeSpinBox.hint_tooltip = Things.data_structure_name.get(value, "?")
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
func _on_ObjRelativeXSpinBox_value_changed(value:float):
	update_object_property(Slabset.obj.RELATIVE_X, value)
func _on_ObjRelativeYSpinBox_value_changed(value:float):
	update_object_property(Slabset.obj.RELATIVE_Y, value)
func _on_ObjRelativeZSpinBox_value_changed(value:float):
	update_object_property(Slabset.obj.RELATIVE_Z, value)

# Helper method to update the object in Slabset.tng
func update_object_property(the_property, new_value):
	var variation = get_current_variation()
	var listOfObjects = get_list_of_objects(variation)
	var object_index = oObjObjectIndexSpinBox.value
	if object_index < 0 or object_index >= listOfObjects.size():
		return # Invalid index, nothing to update
	listOfObjects[object_index][the_property] = new_value
