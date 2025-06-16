extends Node
onready var oPlayerCount = Nodelist.list["oPlayerCount"]
onready var oNoiseDistance = Nodelist.list["oNoiseDistance"]
onready var oPlayerDistance = Nodelist.list["oPlayerDistance"]
onready var oPlayerPositioning = Nodelist.list["oPlayerPositioning"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oRandomPlayers = Nodelist.list["oRandomPlayers"]

const impenetrableColour = Color(0.0, 0.0, 0.0, 1.0)


func apply_pizza_symmetry(imageData):
	var w = imageData.get_width()
	var h = imageData.get_height()
	var centerX = w * 0.5
	var centerY = h * 0.5
	var playerCount = int(oPlayerCount.value)
	if playerCount < 2:
		return
	var angleStep = 2.0 * PI / playerCount
	var originalImage = imageData.duplicate()
	imageData.fill(Color(1,0,0,1))
	originalImage.lock()
	imageData.lock()
	for y in range(h):
		for x in range(w):
			var pixelAngle = atan2(y - centerY, x - centerX)
			if pixelAngle < 0:
				pixelAngle += 2.0 * PI
			var distance = Vector2(x - centerX, y - centerY).length()
			var sliceIndex = int(pixelAngle / angleStep) % playerCount
			var baseAngle = pixelAngle - (sliceIndex * angleStep)
			var baseX = centerX + cos(baseAngle) * distance
			var baseY = centerY + sin(baseAngle) * distance
			var baseXInt = int(baseX)
			var baseYInt = int(baseY)
			if baseXInt >= 0 and baseXInt < w and baseYInt >= 0 and baseYInt < h:
				var originalColor = originalImage.get_pixel(baseXInt, baseYInt)
				imageData.set_pixel(x, y, originalColor)
	originalImage.unlock()
	imageData.unlock()


func calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, angle):
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var maxTestRadius = min(mapSizeX, mapSizeY) * 0.45
	var borderWidth = oNoiseDistance.value
	if borderWidth <= 0.1:
		return (min(mapSizeX, mapSizeY) - 5) * 0.5
	imageData.lock()
	var availableRadius = 0.0
	for testRadius in range(5, int(maxTestRadius), 2):
		var testX = centerX + cos(angle) * testRadius
		var testY = centerY + sin(angle) * testRadius
		var testPos = Vector2(int(testX), int(testY))
		var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
		testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
		testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
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
			var angle = (i * 2.0 * PI) / totalTests
			var testX = centerX + cos(angle) * testRadius
			var testY = centerY + sin(angle) * testRadius
			var testPos = Vector2(int(testX), int(testY))
			var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if check_valid_player_position_unlocked(testPos, imageData):
				validPositions += 1
		if validPositions >= totalTests * 0.5:
			availableRadius = testRadius
	imageData.unlock()
	return availableRadius


func check_valid_player_position_unlocked(centerPos, imageData):
	var halfSize = int(oRandomPlayers.PLAYER_SIZE / 2)
	for dy in range(-halfSize, halfSize + 1):
		for dx in range(-halfSize, halfSize + 1):
			var x = centerPos.x + dx
			var y = centerPos.y + dy
			if x >= 0 and x < imageData.get_width() and y >= 0 and y < imageData.get_height():
				if imageData.get_pixel(x, y) == impenetrableColour:
					return false
			else:
				return false
	return true


