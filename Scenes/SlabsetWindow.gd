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

onready var oObjObjectIndexSpinBox = Nodelist.list["oObjObjectIndexSpinBox"]
onready var oObjAddButton = Nodelist.list["oObjAddButton"]
onready var oObjDeleteButton = Nodelist.list["oObjDeleteButton"]
onready var oObjThingTypeSpinBox = Nodelist.list["oObjThingTypeSpinBox"]
onready var oObjSubtypeSpinBox = Nodelist.list["oObjSubtypeSpinBox"]
onready var oObjIsLightSpinBox = Nodelist.list["oObjIsLightSpinBox"]
onready var oObjEffectRangeSpinBox = Nodelist.list["oObjEffectRangeSpinBox"]
onready var oObjSubtileSpinBox = Nodelist.list["oObjSubtileSpinBox"]
onready var oObjRelativeXSpinBox = Nodelist.list["oObjRelativeXSpinBox"]
onready var oObjRelativeYSpinBox = Nodelist.list["oObjRelativeYSpinBox"]
onready var oObjRelativeZSpinBox = Nodelist.list["oObjRelativeZSpinBox"]


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


func variation_changed(variation):
	variation = int(variation)
	#var slabID = oSlabsetIDSpinBox.value
	#variation
	var constructString = ""
	#var byte = (slabID * 28) + variation
	#constructString += "Byte " + str(byte) + ' - ' + str(byte)
	#constructString += '\n'
	
	if variation != 27:
		match variation % 9:
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
	
	if variation < 9:
		constructString += ""
	elif variation < 18:
		constructString += "Near lava"
	elif variation < 27:
		constructString += "Near water"
	
	oVariationInfoLabel.text = constructString

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
	
	var variation = int(oVariationNumberSpinBox.value)
	var slabID = int(oSlabsetIDSpinBox.value)
	
	for subtile in columnSettersArray.size():
		var spinbox = columnSettersArray[subtile].get_node("CustomSpinBox")
		spinbox.disconnect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		var clmIndex = Slabset.fetch_column_index(slabID, variation, subtile)
		spinbox.value = clmIndex
		spinbox.connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")

func _on_Slabset3x3ColumnSpinBox_value_changed(value):
	var variation = int(oVariationNumberSpinBox.value)
	var slabID = int(oSlabsetIDSpinBox.value)
	
	for y in 3:
		for x in 3:
			var i = (y*3) + x
			var id = oGridContainerDynamicColumns3x3.get_child(i)
			var spinbox = id.get_node("CustomSpinBox")
			var clmIndex = spinbox.value
			
			Slabset.dat[slabID][variation][i] = clmIndex
			#oSlabPalette.slabPal[variation][i] = clmIndex # This may not be working



func _on_SlabsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "Slabset is loaded from /data/slabs.dat \n"
	helptxt += "Columnset is loaded from /data/slabs.clm \n"
	helptxt += "Objectset is loaded from /data/slabs.tng \n"
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
	Slabset.create_cfg_slabset(filePath)
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


func _on_ObjAddButton_pressed():
	pass # Replace with function body.


func _on_ObjDeleteButton_pressed():
	pass # Replace with function body.


func _on_ObjThingTypeSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjSubtypeSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjIsLightSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjEffectRangeSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjSubtileSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjRelativeXSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjRelativeYSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_ObjRelativeZSpinBox_value_changed(value):
	pass # Replace with function body.
