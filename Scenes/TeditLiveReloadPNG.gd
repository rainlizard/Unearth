extends Node

onready var oTabTileset = Nodelist.list["oTabTileset"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]

var packs = {}
var packFolder = ""
var packNumber = -1
var modifiedCheck = File.new()
var reloadTimer = 0.0


func _ready():
	set_process(false)


func _process(delta):
	reloadTimer += delta
	if reloadTimer >= 0.25:
		reloadTimer = 0.0
		execute()


func initialize_pack(folder: String, number: int, reloadAll: bool = false):
	packFolder = folder
	packNumber = number
	packs.clear()
	for type in oTabTileset.TYPES:
		_read_filelist(type, reloadAll)


func _read_filelist(type: String, reloadAll: bool):
	var path = packFolder.plus_file("filelist_" + type + str(packNumber).pad_zeros(3) + ".txt")
	var file = File.new()
	if file.open(path, File.READ) != OK:
		packs.erase(type)
		oTabTileset.set_reload_status(type, packNumber, "Filelist missing: " + path.get_file())
		return
	var content = file.get_as_text()
	file.close()
	if packs.has(type) and content == packs[type].content:
		return
	var lines = Array(content.split("\n", false))
	if lines.empty() or lines[0].strip_edges().begins_with("textures_pack_") == false:
		packs.erase(type)
		oTabTileset.set_reload_status(type, packNumber, "Invalid filelist: " + path.get_file())
		return
	lines.pop_front()
	if lines.size() > 544:
		packs.erase(type)
		oTabTileset.set_reload_status(type, packNumber, "Too many tiles in " + path.get_file())
		return
	var parts = []
	var hashes = []
	for line in lines:
		var fields = Array(line.strip_edges().split("\t", false))
		if fields.size() < 5:
			parts.append([])
			hashes.append("")
			continue
		parts.append(fields)
		var imagePath = packFolder.plus_file(fields[0])
		hashes.append("" if reloadAll else modifiedCheck.get_md5(imagePath) if modifiedCheck.file_exists(imagePath) else "")
	packs[type] = {"content": content, "parts": parts, "hashes": hashes, "image": oTabTileset.images[type].duplicate()}


func set_enabled(value: bool):
	set_process(value)


func stop_session():
	set_process(false)
	packFolder = ""
	packs.clear()


func execute():
	if Directory.new().dir_exists(packFolder) == false:
		for type in oTabTileset.TYPES:
			oTabTileset.set_reload_status(type, packNumber, "Editing folder no longer exists")
		return
	for type in oTabTileset.TYPES:
		_read_filelist(type, true)
		if packs.has(type):
			_reload_type(type)


func _reload_type(type: String):
	var pack = packs[type]
	var parts = pack.parts
	var hashes = pack.hashes
	var modifiedIndices = []
	var currentHashes = {}
	for i in parts.size():
		if parts[i].empty():
			continue
		var path = packFolder.plus_file(parts[i][0])
		if modifiedCheck.file_exists(path) == false:
			continue
		if currentHashes.has(path) == false:
			currentHashes[path] = modifiedCheck.get_md5(path)
		if currentHashes[path] != hashes[i]:
			modifiedIndices.append(i)
	if modifiedIndices.empty():
		return
	var loadedImages = {}
	var updatedImage = pack.image.duplicate()
	for partIndex in modifiedIndices:
		var partData = parts[partIndex]
		var path = packFolder.plus_file(partData[0])
		if loadedImages.has(path) == false:
			var image = Image.new()
			if image.load(path) != OK:
				oTabTileset.set_reload_status(type, packNumber, "Reload failed: could not read " + path.get_file())
				return
			image.convert(Image.FORMAT_RGB8)
			loadedImages[path] = image
		var imgLoader = loadedImages[path]
		var srcRect = Rect2(int(partData[1]), int(partData[2]), int(partData[3]), int(partData[4]))
		if Rect2(Vector2.ZERO, imgLoader.get_size()).encloses(srcRect) == false:
			oTabTileset.set_reload_status(type, packNumber, "Reload failed: unexpected image size in " + path.get_file())
			return
		var tileImage = imgLoader.get_rect(srcRect)
		var destination = Vector2((partIndex % 8) * 32, (partIndex / 8) * 32)
		var referenceImage = updatedImage.get_rect(Rect2(destination, srcRect.size))
		var converted = oTMapLoader.create_l8_image_from_rgb(tileImage, referenceImage)
		if converted == null or converted.is_empty():
			oTabTileset.set_reload_status(type, packNumber, "Reload failed: palette conversion failed for " + path.get_file())
			return
		updatedImage.lock()
		updatedImage.blit_rect(converted, Rect2(Vector2.ZERO, converted.get_size()), destination)
		updatedImage.unlock()
	for partIndex in modifiedIndices:
		hashes[partIndex] = currentHashes[packFolder.plus_file(parts[partIndex][0])]
	pack.image = updatedImage
	if oTabTileset.apply_external_image(type, packNumber, updatedImage, int(ceil(float(parts.size()) / 8.0)) * 32):
		oTabTileset.set_reload_status(type, packNumber, "Reloaded " + parts[modifiedIndices[0]][0].get_file())
