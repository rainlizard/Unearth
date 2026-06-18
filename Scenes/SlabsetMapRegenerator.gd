extends Node2D

onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oUi = Nodelist.list["oUi"]

func calculate_cursor_data():
	var defaultData = {
		"slabID": 0,
		"columnsetIndex": 0,
		"localVariation": 0,
		"fullVariation": 0,
		"clmEntryIndex": 0,
		"variationDescription": ""
	}
	
	if oEditor.currentView != oEditor.VIEW_2D or oUi.mouseOnUi == true:
		return defaultData
	
	var oSelector = Nodelist.list["oSelector"]
	var pos = oSelector.cursorSubtile
	var tilePos = Vector2(floor(pos.x / 3), floor(pos.y / 3))
	var slabID = oSelector.get_slabID_at_pos(tilePos)
	
	if Slabs.data.has(slabID) == false or slabID >= 1000:
		return defaultData
	
	var entryIndex = oDataClmPos.get_cell_clmpos(pos.x, pos.y)
	var subtileIndex = (int(pos.y) % 3) * 3 + (int(pos.x) % 3)
	var columnsetIndex = 0
	var slabVariation = ""
	
	var ownership = oDataOwnership.get_cellv_ownership(tilePos)
	var surrID = oSlabPlacement.get_surrounding_slabIDs(tilePos.x, tilePos.y)
	var surrOwner = oSlabPlacement.get_surrounding_ownership(tilePos.x, tilePos.y)
	var bitmaskType = Slabs.data[slabID][Slabs.BITMASK_TYPE]
	
	var bitmask = get_bitmask(bitmaskType, slabID, ownership, surrID, surrOwner)
	var slabsetIndexGroup = oSlabPlacement.make_slab_for_tile(slabID, bitmask, tilePos.x, tilePos.y)
	
	if bitmaskType == Slabs.BITMASK_REINFORCED:
		oSlabPlacement.modify_wall_based_on_nearby_room_and_liquid(slabsetIndexGroup, surrID, slabID)
	else:
		oSlabPlacement.modify_for_liquid(slabsetIndexGroup, surrID, slabID)
	
	var variation = slabsetIndexGroup[subtileIndex] / 9
	columnsetIndex = Slabset.fetch_columnset_index(variation, subtileIndex)
	slabVariation = get_variation_description(variation, bitmaskType, surrID)
	
	return {
		"slabID": slabID,
		"columnsetIndex": columnsetIndex,
		"localVariation": variation % 28,
		"fullVariation": variation,
		"clmEntryIndex": entryIndex,
		"variationDescription": slabVariation
	}

func get_bitmask(bitmaskType, slabID, ownership, surrID, surrOwner):
	match bitmaskType:
		Slabs.BITMASK_BLOCK: return oSlabPlacement.get_tall_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_FLOOR: return oSlabPlacement.get_general_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_CLAIMED: return oSlabPlacement.get_claimed_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_REINFORCED: return oSlabPlacement.get_wall_bitmask(slabID, ownership, surrID, surrOwner)
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

func make_id_lookup(ids):
	var lookup = {}
	for id in ids:
		lookup[int(id)] = true
	return lookup

func regenerate_slabs_using_columnsets(columnsetIndexes):
	var targetColumnsetIndexes = make_id_lookup(columnsetIndexes)
	if targetColumnsetIndexes.empty():
		return
	var slabIDs = {}
	for variation in Slabset.dat.size():
		var datArray = Slabset.dat[variation]
		for subtileIndex in 9:
			if targetColumnsetIndexes.has(datArray[subtileIndex]):
				slabIDs[int(variation / 28)] = true
				break
	regenerate_slabs_using_slab_ids(slabIDs.keys())

func regenerate_slabs_using_slab_ids(slabIDs):
	var targetSlabIDs = make_id_lookup(slabIDs)
	if targetSlabIDs.empty():
		return

	var slabPositions = []
	for y in M.ySize:
		for x in M.xSize:
			var currentSlabID = oDataSlab.get_cell(x, y)
			if targetSlabIDs.has(currentSlabID):
				slabPositions.append(Vector2(x, y))
	if slabPositions.size() > 0:
		oSlabPlacement.generate_slabs_based_on_id(slabPositions, false)
