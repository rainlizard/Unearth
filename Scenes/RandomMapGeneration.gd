extends Node

onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oNoiseOctaves = Nodelist.list["oNoiseOctaves"]
onready var oNoisePeriod = Nodelist.list["oNoisePeriod"]
onready var oNoisePersistence = Nodelist.list["oNoisePersistence"]
onready var oNoiseLacunarity = Nodelist.list["oNoiseLacunarity"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oNewMapSymmetricalBorder = Nodelist.list["oNewMapSymmetricalBorder"]
onready var oNoiseDistance = Nodelist.list["oNoiseDistance"]
onready var oPlayerCount = Nodelist.list["oPlayerCount"]
onready var oPlayerRadius = Nodelist.list["oPlayerRadius"]
onready var oPlayerRandomness = Nodelist.list["oPlayerRandomness"]
onready var oPlacePlayersCheckBox = Nodelist.list["oPlacePlayersCheckBox"]
onready var oMessage = Nodelist.list["oMessage"]

var noise = OpenSimplexNoise.new()
var playerPositions = []
var occupiedCoordinates = {}
var algorithmType = 0

const earthColour = Color8(36,24,0)
const impenetrableColour = Color8(0,0,0)


func _ready():
	randomize()
	noise.seed = randi()


func overwrite_map_with_blank_values():
	for y in range(1, M.ySize-1):
		for x in range(1, M.xSize-1):
			oDataSlab.set_cell(x, y, Slabs.EARTH)


func overwrite_map_with_border_values(imageData):
	imageData.lock()
	for y in range(1, M.ySize-1):
		for x in range(1, M.xSize-1):
			var pixelColor = imageData.get_pixel(x,y)
			var isPlayerColor = false
			
			for i in range(Constants.ownerRoomCol.size()):
				if pixelColor == Constants.ownerRoomCol[i]:
					oDataSlab.set_cell(x, y, Slabs.CLAIMED_GROUND)
					isPlayerColor = true
					break
				elif pixelColor == Constants.ownerFloorCol[i]:
					oDataSlab.set_cell(x, y, Slabs.CLAIMED_GROUND)
					isPlayerColor = true
					break
			
			if isPlayerColor == false:
				match pixelColor:
					impenetrableColour: oDataSlab.set_cell(x, y, Slabs.ROCK)
					earthColour: oDataSlab.set_cell(x, y, Slabs.EARTH)
	imageData.unlock()
	place_player_dungeon_hearts()


func convert_player_number_to_index(playerNumber):
	match playerNumber:
		1: return 0
		2: return 1
		3: return 2
		4: return 3
		5: return 4
		6: return 6
		7: return 7
		8: return 8
		_: return playerNumber


func place_player_dungeon_hearts():
	for i in range(playerPositions.size()):
		var playerPos = playerPositions[i]
		var playerNumber = i + 1
		var playerIndex = convert_player_number_to_index(playerNumber)
		place_3x3_dungeon_heart(playerPos.x, playerPos.y, playerIndex)


func place_3x3_dungeon_heart(centerX, centerY, playerOwnership):
	var oDataOwnership = Nodelist.list["oDataOwnership"]
	var oInstances = Nodelist.list["oInstances"]
	var claimedGroundPositions = []
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var x = centerX + dx
			var y = centerY + dy
			if x >= 0 and x < M.xSize and y >= 0 and y < M.ySize:
				if abs(dx) <= 1 and abs(dy) <= 1:
					oDataSlab.set_cell(x, y, Slabs.DUNGEON_HEART)
				else:
					oDataSlab.set_cell(x, y, Slabs.CLAIMED_GROUND)
					claimedGroundPositions.append(Vector2(x, y))
				oDataOwnership.set_cellv_ownership(Vector2(x, y), playerOwnership)
	place_four_imps_on_claimed_ground(centerX, centerY, playerOwnership, oInstances)


func place_four_imps_on_claimed_ground(centerX, centerY, playerOwnership, oInstances):
	var impPositions = [
		Vector2(centerX - 2, centerY - 2),
		Vector2(centerX - 2, centerY + 2),
		Vector2(centerX + 2, centerY - 2),
		Vector2(centerX + 2, centerY + 2)
	]
	
	for slabPos in impPositions:
		var impSubtileX = (slabPos.x * 3) + 1.5
		var impSubtileY = (slabPos.y * 3) + 1.5
		var impPosition = Vector3(impSubtileX, impSubtileY, 1)
		oInstances.place_new_thing(Things.TYPE.CREATURE, 23, impPosition, playerOwnership)


func symmetry_supports_player_count(symmetryType, playerCount):
	match symmetryType:
		1, 2:
			return playerCount <= 2
		3, 4:
			return playerCount <= 2
		5:
			return playerCount <= 4
		_:
			return false


func get_5x5_coordinates(centerPos):
	var coordinates = []
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			coordinates.append(Vector2(centerPos.x + dx, centerPos.y + dy))
	return coordinates


func mark_coordinates_as_occupied(centerPos):
	var coordinates = get_5x5_coordinates(centerPos)
	for coord in coordinates:
		occupiedCoordinates[coord] = true


func check_coordinates_available(centerPos):
	var coordinates = get_5x5_coordinates(centerPos)
	for coord in coordinates:
		if occupiedCoordinates.has(coord):
			return false
	return true


func clear_occupied_coordinates():
	occupiedCoordinates.clear()


func calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, angle):
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var maxTestRadius = min(mapSizeX, mapSizeY) * 0.45
	var borderWidth = oNoiseDistance.value
	if borderWidth <= 0.1:
		return (min(mapSizeX, mapSizeY) - 8) * 0.5
	imageData.lock()
	var availableRadius = 0.0
	for testRadius in range(5, int(maxTestRadius), 2):
		var testX = int(centerX + cos(angle) * testRadius)
		var testY = int(centerY + sin(angle) * testRadius)
		var testPos = Vector2(testX, testY)
		testPos.x = clamp(testPos.x, 2, mapSizeX - 3)
		testPos.y = clamp(testPos.y, 2, mapSizeY - 3)
		if check_valid_player_position_unlocked(testPos, imageData):
			availableRadius = testRadius
	imageData.unlock()
	return availableRadius


