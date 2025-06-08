extends Node

onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMessage = Nodelist.list["oMessage"]

var editingImg = Image.new()
var fileTimes = []
var partsList = []
var modifiedCheck = File.new()
var packFilePath = ""
var packFolder = ""


func _ready():
	editingImg.create(8*32, 68*32, false, Image.FORMAT_L8)
	reloader_loop()


func reloader_loop():
	if packFilePath != "": execute()
	yield(get_tree().create_timer(0.25), "timeout")
	reloader_loop()


func initialize_pack(contentString: String, reloaderPath: String):
	packFilePath = reloaderPath
	packFolder = reloaderPath
	partsList.clear()
	var flContent = contentString
	if flContent == "": return
	partsList = Array(flContent.split('\n', false))
	if partsList.empty() == false and partsList[0].begins_with("textures_pack_"):
		partsList.pop_front()
	var validParts = []
	for i in partsList.size():
		var originalLine = partsList[i]
		var lineData = originalLine.split('\t', false)
		if lineData.size() >= 5:
			validParts.append(lineData)
		else:
			validParts.append([])
			printerr("Invalid line in pack (line ", i+2, "): '", originalLine, "' - Marked as invalid.")
	partsList = validParts
	if fileTimes.size() != partsList.size():
		fileTimes.resize(partsList.size())
		fileTimes.fill(-1)
	var fn = get_tmap_number_string()
	if fn != null and oDataLevelStyle.data != int(fn):
		oDataLevelStyle.data = int(fn)
		oTMapLoader.apply_texture_pack()
		oEditor.mapHasBeenEdited = true
		oMessage.quick("Changed map's Tileset to show what you're currently editing")


func execute():
	var partsModifiedIndices = get_modified_parts(packFolder)
	if partsModifiedIndices.empty(): return
	var isTmapb = is_tmapb_type()
	process_modified_parts(partsModifiedIndices, packFolder, isTmapb)
	var tmapNumberStr = get_tmap_number_string()
	if tmapNumberStr != null:
		var tmapNumber = int(tmapNumberStr)
		var tmapType = "tmapb" if isTmapb else "tmapa"
		oTMapLoader.cache_loaded_image(editingImg, tmapNumber, tmapType)
		oTMapLoader.apply_texture_pack()


func get_modified_parts(baseDir: String) -> Array:
	var partsModifiedIndices = []
	for i in partsList.size():
		if partsList[i].empty(): continue
		var path = baseDir.plus_file(partsList[i][0])
		if modifiedCheck.file_exists(path):
			var currentTime = modifiedCheck.get_modified_time(path)
			var storedTime = fileTimes[i]
			if currentTime != storedTime:
				partsModifiedIndices.append(i)
	return partsModifiedIndices


func process_modified_parts(partsModifiedIndices: Array, baseDir: String, isTmapb: bool):
	var imgLoader = Image.new()
	for partIndex in partsModifiedIndices:
		var partData = partsList[partIndex]
		var path = baseDir.plus_file(partData[0])
		fileTimes[partIndex] = modifiedCheck.get_modified_time(path)
		if imgLoader.load(path) != OK:
			printerr("Failed to load image: ", path)
			continue
		imgLoader.convert(Image.FORMAT_RGB8)
		var srcRectInPng = Rect2(int(partData[1]), int(partData[2]), int(partData[3]), int(partData[4]))
		var tileSubImageRgb = imgLoader.get_rect(srcRectInPng)
		if tileSubImageRgb == null or tileSubImageRgb.is_empty():
			printerr("Failed to get_rect from ", path, " with rect ", srcRectInPng)
			continue
		var tileSubImageL8 = convert_rgb_image_to_l8(tileSubImageRgb)
		if tileSubImageL8 == null or tileSubImageL8.is_empty():
			printerr("Failed to convert tile to L8 from: ", path)
			continue
		var destinationCoords = Vector2((partIndex % 8) * 32, (partIndex / 8) * 32)
		editingImg.lock()
		editingImg.blit_rect(tileSubImageL8, Rect2(0,0, tileSubImageL8.get_width(), tileSubImageL8.get_height()), destinationCoords)
		editingImg.unlock()


func is_tmapb_type() -> bool:
	var lowerPath = packFilePath.to_lower()
	var isTmapb = lowerPath.find("tmapb") != -1
	return isTmapb


func get_tmap_number_string():
	var lowerPath = packFilePath.to_lower()
	var tmapaIndex = lowerPath.find("tmapa")
	var tmapbIndex = lowerPath.find("tmapb")
	if tmapaIndex != -1:
		var afterTmapa = lowerPath.substr(tmapaIndex + 5)
		var numberMatch = extract_number_from_string(afterTmapa)
		return numberMatch if numberMatch != "" else null
	elif tmapbIndex != -1:
		var afterTmapb = lowerPath.substr(tmapbIndex + 5)
		var numberMatch = extract_number_from_string(afterTmapb)
		return numberMatch if numberMatch != "" else null
	else:
		return null


func extract_number_from_string(text: String) -> String:
	var result = ""
	for i in text.length():
		var character = text[i]
		if character >= "0" and character <= "9":
			result += character
		elif result != "":
			break
	return result


func find_closest_palette_index(targetColor: Color, paletteArray: Array) -> int:
	if paletteArray.empty(): return 0
	var closestIndex = 0
	var minDistanceSq = -1.0
	for i in paletteArray.size():
		var palColor: Color = paletteArray[i]
		var dr = palColor.r - targetColor.r
		var dg = palColor.g - targetColor.g
		var db = palColor.b - targetColor.b
		var currentDistanceSq = dr*dr + dg*dg + db*db
		if minDistanceSq < 0.0 or currentDistanceSq < minDistanceSq:
			minDistanceSq = currentDistanceSq
			closestIndex = i
			if minDistanceSq == 0.0: break
	return closestIndex


func convert_rgb_image_to_l8(rgbImage: Image) -> Image:
	if rgbImage == null or rgbImage.is_empty(): return null
	var localPaletteArray: Array = oReadPalette.get_palette_data()
	if localPaletteArray.empty(): return null
	var l8Image = Image.new()
	l8Image.create(rgbImage.get_width(), rgbImage.get_height(), false, Image.FORMAT_L8)
	var colorToIndexCache = {}
	rgbImage.lock()
	l8Image.lock()
	for yCoord in rgbImage.get_height():
		for xCoord in rgbImage.get_width():
			var rgbColor = rgbImage.get_pixel(xCoord, yCoord)
			var paletteIndex: int = colorToIndexCache.get(rgbColor, -1)
			if paletteIndex == -1:
				paletteIndex = find_closest_palette_index(rgbColor, localPaletteArray)
				colorToIndexCache[rgbColor] = paletteIndex
			var grayValue = float(paletteIndex) / 255.0
			l8Image.set_pixel(xCoord, yCoord, Color(grayValue, grayValue, grayValue))
	rgbImage.unlock()
	l8Image.unlock()
	return l8Image 
