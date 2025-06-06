extends WindowDialog
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oReloaderPathLabel = Nodelist.list["oReloaderPathLabel"]
onready var oReloaderPathPackLabel = Nodelist.list["oReloaderPathPackLabel"]
onready var oExportTmapaDatDialog = Nodelist.list["oExportTmapaDatDialog"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oChooseTmapaFileDialog = Nodelist.list["oChooseTmapaFileDialog"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oExportTmapaButton = Nodelist.list["oExportTmapaButton"]
onready var oMapProperties = Nodelist.list["oMapProperties"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]

const ExportFilelist = preload("res://Scenes/exportfilelist.gd")

var filelistfile = File.new()
var fileListFilePath = ""
var editingImg = Image.new()
var fileTimes = []
var partsList = []
var modifiedCheck = File.new()
var getPackFolder = ""
var getOpenFolder = ""
var _dialog_confirmed = false


func _ready():
	editingImg.create(8*32, 68*32, false, Image.FORMAT_L8)
	oExportTmapaButton.disabled = true
	oExportTmapaButton.set_tooltip("A filelist pack must be loaded first in order to export")
	oReloaderPathLabel.text = ""
	oReloaderPathPackLabel.text = ""


func reloader_loop():
	if fileListFilePath != "": execute()
	yield(get_tree().create_timer(0.25), "timeout")
	reloader_loop()


func _on_TextureEditingHelpButton_pressed():
	var helptxt = """After you load a tileset, a bunch of .PNG files will be saved to your hard drive. Edit these files in your favourite image editor.
Unearth will actively reload the textures in real-time as you edit and save those .PNGs. So any edits you make will be shown in real-time in Unearth. This applies to the 3D view too, so press Spacebar while in the 3D view to stop the camera from moving."""
	oMessage.big("Help", helptxt)


func initialize_filelist(contentString: String = ""):
	partsList.clear()
	var flContent = contentString if contentString != "" else get_file_content()
	if flContent == "": return
	partsList = Array(flContent.split('\n', false))
	if partsList.empty() == false: partsList.pop_front()
	var validParts = []
	for i in partsList.size():
		var originalLine = partsList[i]
		var lineData = originalLine.split('\t', false)
		if lineData.size() >= 5:
			validParts.append(lineData)
		else:
			validParts.append([])
			printerr("Invalid line in filelist (line ", i+2, "): '", originalLine, "' - Marked as invalid.")
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


func get_file_content() -> String:
	if filelistfile.open(fileListFilePath, File.READ) != OK: return ""
	var content = filelistfile.get_as_text()
	filelistfile.close()
	return content


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


func execute():
	var partsModifiedIndices = get_modified_parts(getPackFolder)
	if partsModifiedIndices.empty(): return
	var isTmapb = fileListFilePath.begins_with("tmapb")
	process_modified_parts(partsModifiedIndices, getPackFolder, isTmapb)
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
		if modifiedCheck.file_exists(path) and modifiedCheck.get_modified_time(path) != fileTimes[i]:
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
		var destinationCoords = Vector2(int(partData[1]), int(partData[2])) if isTmapb else Vector2((partIndex % 8) * 32, (partIndex / 8) * 32)
		editingImg.lock()
		editingImg.blit_rect(tileSubImageL8, Rect2(0,0, tileSubImageL8.get_width(), tileSubImageL8.get_height()), destinationCoords)
		editingImg.unlock()


func get_tmap_number_string():
	return fileListFilePath.substr(5) if fileListFilePath.begins_with("tmapa") or fileListFilePath.begins_with("tmapb") else null


func get_output_directory() -> String:
	return OS.get_user_data_dir().plus_file("UnearthEditorTextureCache") if OS.has_feature('editor') else Settings.unearth_path.plus_file("textures")


func show_confirmation_dialog(message: String) -> bool:
	var confirmDialog = ConfirmationDialog.new()
	confirmDialog.dialog_text = message
	confirmDialog.window_title = "Confirm File Replacement"
	confirmDialog.popup_exclusive = true
	add_child(confirmDialog)
	_dialog_confirmed = false
	confirmDialog.connect("confirmed", self, "_on_dialog_confirmed")
	confirmDialog.popup_centered()
	yield(confirmDialog, "popup_hide")
	yield(get_tree(), "idle_frame")
	var userConfirmed = _dialog_confirmed
	confirmDialog.queue_free()
	return userConfirmed


func _on_dialog_confirmed():
	_dialog_confirmed = true


func _on_ExportTmapaDatDialog_file_selected(pathArgument: String):
	if editingImg.is_empty() or editingImg.get_format() != Image.FORMAT_L8:
		oMessage.big("Error", "Cannot export. Internal image is not in L8 format or is empty.")
		return
	var file = File.new()
	if file.open(pathArgument, File.WRITE) == OK:
		file.store_buffer(editingImg.get_data())
		file.close()
		oMessage.quick("Exported : " + pathArgument.get_file())
	else:
		oMessage.big("Error", "Failed to open file for writing: " + pathArgument)


func _on_ModifyTexturesButton_pressed():
	var folderToOpen = getOpenFolder if getOpenFolder != "" else getPackFolder
	OS.shell_open(folderToOpen.replace("/", "\\") if OS.get_name() == "Windows" else folderToOpen)


func _on_ExportTmapaButton_pressed():
	Utils.popup_centered(oExportTmapaDatDialog)
	oExportTmapaDatDialog.current_dir = oGame.DK_DATA_DIRECTORY
	oExportTmapaDatDialog.current_path = oGame.DK_DATA_DIRECTORY
	var tmapaFilename = get_tmap_number_string()
	if tmapaFilename != null:
		var prefix = "tmapb" if fileListFilePath.begins_with("tmapb") else "tmapa"
		oExportTmapaDatDialog.current_file = prefix + tmapaFilename + ".dat"
	else:
		oExportTmapaDatDialog.current_file = "tmapa" + str(oDataLevelStyle.data).pad_zeros(3) + ".dat"


func _on_CreateFilelistButton_pressed():
	Utils.popup_centered(oChooseTmapaFileDialog)
	var filePath = find_best_tmapa_file()
	oChooseTmapaFileDialog.current_dir = filePath.get_base_dir().plus_file("")
	oChooseTmapaFileDialog.current_path = filePath.get_base_dir().plus_file("")
	oChooseTmapaFileDialog.current_file = filePath.get_file()


func find_best_tmapa_file() -> Array:
	var tmapaFiles = []
	
	if oCfgLoader.paths_loaded.has(oCfgLoader.LOAD_CFG_CURRENT_MAP):
		for filePath in oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP]:
			if filePath.ends_with("dat"):
				if "tmapa" in filePath or "tmapb" in filePath:
					return filePath
	
	if oCfgLoader.paths_loaded.has(oCfgLoader.LOAD_CFG_CAMPAIGN):
		for filePath in oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CAMPAIGN]:
			if filePath.ends_with("dat"):
				if "tmapa" in filePath or "tmapb" in filePath:
					return filePath
	
	if oCfgLoader.paths_loaded.has(oCfgLoader.LOAD_CFG_DATA):
		for filePath in oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_DATA]:
			if filePath.ends_with("dat"):
				if "tmapa" in filePath or "tmapb" in filePath:
					return filePath
	
	return oGame.DK_DATA_DIRECTORY


