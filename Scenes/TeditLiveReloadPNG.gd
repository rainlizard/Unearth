extends Node

onready var oTabTileset = Nodelist.list["oTabTileset"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]

var editingImg = Image.new()
var fileHashes = []
var partsList = []
var modifiedCheck = File.new()
var packFolder = ""
var packType = "tmapa"
var packNumber = -1
var lastError = ""
var reloadTimer = 0.0


func _ready():
	set_process(false)


func _process(delta):
	reloadTimer += delta
	if reloadTimer >= 0.25:
		reloadTimer = 0.0
		execute()


func initialize_pack(contentString: String, reloaderPath: String, type: String, number: int):
	packFolder = reloaderPath
	packType = type
	packNumber = number
	lastError = ""
	editingImg = oTabTileset.images[packType].duplicate()
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
	fileHashes.resize(partsList.size())
	for i in partsList.size():
		var path = packFolder.plus_file(partsList[i][0]) if partsList[i].empty() == false else ""
		fileHashes[i] = modifiedCheck.get_md5(path) if path != "" and modifiedCheck.file_exists(path) else ""


func set_enabled(value: bool):
	set_process(value)


func stop_session():
	set_process(false)
	packFolder = ""
	partsList.clear()


func execute():
	if Directory.new().dir_exists(packFolder) == false:
		if lastError != "Editing folder no longer exists":
			lastError = "Editing folder no longer exists"
			oTabTileset.set_reload_status(packType, packNumber, lastError)
		return
	if lastError == "Editing folder no longer exists":
		lastError = ""
		oTabTileset.set_reload_status(packType, packNumber, "Waiting for changes...")
	lastError = ""
	var partsModifiedIndices = []
	var currentHashes = {}
	for i in partsList.size():
		if partsList[i].empty():
			continue
		var path = packFolder.plus_file(partsList[i][0])
		if modifiedCheck.file_exists(path) == false:
			continue
		if currentHashes.has(path) == false:
			currentHashes[path] = modifiedCheck.get_md5(path)
		if currentHashes[path] != fileHashes[i]:
			partsModifiedIndices.append(i)
	if partsModifiedIndices.empty(): return
	var loadedImages = {}
	var updatedImage = editingImg.duplicate()
	for partIndex in partsModifiedIndices:
		var partData = partsList[partIndex]
		var path = packFolder.plus_file(partData[0])
		if loadedImages.has(path) == false:
			var image = Image.new()
			if image.load(path) != OK:
				lastError = "Reload failed: could not read " + path.get_file()
				break
			image.convert(Image.FORMAT_RGB8)
			loadedImages[path] = image
		var imgLoader = loadedImages[path]
		var srcRectInPng = Rect2(int(partData[1]), int(partData[2]), int(partData[3]), int(partData[4]))
		if Rect2(Vector2.ZERO, imgLoader.get_size()).encloses(srcRectInPng) == false:
			lastError = "Reload failed: unexpected image size in " + path.get_file()
			break
		var tileSubImageRgb = imgLoader.get_rect(srcRectInPng)
		if tileSubImageRgb == null or tileSubImageRgb.is_empty():
			lastError = "Reload failed: invalid region in " + path.get_file()
			break
		var destinationCoords = Vector2((partIndex % 8) * 32, (partIndex / 8) * 32)
		var referenceImage = updatedImage.get_rect(Rect2(destinationCoords, srcRectInPng.size))
		var tileSubImageL8 = oTMapLoader.create_l8_image_from_rgb(tileSubImageRgb, referenceImage)
		if tileSubImageL8 == null or tileSubImageL8.is_empty():
			lastError = "Reload failed: palette conversion failed for " + path.get_file()
			break
		updatedImage.lock()
		updatedImage.blit_rect(tileSubImageL8, Rect2(0,0, tileSubImageL8.get_width(), tileSubImageL8.get_height()), destinationCoords)
		updatedImage.unlock()
	if lastError != "":
		oTabTileset.set_reload_status(packType, packNumber, lastError)
		return
	for partIndex in partsModifiedIndices:
		var path = packFolder.plus_file(partsList[partIndex][0])
		fileHashes[partIndex] = currentHashes[path]
	editingImg = updatedImage
	if oTabTileset.apply_external_image(packType, packNumber, editingImg, int(ceil(float(partsList.size()) / 8.0)) * 32):
		oTabTileset.set_reload_status(packType, packNumber, "Reloaded " + partsList[partsModifiedIndices[0]][0].get_file())
