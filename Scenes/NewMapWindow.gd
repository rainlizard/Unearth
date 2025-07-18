extends WindowDialog
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oQuickNoisePreview = Nodelist.list["oQuickNoisePreview"]
onready var oNoiseUpdateTimer = Nodelist.list["oNoiseUpdateTimer"]
onready var oNewMapNoiseOptions = Nodelist.list["oNewMapNoiseOptions"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oGame = Nodelist.list["oGame"]
onready var oSetNewFormat = Nodelist.list["oSetNewFormat"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCheckBoxNewMapBorder = Nodelist.list["oCheckBoxNewMapBorder"]
onready var oNewMapSymmetricalBorder = Nodelist.list["oNewMapSymmetricalBorder"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oCheckBoxNewMapAutoOpensMapSettings = Nodelist.list["oCheckBoxNewMapAutoOpensMapSettings"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oNewMapPlayerOptions = Nodelist.list["oNewMapPlayerOptions"]
onready var oRandomBorder = Nodelist.list["oRandomBorder"]
onready var oPlayerDistance = Nodelist.list["oPlayerDistance"]
onready var oPlacePlayersCheckBox = Nodelist.list["oPlacePlayersCheckBox"]
onready var oPlayerCount = Nodelist.list["oPlayerCount"]
onready var oRandomPlayers = Nodelist.list["oRandomPlayers"]
onready var oRandomPlayersPizza = Nodelist.list["oRandomPlayersPizza"]
onready var oLinearDistanceCheckBox = Nodelist.list["oLinearDistanceCheckBox"]
onready var oPlayerPositioning = Nodelist.list["oPlayerPositioning"]

var currently_creating_new_map = false

var imageData = Image.new()
var textureData = ImageTexture.new()

func _ready():
	pass

func _on_NewMapWindow_visibility_changed():
	if visible == false: return
	
	
#	var kfxOutOfDate = false
#	if oGame.KEEPERFX_VERSION_INT != 0 and oGame.KEEPERFX_VERSION_INT < oGame.KEEPERFX_VERSION_REQUIRED_INT:
#		kfxOutOfDate = true
	
	# Default to KFX format
	
	if oGame.keeperfx_is_installed() == false: # or kfxOutOfDate == true:
		oSetNewFormat.selected = Constants.ClassicFormat # Set default format to Classic format, for newbies who don't know what KeeperFX is
		_on_NewMapFormat_item_selected(Constants.ClassicFormat)
	else:
		oSetNewFormat.selected = Constants.KfxFormat # Set default format to KFX format
		_on_NewMapFormat_item_selected(Constants.KfxFormat)
	
	reinit_noise_preview()
	
	_on_NewMapSymmetricalBorder_item_selected(oNewMapSymmetricalBorder.selected)
	
	_on_CheckBoxNewMapBorder_pressed()


func reinit_noise_preview():
	var sizeX = oXSizeLine.text.to_int()
	var sizeY = oYSizeLine.text.to_int()
	imageData.create(sizeX, sizeY, false, Image.FORMAT_RGBA8)
	textureData.create_from_image(imageData, 0)
	oQuickNoisePreview.texture = textureData
	
	
	var pixelSize = 4
	var maxSize = Vector2(85*pixelSize,85*pixelSize)
	
	oQuickNoisePreview.rect_min_size = Vector2(min(sizeX*pixelSize, maxSize.x), min(sizeY*pixelSize, maxSize.y))
	
	if sizeX > 85 or sizeY > 85:
		if sizeX < sizeY:
			var aspectRatio = float(max(1.0,sizeX)) / float(max(1.0,sizeY))
			oQuickNoisePreview.rect_min_size.x *= aspectRatio
		else:
			var aspectRatio = float(max(1.0,sizeY)) / float(max(1.0,sizeX))
			oQuickNoisePreview.rect_min_size.y *= aspectRatio
	
	#oQuickNoisePreview.rect_size = oQuickNoisePreview.rect_min_size



func _on_ButtonNewMapOK_pressed():
	currently_creating_new_map = true
	
	if oGame.EXECUTABLE_PATH == "":
		oMessage.quick("Error: Game executable is not set. Set in File -> Preferences")
		return
	
	oCurrentMap._on_ButtonNewMap_pressed()
	
	yield(oOverheadGraphics, "column_graphics_completed")
	
	if Slabset.dat.empty() == true:
		oMessage.quick("Failed loading slabset, game executable might not be correct. Set in File -> Preferences")
		return
	
	var rectStart = Vector2(0, 0)
	var rectEnd = Vector2(M.xSize-1, M.ySize-1)
	var shapePositionArray = []
	for y in range(rectStart.y, rectEnd.y+1):
		for x in range(rectStart.x, rectEnd.x+1):
			shapePositionArray.append(Vector2(x,y))
	var slabID = Slabs.ROCK
	var useOwner = 5
	oSlabPlacement.place_shape_of_slab_id(shapePositionArray, slabID, useOwner)
	
	if oNewMapNoiseOptions.visible == true:
		# Border
		oRandomBorder.convert_pixels_to_slabs(imageData)
		oRandomPlayers.place_objects()
	else:
		# Blank
		oRandomBorder.fill_entire_map_with_earth()
	
	visible = false # Close New Map window after pressing OK button
	
	# yield must be used here, because this function has yields inside of it.
	yield(oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, false), "completed")
	
	if oCheckBoxNewMapAutoOpensMapSettings.pressed == true:
		Utils.popup_centered(oMapSettingsWindow)
	
	currently_creating_new_map = false



func _on_NoisePersistence_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoisePeriod_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoiseLacunarity_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoiseOctaves_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoiseDistance_sliderChanged():
	oNoiseUpdateTimer.start(0.01)

func _on_NoiseAlgTypeCheckBox_toggled(button_pressed):
	if button_pressed == true:
		oRandomBorder.algorithmType = 0
	else:
		oRandomBorder.algorithmType = 1
	oNoiseUpdateTimer.start(0.01)

func _on_YSizeLine_focus_exited():
	if oYSizeLine.text.to_int() > 170:
		oYSizeLine.text = "170"
	if oCheckBoxNewMapBorder.pressed == true:
		reinit_noise_preview()
		update_border_image_with_noise()
func _on_XSizeLine_focus_exited():
	if oXSizeLine.text.to_int() > 170:
		oXSizeLine.text = "170"
	if oCheckBoxNewMapBorder.pressed == true:
		reinit_noise_preview()
		update_border_image_with_noise()


func _on_NoiseUpdateTimer_timeout():
	update_border_image_with_noise()

func update_border_image_with_noise():
	if oCheckBoxNewMapBorder.pressed == false: return
	oRandomBorder.update_border_image_with_noise(imageData, textureData)
	if oNewMapSymmetricalBorder.selected == 6:
		apply_symmetry()
		oRandomPlayers.place_players_automatically(imageData)
		oRandomPlayers.draw_potential_player_positions(imageData)
	elif oNewMapSymmetricalBorder.selected == 0:
		oRandomPlayers.place_players_automatically(imageData)
		oRandomPlayers.draw_potential_player_positions(imageData)
	else:
		oRandomPlayers.place_players_automatically(imageData)
		oRandomPlayers.draw_potential_player_positions(imageData)
		apply_symmetry()
	oRandomBorder.remove_isolated_earth_slabs(imageData)
	oRandomPlayers.convert_potential_positions_to_colored_players(imageData)
	textureData.set_data(imageData)

func update_border_image_with_blank():
	oRandomBorder.update_border_image_with_blank(imageData, textureData)
	if oNewMapSymmetricalBorder.selected == 6:
		apply_symmetry()
		oRandomPlayers.place_players_automatically(imageData)
		oRandomPlayers.draw_potential_player_positions(imageData)
	elif oNewMapSymmetricalBorder.selected == 0:
		oRandomPlayers.place_players_automatically(imageData)
		oRandomPlayers.draw_potential_player_positions(imageData)
	else:
		oRandomPlayers.place_players_automatically(imageData)
		oRandomPlayers.draw_potential_player_positions(imageData)
		apply_symmetry()
	oRandomBorder.remove_isolated_earth_slabs(imageData)
	oRandomPlayers.convert_potential_positions_to_colored_players(imageData)
	textureData.set_data(imageData)


func _on_CheckBoxNewMapBorder_pressed():
	if oCheckBoxNewMapBorder.pressed == true:
		oNewMapNoiseOptions.visible = true
		update_border_image_with_noise()
	else:
		oNewMapNoiseOptions.visible = false
		update_border_image_with_blank()

func _on_NewMapFormat_item_selected(index):
	if index == Constants.ClassicFormat:
		oXSizeLine.editable = false
		oYSizeLine.editable = false
		oXSizeLine.text = "85"
		oYSizeLine.text = "85"
		_on_XSizeLine_focus_exited()
		_on_YSizeLine_focus_exited()
		oXSizeLine.hint_tooltip = "Map size can only be changed if KFX format is used."
		oYSizeLine.hint_tooltip = "Map size can only be changed if KFX format is used."
		oPlayerCount.max_value = 4.0
		if oPlayerCount.value > 4:
			oPlayerCount.value = 4
	elif index == Constants.KfxFormat:
		oXSizeLine.editable = true
		oYSizeLine.editable = true
		oXSizeLine.hint_tooltip = ""
		oYSizeLine.hint_tooltip = ""
		oPlayerCount.max_value = 8.0
	


func _on_QuickNoisePreview_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			oRandomBorder.noise.seed = randi()
			update_border_image_with_noise()



func _on_NewMapSymmetricalBorder_item_selected(index):
	if index == 0 or index == 5 or index == 6:
		oLinearDistanceCheckBox.visible = false
		#oLinearDistanceCheckBox.disabled = true
		#oLinearDistanceCheckBox.self_modulate.a = 0.0
	else:
		oLinearDistanceCheckBox.visible = true
		#oLinearDistanceCheckBox.disabled = false
		#oLinearDistanceCheckBox.self_modulate.a = 1.0
	
	if index == 0 or index == 6:
		oPlayerPositioning.visible = false
		#oPlayerPositioning.modulate.a = 0.0
	else:
		#oPlayerPositioning.modulate.a = 1.0
		oPlayerPositioning.visible = true
	_on_PlayerCount_sliderChanged()

func apply_symmetry():
	if oNewMapSymmetricalBorder.selected == 0: return
	
	var w = imageData.get_width()
	var h = imageData.get_height()
	# Based on whether the map's size is even or odd, adjust the placement slightly.
	var half_w = floor(w*0.5)
	var half_h = floor(h*0.5)
	var half_w_ceil = ceil(w*0.5)
	var half_h_ceil = ceil(h*0.5)
	
	# Note: center pixel won't be mirrored on an odd sized map.
	
	match oNewMapSymmetricalBorder.selected:
		1: # Vertical symmetry
			var imageTopHalf = imageData.get_rect(Rect2(0, 0, w, half_h))
			
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, 0))
			
			imageTopHalf.flip_y()
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, half_h_ceil))
		2: # Vertical symmetry flipped
			var imageTopHalf = imageData.get_rect(Rect2(0, 0, w, half_h))
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, 0))
			
			imageTopHalf.flip_y()
			imageTopHalf.flip_x()
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, half_h_ceil))
		3: # Horizontal symmetry
			var imageLeftHalf = imageData.get_rect(Rect2(0, 0, half_w, h))
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(0, 0))
			
			imageLeftHalf.flip_x()
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(half_w_ceil, 0))
		4: # Horizontal symmetry flipped
			var imageLeftHalf = imageData.get_rect(Rect2(0, 0, half_w, h))
			
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(0, 0))
			
			imageLeftHalf.flip_x()
			imageLeftHalf.flip_y()
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(half_w_ceil, 0))
		5: # 4-way symmetry
			var imageTopLeft = imageData.get_rect(Rect2(0, 0, half_w, half_h))
			imageData.fill(Color(1,0,0,1))
			
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(0, 0))
			
			imageTopLeft.flip_x()
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(half_w_ceil, 0))
			
			imageTopLeft.flip_x() # Flips back so it's normal again
			imageTopLeft.flip_y()
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(0, half_h_ceil))
			
			imageTopLeft.flip_x()
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(half_w_ceil, half_h_ceil))
			
			if half_w != half_w_ceil or half_h != half_h_ceil:
				imageData.lock()
				imageData.set_pixel(half_w, half_h, oRandomBorder.earthColour)
				imageData.unlock()
		6: # pizza symmetry, insert code here
			oRandomPlayersPizza.apply_pizza_symmetry(imageData)
	
	imageData.lock()
	
	for y in range(0, h):
		for x in range(0, w):
			if imageData.get_pixel(x,y) == Color(1,0,0,1):
				
				if imageData.get_pixel(x, max(y-1,0)) == oRandomBorder.earthColour and imageData.get_pixel(x, min(y+1,h-1)) == oRandomBorder.earthColour:
					imageData.set_pixel(x, y, oRandomBorder.earthColour)
					continue
				if imageData.get_pixel(max(x-1,0), y) == oRandomBorder.earthColour and imageData.get_pixel(min(x+1,w-1), y) == oRandomBorder.earthColour:
					imageData.set_pixel(x, y, oRandomBorder.earthColour)
					continue
				
				imageData.set_pixel(x, y, oRandomBorder.impenetrableColour)
	
	imageData.unlock()