func _on_ChooseTmapaFileDialog_file_selected(pathArgument: String):
	var sourceRgbImage = convert_dat_to_rgb_image(pathArgument)
	if sourceRgbImage == null or sourceRgbImage.is_empty():
		oMessage.big("Error", "Failed to load or convert TMAPA.DAT to image.")
		return
	var datBasename = pathArgument.get_file().get_basename()
	var numberStringFromDat = datBasename.trim_prefix('tmapa').trim_prefix('tmapb')
	var isTmapbFile = datBasename.begins_with('tmapb')
	handle_export(sourceRgbImage, numberStringFromDat, isTmapbFile)


func handle_export(sourceRgbImage: Image, numberString: String, isTmapb: bool):
	var codeTimeStart = OS.get_ticks_msec()
	if isTmapb:
		handle_tmapb_export(sourceRgbImage, numberString)
	else:
		handle_tmapa_export(sourceRgbImage, numberString)
	print('Exported Filelist in: ' + str(OS.get_ticks_msec() - codeTimeStart) + 'ms')
	reloader_loop()


func handle_tmapa_export(sourceRgbImage: Image, numberString: String):
	var outputDir = get_output_directory()
	var filelistName = "tmapa" + numberString
	var filelistContent = ExportFilelist.new().string.replace("subdir", filelistName).replace("textures_pack_number", "textures_pack_" + numberString)
	var imageDictionary = build_image_dictionary(filelistContent)
	var uniqueDirectories = get_unique_directories(imageDictionary, outputDir)
	if check_directories_exist(uniqueDirectories):
		var message = "The folder of .PNGs already exists, they will be overwritten: \n" + outputDir + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
		var userConfirmed = yield(show_confirmation_dialog(message), "completed")
		if userConfirmed == false:
			oMessage.quick("Cancelled")
			return
	create_directories(uniqueDirectories)
	create_images_from_dictionary(imageDictionary, sourceRgbImage)
	save_images_to_disk(imageDictionary, outputDir)
	setup_reloader(filelistName, outputDir, filelistContent, outputDir.plus_file(filelistName))


