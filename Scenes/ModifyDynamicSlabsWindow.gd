extends WindowDialog
onready var oSlabsetVoxelView = Nodelist.list["oSlabsetVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oSlabsetIDSpinBox = Nodelist.list["oSlabsetIDSpinBox"]
onready var oSlabsetIDLabel = Nodelist.list["oSlabsetIDLabel"]
onready var oGridContainerDynamicColumns3x3 = Nodelist.list["oGridContainerDynamicColumns3x3"]
onready var oDkSlabs = Nodelist.list["oDkSlabs"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oExportSlabsetDatDialog = Nodelist.list["oExportSlabsetDatDialog"]
onready var oGame = Nodelist.list["oGame"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var columnSpinBoxArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	Utils.popup_centered(self)
	
	for number in 9:
		var id = CustomSpinBox.new()
		id.max_value = 2047
		id.connect("value_changed",oSlabsetVoxelView,"_on_Slabset3x3ColumnSpinBox_value_changed")
		id.connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		oGridContainerDynamicColumns3x3.add_child(id)
		columnSpinBoxArray.append(id)
	
	oSlabsetVoxelView.initialize()
	
	#yield(get_tree(),'idle_frame')
	#_on_SlabsetIDSpinBox_value_changed(0)
	
	#variation_changed(0)


func _on_SlabsetWindow_visibility_changed():
	if visible == true:
		oSlabsetVoxelView._on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)
		_on_SlabsetIDSpinBox_value_changed(oSlabsetIDSpinBox.value)


func variation_changed(variation):
	variation = int(variation)
	var slabID = oSlabsetIDSpinBox.value
	#variation
	var constructString = ""
	#var byte = (slabID * 28) + variation
	#constructString += "Byte " + str(byte) + ' - ' + str(byte)
	#constructString += '\n'
	
	if slabID < 42:
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
	
	var variationStart = (slabID * 28)
	if slabID >= 42:
		variationStart = (42 * 28) + (8 * (slabID - 42))
	variation += variationStart
	
	if variation >= 1304:
		return
	
	for i in columnSpinBoxArray.size():
		columnSpinBoxArray[i].disconnect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")
		var clmIndex = oDkSlabs.dat[variation][i]
		columnSpinBoxArray[i].value = clmIndex
		columnSpinBoxArray[i].connect("value_changed",self,"_on_Slabset3x3ColumnSpinBox_value_changed")

func _on_Slabset3x3ColumnSpinBox_value_changed(value):
	var variation = int(oVariationNumberSpinBox.value)
	var slabID = int(oSlabsetIDSpinBox.value)
	
	var variationStart = (slabID * 28)
	if slabID >= 42:
		variationStart = (42 * 28) + (8 * (slabID - 42))
	variation += variationStart
	
	for y in 3:
		for x in 3:
			var i = (y*3) + x
			var clmIndex = oGridContainerDynamicColumns3x3.get_child(i).value
			oDkSlabs.dat[variation][i] = clmIndex
			#oSlabPalette.slabPal[variation][i] = clmIndex # This may not be working



func _on_SlabsetHelpButton_pressed():
	var helptxt = ""
	helptxt += "This feature is for viewing and editing slabs.dat and slabs.clm from DK's /data/ directory."
	#helptxt += '\n'
	#helptxt += '\n'
	#helptxt += ""
	oMessage.big("Help",helptxt)


func _on_SlabsetExportButton_pressed():
	Utils.popup_centered(oExportSlabsetDatDialog)
	oExportSlabsetDatDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetDatDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportSlabsetDatDialog.current_file = "slabs.dat"

func _on_ExportSlabsetDatDialog_file_selected(filePath):
	var buffer = StreamPeerBuffer.new()
	
	buffer.put_u16(1304)
	for slab in 1304:
		for subtile in 9:
			var value = 65536 - oDkSlabs.dat[slab][subtile]
			buffer.put_u16(value)
	
	var file = File.new()
	file.open(filePath,File.WRITE)
	file.store_buffer(buffer.data_array)
	file.close()
