extends Node2D
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]

var thingScn = preload("res://Scenes/ThingInstance.tscn")
var actionPointScn = preload("res://Scenes/ActionPointInstance.tscn")
var lightScn = preload("res://Scenes/LightInstance.tscn")


func place_new_light(newThingType, newSubtype, newPosition, newOwnership):
	var id = lightScn.instance()
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.locationZ = newPosition.z
	id.lightRange = oPlacingSettings.lightRange
	id.lightIntensity = oPlacingSettings.lightIntensity
	id.data3 = 0
	id.data4 = 0
	id.data5 = 0
	id.data6 = 0
	id.data7 = 0
	id.data8 = 0
	id.data9 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18 = 255
	id.data19 = 255
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

func place_new_thing(newThingType, newSubtype, newPosition, newOwnership): # Placed by hand
	var CODETIME_START = OS.get_ticks_msec()
	var slabID = oDataSlab.get_cell(newPosition.x/3,newPosition.y/3)
	var id = thingScn.instance()
	
	id.data9 = 0
	id.data10 = 0
	id.data11_12 = 0
	id.data13 = 0
	id.data14 = 0
	id.data15 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18 = 0
	id.data19 = 0
	id.data20 = 0
	
	id.locationX = newPosition.x
	id.locationY = newPosition.y
	id.locationZ = newPosition.z
	id.thingType = newThingType
	id.subtype = newSubtype
	id.ownership = newOwnership
	
	match id.thingType:
		Things.TYPE.OBJECT:
			
			if id.subtype == 49: # Hero Gate
				id.herogateNumber = get_free_hero_gate_number() #originalInstance.herogateNumber
				#Set all attached to tile: None, except for these: Torch, Heart, Unlit Torch, all Eggs and Chicken, Spinning Key, Spinning Key 2, all Lairs (don't forget Orc Lair!), Spinning Coin, and Effects.
			elif id.subtype == 133: # Mysterious Box
				id.boxNumber = oPlacingSettings.boxNumber
			elif id.subtype in [2,7]: # Torch and Unlit Torch
				if Slabs.data[oDataSlab.get_cell(floor((id.locationX+1)/3),floor(id.locationY/3))][Slabs.IS_SOLID] == true : id.locationX += 0.25
				if Slabs.data[oDataSlab.get_cell(floor((id.locationX-1)/3),floor(id.locationY/3))][Slabs.IS_SOLID] == true : id.locationX -= 0.25
				if Slabs.data[oDataSlab.get_cell(floor(id.locationX/3),floor((id.locationY+1)/3))][Slabs.IS_SOLID] == true : id.locationY += 0.25
				if Slabs.data[oDataSlab.get_cell(floor(id.locationX/3),floor((id.locationY-1)/3))][Slabs.IS_SOLID] == true : id.locationY -= 0.25
				update_stray_torch_height(id)
			# Whether the object is "Attached to tile" or not.
