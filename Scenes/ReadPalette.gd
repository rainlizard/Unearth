extends Node
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oMessage = Nodelist.list["oMessage"]

var dictionary = {} # Just two different ways to read the palette, for speed.

var palette_data_array: Array = []
var flat_palette_bytes: PoolByteArray = PoolByteArray()
var palette_entry_count: int = 0
var palette_image_texture_2d: ImageTexture = null
var palette_image_texture_3d: ImageTexture = null

func initialize_palette_resources(paletteFilePath: String) -> bool:
	dictionary.clear()
	palette_data_array = _read_colors_from_file(paletteFilePath)
	if palette_data_array.empty():
		printerr("Failed to load palette data from: ", paletteFilePath)
		oMessage.big("Error", "Palette data (" + paletteFilePath.get_file() + ") could not be loaded.")
		palette_image_texture_2d = null
		palette_image_texture_3d = null
		flat_palette_bytes = PoolByteArray()
		palette_entry_count = 0
		return false
	flat_palette_bytes.resize(palette_data_array.size() * 3)
	palette_entry_count = palette_data_array.size()
	var byteIndex = 0
	for colorObject in palette_data_array:
		var colorValue: Color = colorObject
		flat_palette_bytes[byteIndex] = colorValue.r8
		flat_palette_bytes[byteIndex + 1] = colorValue.g8
		flat_palette_bytes[byteIndex + 2] = colorValue.b8
		byteIndex += 3
	var paletteImage = Image.new()
	paletteImage.create_from_data(palette_entry_count, 1, false, Image.FORMAT_RGB8, flat_palette_bytes)
	var tempPaletteTexture = ImageTexture.new()
	tempPaletteTexture.create_from_image(paletteImage, 0)
	if tempPaletteTexture == null or tempPaletteTexture.get_width() == 0:
		printerr("Failed to create palette texture from data in: ", paletteFilePath)
		oMessage.big("Error", "Palette texture could not be created from " + paletteFilePath.get_file() + ". Tilesets may not display correctly.")
		palette_image_texture_2d = null
		palette_image_texture_3d = null
		return false
	palette_image_texture_2d = tempPaletteTexture
	palette_image_texture_3d = tempPaletteTexture.duplicate()
	return true

func _read_colors_from_file(filePath: String) -> Array:
	var dataArray = []
	dataArray.resize(256)
	var buffer = oBuffers.file_path_to_buffer(filePath)
	if buffer.get_size() > 0:
		if buffer.get_size() < 768:
			printerr("Palette file '", filePath, "' is smaller than expected (768 bytes). Actual size: ", buffer.get_size())
			oMessage.big("Error", "Palette file (" + filePath.get_file() + ") is corrupted or incomplete.")
			return []
		for i in 256:
			var rComponent = buffer.get_u8() * 4
			var gComponent = buffer.get_u8() * 4
			var bComponent = buffer.get_u8() * 4
			dataArray[i] = Color8(rComponent, gComponent, bComponent)
			dictionary[Color8(rComponent, gComponent, bComponent)] = i
	else:
		printerr("No palette file found or buffer empty for: ", filePath)
		oMessage.big("Error", "Palette file (" + filePath.get_file() + ") not found or is empty.")
		return []
	return dataArray

func get_palette_data() -> Array:
	return palette_data_array

func getpalette_entry_count() -> int:
	return palette_entry_count