func calculate_available_radius(mapSizeX, mapSizeY, imageData):
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var maxTestRadius = min(mapSizeX, mapSizeY) * 0.45
	var availableRadius = 0.0
	var borderWidth = oNoiseDistance.value
	if borderWidth <= 0.1:
		return (min(mapSizeX, mapSizeY) - 8) * 0.5
	imageData.lock()
	for testRadius in range(5, int(maxTestRadius), 2):
		var validPositions = 0
		var totalTests = 8
		for i in range(totalTests):
			var angle = (i * 2 * PI) / totalTests
			var testX = int(centerX + cos(angle) * testRadius)
			var testY = int(centerY + sin(angle) * testRadius)
			var testPos = Vector2(testX, testY)
			testPos.x = clamp(testPos.x, 2, mapSizeX - 3)
			testPos.y = clamp(testPos.y, 2, mapSizeY - 3)
			if check_valid_player_position_unlocked(testPos, imageData):
				validPositions += 1
		if validPositions >= totalTests * 0.5:
			availableRadius = testRadius
	imageData.unlock()
	return availableRadius


func check_valid_player_position_unlocked(centerPos, imageData):
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var x = centerPos.x + dx
			var y = centerPos.y + dy
			if x >= 0 and x < imageData.get_width() and y >= 0 and y < imageData.get_height():
				if imageData.get_pixel(x, y) == impenetrableColour:
					return false
	return true