#			if id.subtype in [2, 5, 7, 9,10,40,41,42, 50, 57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85, 126, 128]:
#				id.sensitiveTile = (floor(newPosition.y/3) * 85) + floor(newPosition.x/3)
#			else:
			id.sensitiveTile = 65535 # "None"
			
		Things.TYPE.CREATURE:
			id.creatureLevel = oPlacingSettings.creatureLevel
			id.index = get_free_index_number()
		Things.TYPE.EFFECT:
			id.effectRange = oPlacingSettings.effectRange
			id.sensitiveTile = (floor(newPosition.y/3) * 85) + floor(newPosition.x/3)
		Things.TYPE.TRAP:
			id.index = get_free_index_number()
		Things.TYPE.DOOR:
			id.index = get_free_index_number()
			id.doorLocked = oPlacingSettings.doorLocked
			if newSubtype == 0: id.subtype = 1 #Depending on whether it was placed via autoslab or a hand placed Thing object.
			match slabID:
				Slabs.WOODEN_DOOR_1:
					id.subtype = 1
					id.doorOrientation = 1
				Slabs.WOODEN_DOOR_2:
					id.subtype = 1
					id.doorOrientation = 0
				Slabs.BRACED_DOOR_1:
					id.subtype = 2
					id.doorOrientation = 1
				Slabs.BRACED_DOOR_2:
					id.subtype = 2
					id.doorOrientation = 0
				Slabs.IRON_DOOR_1:
					id.subtype = 3
					id.doorOrientation = 1
				Slabs.IRON_DOOR_2:
					id.subtype = 3
					id.doorOrientation = 0
				Slabs.MAGIC_DOOR_1:
					id.subtype = 4
					id.doorOrientation = 1
				Slabs.MAGIC_DOOR_2:
					id.subtype = 4
					id.doorOrientation = 0
	
	add_child(id)
	print('Thing placed in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	# Warnings
	if id.thingType == Things.TYPE.OBJECT:
		if id.subtype == 10:
			if slabID != Slabs.HATCHERY:
				oMessage.big("Warning","Chicken won't appear unless placed inside a Hatchery. Place an Egg instead.")
		if id.subtype in [52,53,54,55,56]: # Treasury Gold
			if slabID != Slabs.TREASURE_ROOM:
				oMessage.big("Warning","Treasury Gold won't appear unless placed inside a Treasure Room.")
			
			# Place on center of slab. Won't be functional otherwise.
			var locX = (floor( floor(id.locationX) / 3 ) * 3) + 1.5
			var locY = (floor( floor(id.locationY) / 3 ) * 3) + 1.5
			
			# Move away while I check location
			id.locationX = -32767
			id.locationY = -32767
			var goldID = get_node_on_subtile("TreasuryGold", locX, locY)
			if is_instance_valid(goldID) == true:
				goldID.queue_free()
			id.locationX = locX
			id.locationY = locY

func spawn(xSlab, ySlab, slabID, ownership, subtile, tngObj): # Spawns from tng file
	var id = thingScn.instance()
	id.data9 = 0
	id.data10 = 0
	id.data11_12 = 0
	id.data13 = 0
	id.data14 = 0
	id.data15 = 0
	id.data16 = 0
	id.data17 = 0
	id.data18 = 0
	id.data19 = 0
	id.data20 = 0
	
	var subtileY = subtile/3
	var subtileX = subtile-(subtileY*3)
	id.locationX = ((xSlab*3) + subtileX) + tngObj[3]
	id.locationY = ((ySlab*3) + subtileY) + tngObj[4]
	id.locationZ = tngObj[5]
	id.sensitiveTile = (ySlab * 85) + xSlab
	id.thingType = tngObj[6]
	id.subtype = tngObj[7]
	id.ownership = ownership
	
	if id.thingType == Things.TYPE.EFFECT:
		id.effectRange = tngObj[8]
	
	if slabID == Slabs.GUARD_POST:
		if tngObj[7] == 115: # Guard Flag (Red)
			match ownership:
				0: pass # Red
				1: id.subtype = 116 # Blue
				2: id.subtype = 117 # Green
				3: id.subtype = 118 # Yellow
				4: id.queue_free() # White
				5: id.subtype = 119 # None
	elif slabID == Slabs.DUNGEON_HEART:
		if tngObj[7] == 111: # Heart Flame (Red)
			match ownership:
				0: pass # Red
				1: id.subtype = 120 # Blue
				2: id.subtype = 121 # Green
				3: id.subtype = 122 # Yellow
				4: id.queue_free() # White
				5: id.queue_free() # None
	
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


func update_height_of_things_on_slab(xSlab, ySlab):
#	var pos = Vector2(xSlab*96,ySlab*96)
#	var arrayColliders = collision_rectangle_list(pos, pos+Vector2(96,96), "Thing")
#
#	for id in arrayColliders:
	var checkSlabLocationGroup = "slab_location_group_"+str(xSlab)+'_'+str(ySlab)
	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
		if id.is_in_group("Thing") and id.sensitiveTile == 65535: # None. Not attached to any slab.
			var xSubtile = floor(id.locationX)
			var ySubtile = floor(id.locationY)
			var detectTerrainHeight = oDataClm.height[oDataClmPos.get_cell(xSubtile,ySubtile)]
			id.locationZ = detectTerrainHeight
			
			if id.subtype in [2,7]:
				update_stray_torch_height(id)

func update_stray_torch_height(id):
	id.locationZ = 2.875

func delete_all_on_slab(xSlab, ySlab, arrayOfGroupNameStrings):
	var checkSlabLocationGroup = "slab_location_group_"+str(xSlab)+'_'+str(ySlab)
	for id in get_tree().get_nodes_in_group(checkSlabLocationGroup):
		for groupName in arrayOfGroupNameStrings:
			if id.is_in_group(groupName):
				id.queue_free()
	
#	for groupName in arrayOfGroupNameStrings:
#		var pos = Vector2(xSlab*96,ySlab*96)
#		var arrayColliders = collision_rectangle_list(pos, pos+Vector2(96,96), groupName)
#		for id in arrayColliders:
#			id.queue_free()



func get_node_on_subtile(nodegroup, xSubtile, ySubtile):
	for id in get_tree().get_nodes_in_group(nodegroup):
		if id.is_queued_for_deletion() == false:
			if floor(id.locationX) == floor(xSubtile) and floor(id.locationY) == floor(ySubtile):
				return id
	return null

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

func delete_attached_objects_on_slab(xSlab, ySlab):
	
	# Figure out how to make this faster
	# Objects like torches are placed off the slab, their sensitiveTile needs to be checked.
	
	var groupName = 'attachedtotile_'+str((ySlab*85)+xSlab)
	if groupName == "attachedtotile_0": return # This fixes an edge case issue with Spinning Keys being destroyed if you click the top left corner
	for id in get_tree().get_nodes_in_group(groupName):
		#id.position = Vector2(-32767,-32767)
		#id.remove_child()
		id.queue_free()

#			if oDkTng.tngObject[idx][8] != 0:
#				var id = oDkTng.tngObject[idx][7]
#				print(Things.DATA_OBJECT[id][Things.NAME] + ". Unknown value: " + str(oDkTng.tngObject[idx][8]))

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
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 49: # Hero gate
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
		if id.thingType == Things.TYPE.OBJECT and id.subtype == 49: # Hero gate
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