func place_players_in_pizza_slices(mapSizeX, mapSizeY, imageData, playerPositions, occupiedCoordinates, playerManager):
	var playerCount = int(oPlayerCount.value)
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var radiusValue = oPlayerDistance.value
	var positioningValue = oPlayerPositioning.value
	var angleStep = 2.0 * PI / playerCount
	var randomRotation = rand_range(0, 2.0 * PI)
	var globalMaxRadius = (min(mapSizeX, mapSizeY) - 5) * 0.5
	print("Pizza slice placement: ", playerCount, " players, center(", centerX, ",", centerY, "), radius factor: ", radiusValue, ", positioning: ", positioningValue)
	for playerIndex in range(playerCount):
		var angle = playerIndex * angleStep + randomRotation
		var availableRadius = calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, angle)
		var effectiveMaxRadius = min(globalMaxRadius, availableRadius) if availableRadius > 0 else globalMaxRadius * 0.3
		var baseRadius = radiusValue * effectiveMaxRadius
		var baseX = centerX + cos(angle) * baseRadius
		var baseY = centerY + sin(angle) * baseRadius
		
		# Apply proportional tangential positioning for pizza slices
		if positioningValue != 0.5:
			# Calculate radial and perpendicular directions
			var radialDirectionX = cos(angle)
			var radialDirectionY = sin(angle)
			var perpendicularX = -radialDirectionY
			var perpendicularY = radialDirectionX
			
			# For pizza slices, the "distance from center line" is the angular distance
			# We'll use the radius as the reference distance for proportional scaling
			var referenceDistance = baseRadius
			
			# Convert positioning value to rotation angle scaling
			# 0.5 = no rotation (maintain original angular positions)
			# 0.0 = collapse angular spacing (all players converge to one side)
			# 1.0 = expand angular spacing (double the angular spread)
			var angularScaling = positioningValue * 2.0
			
			# Calculate tangential offset based on radius and angular scaling
			# This creates proportional movement where players farther from center move more
			var angularOffset = (angularScaling - 1.0) * (PI / (playerCount * 2.0))  # Base angular offset
			var tangentialOffset = referenceDistance * sin(angularOffset)
			
			baseX += perpendicularX * tangentialOffset
			baseY += perpendicularY * tangentialOffset
			
			print("Pizza player ", playerIndex + 1, " proportional tangential positioning: radius=", referenceDistance, ", angular scaling=", angularScaling, ", tangential offset=", tangentialOffset)
		
		var basePos = Vector2(int(baseX), int(baseY))
		var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
		basePos.x = clamp(basePos.x, playerMargin, mapSizeX - playerMargin - 1)
		basePos.y = clamp(basePos.y, playerMargin, mapSizeY - playerMargin - 1)
		var playerPlaced = false
		if playerManager.check_valid_player_position(basePos, imageData) and playerManager.check_coordinates_available(basePos):
			playerPositions.append(basePos)
			playerManager.mark_coordinates_as_occupied(basePos)
			playerPlaced = true
			print("Pizza player ", playerIndex + 1, " placed at: ", basePos)
		else:
			var fallbackPos = find_nearest_valid_position(basePos, mapSizeX, mapSizeY, imageData, playerManager)
			if fallbackPos != Vector2(-1, -1):
				playerPositions.append(fallbackPos)
				playerManager.mark_coordinates_as_occupied(fallbackPos)
				playerPlaced = true
				print("Pizza player ", playerIndex + 1, " placed at fallback: ", fallbackPos)
		if playerPlaced == false:
			var spiralPos = find_position_with_spiral_search(centerX, centerY, mapSizeX, mapSizeY, imageData, playerManager)
			if spiralPos != Vector2(-1, -1):
				playerPositions.append(spiralPos)
				playerManager.mark_coordinates_as_occupied(spiralPos)
				print("Pizza player ", playerIndex + 1, " placed via spiral: ", spiralPos)
			else:
				oMessage.quick("Not enough room to place player")
				print("Failed to place pizza player ", playerIndex + 1)


func find_position_with_spiral_search(centerX, centerY, mapSizeX, mapSizeY, imageData, playerManager):
	var maxSearchRadius = min(mapSizeX, mapSizeY) * 0.4
	var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
	for radius in range(5, int(maxSearchRadius), 3):
		var angleSteps = max(8, int(radius * 0.5))
		for i in range(angleSteps):
			var angle = (i * 2.0 * PI) / angleSteps
			var testX = centerX + cos(angle) * radius
			var testY = centerY + sin(angle) * radius
			var testPos = Vector2(int(testX), int(testY))
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if playerManager.check_valid_player_position(testPos, imageData) and playerManager.check_coordinates_available(testPos):
					return testPos
	return Vector2(-1, -1)