func place_players_in_pizza_slices(mapSizeX, mapSizeY, imageData):
	var playerCount = int(oPlayerCount.value)
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var radiusValue = oPlayerRadius.value
	var randomnessValue = oPlayerRandomness.value
	var angleStep = 2 * PI / playerCount
	var randomRotation = rand_range(0, 2 * PI)
	var globalMaxRadius = (min(mapSizeX, mapSizeY) - 5) * 0.5
	for playerIndex in range(playerCount):
		var angle = playerIndex * angleStep + randomRotation
		var availableRadius = calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, angle)
		var effectiveMaxRadius
		if randomnessValue >= 0.5:
			effectiveMaxRadius = globalMaxRadius
		else:
			effectiveMaxRadius = min(globalMaxRadius, availableRadius) if availableRadius > 0 else globalMaxRadius * 0.3
		var baseRadius = radiusValue * effectiveMaxRadius
		var baseX = int(centerX + cos(angle) * baseRadius)
		var baseY = int(centerY + sin(angle) * baseRadius)
		var basePos = Vector2(baseX, baseY)
		basePos.x = clamp(basePos.x, 2, mapSizeX - 3)
		basePos.y = clamp(basePos.y, 2, mapSizeY - 3)
		var playerPlaced = false
		if randomnessValue == 0.0:
			if check_valid_player_position(basePos, imageData) and check_coordinates_available(basePos):
				playerPositions.append(basePos)
				mark_coordinates_as_occupied(basePos)
				playerPlaced = true
			else:
				var fallbackPos = find_nearest_valid_position(basePos, mapSizeX, mapSizeY, imageData)
				if fallbackPos != Vector2(-1, -1) and check_coordinates_available(fallbackPos):
					playerPositions.append(fallbackPos)
					mark_coordinates_as_occupied(fallbackPos)
					playerPlaced = true
				else:
					fallbackPos = find_valid_position_in_slice_with_randomness(angle, angleStep, randomnessValue, mapSizeX, mapSizeY, imageData)
					if fallbackPos != Vector2(-1, -1):
						playerPositions.append(fallbackPos)
						mark_coordinates_as_occupied(fallbackPos)
						playerPlaced = true
		else:
			var fallbackPos = find_valid_position_in_slice_with_randomness(angle, angleStep, randomnessValue, mapSizeX, mapSizeY, imageData)
			if fallbackPos != Vector2(-1, -1):
				playerPositions.append(fallbackPos)
				mark_coordinates_as_occupied(fallbackPos)
				playerPlaced = true
		if playerPlaced == false:
			var spiralPos = find_position_with_spiral_search(centerX, centerY, mapSizeX, mapSizeY, imageData)
			if spiralPos != Vector2(-1, -1):
				playerPositions.append(spiralPos)
				mark_coordinates_as_occupied(spiralPos)
			else:
				oMessage.quick("Not enough room to place player")


func find_position_with_spiral_search(centerX, centerY, mapSizeX, mapSizeY, imageData):
	var maxSearchRadius = min(mapSizeX, mapSizeY) * 0.4
	for radius in range(5, int(maxSearchRadius), 3):
		var angleSteps = max(8, int(radius * 0.5))
		for i in range(angleSteps):
			var angle = (i * 2 * PI) / angleSteps
			var testX = int(centerX + cos(angle) * radius)
			var testY = int(centerY + sin(angle) * radius)
			var testPos = Vector2(testX, testY)
			testPos.x = clamp(testPos.x, 2, mapSizeX - 3)
			testPos.y = clamp(testPos.y, 2, mapSizeY - 3)
			if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
				return testPos
	return Vector2(-1, -1)


