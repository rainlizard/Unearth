extends Control
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oSelector3D = Nodelist.list["oSelector3D"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oColumnListData = Nodelist.list["oColumnListData"]
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]
onready var oUi = Nodelist.list["oUi"]
onready var oSelector = Nodelist.list["oSelector"]

var currentlyLookingAtNode = null
var instanceType = 0

func _ready():
	get_parent().set_tab_title(2, "Column")

func update_details():
	if visible == false or oDataClm.cubes.size() == 0: return
	oColumnListData.clear()
	
	var cursorData = oSlabsetMapRegenerator.calculate_cursor_data()
	var entryIndex = cursorData.clmEntryIndex
	var columnsetIndex = cursorData.columnsetIndex
	var slabVariation = cursorData.variationDescription
	
	# Calculate the real slab ID and name from the full variation
	var realSlabID = cursorData.fullVariation / 28
	var realSlabName = "Unknown"
	if Slabs.data.has(realSlabID):
		realSlabName = Slabs.data[realSlabID][Slabs.NAME]
	var slabsetInfo = realSlabName + " : " + str(realSlabID)
	
	var data = [
		["Slabset", slabsetInfo],
		["Variation", slabVariation if slabVariation != "" else "N/A"],
		["Columnset", columnsetIndex],
		["Clm data", entryIndex],
		["Utilized", oDataClm.utilized[entryIndex]],
		["Orient", oDataClm.orientation[entryIndex]],
		["Solid mask", oDataClm.solidMask[entryIndex]],
		["Permanent", oDataClm.permanent[entryIndex]],
		["Lintel", oDataClm.lintel[entryIndex]],
		["Height", oDataClm.height[entryIndex]]
	]
	
	for i in range(8):
		var cubeIndex = 7 - i
		var cubeNumber = oDataClm.cubes[entryIndex][cubeIndex]
		var cubeName = Cube.names[cubeNumber] if cubeNumber < Cube.names.size() else ""
		data.append(["Cube " + str(i + 1), str(cubeNumber) + (" : " + cubeName if cubeName != "" else "")])
	
	data.append(["Floor texture", oDataClm.floorTexture[entryIndex]])
	
	for item in data:
		if item[1] != null:
			oColumnListData.add_item(item[0], str(item[1]))




