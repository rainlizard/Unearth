extends Node2D
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oPlaceLockedCheckBox = Nodelist.list["oPlaceLockedCheckBox"]
onready var oMirrorOptions = Nodelist.list["oMirrorOptions"]
onready var oMirrorFlipCheckBox = Nodelist.list["oMirrorFlipCheckBox"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oPlaceThingsAnywhere = Nodelist.list["oPlaceThingsAnywhere"]
onready var oOnlyOwnership = Nodelist.list["oOnlyOwnership"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]


var thingScn = preload("res://Scenes/ThingInstance.tscn")
var actionPointScn = preload("res://Scenes/ActionPointInstance.tscn")
var lightScn = preload("res://Scenes/LightInstance.tscn")

func _ready():
	erase_instances_loop()

func place_new_light(newThingType, newSubtype, newPosition, newOwnership):
	var id = lightScn.instance()
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.locationZ = newPosition.z
	id.lightRange = oPlacingSettings.lightRange
	id.lightIntensity = oPlacingSettings.lightIntensity
	id.parentTile = 65535 # "None"
	id.data3 = 0
	id.data4 = 0
	id.data5 = 0
	id.data6 = 0
	id.data7 = 0
	id.data8 = 0
	id.data9 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18_19 = 0
	add_child(id)

func place_new_action_point(newThingType, newSubtype, newPosition, newOwnership):
	var id = actionPointScn.instance()
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.pointRange = oPlacingSettings.pointRange
	id.pointNumber = get_free_action_point_number()
	id.data7 = 0
	add_child(id)
	
	oScriptHelpers.start() # Update when action points change

enum {
	MIRROR_THING
	MIRROR_LIGHT
	MIRROR_ACTIONPOINT
}

func mirror_adjusted_value(instanceBeingAdjusted, variableNameToAdjust, originalPosition):
	if oMirrorPlacementCheckBox.pressed == false:
		return
	
	var actions = []
	match oMirrorOptions.splitType:
		0: actions = [0]
		1: actions = [1]
		2: actions = [0,1,2]
	
	var flip = oMirrorFlipCheckBox.pressed
	var fieldX = (M.xSize*3)+1 # Don't know why this +1 works, but it does.
	var fieldY = (M.ySize*3)+1
	
	for performAction in actions:
		var mirroredPos = oMirrorOptions.mirror_calculation(performAction, flip, originalPosition, fieldX, fieldY)
		
		var arrayOfMirroredInstances = get_all_instances_on_subtile(mirroredPos.x, mirroredPos.y)
		for getNodeAtMirroredPosition in arrayOfMirroredInstances:
			if is_instance_valid(getNodeAtMirroredPosition):
				if getNodeAtMirroredPosition.subtype == instanceBeingAdjusted.subtype:
					if getNodeAtMirroredPosition.thingType == instanceBeingAdjusted.thingType:
						match variableNameToAdjust:
							"locationXYZ":
								var movedPosition = Vector2(instanceBeingAdjusted.locationX, instanceBeingAdjusted.locationY)
								var mirrorMovedPosition = oMirrorOptions.mirror_calculation(performAction, flip, movedPosition, fieldX, fieldY)
								getNodeAtMirroredPosition.locationX = mirrorMovedPosition.x
								getNodeAtMirroredPosition.locationY = mirrorMovedPosition.y
								getNodeAtMirroredPosition.locationZ = instanceBeingAdjusted.locationZ
							"pointRange":
								getNodeAtMirroredPosition.pointRange = instanceBeingAdjusted.pointRange
							"lightRange":
								getNodeAtMirroredPosition.lightRange = instanceBeingAdjusted.lightRange
							"effectRange":
								getNodeAtMirroredPosition.effectRange = instanceBeingAdjusted.effectRange
							"lightIntensity":
								getNodeAtMirroredPosition.lightIntensity = instanceBeingAdjusted.lightIntensity
							"creatureLevel":
								getNodeAtMirroredPosition.creatureLevel = instanceBeingAdjusted.creatureLevel
							"boxNumber":
								getNodeAtMirroredPosition.boxNumber = instanceBeingAdjusted.boxNumber
							"doorLocked":
								getNodeAtMirroredPosition.doorLocked = instanceBeingAdjusted.doorLocked
								getNodeAtMirroredPosition.update_spinning_key()
							"ownership":
								var finalOwner = calculate_mirrored_ownership(mirroredPos, originalPosition, fieldX, fieldY, instanceBeingAdjusted.ownership)
								getNodeAtMirroredPosition.ownership = finalOwner
							"creatureName":
								getNodeAtMirroredPosition.creatureName = instanceBeingAdjusted.creatureName
							"creatureGold":
								getNodeAtMirroredPosition.creatureGold = instanceBeingAdjusted.creatureGold
							"creatureInitialHealth":
								getNodeAtMirroredPosition.creatureInitialHealth = instanceBeingAdjusted.creatureInitialHealth
							"orientation":
								getNodeAtMirroredPosition.orientation = instanceBeingAdjusted.orientation
							"goldValue":
								getNodeAtMirroredPosition.goldValue = instanceBeingAdjusted.goldValue

func mirror_deletion_of_instance(instanceBeingDeleted):
	var actions = []
	match oMirrorOptions.splitType:
		0: actions = [0]
		1: actions = [1]
		2: actions = [0,1,2]
	
	var flip = oMirrorFlipCheckBox.pressed
	var fieldX = (M.xSize*3)+1 # Don't know why this +1 works, but it does.
	var fieldY = (M.ySize*3)+1
	
#	if oInspector.inspectingInstance == inst:
#		oInspector.deselect()
	var fromPos = Vector2(instanceBeingDeleted.locationX, instanceBeingDeleted.locationY)
	
	for performAction in actions:
		var toPos = oMirrorOptions.mirror_calculation(performAction, flip, fromPos, fieldX, fieldY)
		
		var arrayOfInstances = get_all_instances_on_subtile(toPos.x, toPos.y)
		for getNodeAtMirroredPosition in arrayOfInstances:
			if is_instance_valid(getNodeAtMirroredPosition):
				if getNodeAtMirroredPosition.subtype == instanceBeingDeleted.subtype:
					if getNodeAtMirroredPosition.thingType == instanceBeingDeleted.thingType:
						kill_instance(getNodeAtMirroredPosition)

func placement_is_obstructed(thingType, placeSubtile):
	var detectTerrainHeight = oDataClm.height[oDataClmPos.get_cell_clmpos(placeSubtile.x,placeSubtile.y)]
	if oPlaceThingsAnywhere.pressed == false and detectTerrainHeight >= 5 and thingType != Things.TYPE.EXTRA: # Lights and Action Points can always be placed anywhere
		return true
	return false

func mirror_instance_placement(newThingType, newSubtype, fromPos, newOwner, mirrorType):
	var actions = []
	match oMirrorOptions.splitType:
		0: actions = [0]
		1: actions = [1]
		2: actions = [0,1,2]
	
	var fromPosZ = fromPos.z
	
	var flip = oMirrorFlipCheckBox.pressed
	
	var fieldX = (M.xSize*3)+1 # Don't know why this +1 works, but it does.
	var fieldY = (M.ySize*3)+1
	
	var placedInstances = 0
	for performAction in actions:
		var toPos = oMirrorOptions.mirror_calculation(performAction, flip, fromPos, fieldX, fieldY)
		
		toPos = Vector3(toPos.x, toPos.y, fromPosZ)
		if placement_is_obstructed(newThingType, Vector2(toPos.x,toPos.y)) == true:
			continue
		# Prevent overlapping placements along the center line
		if oMirrorOptions.splitType == 0: # Don't use 'match', 'continue' doesn't work correctly there.
			if toPos == fromPos:
				continue
		elif oMirrorOptions.splitType == 1:
			if toPos == fromPos:
				continue
		elif oMirrorOptions.splitType == 2:
			if toPos == fromPos:
				continue
			if placedInstances > 0:
				if toPos.x == (fieldX-1) * 0.5 or toPos.y == (fieldY-1) * 0.5:
					continue
		
		placedInstances += 1
		
		var finalOwner = calculate_mirrored_ownership(toPos, fromPos, fieldX, fieldY, newOwner)
		
		match mirrorType:
			MIRROR_THING: place_new_thing(newThingType, newSubtype, toPos, finalOwner)
			MIRROR_LIGHT: place_new_light(newThingType, newSubtype, toPos, finalOwner)
			MIRROR_ACTIONPOINT: place_new_action_point(newThingType, newSubtype, toPos, finalOwner)

func calculate_mirrored_ownership(toPos, fromPos, fieldX, fieldY, mainPaint):
	var quadrantDestination = oMirrorOptions.get_quadrant(toPos, fieldX, fieldY)
	var quadrantClickedOn = oMirrorOptions.get_quadrant(fromPos, fieldX, fieldY)
	var quadrantDestinationOwner = oMirrorOptions.ownerValue[quadrantDestination]
	var quadrantClickedOnOwner = oMirrorOptions.ownerValue[quadrantClickedOn]
	
	var finalOwner = 5
	
	if oMirrorOptions.ui_quadrants_have_owner(mainPaint) == false:
		finalOwner = mainPaint
	else:
		if mainPaint == quadrantDestinationOwner:
			finalOwner = quadrantClickedOnOwner
		else:
			match oMirrorOptions.splitType:
				0,1:
					finalOwner = quadrantDestinationOwner
				2:
					var otherTwoQuadrants = []
					for i in 4:
						if oMirrorOptions.ownerValue[i] == quadrantClickedOnOwner: continue
						if oMirrorOptions.ownerValue[i] == mainPaint: continue
						otherTwoQuadrants.append(oMirrorOptions.ownerValue[i])
					
					if otherTwoQuadrants.size() == 2:
						if quadrantDestinationOwner == otherTwoQuadrants[0]:
							finalOwner = otherTwoQuadrants[1]
						else:
							finalOwner = otherTwoQuadrants[0]
					else:
						finalOwner = quadrantDestinationOwner
	return finalOwner

func place_new_thing(newThingType, newSubtype, newPosition, newOwnership): # Placed by hand
	#var CODETIME_START = OS.get_ticks_msec()
	var xSlab = floor(newPosition.x / 3)
	var ySlab = floor(newPosition.y / 3)
	var slabID = oDataSlab.get_cell(xSlab, ySlab)
	var id = thingScn.instance()
	
	id.data9 = 0
	id.data10 = 0
	id.data11_12 = 0
	id.data13 = 0
	id.data14 = 0
	id.data15 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18_19 = 0
	id.data20 = 0
	
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.locationZ = newPosition.z
	id.thingType = newThingType
	id.subtype = newSubtype
	id.ownership = newOwnership
	
	set_collectibles_ownership(id, slabID, oDataOwnership.get_cell_ownership(xSlab, ySlab))
	
	match id.thingType:
		Things.TYPE.OBJECT:
			id.parentTile = 65535 # "None"
			id.orientation = oPlacingSettings.orientation
			
			if id.subtype == 49: # Hero Gate
				id.herogateNumber = get_free_hero_gate_number() #originalInstance.herogateNumber
			elif id.subtype == 133: # Mysterious Box
				id.boxNumber = oPlacingSettings.boxNumber
			elif id.subtype in [2,7]: # Torch and Unlit Torch
				if Slabs.data[oDataSlab.get_cell(xSlab+1,ySlab)][Slabs.IS_SOLID] == true:
					id.locationX += 0.25
					id.parentTile = (xSlab+1) + ((ySlab) * M.xSize) # Should this be M.ySize ???
				if Slabs.data[oDataSlab.get_cell(xSlab-1,ySlab)][Slabs.IS_SOLID] == true:
					id.locationX -= 0.25
					id.parentTile = (xSlab-1) + ((ySlab) * M.xSize) # Should this be M.ySize ???
				if Slabs.data[oDataSlab.get_cell(xSlab,ySlab+1)][Slabs.IS_SOLID] == true:
					id.locationY += 0.25
					id.parentTile = (xSlab) + ((ySlab+1) * M.xSize) # Should this be M.ySize ???
				if Slabs.data[oDataSlab.get_cell(xSlab,ySlab-1)][Slabs.IS_SOLID] == true:
					id.locationY -= 0.25
					id.parentTile = (xSlab) + ((ySlab-1) * M.xSize) # Should this be M.ySize ???
				update_stray_torch_height(id)
			elif id.subtype in Things.LIST_OF_GOLDPILES:
				match id.subtype:
					3: id.goldValue = 500
					6: id.goldValue = 250
					43: id.goldValue = 200
					128: id.goldValue = 1
					136: id.goldValue = 100
		Things.TYPE.CREATURE:
			id.creatureLevel = oPlacingSettings.creatureLevel
			id.creatureName = oPlacingSettings.creatureName
			id.creatureGold = oPlacingSettings.creatureGold
			id.creatureInitialHealth = oPlacingSettings.creatureInitialHealth
			#id.orientation = oPlacingSettings.orientation
			id.index = get_free_index_number()
		Things.TYPE.EFFECTGEN:
			id.effectRange = oPlacingSettings.effectRange
			id.parentTile = (floor(newPosition.y/3) * M.xSize) + floor(newPosition.x/3) # Should this be M.ySize ???
			id.orientation = oPlacingSettings.orientation
		Things.TYPE.TRAP:
			id.index = get_free_index_number()
			id.orientation = oPlacingSettings.orientation
		Things.TYPE.DOOR:
			id.index = get_free_index_number()
			id.doorLocked = oPlacingSettings.doorLocked
			if newSubtype == 0:
				id.subtype = 1 #Depending on whether it was placed via autoslab or a hand placed Thing object.
			if Slabs.door_data.has(slabID):
				id.subtype = Slabs.door_data[slabID][Slabs.DOORSLAB_THING]
				id.doorOrientation = Slabs.door_data[slabID][Slabs.DOORSLAB_ORIENTATION]
	
	add_child(id)
	#print('Thing placed in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	# Warnings
	if id.thingType == Things.TYPE.OBJECT:
		if id.subtype == 10:
			if slabID != Slabs.HATCHERY:
				oMessage.big("Warning","Chicken won't appear unless placed inside a Hatchery. Place an Egg instead.")
		if id.subtype in [52,53,54,55,56]: # Treasury Hoard
			if slabID != Slabs.TREASURE_ROOM:
				oMessage.big("Warning","Treasury Hoard should be placed inside a Treasure Room.")
			
			# Place on center of slab. Won't be functional otherwise.
			var locX = (floor( floor(id.locationX) / 3 ) * 3) + 1.5
			var locY = (floor( floor(id.locationY) / 3 ) * 3) + 1.5
			
			# Move away while I check location
			id.locationX = -32767
			id.locationY = -32767
			var goldID = get_node_on_subtile(locX, locY, "TreasuryGold")
			if is_instance_valid(goldID) == true:
				kill_instance(goldID)
			id.locationX = locX
			id.locationY = locY
	elif id.thingType == Things.TYPE.DOOR:
		if Slabs.door_data.has(slabID) == false:
			oMessage.big("Warning","You placed a Door Thing without a Door Slab. Switch to Slab Mode and place a Door Slab for proper functionality.")
	return id

#Slabset.obj.IS_LIGHT,     # [0] IsLight [0-1]
#Slabset.obj.VARIATION,    # [1] Variation
#Slabset.obj.SUBTILE,      # [2] Subtile [0-9]
#Slabset.obj.RELATIVE_X,   # [3] RelativeX
#Slabset.obj.RELATIVE_Y,   # [4] RelativeY
#Slabset.obj.RELATIVE_Z,   # [5] RelativeZ
#Slabset.obj.THING_TYPE,   # [6] Thing type
#Slabset.obj.THING_SUBTYPE,# [7] Thing subtype
#Slabset.obj.EFFECT_RANGE  # [8] Effect range

func spawn_attached(xSlab, ySlab, slabID, ownership, subtile, tngObj): # Spawns from tng file
	var id
	if tngObj[Slabset.obj.IS_LIGHT] == 1:
		id = lightScn.instance()
		id.data3 = 0
		id.data4 = 0
		id.data5 = 0
		id.data6 = 0
		id.data7 = 0
		id.data8 = 0
		id.data9 = 0
		id.data16 = 0
		id.data17 = 0
		id.data18_19 = 0
		id.lightRange = tngObj[Slabset.obj.EFFECT_RANGE]
		id.lightIntensity = tngObj[Slabset.obj.THING_SUBTYPE] # The intensity is stored in the subtype of tngObj
		# ThingType and subtype must be handled in LightInstance.gd
	else:
		id = thingScn.instance()
		id.data9 = 0
		id.data10 = 0
		id.data11_12 = 0
		id.data13 = 0
		id.data14 = 0
		id.data15 = 0
		id.data16 = 0
		id.data17 = 0
		id.data18_19 = 0
		id.data20 = 0
		id.thingType = tngObj[Slabset.obj.THING_TYPE]
		id.subtype = tngObj[Slabset.obj.THING_SUBTYPE]
	
	id.parentTile = (ySlab * M.xSize) + xSlab
	
	var subtileY = subtile/3
	var subtileX = subtile-(subtileY*3)
	id.locationX = ((xSlab*3) + subtileX) + Things.convert_relative_256_to_float(tngObj[Slabset.obj.RELATIVE_X])
	id.locationY = ((ySlab*3) + subtileY) + Things.convert_relative_256_to_float(tngObj[Slabset.obj.RELATIVE_Y])
	id.locationZ = Things.convert_relative_256_to_float(tngObj[Slabset.obj.RELATIVE_Z])
	
	id.ownership = ownership
	
	if id.thingType == Things.TYPE.EFFECTGEN:
		id.effectRange = tngObj[Slabset.obj.EFFECT_RANGE]
	
	if slabID == Slabs.GUARD_POST:
		if tngObj[Slabset.obj.THING_SUBTYPE] == 115: # Guard Flag (Red)
			match ownership:
				0: pass # Red
				1: id.subtype = 116 # Blue
				2: id.subtype = 117 # Green
				3: id.subtype = 118 # Yellow
				4: id.subtype = 161 # White
				5:id.subtype = 119 # None
				6: id.subtype = 164 # Purple
				7: id.subtype = 166 # Black
				8: id.subtype = 168 # Orange
	elif slabID == Slabs.DUNGEON_HEART:
		if tngObj[Slabset.obj.THING_SUBTYPE] == 111: # Heart Flame (Red)
			match ownership:
				0: pass # Red
				1: id.subtype = 120 # Blue
				2: id.subtype = 121 # Green
				3: id.subtype = 122 # Yellow
				4:
					if oCurrentFormat.selected == Constants.ClassicFormat:
						kill_instance(id) # White
					else:
						id.subtype = 162 # White
				5: kill_instance(id) # None
				6: id.subtype = 165 # Purple
				7: id.subtype = 167 # Black
				8: id.subtype = 169 # Orange
	
	add_child(id)
	
#	if slabID == Slabs.WALL_WITH_TORCH or slabID == Slabs.EARTH_WITH_TORCH:
#
#		var scene = preload('res://scenes/TorchPartnerArrow.tscn')
#		var partnerArrow = scene.instance()
#		#partnerArrow.position = Vector2(xSlab*96, ySlab*96)
#
#		var oSlabPlacement = Nodelist.list["oSlabPlacement"]
#		match Nodelist.list["oSlabPlacement"].calculate_torch_side(xSlab, ySlab):
#			0: partnerArrow.texture = preload("res://Art/torchdir0.png")
#			1: partnerArrow.texture = preload("res://Art/torchdir1.png")
#			2: partnerArrow.texture = preload("res://Art/torchdir2.png")
#			3: partnerArrow.texture = preload("res://Art/torchdir3.png")
#		id.add_child(partnerArrow)

var instances_to_erase = []

func erase_instances_loop(): # started by _ready()
	for i in 2: # We need 2 idle_frames to separate the wait from the 1 idle_frame that perform_undo uses
		yield(get_tree(),'idle_frame')
	var items_freed = 0
	var max_items_to_free = max(1, instances_to_erase.size() * 0.01)
	#var FREEING_CODETIME_START = OS.get_ticks_msec()
	
	while true:
		var id = instances_to_erase.pop_back()
		if is_instance_valid(id):
			items_freed += 1
			id.free()
		if instances_to_erase.size() > 2000: # If you're not erasing them fast enough, leaving too many instances on the field creates its own lag.
			continue
		elif instances_to_erase.empty() == true or items_freed > max_items_to_free:
			break
	#if items_freed > 0:
		#print(items_freed)
		#print('Time spent freeing instances: ' + str(OS.get_ticks_msec() - FREEING_CODETIME_START) + 'ms')
	
	erase_instances_loop()

func kill_instance(id): # Multi-thread safe
	id.position = Vector2(rand_range(-10000000,-20000000),rand_range(-10000000,-20000000)) # Stacking them on the same position causes lag for some reason.
	for group in id.get_groups():
		id.remove_from_group(group)
	instances_to_erase.append(id)


func manage_things_on_slab(xSlab, ySlab, slabID, ownership):
	if Slabs.data[slabID][Slabs.IS_SOLID] == true:
		var nodesOnSlab = get_all_nodes_on_slab(xSlab, ySlab, ["Thing"])
		for id in nodesOnSlab:
			kill_instance(id)
	else:
		var checkSlabLocationGroup = "slab_location_group_"+str(xSlab)+'_'+str(ySlab)
		for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
			on_slab_update_thing_height(id)
			on_slab_delete_stray_door_thing_and_key(id, slabID)
			set_collectibles_ownership(id, slabID, ownership)


func set_collectibles_ownership(id, slabID, slabOwnership):
	if id.thingType == Things.TYPE.OBJECT:
		if Things.DATA_OBJECT.has(id.subtype):
			var genre = Things.DATA_OBJECT[id.subtype][Things.EDITOR_TAB]
			if Things.collectible_belonging.has(genre):
				if slabID == Things.collectible_belonging[genre]:
					id.ownership = slabOwnership
				else:
					id.ownership = 5

func manage_thing_ownership_on_slab(xSlab, ySlab, ownership):
	var checkSlabLocationGroup = "slab_location_group_"+str(xSlab)+'_'+str(ySlab)
	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
		id.ownership = ownership


#func delete_all_on_slab(xSlab, ySlab, arrayOfGroupNameStrings):
#	var checkSlabLocationGroup = "slab_location_group_"+str(xSlab)+'_'+str(ySlab)
#	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
#		for groupName in arrayOfGroupNameStrings:
#			if id.is_in_group(groupName):
#				id.queue_free()

func get_all_nodes_on_slab(xSlab, ySlab, arrayOfGroups):
	var array = []
	var checkSlabLocationGroup = "slab_location_group_" + str(xSlab) + '_' + str(ySlab)
	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
		if id.is_queued_for_deletion() == false:
			for nodeGroup in arrayOfGroups:
				if id.is_in_group(nodeGroup):
					array.append(id)
	return array


func get_node_on_subtile(xSubtile, ySubtile, nodeGroup):
	var checkSlabLocationGroup = "slab_location_group_"+str(floor(xSubtile/3))+'_'+str(floor(ySubtile/3))
	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
		if id.is_in_group(nodeGroup) and id.is_queued_for_deletion() == false and floor(id.locationX) == floor(xSubtile) and floor(id.locationY) == floor(ySubtile):
			return id
	return null

func get_all_instances_on_subtile(xSubtile, ySubtile):
	var checkSlabLocationGroup = "slab_location_group_"+str(floor(xSubtile/3))+'_'+str(floor(ySubtile/3))
	var array = []
	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
		if id.is_in_group("Instance") and id.is_queued_for_deletion() == false and floor(id.locationX) == floor(xSubtile) and floor(id.locationY) == floor(ySubtile):
			array.append(id)
	return array

func on_slab_update_thing_height(id): # Update heights of any manually placed objects
	if id.is_in_group("Thing"):
		if id.parentTile == 65535: # None. Not attached to any slab.
			var xSubtile = floor(id.locationX)
			var ySubtile = floor(id.locationY)
			var detectTerrainHeight = oDataClm.height[oDataClmPos.get_cell_clmpos(xSubtile,ySubtile)]
			id.locationZ = detectTerrainHeight
			if id.subtype in [2,7]:
				update_stray_torch_height(id)
			elif id.subtype == 44:
				id.locationZ = detectTerrainHeight-1
func update_stray_torch_height(id):
	id.locationZ = 2.875

func on_slab_delete_stray_door_thing_and_key(id, slabID):
	if id.is_in_group("Thing"):
		# Kill doors and keys that aren't on door slabIDs
		if id.is_in_group("Door") or id.is_in_group("Key"):
			if Slabs.is_door(slabID) == false:
				kill_instance(id)




#	for groupName in arrayOfGroupNameStrings:
#		var pos = Vector2(xSlab*96,ySlab*96)
#		var arrayColliders = collision_rectangle_list(pos, pos+Vector2(96,96), groupName)
#		for id in arrayColliders:
#			id.queue_free()



#func get_all_on_slab(nodegroup, xSlab, ySlab):
#	var array = []
#	for id in get_tree().get_nodes_in_group(nodegroup):
#		if id.is_queued_for_deletion() == false:
#			if id.locationX >= xSlab*3 and id.locationX < (xSlab+1) * 3 and id.locationY >= ySlab*3 and id.locationY < (ySlab+1) * 3:
#				array.append(id)
#	return array

#func delete_objects_on_subtile(xSubtile,ySubtile):
#	for id in get_tree().get_nodes_in_group("Thing"):
#		if id.locationX >= floor(xSubtile) and id.locationX < ceil(xSubtile) and id.locationY >= floor(ySubtile) and id.locationY < ceil(ySubtile):
#			id.queue_free()

#func delete_objects_on_subtile(checkPos):
#	checkPos += Vector2(0.5,0.5)
#	var space = get_world_2d().direct_space_state
#	for i in space.intersect_point(global_transform.translated(checkPos).get_origin(), 32, [], 0x7FFFFFFF, true, true):
#		if i["collider"].get_parent().is_in_group("Thing"):
#			i.queue_free()

func delete_attached_instances_on_slab(xSlab, ySlab):
	# Objects like torches are placed off the slab, so we use groups not coordinates
	var groupName = 'attachedtotile_'+str((ySlab*M.xSize)+xSlab)
	if groupName == "attachedtotile_0": return # This fixes an edge case issue with Spinning Keys being destroyed if you click the top left corner
	for id in get_tree().get_nodes_in_group(groupName):
		kill_instance(id)

func get_free_index_number():
	var listOfThingNumbers = []
	for id in get_tree().get_nodes_in_group("Creature"):
		listOfThingNumbers.append(id.index)
	for id in get_tree().get_nodes_in_group("Trap"):
		listOfThingNumbers.append(id.index)
	for id in get_tree().get_nodes_in_group("Door"):
		listOfThingNumbers.append(id.index)
	
	var newNumber = 1
	while true:
		if newNumber in listOfThingNumbers:
			newNumber += 1
		else:
			return newNumber

func get_free_hero_gate_number():
	var listOfHeroGateNumbers = []
	for id in get_tree().get_nodes_in_group("Thing"):
		if id.is_in_group("HeroGate"):
			listOfHeroGateNumbers.append(id.herogateNumber)
	
	var newNumber = 1
	while true:
		if newNumber in listOfHeroGateNumbers:
			newNumber += 1
		else:
			return newNumber

func get_free_action_point_number():
	var listOfpointNumbers = []
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		listOfpointNumbers.append(id.pointNumber)
	
	var newNumber = 1
	while true:
		if newNumber in listOfpointNumbers:
			newNumber += 1
		else:
			return newNumber

func return_dungeon_heart(ownership):
	for id in get_tree().get_nodes_in_group("Instance"):
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 5: # Dungeon Heart
			if id.ownership == ownership:
				return id
	return null

func return_hero_gate(number):
	for id in get_tree().get_nodes_in_group("Thing"):
		if id.is_in_group("HeroGate"):
			if id.herogateNumber == number:
				return id
	return null

func return_action_point(number):
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.pointNumber == number:
			return id
	return null

func check_for_dungeon_heart(ownership):
	for id in get_tree().get_nodes_in_group("Instance"):
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 5: # Dungeon Heart
			if id.ownership == ownership:
				return true
	return false

#var ts = Constants.TILE_SIZE
		#delete_within_range(ts*3, Vector2(cursorTile.x*ts,cursorTile.y*ts)+Vector2(ts/2,ts/2))

#func delete_within_range(withinRange, sourcePosition):
#	var rect = RectangleShape2D.new()
#	rect.extents = Vector2(withinRange/2, withinRange/2)
#
#	var query = Physics2DShapeQueryParameters.new()
#	query.set_shape(rect)
#	query.transform = oInstances.global_transform.translated(sourcePosition)
#	query.collide_with_areas = true
#
#	var space = oInstances.get_world_2d().direct_space_state
#	for i in space.intersect_shape(query,9999999):
#		var thingId = i["collider"].get_parent()
#		if thingId.is_in_group("Thing"):
#			thingId.queue_free()



#func torch_within_range(withinRange, sourcePosition):
#	var rect = RectangleShape2D.new()
#	rect.extents = Vector2(withinRange/2, withinRange/2)
#
#	var query = Physics2DShapeQueryParameters.new()
#	query.set_shape(rect)
#	query.transform = oInstances.global_transform.translated(sourcePosition)
#	query.collide_with_areas = true
#
#	var space = oInstances.get_world_2d().direct_space_state
#	for i in space.intersect_shape(query,99999999):
#		var thingId = i["collider"].get_parent()
#		if thingId.is_in_group("Thing"):
#			if thingId.subtype == 2 and thingId.thingType == Things.TYPE.OBJECT:
#				return true
#	return false

#var colShape = RectangleShape2D.new()
#func collision_rectangle_list(startPos, endPos, groupName):
#
#	var query = Physics2DShapeQueryParameters.new()
#	colShape.extents = (endPos - startPos) / 2
#	query.collide_with_areas = true # "Areas" are used by Instances
#
#	query.shape_rid = colShape
#	query.transform = Transform2D(0, (endPos + startPos)/2)
#
#	var space = get_world_2d().direct_space_state
#	var array = []
#	for i in space.intersect_shape(query):
#		var getInstance = i.collider.get_parent()
#		if getInstance.is_in_group(groupName):
#			array.append(getInstance)
#	return array