func find_valid_position_in_slice_with_randomness(centerAngle, angleRange, randomnessValue, mapSizeX, mapSizeY, imageData):
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var radiusValue = oPlayerRadius.value
	var availableRadius = calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, centerAngle)
	var maxRadius = (min(mapSizeX, mapSizeY) - 5) * 0.5
	var effectiveMaxRadius
	if randomnessValue >= 0.5:
		effectiveMaxRadius = maxRadius
	else:
		effectiveMaxRadius = min(maxRadius, availableRadius) if availableRadius > 0 else maxRadius * 0.3
	var baseRadius = radiusValue * effectiveMaxRadius
	var attempts = 100
	for attempt in range(attempts):
		var testPos
		if randomnessValue == 0.0:
			var testX = int(centerX + cos(centerAngle) * baseRadius)
			var testY = int(centerY + sin(centerAngle) * baseRadius)
			testPos = Vector2(testX, testY)
		else:
			var angle = lerp(centerAngle, centerAngle + rand_range(-angleRange * 0.4, angleRange * 0.4), randomnessValue)
			var angleAvailableRadius = calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, angle)
			var angleEffectiveMaxRadius = min(maxRadius, angleAvailableRadius) if angleAvailableRadius > 0 else maxRadius * 0.3
			var randomRadius = rand_range(0, maxRadius)
			var radius = lerp(baseRadius, randomRadius, randomnessValue)
			var testX = int(centerX + cos(angle) * radius)
			var testY = int(centerY + sin(angle) * radius)
			testPos = Vector2(testX, testY)
		testPos.x = clamp(testPos.x, 2, mapSizeX - 3)
		testPos.y = clamp(testPos.y, 2, mapSizeY - 3)
		if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
			return testPos
	return Vector2(-1, -1)


func place_players_automatically(imageData):
	playerPositions.clear()
	clear_occupied_coordinates()
	if oPlacePlayersCheckBox.pressed == false:
		return
	var mapSizeX = oXSizeLine.text.to_int()
	var mapSizeY = oYSizeLine.text.to_int()
	place_players_in_pizza_slices(mapSizeX, mapSizeY, imageData)


func place_players_with_symmetry(mapSizeX, mapSizeY, imageData):
	var margin = 7
	var maxAttempts = 100
	var playerCount = int(oPlayerCount.value)
	var symmetryType = oNewMapSymmetricalBorder.selected
	if symmetry_supports_player_count(symmetryType, playerCount) == false:
		place_players_randomly(mapSizeX, mapSizeY, imageData)
		return
	var attempts = 0
	var successfulPlacement = false
	while attempts < maxAttempts and successfulPlacement == false:
		playerPositions.clear()
		clear_occupied_coordinates()
		var randomX = rand_range(margin + 2, mapSizeX - margin - 3)
		var randomY = rand_range(margin + 2, mapSizeY - margin - 3)
		var basePosition = Vector2(int(randomX), int(randomY))
		if basePosition.x > 1 and basePosition.x < mapSizeX - 2 and basePosition.y > 1 and basePosition.y < mapSizeY - 2:
			if check_valid_player_position(basePosition, imageData) and check_coordinates_available(basePosition):
				var mirroredPositions = get_mirrored_positions(basePosition, mapSizeX, mapSizeY)
				var positionsToPlace = min(playerCount, mirroredPositions.size())
				var validPositions = []
				for i in range(positionsToPlace):
					var pos = mirroredPositions[i]
					if pos.x > 1 and pos.x < mapSizeX - 2 and pos.y > 1 and pos.y < mapSizeY - 2:
						if check_valid_player_position(pos, imageData) and check_coordinates_available(pos):
							validPositions.append(pos)
				if validPositions.size() >= playerCount:
					for i in range(playerCount):
						var pos = validPositions[i]
						playerPositions.append(pos)
						mark_coordinates_as_occupied(pos)
					successfulPlacement = true
		attempts += 1
	if successfulPlacement == false:
		place_players_randomly(mapSizeX, mapSizeY, imageData)


func get_mirrored_positions(basePos, mapSizeX, mapSizeY):
	var positions = []
	var halfX = (mapSizeX - 1) * 0.5
	var halfY = (mapSizeY - 1) * 0.5
	
	match oNewMapSymmetricalBorder.selected:
		1, 2:
			positions.append(basePos)
			var mirroredY = int(halfY * 2 - basePos.y)
			if mirroredY != basePos.y:
				positions.append(Vector2(basePos.x, mirroredY))
		3, 4:
			positions.append(basePos)
			var mirroredX = int(halfX * 2 - basePos.x)
			if mirroredX != basePos.x:
				positions.append(Vector2(mirroredX, basePos.y))
		5:
			positions.append(basePos)
			var mirroredX = int(halfX * 2 - basePos.x)
			var mirroredY = int(halfY * 2 - basePos.y)
			
			if mirroredX != basePos.x:
				positions.append(Vector2(mirroredX, basePos.y))
			if mirroredY != basePos.y:
				positions.append(Vector2(basePos.x, mirroredY))
			if mirroredX != basePos.x and mirroredY != basePos.y:
				positions.append(Vector2(mirroredX, mirroredY))
	
	return positions