func check_valid_single_pixel_position(pos, imageData):
	imageData.lock()
	var result = imageData.get_pixel(pos.x, pos.y) != impenetrableColour
	imageData.unlock()
	return result


func find_nearest_valid_position(basePos, mapSizeX, mapSizeY, imageData, playerManager):
	var searchRadius = 20
	var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
	for radius in range(1, searchRadius):
		for angle in range(0, 16):
			var angleRad = (angle * 2.0 * PI) / 16.0
			var searchX = basePos.x + cos(angleRad) * radius
			var searchY = basePos.y + sin(angleRad) * radius
			var testPos = Vector2(int(searchX), int(searchY))
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if playerManager.check_valid_player_position(testPos, imageData) and playerManager.check_coordinates_available(testPos):
				return testPos
	return Vector2(-1, -1)


func find_nearest_valid_single_pixel_position(basePos, mapSizeX, mapSizeY, imageData, playerManager):
	var searchRadius = 20
	var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
	for radius in range(1, searchRadius):
		for angle in range(0, 16):
			var angleRad = (angle * 2.0 * PI) / 16.0
			var searchX = basePos.x + cos(angleRad) * radius
			var searchY = basePos.y + sin(angleRad) * radius
			var testPos = Vector2(int(searchX), int(searchY))
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if check_valid_single_pixel_position(testPos, imageData) and playerManager.check_coordinates_available(testPos):
				return testPos
	return Vector2(-1, -1)


func find_position_with_spiral_search_single_pixel(centerX, centerY, mapSizeX, mapSizeY, imageData, playerManager):
	var maxSearchRadius = min(mapSizeX, mapSizeY) * 0.4
	var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
	for radius in range(5, int(maxSearchRadius), 3):
		var angleSteps = max(8, int(radius * 0.5))
		for i in range(angleSteps):
			var angle = (i * 2.0 * PI) / angleSteps
			var testX = centerX + cos(angle) * radius
			var testY = centerY + sin(angle) * radius
			var testPos = Vector2(int(testX), int(testY))
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if check_valid_single_pixel_position(testPos, imageData) and playerManager.check_coordinates_available(testPos):
					return testPos
	return Vector2(-1, -1)


func find_valid_position_in_slice_with_deterministic_placement(centerAngle, angleRange, mapSizeX, mapSizeY, imageData, playerManager):
	var centerX = mapSizeX * 0.5
	var centerY = mapSizeY * 0.5
	var radiusValue = oPlayerDistance.value
	var availableRadius = calculate_available_radius_for_angle(mapSizeX, mapSizeY, imageData, centerAngle)
	var maxRadius = (min(mapSizeX, mapSizeY) - 5) * 0.5
	var effectiveMaxRadius = min(maxRadius, availableRadius) if availableRadius > 0 else maxRadius * 0.3
	var baseRadius = radiusValue * effectiveMaxRadius
	var testX = centerX + cos(centerAngle) * baseRadius
	var testY = centerY + sin(centerAngle) * baseRadius
	var testPos = Vector2(int(testX), int(testY))
	var playerMargin = int(oRandomPlayers.PLAYER_SIZE / 2) + 1
	testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
	testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
	if playerManager.check_valid_player_position(testPos, imageData) and playerManager.check_coordinates_available(testPos):
		return testPos
	return Vector2(-1, -1)


func get_pizza_slice_angles(playerCount, randomRotation = 0.0):
	var angles = []
	var angleStep = 2.0 * PI / playerCount
	for playerIndex in range(playerCount):
		angles.append(playerIndex * angleStep + randomRotation)
	return angles


func get_pizza_slice_positions(centerX, centerY, playerCount, radius, randomRotation = 0.0):
	var positions = []
	var angles = get_pizza_slice_angles(playerCount, randomRotation)
	for angle in angles:
		var x = centerX + cos(angle) * radius
		var y = centerY + sin(angle) * radius
		positions.append(Vector2(int(x), int(y)))
	return positions


 
