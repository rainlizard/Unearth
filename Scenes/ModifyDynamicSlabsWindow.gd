extends WindowDialog
onready var oDynamicSlabVoxelView = Nodelist.list["oDynamicSlabVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oDynamicSlabIDSpinBox = Nodelist.list["oDynamicSlabIDSpinBox"]
onready var oDynamicSlabIDLabel = Nodelist.list["oDynamicSlabIDLabel"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	Utils.popup_centered(self)
	
	oDynamicSlabVoxelView.initialize()
	
	variation_changed(0)

func variation_changed(variation):
	variation = int(variation)
	var slabID = oDynamicSlabIDSpinBox.value
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


func _on_DynamicSlabIDSpinBox_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oDynamicSlabIDLabel.text = slabName