func place_players_randomly(mapSizeX, mapSizeY, imageData):
	var maxAttempts = 100
	var margin = 7
	var playerCount = int(oPlayerCount.value)
	for playerIndex in range(playerCount):
		var attempts = 0
		var validPositionFound = false
		while attempts < maxAttempts and validPositionFound == false:
			var randomX = rand_range(margin + 2, mapSizeX - margin - 3)
			var randomY = rand_range(margin + 2, mapSizeY - margin - 3)
			var testPos = Vector2(int(randomX), int(randomY))
			if testPos.x > 1 and testPos.x < mapSizeX - 2 and testPos.y > 1 and testPos.y < mapSizeY - 2:
				if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
					playerPositions.append(testPos)
					mark_coordinates_as_occupied(testPos)
					validPositionFound = true
			attempts += 1
		if validPositionFound == false:
			var fallbackPos = find_valid_position_without_overlap(mapSizeX, mapSizeY, imageData)
			if fallbackPos != Vector2(-1, -1):
				playerPositions.append(fallbackPos)
				mark_coordinates_as_occupied(fallbackPos)
			else:
				oMessage.quick("Not enough room to place player")


func check_valid_player_position(centerPos, imageData):
	imageData.lock()
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var x = centerPos.x + dx
			var y = centerPos.y + dy
			if x >= 0 and x < imageData.get_width() and y >= 0 and y < imageData.get_height():
				if imageData.get_pixel(x, y) == impenetrableColour:
					imageData.unlock()
					return false
	imageData.unlock()
	return true


func find_nearest_valid_position(originalPos, mapSizeX, mapSizeY, imageData):
	var searchRadius = 1
	var maxSearchRadius = min(mapSizeX, mapSizeY) / 2
	while searchRadius <= maxSearchRadius:
		for dy in range(-searchRadius, searchRadius + 1):
			for dx in range(-searchRadius, searchRadius + 1):
				if abs(dx) == searchRadius or abs(dy) == searchRadius:
					var testPos = Vector2(originalPos.x + dx, originalPos.y + dy)
					if testPos.x > 1 and testPos.x < mapSizeX - 2 and testPos.y > 1 and testPos.y < mapSizeY - 2:
						if check_valid_player_position(testPos, imageData):
							return testPos
		searchRadius += 1
	var fallbackPos = find_any_valid_position(mapSizeX, mapSizeY, imageData)
	return fallbackPos


func find_any_valid_position(mapSizeX, mapSizeY, imageData):
	for y in range(2, mapSizeY - 2):
		for x in range(2, mapSizeX - 2):
			var testPos = Vector2(x, y)
			if check_valid_player_position(testPos, imageData):
				return testPos
	return Vector2(-1, -1)


func find_valid_position_without_overlap(mapSizeX, mapSizeY, imageData):
	for y in range(2, mapSizeY - 2):
		for x in range(2, mapSizeX - 2):
			var testPos = Vector2(x, y)
			if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
				return testPos
	return Vector2(-1, -1)


func draw_players_in_preview(imageData):
	if playerPositions.size() == 0:
		return
	
	imageData.lock()
	for i in range(playerPositions.size()):
		var playerPos = playerPositions[i]
		var playerNumber = i + 1
		var playerIndex = convert_player_number_to_index(playerNumber)
		var dungeonHeartColor = Constants.ownerRoomCol[playerIndex]
		var claimedFloorColor = Constants.ownerFloorCol[playerIndex]
		
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var x = playerPos.x + dx
				var y = playerPos.y + dy
				if x >= 0 and x < imageData.get_width() and y >= 0 and y < imageData.get_height():
					if abs(dx) <= 1 and abs(dy) <= 1:
						imageData.set_pixel(x, y, dungeonHeartColor)
					else:
						imageData.set_pixel(x, y, claimedFloorColor)
	imageData.unlock()