func handle_tmapb_export(sourceRgbImage: Image, numberString: String):
	var outputDir = get_output_directory()
	var filelistName = "tmapb" + numberString
	var packFolder = outputDir.plus_file(filelistName)
	var uniqueDirectories = {packFolder: true}
	if check_directories_exist(uniqueDirectories):
		var message = "The folder of .PNGs already exists, they will be overwritten: \n" + packFolder + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
		var userConfirmed = yield(show_confirmation_dialog(message), "completed")
		if userConfirmed == false:
			oMessage.quick("Cancelled")
			return
	create_directories(uniqueDirectories)
	var pngPath = packFolder.plus_file(filelistName + ".png")
	var errCode = sourceRgbImage.save_png(pngPath)
	if errCode == OK:
		oMessage.quick("Exported : " + filelistName + ".png")
	else:
		printerr("Failed to save PNG: ", pngPath, " Error code: ", errCode)
		oMessage.big("Error", "Failed to save PNG: " + filelistName + ".png")
		return
	var filelistContent = filelistName + ".png\t0\t0\t256\t2176"
	editingImg = Image.new()
	editingImg.create(256, 2176, false, Image.FORMAT_L8)
	editingImg.fill(Color(0, 0, 0))
	var sourceL8Image = convert_rgb_image_to_l8(sourceRgbImage)
	if sourceL8Image != null and sourceL8Image.is_empty() == false:
		editingImg.blit_rect(sourceL8Image, Rect2(0, 0, sourceL8Image.get_width(), sourceL8Image.get_height()), Vector2(0, 0))
	setup_reloader(filelistName, packFolder, filelistContent, packFolder)


func build_image_dictionary(flContent: String) -> Dictionary:
	var imageDictionary = {}
	var rawLines = Array(flContent.split('\n', false))
	if rawLines.empty() == false: rawLines.pop_front()
	for iIdx in rawLines.size():
		var lineDataArray = Array(rawLines[iIdx].split('\t', false))
		var localPath = lineDataArray[0]
		var posX = int(lineDataArray[1]) + int(lineDataArray[3])
		var posY = int(lineDataArray[2]) + int(lineDataArray[4])
		if imageDictionary.has(localPath) == false:
			imageDictionary[localPath] = {"max_x":0, "max_y":0, "image_obj":null, "tiles_info":[]}
		imageDictionary[localPath]["max_x"] = max(posX, imageDictionary[localPath]["max_x"])
		imageDictionary[localPath]["max_y"] = max(posY, imageDictionary[localPath]["max_y"])
		imageDictionary[localPath]["tiles_info"].append({"line_data": lineDataArray, "source_flat_index": iIdx})
	for localPath in imageDictionary:
		var imgData = imageDictionary[localPath]
		var createNewImage = Image.new()
		createNewImage.create(imgData["max_x"], imgData["max_y"], false, Image.FORMAT_RGB8)
		imgData["image_obj"] = createNewImage
	return imageDictionary


