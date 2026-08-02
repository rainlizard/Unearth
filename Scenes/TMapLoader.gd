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
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

const TMAP_IMAGE_WIDTH: int = 256
const TMAP_IMAGE_HEIGHT: int = 2176
const TMAP_HALF_HEIGHT: int = TMAP_IMAGE_HEIGHT / 2
const TMAP_COUNT: int = 256
const EMPTY_TEXTURE_INDEX: int = 0
const TEXTURE_FLAGS = Texture.FLAG_REPEAT + Texture.FLAG_ANISOTROPIC_FILTER

enum {
	LOADING_NOT_STARTED,
	LOADING_IN_PROGRESS,
	LOADING_SUCCESS
}

enum PaletteType {
	PALETTE_2D,
	PALETTE_3D
}

var rememberedTmapaPaths = {}
var decodedTmapSizes = {}
var cachedTextures = []
var texturesLoadedState = LOADING_NOT_STARTED
var blankHalfTexture: ImageTexture

func finish_load_ui():
	for i in 100:
		yield(get_tree(), 'idle_frame')
	oMapProperties._on_MapProperties_visibility_changed()


func load_remembered_paths(dictionaryFromSettings):
	rememberedTmapaPaths = dictionaryFromSettings


func parse_tmap_path_details(filePath: String):
	var baseNameLower = filePath.get_file().get_basename().to_lower()
	for type in ["tmapa", "tmapb"]:
		var marker = "." + type if baseNameLower.find("." + type) != -1 else type
		if marker != type or baseNameLower.begins_with(type):
			var number = baseNameLower.substr(baseNameLower.rfind(marker) + marker.length())
			if number.is_valid_integer():
				return {"number": int(number), "type": type}
	return null


func get_effective_tmap_data_from_cfgloader() -> Dictionary:
	var effectivePaths = {}
	var file = File.new()
	for configType in [oConfigFileManager.LOAD_CFG_DATA, oConfigFileManager.LOAD_CFG_CAMPAIGN, oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
		for path in oConfigFileManager.paths_loaded.get(configType, []):
			if path == null or path.get_extension().to_lower() != "dat" or file.file_exists(path) == false:
				continue
			var details = parse_tmap_path_details(path)
			if details != null:
				effectivePaths[[details.number, details.type]] = path
	var result = {}
	for path in effectivePaths.values():
		result[path] = file.get_modified_time(path)
	return result


func start():
	if oGame.EXECUTABLE_PATH == "" or oGame.DK_DATA_DIRECTORY == "" or oGame.GAME_DIRECTORY == "":
		return
	var totalProcessStartTime = OS.get_ticks_msec()
	texturesLoadedState = LOADING_IN_PROGRESS

	if oReadPalette.initialize_palette_resources() == false or oReadPalette.palette_image_texture_2d == null:
		printerr("Critical: Palette texture is null or initialization failed.")
		oMessage.big("Error", "Tileset Error: Palette texture unavailable.")
		texturesLoadedState = LOADING_NOT_STARTED
		return

	var tmapaDatDictionary = get_effective_tmap_data_from_cfgloader()
	var tmapaDatListSorted = tmapaDatDictionary.keys()
	tmapaDatListSorted.sort()
	
	cachedTextures.clear()
	
	var newRememberedPaths = {}
	for pathStr in tmapaDatListSorted:
		var parsedDetails = parse_tmap_path_details(pathStr)
		if parsedDetails == null or parsedDetails.number < 0 or parsedDetails.number >= TMAP_COUNT:
			printerr("Invalid TMAP filename or Tileset ID: ", pathStr.get_file().get_basename())
			continue
		
		var l8Image: Image = create_l8_image(pathStr)
		if l8Image == null or l8Image.is_empty():
			printerr("Failed to create L8 image from DAT: ", pathStr)
			continue
		
		cache_loaded_image(l8Image, parsedDetails.number, parsedDetails.type)
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
	var l8ByteArray: PoolByteArray = oRNC.decompress_to_bytes(tmapDatPath)
	
	if l8ByteArray.empty():
		printerr("Failed to process file: ", tmapDatPath)
		return null
	
	var actualDataSize = l8ByteArray.size()
	var maxExpectedSize = TMAP_IMAGE_WIDTH * TMAP_IMAGE_HEIGHT
	
	if actualDataSize > maxExpectedSize:
		printerr("TMAP data too large for " + tmapDatPath + ". Expected max " + str(maxExpectedSize) + ", got " + str(actualDataSize) + ". Truncating to expected size.")
		l8ByteArray.resize(maxExpectedSize)
		actualDataSize = maxExpectedSize
	decodedTmapSizes[tmapDatPath] = actualDataSize
	
	var actualHeight = actualDataSize / TMAP_IMAGE_WIDTH
	if actualDataSize % TMAP_IMAGE_WIDTH != 0:
		actualHeight += 1
		var paddedSize = actualHeight * TMAP_IMAGE_WIDTH
		l8ByteArray.resize(paddedSize)
		for i in range(actualDataSize, paddedSize):
			l8ByteArray[i] = EMPTY_TEXTURE_INDEX
	
	var img = Image.new()
	img.create_from_data(TMAP_IMAGE_WIDTH, actualHeight, false, Image.FORMAT_L8, l8ByteArray)
	if img == null or img.is_empty():
		printerr("Failed to create L8 image from TMAP data: ", tmapDatPath)
		return null
	
	if actualHeight < TMAP_IMAGE_HEIGHT:
		var fullSizeImage = Image.new()
		fullSizeImage.create(TMAP_IMAGE_WIDTH, TMAP_IMAGE_HEIGHT, false, Image.FORMAT_L8)
		var emptyValue = float(EMPTY_TEXTURE_INDEX) / 255.0
		fullSizeImage.fill(Color(emptyValue, emptyValue, emptyValue))
		fullSizeImage.blit_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), Vector2(0, 0))
		return fullSizeImage
	
	return img


