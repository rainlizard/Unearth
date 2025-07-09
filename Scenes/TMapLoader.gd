extends Node

onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oGame = Nodelist.list["oGame"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oGame3D = Nodelist.list["oGame3D"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oClmEditorVoxelView = Nodelist.list["oClmEditorVoxelView"]
onready var oMapProperties = Nodelist.list["oMapProperties"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

const TMAP_IMAGE_WIDTH: int = 256
const TMAP_IMAGE_HEIGHT: int = 2176
const TMAP_HALF_HEIGHT: int = TMAP_IMAGE_HEIGHT / 2
const TEXTURE_FLAGS = Texture.FLAG_REPEAT + Texture.FLAG_ANISOTROPIC_FILTER

enum {
	LOADING_NOT_STARTED,
	LOADING_IN_PROGRESS,
	LOADING_SUCCESS
}

var rememberedTmapaPaths = {}
var cachedTextures = []
var texturesLoadedState = LOADING_NOT_STARTED

func finish_load_ui():
	for i in 100:
		yield(get_tree(), 'idle_frame')
	oMapProperties._on_MapProperties_visibility_changed()


func load_remembered_paths(dictionaryFromSettings):
	rememberedTmapaPaths = dictionaryFromSettings


func parse_tmap_path_details(filePath: String):
	var baseNameLower = filePath.get_file().get_basename().to_lower()
	var tmapType = ""
	var numberStr = ""

	var coreTypes = ["tmapa", "tmapb"]
	for core_type_str in coreTypes:
		# Check for format: mapname.tmapaNUMBER or mapname.tmapbNUMBER
		var patternWithDot = "." + core_type_str
		var dotIndex = baseNameLower.rfind(patternWithDot)
		if dotIndex != -1:
			var potentialNumber = baseNameLower.substr(dotIndex + patternWithDot.length())
			if potentialNumber.is_valid_integer():
				tmapType = core_type_str
				numberStr = potentialNumber
				break 
		
		# Check for format: tmapaNUMBER or tmapbNUMBER (at the beginning)
		if baseNameLower.begins_with(core_type_str):
			var potentialNumber = baseNameLower.substr(core_type_str.length())
			if potentialNumber.is_valid_integer():
				tmapType = core_type_str
				numberStr = potentialNumber
				break 

	if tmapType != "" and numberStr != "" and numberStr.is_valid_integer():
		return { "number": int(numberStr), "type": tmapType }
	else:
		return null


func get_effective_tmap_data_from_cfgloader() -> Dictionary:
	if is_instance_valid(oCfgLoader) == false:
		printerr("CfgLoader not available.")
		return {}

	var effectiveSourcesByIdentifier = {}
	var cfgLoaderPathsLoaded = oConfigFileManager.paths_loaded

	var sourceTypesWithEnum = [
		{"sourceType": "data", "enumKey": oConfigFileManager.LOAD_CFG_DATA},
		{"sourceType": "campaign", "enumKey": oConfigFileManager.LOAD_CFG_CAMPAIGN},
		{"sourceType": "map", "enumKey": oConfigFileManager.LOAD_CFG_CURRENT_MAP}
	]
	
	var fileChecker = File.new() # To get modified times

	for sourceInfo in sourceTypesWithEnum:
		var enumKey = sourceInfo.enumKey
		if cfgLoaderPathsLoaded.has(enumKey) == false:
			continue

		var pathsList = cfgLoaderPathsLoaded[enumKey]
		for pathStrKey in pathsList:
			if pathStrKey == null:
				continue
			if pathStrKey.get_extension().to_lower() != "dat": # Only process .dat files
				continue

			var parsedTmapDetails = parse_tmap_path_details(pathStrKey)
			if parsedTmapDetails != null:
				var tmapIdentifierKey = [parsedTmapDetails.number, parsedTmapDetails.type]
				var modTimeVal = 0
				if fileChecker.file_exists(pathStrKey):
					modTimeVal = fileChecker.get_modified_time(pathStrKey)
				else:
					printerr("TMapLoader: File path from CfgLoader does not exist, cannot get mod time: ", pathStrKey)
					continue

				effectiveSourcesByIdentifier[tmapIdentifierKey] = { "path": pathStrKey, "modifiedTime": modTimeVal }
	
	var finalTmapDataDictionary = {}
	for tmapIdentifierKeyArray in effectiveSourcesByIdentifier:
		var tmapDataEntry = effectiveSourcesByIdentifier[tmapIdentifierKeyArray]
		finalTmapDataDictionary[tmapDataEntry.path] = tmapDataEntry.modifiedTime
	return finalTmapDataDictionary


func start():
	if oGame.EXECUTABLE_PATH == "" or oGame.DK_DATA_DIRECTORY == "" or oGame.GAME_DIRECTORY == "":
		return
	var totalProcessStartTime = OS.get_ticks_msec()
	texturesLoadedState = LOADING_IN_PROGRESS

	if oReadPalette.initialize_palette_resources(Settings.unearthdata.plus_file("palette.dat")) == false or oReadPalette.get_palette_texture() == null:
		printerr("Critical: Palette texture is null or initialization failed.")
		oMessage.big("Error", "Tileset Error: Palette texture unavailable.")
		texturesLoadedState = LOADING_NOT_STARTED
		return

	var tmapaDatDictionary = get_effective_tmap_data_from_cfgloader()
	var tmapaDatListSorted = tmapaDatDictionary.keys()
	tmapaDatListSorted.sort()
	
	cachedTextures.clear()
	
	var maxTmapNumber = -1
	if tmapaDatListSorted.empty() == false:
		for pathStr in tmapaDatListSorted:
			var parsedDetails = parse_tmap_path_details(pathStr)
			if parsedDetails != null and parsedDetails.number > maxTmapNumber:
				maxTmapNumber = parsedDetails.number
	
	if maxTmapNumber != -1:
		cachedTextures.resize(maxTmapNumber + 1)
		for i in range(maxTmapNumber + 1):
			cachedTextures[i] = [null, null, null, null]
	var newRememberedPaths = {}
	for pathStr in tmapaDatListSorted:
		var parsedDetails = parse_tmap_path_details(pathStr)
		if parsedDetails == null:
			printerr("Invalid TMAP name format (non-numeric suffix likely), cannot extract number: ", pathStr.get_file().get_basename())
			continue
		
		var tmapNumber = parsedDetails.number
		var tmapType = parsedDetails.type

		var l8Image: Image = create_l8_image(pathStr)
		if l8Image == null or l8Image.is_empty():
			printerr("Failed to create L8 image from DAT: ", pathStr)
			continue
		
		cache_loaded_image(l8Image, tmapNumber, tmapType)
		newRememberedPaths[pathStr] = tmapaDatDictionary[pathStr]
	
	rememberedTmapaPaths = newRememberedPaths
	Settings.set_setting("REMEMBER_TMAPA_PATHS", rememberedTmapaPaths)
	if cachedTextures.empty() and tmapaDatListSorted.empty() == false:
		oMessage.big("Error", "No TMAP textures were loaded, though .dat files were found. Check console.")
		texturesLoadedState = LOADING_NOT_STARTED
		return

	texturesLoadedState = LOADING_SUCCESS
	print("TMapLoader: " + str(OS.get_ticks_msec() - totalProcessStartTime) + "ms")
	call_deferred("finish_load_ui")


func create_l8_image(tmapDatPath: String) -> Image:
	var CODETIME_START = OS.get_ticks_msec()
	var l8ByteArray: PoolByteArray = oRNC.decompress(tmapDatPath)
	print('RNC processing ' + tmapDatPath + " : " + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	if l8ByteArray.empty():
		printerr("Failed to process file: ", tmapDatPath)
		return null
	
	var actualDataSize = l8ByteArray.size()
	var maxExpectedSize = TMAP_IMAGE_WIDTH * TMAP_IMAGE_HEIGHT
	
	if actualDataSize > maxExpectedSize:
		printerr("TMAP data too large for " + tmapDatPath + ". Expected max " + str(maxExpectedSize) + ", got " + str(actualDataSize) + ". Truncating to expected size.")
		l8ByteArray.resize(maxExpectedSize)
		actualDataSize = maxExpectedSize
	
	var actualHeight = actualDataSize / TMAP_IMAGE_WIDTH
	if actualDataSize % TMAP_IMAGE_WIDTH != 0:
		actualHeight += 1
		var paddedSize = actualHeight * TMAP_IMAGE_WIDTH
		l8ByteArray.resize(paddedSize)
		actualDataSize = paddedSize
	
	var img = Image.new()
	img.create_from_data(TMAP_IMAGE_WIDTH, actualHeight, false, Image.FORMAT_L8, l8ByteArray)
	if img == null or img.is_empty():
		printerr("Failed to create L8 image from TMAP data: ", tmapDatPath)
		return null
	
	if actualHeight < TMAP_IMAGE_HEIGHT:
		var fullSizeImage = Image.new()
		fullSizeImage.create(TMAP_IMAGE_WIDTH, TMAP_IMAGE_HEIGHT, false, Image.FORMAT_L8)
		fullSizeImage.fill(Color(0, 0, 0))
		fullSizeImage.blit_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), Vector2(0, 0))
		return fullSizeImage
	
	return img


func cache_loaded_image(l8Image: Image, tmapNumber: int, tmapType: String):
	if tmapNumber < 0 or tmapNumber >= cachedTextures.size():
		printerr("Error: tmapNumber ", tmapNumber, " is out of bounds for pre-sized cachedTextures (size: ", cachedTextures.size(), "). File processing skipped.")
		return
	var topRect = Rect2(0, 0, TMAP_IMAGE_WIDTH, TMAP_HALF_HEIGHT)
	var bottomRect = Rect2(0, TMAP_HALF_HEIGHT, TMAP_IMAGE_WIDTH, TMAP_HALF_HEIGHT)

	var topHalfImage: Image = l8Image.get_rect(topRect)
	var bottomHalfImage: Image = l8Image.get_rect(bottomRect)

	if topHalfImage == null or topHalfImage.is_empty() or bottomHalfImage == null or bottomHalfImage.is_empty():
		printerr("Failed to split L8 image for tmap ", tmapNumber, " type ", tmapType)
		return
	var topTexture = ImageTexture.new()
	topTexture.create_from_image(topHalfImage, TEXTURE_FLAGS)
	
	var bottomTexture = ImageTexture.new()
	bottomTexture.create_from_image(bottomHalfImage, TEXTURE_FLAGS)

	if tmapType == "tmapa":
		cachedTextures[tmapNumber][0] = topTexture
		cachedTextures[tmapNumber][1] = bottomTexture
	elif tmapType == "tmapb":
		cachedTextures[tmapNumber][2] = topTexture
		cachedTextures[tmapNumber][3] = bottomTexture
	else:
		printerr("Unknown tmap type in cache_loaded_image: ", tmapType)


func _create_blank_half_texture() -> ImageTexture:
	var defaultBytes = PoolByteArray()
	defaultBytes.resize(TMAP_IMAGE_WIDTH * TMAP_HALF_HEIGHT)
	var blankImage = Image.new()
	blankImage.create_from_data(TMAP_IMAGE_WIDTH, TMAP_HALF_HEIGHT, false, Image.FORMAT_L8, defaultBytes)
	var blankTexture = ImageTexture.new()
	blankTexture.create_from_image(blankImage, TEXTURE_FLAGS)
	return blankTexture


func _apply_shader_parameters(material: ShaderMaterial, shaderParameters: Dictionary):
	if material != null:
		for paramName in shaderParameters:
			material.set_shader_param(paramName, shaderParameters[paramName])

var alreadyShowedErrorOnce = false

func apply_texture_pack():
	var tilesetIndex = oDataLevelStyle.data
	if texturesLoadedState != LOADING_SUCCESS or cachedTextures.empty():
		oMessage.big("Error", "Tilesets are not loaded or failed to load. Cannot set texture pack.")
		return
	var localPaletteTexture = oReadPalette.get_palette_texture()
	if localPaletteTexture == null:
		oMessage.big("Error", "Palette texture is not loaded. Cannot apply textures.")
		return
	if tilesetIndex < 0 or tilesetIndex >= cachedTextures.size() or cachedTextures[tilesetIndex] == null:
		oMessage.big("Error", "Selected tileset " + str(tilesetIndex) + " is out of bounds or not loaded. Max: " + str(cachedTextures.size() - 1))
		return
	var currentPack = cachedTextures[tilesetIndex]
	var tmapATopTex: ImageTexture = currentPack[0]
	var tmapABottomTex: ImageTexture = currentPack[1]
	var tmapBTopTex: ImageTexture = currentPack[2]
	var tmapBBottomTex: ImageTexture = currentPack[3]
	if tmapATopTex == null or tmapABottomTex == null:
		oMessage.big("Error", "TMAPA textures for tileset " + str(tilesetIndex) + " are missing.")
		var blankTexture = _create_blank_half_texture()
		if tmapBTopTex == null: tmapBTopTex = blankTexture
		if tmapBBottomTex == null: tmapBBottomTex = blankTexture
	if tmapBTopTex == null or tmapBBottomTex == null:
		if alreadyShowedErrorOnce == false:
			alreadyShowedErrorOnce = true
			if oGame.EXECUTABLE_PATH.get_file().to_lower() == "keeperfx.exe": #keeper.exe shouldn't give this warning, because dos versions don't have tmapb files
				oMessage.quick("Warning: TMAPB textures for tileset " + str(tilesetIndex) + " are missing.")
		var blankTexture = _create_blank_half_texture()
		if tmapBTopTex == null: tmapBTopTex = blankTexture
		if tmapBBottomTex == null: tmapBBottomTex = blankTexture
	var shaderParameters = {
		"tmap_A_top": tmapATopTex, "tmap_A_bottom": tmapABottomTex,
		"tmap_B_top": tmapBTopTex, "tmap_B_bottom": tmapBBottomTex,
		"palette_texture": localPaletteTexture
	}
	for i in range(oOverheadGraphics.arrayOfColorRects.size()):
		_apply_shader_parameters(oOverheadGraphics.arrayOfColorRects[i].get_material() as ShaderMaterial, shaderParameters)
	if oGame3D.materialArray.size() > 0:
		_apply_shader_parameters(oGame3D.materialArray[0] as ShaderMaterial, shaderParameters)
	for nodeID in get_tree().get_nodes_in_group("VoxelViewer"):
		if is_instance_valid(nodeID) == false: continue
		if nodeID.has_method("get_voxel_material"):
			_apply_shader_parameters(nodeID.get_voxel_material("all") as ShaderMaterial, shaderParameters)
			_apply_shader_parameters(nodeID.get_voxel_material("selected") as ShaderMaterial, shaderParameters)
		elif nodeID.has_node("oAllVoxelObjects") and nodeID.has_node("oSelectedVoxelObject"):
			var allVoxelsNode = nodeID.get_node("oAllVoxelObjects")
			if allVoxelsNode is MeshInstance and allVoxelsNode.mesh != null and allVoxelsNode.mesh.surface_get_material_count() > 0:
				_apply_shader_parameters(allVoxelsNode.mesh.surface_get_material(0) as ShaderMaterial, shaderParameters)
			var selectedVoxelsNode = nodeID.get_node("oSelectedVoxelObject")
			if selectedVoxelsNode is MeshInstance and selectedVoxelsNode.mesh != null and selectedVoxelsNode.mesh.surface_get_material_count() > 0:
				_apply_shader_parameters(selectedVoxelsNode.mesh.surface_get_material(0) as ShaderMaterial, shaderParameters)
	apply_slabwindow_textures(shaderParameters)


func apply_slabwindow_textures(shaderParameters: Dictionary):
	yield(get_tree(),'idle_frame')
	for nodeID in get_tree().get_nodes_in_group("SlabDisplay"):
		if is_instance_valid(nodeID):
			_apply_shader_parameters(nodeID.get_material() as ShaderMaterial, shaderParameters)