func create_images_from_dictionary(imageDictionary: Dictionary, sourceRgbImage: Image):
	sourceRgbImage.lock()
	for localPath in imageDictionary:
		var imgData = imageDictionary[localPath]
		var currentPngImage:Image = imgData["image_obj"]
		currentPngImage.lock()
		for tileEntry in imgData["tiles_info"]:
			var lineDataArray = tileEntry["line_data"]
			var sourceTileFlatIndex = tileEntry["source_flat_index"]
			var sourceTileY = sourceTileFlatIndex / 8
			var sourceTileX = sourceTileFlatIndex % 8
			var destXInPng = int(lineDataArray[1])
			var destYInPng = int(lineDataArray[2])
			currentPngImage.blit_rect(sourceRgbImage, Rect2(sourceTileX*32, sourceTileY*32, 32,32), Vector2(destXInPng, destYInPng))
		currentPngImage.unlock()
	sourceRgbImage.unlock()


func get_unique_directories(imageDictionary: Dictionary, outputDir: String) -> Dictionary:
	var uniqueDirectories = {}
	for localPath in imageDictionary:
		uniqueDirectories[outputDir.plus_file(localPath).get_base_dir()] = true
	return uniqueDirectories


func check_directories_exist(uniqueDirectories: Dictionary) -> bool:
	var dir = Directory.new()
	for packFolder in uniqueDirectories:
		if dir.dir_exists(packFolder): return true
	return false


func create_directories(uniqueDirectories: Dictionary):
	var dir = Directory.new()
	for packFolder in uniqueDirectories:
		dir.make_dir_recursive(packFolder)


func save_images_to_disk(imageDictionary: Dictionary, outputDir: String):
	for localPath in imageDictionary:
		var savePath = outputDir.plus_file(localPath)
		var imageToSave: Image = imageDictionary[localPath]["image_obj"]
		if imageToSave != null and imageToSave is Image:
			var errCode = imageToSave.save_png(savePath)
			if errCode == OK:
				oMessage.quick("Exported : textures/" + localPath)
			else:
				printerr("Failed to save PNG: ", savePath, " Error code: ", errCode)
				oMessage.big("Error", "Failed to save PNG: " + localPath)
		else:
			printerr("Cannot save PNG, image_obj is null or not an Image for path: ", localPath, ". Object is: ", imageToSave)


func setup_reloader(fileListName: String, packFolder: String, filelistContent: String, openFolder: String = ""):
	getPackFolder = packFolder
	getOpenFolder = openFolder if openFolder != "" else packFolder
	oReloaderPathPackLabel.text = getPackFolder
	fileListFilePath = fileListName
	oReloaderPathLabel.text = "Using hardcoded " + fileListName + " data"
	oExportTmapaButton.disabled = false
	oExportTmapaButton.set_tooltip("")
	initialize_filelist(filelistContent)


func convert_dat_to_rgb_image(datPathArgument: String) -> Image:
	var l8FullImage: Image = oTMapLoader.create_l8_image(datPathArgument)
	if l8FullImage == null or l8FullImage.is_empty(): return null
	var rgbFullImage = Image.new()
	rgbFullImage.create(l8FullImage.get_width(), l8FullImage.get_height(), false, Image.FORMAT_RGB8)
	var paletteColors: Array = oReadPalette.get_palette_data()
	if paletteColors.empty(): return null
	l8FullImage.lock()
	rgbFullImage.lock()
	for yPx in l8FullImage.get_height():
		for xPx in l8FullImage.get_width():
			var paletteIndex = int(l8FullImage.get_pixel(xPx, yPx).r * 255.0 + 0.5)
			var color = paletteColors[paletteIndex] if paletteIndex >= 0 and paletteIndex < paletteColors.size() else Color(1,0,1)
			rgbFullImage.set_pixel(xPx, yPx, color)
	l8FullImage.unlock()
	rgbFullImage.unlock()
	return rgbFullImage