func create_rgb_image(l8Image: Image) -> Image:
	if l8Image == null or l8Image.is_empty(): return null
	var paletteBytes = oReadPalette.flat_palette_bytes
	if paletteBytes.empty():
		oReadPalette.initialize_palette_resources()
		paletteBytes = oReadPalette.flat_palette_bytes
	if paletteBytes.empty(): return null
	var l8Bytes = l8Image.get_data()
	var rgbBytes = PoolByteArray()
	rgbBytes.resize(l8Bytes.size() * 3)
	for i in l8Bytes.size():
		var paletteIndex = l8Bytes[i] * 3
		var rgbIndex = i * 3
		rgbBytes[rgbIndex] = paletteBytes[paletteIndex]
		rgbBytes[rgbIndex + 1] = paletteBytes[paletteIndex + 1]
		rgbBytes[rgbIndex + 2] = paletteBytes[paletteIndex + 2]
	var rgbImage = Image.new()
	rgbImage.create_from_data(l8Image.get_width(), l8Image.get_height(), false, Image.FORMAT_RGB8, rgbBytes)
	return rgbImage


func create_l8_image_from_rgb(rgbImage: Image, referenceImage: Image = null) -> Image:
	if rgbImage == null or rgbImage.is_empty(): return null
	var paletteColors = oReadPalette.get_palette_data()
	if paletteColors.empty():
		oReadPalette.initialize_palette_resources()
		paletteColors = oReadPalette.get_palette_data()
	if paletteColors.empty(): return null
	rgbImage.convert(Image.FORMAT_RGB8)
	var l8Image = Image.new()
	l8Image.create(rgbImage.get_width(), rgbImage.get_height(), false, Image.FORMAT_L8)
	var colorToIndex = {}
	rgbImage.lock()
	l8Image.lock()
	if referenceImage != null:
		referenceImage.lock()
	for y in rgbImage.get_height():
		for x in rgbImage.get_width():
			var color = rgbImage.get_pixel(x, y)
			var paletteIndex = -1
			if referenceImage != null and referenceImage.get_size() == rgbImage.get_size():
				var referenceIndex = int(referenceImage.get_pixel(x, y).r * 255.0 + 0.5)
				if paletteColors[referenceIndex] == color:
					paletteIndex = referenceIndex
			if paletteIndex == -1:
				paletteIndex = colorToIndex.get(color, -1)
				if paletteIndex == -1:
					var closestDistance = -1.0
					for i in paletteColors.size():
						var difference = paletteColors[i] - color
						var distance = difference.r * difference.r + difference.g * difference.g + difference.b * difference.b
						if closestDistance < 0.0 or distance < closestDistance:
							closestDistance = distance
							paletteIndex = i
							if distance == 0.0: break
					colorToIndex[color] = paletteIndex
			var value = float(paletteIndex) / 255.0
			l8Image.set_pixel(x, y, Color(value, value, value))
	rgbImage.unlock()
	l8Image.unlock()
	if referenceImage != null:
		referenceImage.unlock()
	return l8Image


