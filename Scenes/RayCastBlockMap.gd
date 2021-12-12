extends Spatial
onready var oPlayer = Nodelist.list["oPlayer"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oGame3D = Nodelist.list["oGame3D"]

var reach = 100
var blockChecks = {}
var blockCheckerScene = preload("res://Scenes/BlockCheck.tscn")
#var basicDir = [Vector3(0,0,-1), Vector3(0,0,1), Vector3(1,0,0), Vector3(-1,0,0), Vector3(0,1,0), Vector3(0,-1,0)] # N,S,E,W,T,B

#var CODETIME_START = OS.get_ticks_usec() # USEC - MICRO SECONDS
#print('RayCastBlockMap single check time: '+str(OS.get_ticks_usec()-CODETIME_START)+' MICRO seconds')

#var countTime

func start(startPoint, endPoint):
	#countTime = 0
	if oGenerateTerrain.blockMap.size() == 0: return
	var raycast = Vector3()
	var remainingVector = startPoint-endPoint
	var increment = remainingVector.normalized()
	
	#print(axisArray)
	var abcKeys = blockChecks.keys()
	for i in abcKeys.size():
		blockChecks[abcKeys[i]].markForCulling = true
	
	var raycastData = {}
	
	var previousCheck
	
	while true:
		var newCheck = (startPoint+raycast).floor()
		if previousCheck != newCheck:
			previousCheck = newCheck
			place_area_check(newCheck)
		raycastData = oPlayer.get_world().get_direct_space_state().intersect_ray(startPoint, startPoint+raycast, [], 524288, true, true) #This line is cheap, the performance cost comes from placing the areaChecks
		if raycastData:
			break
		
		raycast += increment
		if remainingVector.length() <= increment.length():
			break
		else:
			remainingVector -= increment
	
	for i in abcKeys.size():
		var id = blockChecks[abcKeys[i]]
		if id.markForCulling == true:
			blockChecks.erase(id.translation)
			id.queue_free()
	
	#print('countTime: ' + str(countTime) )
	return raycastData

func place_area_check(raypos):
	
	#var CODETIME_START = OS.get_ticks_usec() # USEC - MICRO SECONDS
	# spawn blockcheck in directions AND on original position
	for vecAxis in [Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,1), Vector3(1,0,0), Vector3(-1,0,0), Vector3(0,1,0), Vector3(0,-1,0)]:
		var superPos = raypos+vecAxis
		if oGenerateTerrain.get_block(superPos) != oGenerateTerrain.EMPTY:
			if blockChecks.has(superPos) == false:
				
				var id = blockCheckerScene.instance()
				id.translation = superPos
				oGame3D.add_child(id)
				
				blockChecks[superPos] = id #adds an entry to the dictionary
			else:
				blockChecks[superPos].markForCulling = false
	#countTime += OS.get_ticks_usec()-CODETIME_START


#	var axisArray = []
#	axisArray.append(Vector3(ceil(abs(increment.x)) * sign(increment.x),0,0))
#	axisArray.append(Vector3(0,ceil(abs(increment.y)) * sign(increment.y),0))
#	axisArray.append(Vector3(0,0,ceil(abs(increment.z)) * sign(increment.z)))

#func placeAreaCheck(raypos):
#	var superPos = raypos #check original position first
#	for i in 7: # spawn blockcheck in directions AND on original position
#		if oGenerateTerrain.getBlock(superPos) != oGenerateTerrain.EMPTY:
#			if blockChecks.has(superPos) == false:
#
#				var id = blockCheckerScene.instance()
#				id.translation = superPos
#				oGame3D.add_child(id)
#
#				blockChecks[superPos] = id
#			else:
#				blockChecks[superPos].markForCulling = false
#		superPos = raypos+basicDir[i-1] #1-6 becomes 0-5

#func start(startPosition, travelVector):
#	if oGenerateTerrain.blockMap.size() == 0: return
#
#	var perfectPosition = startPosition
#	var blockPosition = perfectPosition.floor()
#
#	for i in reach:
#		perfectPosition -= travelVector
#
#		var moveGridVector = perfectPosition.floor()-blockPosition
#
#		blockPosition.x += moveGridVector.x
#		if checkCollision(blockPosition) == true: return blockPosition
#		blockPosition.y += moveGridVector.y
#		if checkCollision(blockPosition) == true: return blockPosition
#		blockPosition.z += moveGridVector.z
#		if checkCollision(blockPosition) == true: return blockPosition
#
#	return null
#
	
#	for i in 10:
#		yield(get_tree(),'idle_frame')

#func raycastBlockmap(startPoint, endPoint):
#	var raycast = Vector3()
#	var remainingVector = endPoint-startPoint
#	var increment = remainingVector.normalized()
#
#	var raycastData = {}
#
#	var previousCheck
#	while true:
#		var newCheck = (startPoint+raycast).floor()
#		if previousCheck != newCheck:
#			previousCheck = newCheck
#			placeAreaCheck(newCheck)
#
#		raycastData = oPlayer.get_world().get_direct_space_state().intersect_ray(startPoint, startPoint+raycast, [], 4, true, true) #This line is cheap, the performance cost comes from placing the areaChecks
#		if raycastData:
#			break
#
#		raycast += increment
#		if remainingVector.length() <= increment.length():
#			break
#		else:
#			remainingVector -= increment
#
#	return raycastData