func update_border_image_with_noise(imageData, textureData):
	var NOISECODETIME = OS.get_ticks_msec()
	var borderDist = oNoiseDistance.value
	noise.period = (oNoisePeriod.max_value - oNoisePeriod.value) + (0.01)
	noise.persistence = (oNoisePersistence.max_value - oNoisePersistence.value)
	noise.lacunarity = oNoiseLacunarity.value
	noise.octaves = oNoiseOctaves.value
	
	var fullMapSize = Vector2(oXSizeLine.text.to_int()-1, oYSizeLine.text.to_int()-1)
	var halfMapSize = Vector2(fullMapSize.x * 0.5, fullMapSize.y * 0.5)
	
	var floodFillTileMap = TileMap.new()
	
	var aspectRatio = Vector2()
	if fullMapSize.x < fullMapSize.y:
		aspectRatio.x = max(fullMapSize.x,1.0) / max(fullMapSize.y,1.0)
		aspectRatio.y = 1.0
	else:
		aspectRatio.x = 1.0
		aspectRatio.y = max(fullMapSize.y,1.0) / max(fullMapSize.x,1.0)
	
	var edgeDist = Vector2()
	match algorithmType:
		0:
			for x in range(1, fullMapSize.x):
				for y in range(1, fullMapSize.y):
					edgeDist.x = (abs(x-halfMapSize.x) / halfMapSize.x) * borderDist
					edgeDist.y = (abs(y-halfMapSize.y) / halfMapSize.y) * borderDist
					var n = 1.0-abs(noise.get_noise_2d( (x/fullMapSize.x)*aspectRatio.x, (y/fullMapSize.y)*aspectRatio.y ))
					if n > edgeDist.x and n > edgeDist.y:
						floodFillTileMap.set_cell(x,y,1)
		1:
			for x in range(1, fullMapSize.x):
				for y in range(1, fullMapSize.y):
					edgeDist.x = (abs(x-halfMapSize.x) / halfMapSize.x) * borderDist
					edgeDist.y = (abs(y-halfMapSize.y) / halfMapSize.y) * borderDist
					var n = 1.0-noise.get_noise_2d( (x/fullMapSize.x)*aspectRatio.x, (y/fullMapSize.y)*aspectRatio.y )
					if n > edgeDist.x and n > edgeDist.y:
						floodFillTileMap.set_cell(x,y,1)
	
	var coordsToCheck = [Vector2(halfMapSize.x,halfMapSize.y)]
	
	imageData.fill(impenetrableColour)
	imageData.lock()
	
	while coordsToCheck.size() > 0:
		var coord = coordsToCheck.pop_back()
		if floodFillTileMap.get_cellv(coord) == 1:
			floodFillTileMap.set_cellv(coord, 0)
			imageData.set_pixelv(coord, earthColour)
			coordsToCheck.append(coord + Vector2(0,1))
			coordsToCheck.append(coord + Vector2(0,-1))
			coordsToCheck.append(coord + Vector2(1,0))
			coordsToCheck.append(coord + Vector2(-1,0))
	
	imageData.unlock()
	
	print('Border image time: ' + str(OS.get_ticks_msec() - NOISECODETIME) + 'ms')


func update_border_image_with_blank(imageData, textureData):
	imageData.fill(earthColour)
	imageData.lock()
	
	var fullMapSize = Vector2(oXSizeLine.text.to_int(), oYSizeLine.text.to_int())
	
	for x in fullMapSize.x:
		for y in fullMapSize.y:
			if x == 0 or x == fullMapSize.x-1 or y == 0 or y == fullMapSize.y-1:
				imageData.set_pixel(x,y, impenetrableColour)
	imageData.unlock()
