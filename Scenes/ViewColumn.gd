extends Control
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oSelector3D = Nodelist.list["oSelector3D"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oColumnListData = Nodelist.list["oColumnListData"]
onready var oColumnEditorVoxelView = Nodelist.list["oColumnEditorVoxelView"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oUi = Nodelist.list["oUi"]
onready var oColumnEditor = Nodelist.list["oColumnEditor"]
onready var oReadCubes = Nodelist.list["oReadCubes"]

var currentlyLookingAtNode = null
var instanceType = 0

func _ready():
	get_parent().set_tab_title(2, "Column")

func update_details():
	if visible == false: return
	if oDataClm.cubes.size() == 0: return
	
	oColumnListData.clear()
	
	var pos = Vector2()
	var entryIndex = 0
	
	if oEditor.currentView == oEditor.VIEW_2D and oUi.mouseOnUi == false:
		pos = oSelector.cursorSubtile
		entryIndex = oDataClmPos.get_cell(pos.x,pos.y)
#	elif oEditor.currentView == oEditor.VIEW_3D:
#		if oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_MAP:
#			pos = Vector2(oSelector3D.translation.x, oSelector3D.translation.z)
#			entryIndex = oDataClmPos.get_cell(pos.x, pos.y)
#
#		elif oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_CLM:
#			entryIndex = oGenerateTerrain.get_clm_index(oSelector3D.translation.x, oSelector3D.translation.z)
#			if entryIndex == null:
#				oColumnListData.clear()
#				return
	
	if oColumnEditor.visible == true:
		if oColumnEditorVoxelView.visible == true:
			entryIndex = oColumnEditorVoxelView.viewObject
		if oCustomSlabVoxelView.visible == true:
			if is_instance_valid(get_focus_owner()):
				if is_instance_valid(get_focus_owner().get_parent()):
					if get_focus_owner().get_parent() is SpinBox:
						entryIndex = get_focus_owner().get_parent().value
	
	for i in 16:
		var description
		var value
		match i:
			0:
				description = "Clm index"
				value = entryIndex
			1:
				description = "Utilized"
				value = oDataClm.utilized[entryIndex]
			2:
				description = "Orientation"
				value = oDataClm.orientation[entryIndex]
			3:
				description = "Solid mask"
				value = oDataClm.solidMask[entryIndex]
			4:
				description = "Permanent"
				value = oDataClm.permanent[entryIndex]
			5:
				description = "Lintel"
				value = oDataClm.lintel[entryIndex]
			6:
				description = "Height"
				value = oDataClm.height[entryIndex]
			7:
				description = "Cube 8"
				var cubeNumber = oDataClm.cubes[entryIndex][7]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			8:
				description = "Cube 7"
				var cubeNumber = oDataClm.cubes[entryIndex][6]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			9:
				description = "Cube 6"
				var cubeNumber = oDataClm.cubes[entryIndex][5]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			10:
				description = "Cube 5"
				var cubeNumber = oDataClm.cubes[entryIndex][4]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			11:
				description = "Cube 4"
				var cubeNumber = oDataClm.cubes[entryIndex][3]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			12:
				description = "Cube 3"
				var cubeNumber = oDataClm.cubes[entryIndex][2]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			13:
				description = "Cube 2"
				var cubeNumber = oDataClm.cubes[entryIndex][1]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			14:
				description = "Cube 1"
				var cubeNumber = oDataClm.cubes[entryIndex][0]
				value = str(cubeNumber)
				if cubeNumber < oReadCubes.names.size():
					value += ' : '+ oReadCubes.names[cubeNumber]
			15:
				description = "Floor texture"
				value = oDataClm.floorTexture[entryIndex]
#			16:
#				description = "Special byte"
#				value = oDataClm.testingSpecialByte[entryIndex]
		if value != null:
			oColumnListData.add_item(description, str(value))
			#oDisplay.add_item([description, str(value)],[HALIGN_LEFT,HALIGN_RIGHT])