func _on_PlacePlayersCheckBox_toggled(button_pressed):
	if oCheckBoxNewMapBorder.pressed == true:
		update_border_image_with_noise()
	else:
		update_border_image_with_blank()
	oNewMapPlayerOptions.visible = button_pressed

func _on_PlayerCount_sliderChanged():
	var currentSymmetry = oNewMapSymmetricalBorder.selected
	match currentSymmetry:
		1, 2, 3, 4: # Vertical or horizontal symmetry
			if not (oPlayerCount.value in [2, 4, 6, 8]):
				var validValues = [2, 4, 6, 8]
				var closestValue = validValues[0]
				var smallestDiff = abs(oPlayerCount.value - validValues[0])
				for validValue in validValues:
					var diff = abs(oPlayerCount.value - validValue)
					if diff < smallestDiff:
						smallestDiff = diff
						closestValue = validValue
				oPlayerCount.value = closestValue
		5: # 4-way symmetry
			oPlayerCount.value = 4
		6: # Pizza symmetry - no constraints, any player count is valid
			pass
	
	if oSetNewFormat.selected == Constants.ClassicFormat:
		if oPlayerCount.value > 4:
			oPlayerCount.value = 4
	
	if oCheckBoxNewMapBorder.pressed == true:
		update_border_image_with_noise()
	else:
		update_border_image_with_blank()
	

func _on_PlayersZonedCheckBox_toggled(button_pressed):
	if oCheckBoxNewMapBorder.pressed == true:
		update_border_image_with_noise()
	else:
		update_border_image_with_blank()

func _on_PlayerDistance_sliderChanged():
	if oCheckBoxNewMapBorder.pressed == true:
		update_border_image_with_noise()
	else:
		update_border_image_with_blank()

func _on_PlayerPositioning_sliderChanged():
	if oCheckBoxNewMapBorder.pressed == true:
		update_border_image_with_noise()
	else:
		update_border_image_with_blank()

func _on_LinearDistanceCheckBox_toggled(button_pressed):
	if oCheckBoxNewMapBorder.pressed == true:
		update_border_image_with_noise()
	else:
		update_border_image_with_blank()
