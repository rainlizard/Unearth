extends Node

onready var oMessage = Nodelist.list["oMessage"]
onready var oTeditLiveReloadPNG = Nodelist.list["oTeditLiveReloadPNG"]
onready var oTextureEditingWindow = Nodelist.list["oTextureEditingWindow"]

const ExportFilelist = preload("res://Scenes/exportfilelist.gd")

var packFolder = ""
var openFolder = ""


func handle_tmapa_export(sourceRgbImage: Image, folderNameString: String):
	var outputDir = get_output_directory()
	var packFolderName = folderNameString
	var texturePackNumber = ""
	if "_" in folderNameString:
		var parts = folderNameString.split("_")
		if parts.size() > 1:
			texturePackNumber = parts[1]
	else:
		texturePackNumber = folderNameString
	var packContent = ExportFilelist.new().string.replace("textures_pack_number", "textures_pack_" + texturePackNumber)
	var imageDictionary = build_image_dictionary(packContent)
	var packFolderPath = outputDir.plus_file(packFolderName)
	var uniqueDirectories = get_unique_directories(imageDictionary, packFolderPath)
	if check_directories_exist(uniqueDirectories):
		var fullPackPath = outputDir.plus_file(packFolderName).plus_file("")
		var message = "The folder of .PNGs already exists, they will be overwritten: \n" + fullPackPath + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
		var userConfirmed = yield(oTextureEditingWindow.show_confirmation_dialog(message), "completed")
		if userConfirmed == false:
			oMessage.quick("Cancelled")
			return
	create_directories(uniqueDirectories)
	create_images_from_dictionary(imageDictionary, sourceRgbImage)
	save_images_to_disk(imageDictionary, packFolderPath)
	setup_reloader(packFolderName, packFolderPath, packContent, packFolderPath)


func handle_tmapb_export(sourceRgbImage: Image, folderNameString: String):
	var outputDir = get_output_directory()
	var packFolderName = folderNameString
	var packFolderPath = outputDir.plus_file(packFolderName)
	var uniqueDirectories = {packFolderPath: true}
	if check_directories_exist(uniqueDirectories):
		var message = "The folder of .PNGs already exists, they will be overwritten: \n" + packFolderPath + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
		var userConfirmed = yield(oTextureEditingWindow.show_confirmation_dialog(message), "completed")
		if userConfirmed == false:
			oMessage.quick("Cancelled")
			return
	create_directories(uniqueDirectories)
	var pngPath = packFolderPath.plus_file(packFolderName + ".png")
	var errCode = sourceRgbImage.save_png(pngPath)
	if errCode != OK:
		printerr("Failed to save PNG: ", pngPath, " Error code: ", errCode)
		oMessage.big("Error", "Failed to save PNG: " + packFolderName + ".png")
		return
	var packContent = packFolderName + ".png\t0\t0\t256\t2176"
	setup_reloader(packFolderName, packFolderPath, packContent, packFolderPath)


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
		var fullDirPath = outputDir.plus_file(localPath).get_base_dir()
		uniqueDirectories[fullDirPath] = true
	return uniqueDirectories


func check_directories_exist(uniqueDirectories: Dictionary) -> bool:
	var dir = Directory.new()
	for packFolderPath in uniqueDirectories:
		if dir.dir_exists(packFolderPath): return true
	return false


func create_directories(uniqueDirectories: Dictionary):
	var dir = Directory.new()
	for packFolderPath in uniqueDirectories:
		dir.make_dir_recursive(packFolderPath)


func save_images_to_disk(imageDictionary: Dictionary, outputDir: String):
	for localPath in imageDictionary:
		var savePath = outputDir.plus_file(localPath)
		var imageToSave: Image = imageDictionary[localPath]["image_obj"]
		if imageToSave != null and imageToSave is Image:
			var errCode = imageToSave.save_png(savePath)
			if errCode != OK:
				printerr("Failed to save PNG: ", savePath, " Error code: ", errCode)
				oMessage.big("Error", "Failed to save PNG: " + localPath)
		else:
			printerr("Cannot save PNG, image_obj is null or not an Image for path: ", localPath, ". Object is: ", imageToSave)


func get_output_directory() -> String:
	var outputDir = OS.get_user_data_dir().plus_file("UnearthEditorTextureCache") if OS.has_feature('editor') else Settings.unearth_path.plus_file("textures")
	return outputDir


func setup_reloader(packFolderName: String, packFolderPath: String, packContent: String, openFolderPath: String = ""):
	packFolder = packFolderPath
	openFolder = openFolderPath if openFolderPath != "" else packFolderPath
	oTextureEditingWindow.update_reloader_path_label(packFolderPath)
	oTextureEditingWindow.enable_export_button()
	oTeditLiveReloadPNG.initialize_pack(packContent, packFolderPath)


func open_texture_folder():
	if packFolder == "" and openFolder == "":
		oMessage.big("Error", "No texture pack loaded. Please load a tileset first using 'Create Filelist'.")
		return
	var folderToOpen = openFolder if openFolder != "" else packFolder
	if not Directory.new().dir_exists(folderToOpen):
		oMessage.big("Error", "Texture folder does not exist: " + folderToOpen)
		return
	var finalPath = folderToOpen.replace("/", "\\") if OS.get_name() == "Windows" else folderToOpen
	OS.shell_open(finalPath)
