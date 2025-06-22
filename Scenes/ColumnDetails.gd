extends Control
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oSelector3D = Nodelist.list["oSelector3D"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oColumnListData = Nodelist.list["oColumnListData"]
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oUi = Nodelist.list["oUi"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]

var currentlyLookingAtNode = null
var instanceType = 0

func _ready():
	get_parent().set_tab_title(2, "Column")

func update_details():
	if visible == false or oDataClm.cubes.size() == 0: return
	oColumnListData.clear()
	
	var pos = Vector2()
	var entryIndex = 0
	var columnsetIndex = 0
	var slabVariation = ""
	
	if oEditor.currentView == oEditor.VIEW_2D and oUi.mouseOnUi == false:
		pos = oSelector.cursorSubtile
		entryIndex = oDataClmPos.get_cell_clmpos(pos.x, pos.y)
		var tilePos = Vector2(floor(pos.x / 3), floor(pos.y / 3))
		var subtileIndex = (int(pos.y) % 3) * 3 + (int(pos.x) % 3)
		var slabID = oSelector.get_slabID_at_pos(tilePos)
		
		if Slabs.data.has(slabID) and slabID < 1000:
			var ownership = oDataOwnership.get_cellv_ownership(tilePos)
			var surrID = oSlabPlacement.get_surrounding_slabIDs(tilePos.x, tilePos.y)
			var surrOwner = oSlabPlacement.get_surrounding_ownership(tilePos.x, tilePos.y)
			var bitmaskType = Slabs.data[slabID][Slabs.BITMASK_TYPE]
			
			var bitmask = get_bitmask(bitmaskType, slabID, ownership, surrID, surrOwner, tilePos)
			var slabsetIndexGroup = oSlabPlacement.make_slab(slabID * 28, bitmask)
			
			if bitmaskType == Slabs.BITMASK_REINFORCED:
				oSlabPlacement.modify_wall_based_on_nearby_room_and_liquid(slabsetIndexGroup, surrID, slabID)
			else:
				oSlabPlacement.modify_for_liquid(slabsetIndexGroup, surrID, slabID)
			
			var variation = slabsetIndexGroup[subtileIndex] / 9
			columnsetIndex = Slabset.fetch_columnset_index(variation, subtileIndex)
			slabVariation = get_variation_description(variation, bitmaskType, surrID)
	
	var data = [
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

func get_bitmask(bitmaskType, slabID, ownership, surrID, surrOwner, tilePos):
	match bitmaskType:
		Slabs.BITMASK_BLOCK: return oSlabPlacement.get_tall_bitmask(surrID)
		Slabs.BITMASK_FLOOR: return oSlabPlacement.get_general_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_CLAIMED: return oSlabPlacement.get_claimed_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_REINFORCED: return oSlabPlacement.get_wall_bitmask(tilePos.x, tilePos.y, surrID, ownership)
		_: return 1

func get_variation_description(variation, bitmaskType, surrID):
	var localVariation = variation % 28
	if localVariation == 27: return "Center"
	
	var baseDescription = oSlabPlacement.DIRECTION_NAMES[localVariation % 9]
	
	if localVariation >= 9 and localVariation < 18:
		var hasRoomFace = bitmaskType == Slabs.BITMASK_REINFORCED and (Slabs.rooms_that_have_walls.has(surrID[0]) or Slabs.rooms_that_have_walls.has(surrID[1]) or Slabs.rooms_that_have_walls.has(surrID[2]) or Slabs.rooms_that_have_walls.has(surrID[3]))
		return baseDescription + (" (room face)" if hasRoomFace else " (near lava)")
	elif localVariation >= 18 and localVariation < 27:
		var hasRoomFace = bitmaskType == Slabs.BITMASK_REINFORCED and (Slabs.rooms_that_have_walls.has(surrID[0]) or Slabs.rooms_that_have_walls.has(surrID[1]) or Slabs.rooms_that_have_walls.has(surrID[2]) or Slabs.rooms_that_have_walls.has(surrID[3]))
		return baseDescription + (" (room face)" if hasRoomFace else " (near water)")
	
	return baseDescription
