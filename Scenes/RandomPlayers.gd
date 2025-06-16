extends Node

onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oNewMapSymmetricalBorder = Nodelist.list["oNewMapSymmetricalBorder"]
onready var oPlayerCount = Nodelist.list["oPlayerCount"]
onready var oPlacePlayersCheckBox = Nodelist.list["oPlacePlayersCheckBox"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oRandomPlayersPizza = Nodelist.list["oRandomPlayersPizza"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oPlayerDistance = Nodelist.list["oPlayerDistance"]
onready var oPlayerPositioning = Nodelist.list["oPlayerPositioning"]
onready var oNoiseDistance = Nodelist.list["oNoiseDistance"]
onready var oLinearDistanceCheckBox = Nodelist.list["oLinearDistanceCheckBox"]

var playerPositions = []
var occupiedCoordinates = {}

const PLAYER_SIZE = 5
const earthColour = Color(36.0/255.0, 24.0/255.0, 0.0/255.0, 1.0)
const impenetrableColour = Color(0.0, 0.0, 0.0, 1.0)


func convert_player_number_to_index(playerNumber):
	match playerNumber:
		1: return 0
		2: return 1
		3: return 2
		4: return 3
		5: return 4 # Intentionally skip player 5
		6: return 6
		7: return 7
		8: return 8
		_: return 8

func mark_coordinates_as_occupied(centerPos):
	var halfSize = int(PLAYER_SIZE / 2)
	for dy in range(-halfSize, halfSize + 1):
		for dx in range(-halfSize, halfSize + 1):
			var occupiedPos = Vector2(centerPos.x + dx, centerPos.y + dy)
			occupiedCoordinates[occupiedPos] = true


func check_coordinates_available(centerPos):
	var halfSize = int(PLAYER_SIZE / 2)
	for dy in range(-halfSize, halfSize + 1):
		for dx in range(-halfSize, halfSize + 1):
			var checkPos = Vector2(centerPos.x + dx, centerPos.y + dy)
			if occupiedCoordinates.has(checkPos):
				return false
	return true


func clear_occupied_coordinates():
	occupiedCoordinates.clear()


func place_players_automatically(imageData):
	print("place_players_automatically called")
	print("DEBUG: Multiple player placement in sub-sections - mirroring handled by apply_symmetry()")
	playerPositions.clear()
	clear_occupied_coordinates()
	if oPlacePlayersCheckBox.pressed == false:
		print("Place players checkbox is not pressed - exiting")
		return
	var mapSizeX = oXSizeLine.text.to_float()
	var mapSizeY = oYSizeLine.text.to_float()
	var totalPlayerCount = int(oPlayerCount.value)
	var symmetryType = oNewMapSymmetricalBorder.selected
	
	print("Map size: ", mapSizeX, "x", mapSizeY, ", Total players: ", totalPlayerCount, ", Symmetry type: ", symmetryType)
	
	# Handle pizza symmetry and no symmetry with ring/radius formation
	if symmetryType == 6 or symmetryType == 0:
		var placementType = "pizza slice" if symmetryType == 6 else "ring/radius"
		print("Using ", placementType, " placement for symmetry type ", symmetryType, " - placing directly in all positions")
		oRandomPlayersPizza.place_players_in_pizza_slices(mapSizeX, mapSizeY, imageData, playerPositions, occupiedCoordinates, self)
		return
	
	var playersToPlace = totalPlayerCount / 2
	
	# Special case for four-way symmetry - only place 1 player in first quadrant
	if symmetryType == 5:
		playersToPlace = totalPlayerCount / 4
	print("Placing in first section: ", playersToPlace, " players")
	
	# Early return if no players to place
	if playersToPlace <= 0:
		print("No players to place in first section")
		return
	
	# Define the first section based on symmetry type
	var sectionStartX = 0.0
	var sectionStartY = 0.0
	var sectionWidth = 0.0
	var sectionHeight = 0.0
	
	match symmetryType:
		1, 2: # Vertical symmetry (normal and flipped)
			# First section = top half of entire map
			sectionStartX = 0.0
			sectionStartY = 0.0
			sectionWidth = mapSizeX
			sectionHeight = mapSizeY * 0.5
		3, 4: # Horizontal symmetry (normal and flipped)
			# First section = left half of entire map
			sectionStartX = 0.0
			sectionStartY = 0.0
			sectionWidth = mapSizeX * 0.5
			sectionHeight = mapSizeY
		5: # Four-way symmetry
			# First section = top-left quadrant
			sectionStartX = 0.0
			sectionStartY = 0.0
			sectionWidth = mapSizeX * 0.5
			sectionHeight = mapSizeY * 0.5
		6: # Pizza symmetry
			# First section = first pizza slice (simplified to top-right quadrant for now)
			sectionStartX = mapSizeX * 0.5
			sectionStartY = 0.0
			sectionWidth = mapSizeX * 0.5
			sectionHeight = mapSizeY * 0.5
		_: # No symmetry or other
			# First section = entire map
			sectionStartX = 0.0
			sectionStartY = 0.0
			sectionWidth = mapSizeX
			sectionHeight = mapSizeY
	
	# Divide the first section into sub-sections for each player
	# Arrange players in a single row oriented correctly for the symmetry type
	var subSectionsPerRow = 1
	var subSectionsPerCol = 1
	
	match symmetryType:
		1, 2: # Vertical symmetry - arrange players in horizontal row
			subSectionsPerRow = playersToPlace
			subSectionsPerCol = 1
		3, 4: # Horizontal symmetry - arrange players in vertical row
			subSectionsPerRow = 1
			subSectionsPerCol = playersToPlace
		5: # Four-way symmetry - place single player in center of quadrant
			subSectionsPerRow = 1
			subSectionsPerCol = 1
		6: # Pizza symmetry - arrange in a small grid
			subSectionsPerRow = max(int(ceil(sqrt(playersToPlace))), 1)
			subSectionsPerCol = max(int(ceil(float(playersToPlace) / float(subSectionsPerRow))), 1)
		_: # No symmetry - use square grid
			subSectionsPerRow = max(int(ceil(sqrt(playersToPlace))), 1)
			subSectionsPerCol = max(int(ceil(float(playersToPlace) / float(subSectionsPerRow))), 1)
	
	var subSectionWidth = sectionWidth / max(subSectionsPerRow, 1)
	var subSectionHeight = sectionHeight / max(subSectionsPerCol, 1)
	
	print("First section: start(", sectionStartX, ",", sectionStartY, ") size(", sectionWidth, "x", sectionHeight, ")")
	print("Sub-sections: ", subSectionsPerRow, " per row, ", subSectionsPerCol, " per col")
	print("Sub-section size: ", subSectionWidth, "x", subSectionHeight)
	
	# Place each player in their designated sub-section
	for i in range(playersToPlace):
		var row = i / subSectionsPerRow
		var col = i % subSectionsPerRow
		var subSectionCenterX = sectionStartX + (col * subSectionWidth) + (subSectionWidth / 2.0)
		var subSectionCenterY = sectionStartY + (row * subSectionHeight) + (subSectionHeight / 2.0)
		var targetPos = calculate_distance_adjusted_position(subSectionCenterX, subSectionCenterY, subSectionWidth, subSectionHeight, mapSizeX, mapSizeY, symmetryType, imageData)
		
		print("Placing player ", i + 1, " distance=", oPlayerDistance.value)
		var playerPos = find_position_in_subsection(targetPos, subSectionWidth, subSectionHeight, imageData)
		if playerPos != Vector2(-1, -1):
			playerPositions.append(playerPos)
			mark_coordinates_as_occupied(playerPos)
			print("Player ", i + 1, " placed at: ", playerPos, " (sub-section row:", row, " col:", col, ")")
		else:
			print("Initial placement failed for player ", i + 1, " - trying fallback methods")
			var fallbackPos = find_nearest_valid_position(targetPos, mapSizeX, mapSizeY, imageData)
			if fallbackPos != Vector2(-1, -1):
				playerPositions.append(fallbackPos)
				mark_coordinates_as_occupied(fallbackPos)
				print("Player ", i + 1, " placed at nearest fallback: ", fallbackPos)
			else:
				var spiralPos = find_position_with_spiral_search(mapSizeX * 0.5, mapSizeY * 0.5, mapSizeX, mapSizeY, imageData)
				if spiralPos != Vector2(-1, -1):
					playerPositions.append(spiralPos)
					mark_coordinates_as_occupied(spiralPos)
					print("Player ", i + 1, " placed via spiral search: ", spiralPos)
				else:
					print("All fallback methods failed for player ", i + 1, " - this should be extremely rare")


func calculate_distance_adjusted_position(subSectionCenterX, subSectionCenterY, subSectionWidth, subSectionHeight, mapSizeX, mapSizeY, symmetryType, imageData):
	var distanceValue = oPlayerDistance.value
	var positioningValue = oPlayerPositioning.value
	var noiseDistance = oNoiseDistance.value
	var mapCenterX = mapSizeX * 0.5
	var mapCenterY = mapSizeY * 0.5
	
	# If distance is 0.5 (center), just return the subsection center to maintain layout
	if distanceValue == 0.5 and positioningValue == 0.5:
		return Vector2(subSectionCenterX, subSectionCenterY)
	
	var finalTargetX = subSectionCenterX
	var finalTargetY = subSectionCenterY
	var primaryDirectionX = 0.0
	var primaryDirectionY = 0.0
	
	# Check if linear distance mode is enabled
	if oLinearDistanceCheckBox.pressed:
		print("Using linear distance mode")
		# Linear distance: move toward/away from the center line perpendicular to symmetry axis
		match symmetryType:
			1, 2: # Vertical symmetry - move toward/away from horizontal center line
				var centerY = mapCenterY
				var maxDistanceY = (mapSizeY * 0.5) - 10  # Leave some margin from edges
				finalTargetY = lerp(centerY, centerY + (sign(subSectionCenterY - centerY) * maxDistanceY), distanceValue)
				primaryDirectionX = 0.0
				primaryDirectionY = sign(subSectionCenterY - centerY)
				print("Linear vertical: original Y=", subSectionCenterY, " target Y=", finalTargetY)
			3, 4: # Horizontal symmetry - move toward/away from vertical center line
				var centerX = mapCenterX
				var maxDistanceX = (mapSizeX * 0.5) - 10  # Leave some margin from edges
				finalTargetX = lerp(centerX, centerX + (sign(subSectionCenterX - centerX) * maxDistanceX), distanceValue)
				primaryDirectionX = sign(subSectionCenterX - centerX)
				primaryDirectionY = 0.0
				print("Linear horizontal: original X=", subSectionCenterX, " target X=", finalTargetX)
			5: # Four-way symmetry - move diagonally toward/away from center
				var centerX = mapCenterX
				var centerY = mapCenterY
				var maxDistanceX = (mapSizeX * 0.5) - 10
				var maxDistanceY = (mapSizeY * 0.5) - 10
				finalTargetX = lerp(centerX, centerX + (sign(subSectionCenterX - centerX) * maxDistanceX), distanceValue)
				finalTargetY = lerp(centerY, centerY + (sign(subSectionCenterY - centerY) * maxDistanceY), distanceValue)
				primaryDirectionX = sign(subSectionCenterX - centerX)
				primaryDirectionY = sign(subSectionCenterY - centerY)
			_: # No symmetry - default to radial
				var directionX = subSectionCenterX - mapCenterX
				var directionY = subSectionCenterY - mapCenterY
				var directionLength = sqrt(directionX * directionX + directionY * directionY)
				if directionLength > 0.1:
					primaryDirectionX = directionX / directionLength
					primaryDirectionY = directionY / directionLength
				var maxDistance = min(mapSizeX, mapSizeY) * 0.4
				var targetDistance = lerp(0.0, maxDistance, distanceValue)
				finalTargetX = mapCenterX + primaryDirectionX * targetDistance
				finalTargetY = mapCenterY + primaryDirectionY * targetDistance
	else:
		print("Using radial distance mode")
		# Original radial distance calculation
		var availableRadius = calculate_available_radius_for_direction(mapSizeX, mapSizeY, imageData, subSectionCenterX, subSectionCenterY, mapCenterX, mapCenterY)
		
		print("Distance calc: distanceValue=", distanceValue, " noiseDistance=", noiseDistance, " availableRadius=", availableRadius)
		
		# Calculate the direction from map center to this subsection
		var directionX = subSectionCenterX - mapCenterX
		var directionY = subSectionCenterY - mapCenterY
		var directionLength = sqrt(directionX * directionX + directionY * directionY)
		
		# Normalize direction (avoid division by zero)
		if directionLength > 0.1:
			primaryDirectionX = directionX / directionLength
			primaryDirectionY = directionY / directionLength
		else:
			# If subsection is at map center, use a default direction based on symmetry
			match symmetryType:
				1, 2: # Vertical symmetry - default to upward
					primaryDirectionX = 0.0
					primaryDirectionY = -1.0
				3, 4: # Horizontal symmetry - default to leftward
					primaryDirectionX = -1.0
					primaryDirectionY = 0.0
				_:
					primaryDirectionX = -1.0
					primaryDirectionY = -1.0
		
		# Calculate target position along this direction based on distance value
		var targetDistance = lerp(0.0, availableRadius, distanceValue)
		finalTargetX = mapCenterX + primaryDirectionX * targetDistance
		finalTargetY = mapCenterY + primaryDirectionY * targetDistance
	
	# Apply perpendicular positioning offset relative to the center line
	if positioningValue != 0.5:
		# Calculate perpendicular direction (rotate primary direction by 90 degrees)
		var perpendicularX = -primaryDirectionY
		var perpendicularY = primaryDirectionX
		
		# Calculate the player's distance from the center line and apply proportional positioning
		var centerLineDistanceFromCenter = 0.0
		
		if oLinearDistanceCheckBox.pressed:
			match symmetryType:
				1, 2: # Vertical symmetry - center line is horizontal, measure horizontal distance from center
					centerLineDistanceFromCenter = abs(subSectionCenterX - mapCenterX)
				3, 4: # Horizontal symmetry - center line is vertical, measure vertical distance from center
					centerLineDistanceFromCenter = abs(subSectionCenterY - mapCenterY)
				5: # Four-way symmetry - use distance to center point
					centerLineDistanceFromCenter = sqrt((subSectionCenterX - mapCenterX) * (subSectionCenterX - mapCenterX) + (subSectionCenterY - mapCenterY) * (subSectionCenterY - mapCenterY))
				_: # No symmetry - use perpendicular distance from radial direction
					var radialX = subSectionCenterX - mapCenterX
					var radialY = subSectionCenterY - mapCenterY
					centerLineDistanceFromCenter = abs(radialX * perpendicularX + radialY * perpendicularY)
		else:
			# For radial distance mode, use perpendicular distance from radial direction
			var radialX = subSectionCenterX - mapCenterX
			var radialY = subSectionCenterY - mapCenterY
			centerLineDistanceFromCenter = abs(radialX * perpendicularX + radialY * perpendicularY)
		
		# Determine which side of the center line the player is on for direction
		var sideOfCenterLine = 1.0
		if oLinearDistanceCheckBox.pressed:
			match symmetryType:
				1, 2: # Vertical symmetry
					sideOfCenterLine = sign(subSectionCenterX - mapCenterX)
				3, 4: # Horizontal symmetry
					sideOfCenterLine = sign(subSectionCenterY - mapCenterY)
				5: # Four-way symmetry
					var radialX = subSectionCenterX - mapCenterX
					var radialY = subSectionCenterY - mapCenterY
					sideOfCenterLine = sign(radialX * perpendicularX + radialY * perpendicularY)
				_: # No symmetry
					var radialX = subSectionCenterX - mapCenterX
					var radialY = subSectionCenterY - mapCenterY
					sideOfCenterLine = sign(radialX * perpendicularX + radialY * perpendicularY)
		else:
			var radialX = subSectionCenterX - mapCenterX
			var radialY = subSectionCenterY - mapCenterY
			sideOfCenterLine = sign(radialX * perpendicularX + radialY * perpendicularY)
		
		if sideOfCenterLine == 0.0:
			sideOfCenterLine = 1.0
		
		# Convert positioning value from 0-1 range to scaling factor
		# 0.5 = no change (100% of original distance)
		# 0.0 = collapse to center line (0% of original distance)  
		# 1.0 = expand to double distance (200% of original distance)
		var distanceScaling = positioningValue * 2.0
		
		# Calculate the new distance from center line (proportional to original)
		var newDistanceFromCenter = centerLineDistanceFromCenter * distanceScaling
		var changeInDistance = newDistanceFromCenter - centerLineDistanceFromCenter
		
		# Apply the distance change in the perpendicular direction
		var offsetDistance = changeInDistance * sideOfCenterLine
		
		finalTargetX += perpendicularX * offsetDistance
		finalTargetY += perpendicularY * offsetDistance
		
		print("Applied proportional positioning: original distance=", centerLineDistanceFromCenter, ", scaling=", distanceScaling, ", offset=", offsetDistance)
	
	print("Final target position: (", finalTargetX, ",", finalTargetY, ") direction=(", primaryDirectionX, ",", primaryDirectionY, ")")
	return Vector2(finalTargetX, finalTargetY)


func find_position_in_subsection(centerPos, subSectionWidth, subSectionHeight, imageData):
	print("Finding position: center=(", centerPos.x, ",", centerPos.y, ") using deterministic search")
	
	var searchRadius = min(subSectionWidth, subSectionHeight) * 0.3
	var testPos = Vector2(int(centerPos.x), int(centerPos.y))
	if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
		return testPos
	for radius in range(1, int(searchRadius)):
		for angle in range(0, 8):
			var angleRad = (angle * 2.0 * PI) / 8.0
			var searchX = centerPos.x + cos(angleRad) * radius
			var searchY = centerPos.y + sin(angleRad) * radius
			testPos = Vector2(int(searchX), int(searchY))
			if testPos.x >= 2 and testPos.y >= 2:
				if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
					return testPos
	return Vector2(-1, -1)


func check_valid_player_position(centerPos, imageData):
	imageData.lock()
	var halfSize = int(PLAYER_SIZE / 2)
	for dy in range(-halfSize, halfSize + 1):
		for dx in range(-halfSize, halfSize + 1):
			var x = centerPos.x + dx
			var y = centerPos.y + dy
			if x >= 0 and x < imageData.get_width() and y >= 0 and y < imageData.get_height():
				if imageData.get_pixel(x, y) == impenetrableColour:
					imageData.unlock()
					return false
	imageData.unlock()
	return true


const potentialPlayerColour = Color(1.0, 0.0, 1.0, 1.0) # Magenta for potential player positions

func draw_potential_player_positions(imageData):
	if playerPositions.size() == 0:
		return
	
	imageData.lock()
	for i in range(playerPositions.size()):
		var playerPos = playerPositions[i]
		var x = playerPos.x
		var y = playerPos.y
		if x >= 0 and x < imageData.get_width() and y >= 0 and y < imageData.get_height():
			imageData.set_pixel(x, y, potentialPlayerColour)
	imageData.unlock()


func convert_potential_positions_to_colored_players(imageData):
	print("Converting potential player positions to actual players with hearts and claimed floor")
	var mapWidth = imageData.get_width()
	var mapHeight = imageData.get_height()
	var potentialPositions = []
	
	imageData.lock()
	for y in range(mapHeight):
		for x in range(mapWidth):
			var pixelColor = imageData.get_pixel(x, y)
			if pixelColor == potentialPlayerColour:
				potentialPositions.append(Vector2(x, y))
	
	print("Found ", potentialPositions.size(), " potential player positions")
	
	for i in range(potentialPositions.size()):
		var pos = potentialPositions[i]
		var playerNumber = i + 1
		place_colored_player_pixels_at_position(imageData, pos, playerNumber)
	
	imageData.unlock()


func place_colored_player_pixels_at_position(imageData, centerPos, playerNumber):
	var mapWidth = imageData.get_width()
	var mapHeight = imageData.get_height()
	var playerIndex = convert_player_number_to_index(playerNumber)
	var dungeonHeartColor = Constants.ownerRoomCol[playerIndex]
	var claimedFloorColor = Constants.ownerFloorCol[playerIndex]
	
	# Create 3x3 dungeon heart
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var x = centerPos.x + dx
			var y = centerPos.y + dy
			if x >= 0 and x < mapWidth and y >= 0 and y < mapHeight:
				var currentPixel = imageData.get_pixel(x, y)
				if currentPixel != impenetrableColour:
					imageData.set_pixel(x, y, dungeonHeartColor)
	
	# Create claimed floor around the heart (5x5 area, excluding the 3x3 heart)
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var x = centerPos.x + dx
			var y = centerPos.y + dy
			if x >= 0 and x < mapWidth and y >= 0 and y < mapHeight:
				# Skip the 3x3 heart area
				if abs(dx) <= 1 and abs(dy) <= 1:
					continue
				var currentPixel = imageData.get_pixel(x, y)
				if currentPixel != impenetrableColour and currentPixel != dungeonHeartColor:
					imageData.set_pixel(x, y, claimedFloorColor)
	
	print("Placed player ", playerNumber, " (index ", playerIndex, ") at position ", centerPos)


func place_objects():
	for y in range(1, M.ySize - 1):
		for x in range(1, M.xSize - 1):
			if oDataSlab.get_cell(x, y) == Slabs.DUNGEON_HEART:
				var centerOwnership = oDataOwnership.get_cell_ownership(x, y)
				var isCenter = true
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var checkX = x + dx
						var checkY = y + dy
						if checkX < 0 or checkX >= M.xSize or checkY < 0 or checkY >= M.ySize or oDataSlab.get_cell(checkX, checkY) != Slabs.DUNGEON_HEART or oDataOwnership.get_cell_ownership(checkX, checkY) != centerOwnership:
							isCenter = false
							break
					if not isCenter:
						break
				if isCenter:
					for offset in [Vector2(-2, -2), Vector2(-2, 2), Vector2(2, -2), Vector2(2, 2)]:
						var impPos = Vector3((x + offset.x) * 3 + 1.5, (y + offset.y) * 3 + 1.5, 1)
						oInstances.place_new_thing(Things.TYPE.CREATURE, 23, impPos, centerOwnership)
					print("Placed 4 imps around dungeon heart at (", x, ",", y, ") for owner ", centerOwnership)


func find_nearest_valid_position(basePos, mapSizeX, mapSizeY, imageData):
	var searchRadius = 20
	var playerMargin = int(PLAYER_SIZE / 2) + 1
	for radius in range(1, searchRadius):
		for angle in range(0, 16):
			var angleRad = (angle * 2.0 * PI) / 16.0
			var searchX = basePos.x + cos(angleRad) * radius
			var searchY = basePos.y + sin(angleRad) * radius
			var testPos = Vector2(int(searchX), int(searchY))
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
				return testPos
	return Vector2(-1, -1)


func get_player_coordinates(centerPos):
	var coordinates = []
	var halfSize = int(PLAYER_SIZE / 2)
	for dy in range(-halfSize, halfSize + 1):
		for dx in range(-halfSize, halfSize + 1):
			coordinates.append(Vector2(centerPos.x + dx, centerPos.y + dy))
	return coordinates


func calculate_available_radius_for_direction(mapSizeX, mapSizeY, imageData, subSectionCenterX, subSectionCenterY, mapCenterX, mapCenterY):
	var noiseDistance = oNoiseDistance.value
	var maxTestRadius = min(mapSizeX, mapSizeY) * 0.45
	
	if noiseDistance <= 0.1:
		return (min(mapSizeX, mapSizeY) - 5) * 0.5
	
	# Determine direction from center to subsection
	var directionX = 0.0
	var directionY = 0.0
	
	if subSectionCenterX < mapCenterX:
		directionX = -1.0
	elif subSectionCenterX > mapCenterX:
		directionX = 1.0
		
	if subSectionCenterY < mapCenterY:
		directionY = -1.0
	elif subSectionCenterY > mapCenterY:
		directionY = 1.0
	
	# Test along the direction to find available radius
	imageData.lock()
	var availableRadius = 0.0
	for testRadius in range(5, int(maxTestRadius), 2):
		var testX = mapCenterX + directionX * testRadius
		var testY = mapCenterY + directionY * testRadius
		var testPos = Vector2(int(testX), int(testY))
		var playerMargin = int(PLAYER_SIZE / 2) + 1
		testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
		testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
		if check_valid_player_position_unlocked(testPos, imageData):
			availableRadius = testRadius
	imageData.unlock()
	return availableRadius


func check_valid_player_position_unlocked(centerPos, imageData):
	var halfSize = int(PLAYER_SIZE / 2)
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


func find_position_with_spiral_search(centerX, centerY, mapSizeX, mapSizeY, imageData):
	var maxSearchRadius = min(mapSizeX, mapSizeY) * 0.4
	var playerMargin = int(PLAYER_SIZE / 2) + 1
	for radius in range(5, int(maxSearchRadius), 3):
		var angleSteps = max(8, int(radius * 0.5))
		for i in range(angleSteps):
			var angle = (i * 2.0 * PI) / angleSteps
			var testX = centerX + cos(angle) * radius
			var testY = centerY + sin(angle) * radius
			var testPos = Vector2(int(testX), int(testY))
			testPos.x = clamp(testPos.x, playerMargin, mapSizeX - playerMargin - 1)
			testPos.y = clamp(testPos.y, playerMargin, mapSizeY - playerMargin - 1)
			if check_valid_player_position(testPos, imageData) and check_coordinates_available(testPos):
				return testPos
	return Vector2(-1, -1)