func cache_loaded_image(l8Image: Image, tmapNumber: int, tmapType: String):
	if tmapNumber < 0 or tmapNumber >= TMAP_COUNT: return
	while cachedTextures.size() <= tmapNumber:
		cachedTextures.append([null, null, null, null])
	if cachedTextures[tmapNumber] == null:
		cachedTextures[tmapNumber] = [null, null, null, null]
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
	if is_instance_valid(blankHalfTexture):
		return blankHalfTexture
	var blankImage = Image.new()
	blankImage.create(TMAP_IMAGE_WIDTH, TMAP_HALF_HEIGHT, false, Image.FORMAT_L8)
	var emptyValue = float(EMPTY_TEXTURE_INDEX) / 255.0
	blankImage.fill(Color(emptyValue, emptyValue, emptyValue))
	blankHalfTexture = ImageTexture.new()
	blankHalfTexture.create_from_image(blankImage, TEXTURE_FLAGS)
	return blankHalfTexture


func apply_shader_params(material: ShaderMaterial, tmapTextures: Dictionary, paletteType: int = PaletteType.PALETTE_2D):
	if material == null: return
	material.set_shader_param("tmap_A_top", tmapTextures["tmap_A_top"])
	material.set_shader_param("tmap_A_bottom", tmapTextures["tmap_A_bottom"])
	material.set_shader_param("tmap_B_top", tmapTextures["tmap_B_top"])
	material.set_shader_param("tmap_B_bottom", tmapTextures["tmap_B_bottom"])
	match paletteType:
		PaletteType.PALETTE_2D: material.set_shader_param("palette_texture", oReadPalette.palette_image_texture_2d)
		PaletteType.PALETTE_3D: material.set_shader_param("palette_texture", oReadPalette.palette_image_texture_3d)

func apply_texture_pack(previewTileset: int = -1):
	if texturesLoadedState != LOADING_SUCCESS or cachedTextures.empty():
		return
	if oReadPalette.palette_image_texture_2d == null:
		oMessage.big("Error", "Palette texture is not loaded. Cannot apply textures.")
		return
	var tilesetIndex = previewTileset if previewTileset >= 0 else int(oDataLevelStyle.data)
	var tmapTextures = _get_tmap_textures(tilesetIndex)
	if tmapTextures.empty():
		return
	for i in oOverheadGraphics.arrayOfColorRects.size():
		var overheadTextures = tmapTextures if previewTileset >= 0 or i == 0 else _get_tmap_textures(i - 1)
		if overheadTextures.empty() == false:
			apply_shader_params(oOverheadGraphics.arrayOfColorRects[i].get_material() as ShaderMaterial, overheadTextures)
	for i in oGame3D.materialArray.size():
		var materialTextures = tmapTextures if previewTileset >= 0 or i == 0 else _get_tmap_textures(i - 1)
		if materialTextures.empty() == false:
			apply_shader_params(oGame3D.materialArray[i] as ShaderMaterial, materialTextures, PaletteType.PALETTE_3D)
	for viewer in get_tree().get_nodes_in_group("VoxelViewer"):
		if is_instance_valid(viewer):
			for voxels in [viewer.oAllVoxelObjects, viewer.oSelectedVoxelObject]:
				if voxels.mesh != null and voxels.mesh.get_surface_count() > 0:
					apply_shader_params(voxels.mesh.surface_get_material(0) as ShaderMaterial, tmapTextures, PaletteType.PALETTE_3D)
	apply_slabwindow_textures(tmapTextures)


func _get_tmap_textures(tilesetIndex: int) -> Dictionary:
	if tilesetIndex < 0 or tilesetIndex >= TMAP_COUNT:
		return {}
	var currentPack = cachedTextures[tilesetIndex] if tilesetIndex < cachedTextures.size() and cachedTextures[tilesetIndex] != null else [null, null, null, null]
	var tmapATopTex: ImageTexture = currentPack[0]
	var tmapABottomTex: ImageTexture = currentPack[1]
	var tmapBTopTex: ImageTexture = currentPack[2]
	var tmapBBottomTex: ImageTexture = currentPack[3]
	if tmapATopTex == null or tmapABottomTex == null:
		var blankTexture = _create_blank_half_texture()
		if tmapATopTex == null: tmapATopTex = blankTexture
		if tmapABottomTex == null: tmapABottomTex = blankTexture
	if tmapBTopTex == null or tmapBBottomTex == null:
		var blankTexture = _create_blank_half_texture()
		if tmapBTopTex == null: tmapBTopTex = blankTexture
		if tmapBBottomTex == null: tmapBBottomTex = blankTexture
	return {
		"tmap_A_top": tmapATopTex, "tmap_A_bottom": tmapABottomTex,
		"tmap_B_top": tmapBTopTex, "tmap_B_bottom": tmapBBottomTex
	}


func apply_slabwindow_textures(tmapTextures: Dictionary):
	for nodeID in get_tree().get_nodes_in_group("SlabDisplay"):
		if is_instance_valid(nodeID):
			apply_shader_params(nodeID.get_material() as ShaderMaterial, tmapTextures)
