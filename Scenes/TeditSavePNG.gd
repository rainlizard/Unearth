extends Node

onready var oMessage = Nodelist.list["oMessage"]
onready var oTabTileset = Nodelist.list["oTabTileset"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oTilesetPackConfirmDialog = Nodelist.list["oTilesetPackConfirmDialog"]

const ExportFilelists = {
	"tmapa": preload("res://Scenes/exportfilelist_tmapa.gd"),
	"tmapb": preload("res://Scenes/exportfilelist_tmapb.gd"),
}

var pendingMapName = ""
var pendingNumber = -1

func handle_tmap_export(mapName: String, number: int):
	var outputDir = get_output_directory().plus_file(mapName)
	var numberString = str(number).pad_zeros(3)
	var packFolderPath = outputDir.plus_file("pack" + numberString)
	var existingFilelists = []
	for type in ExportFilelists:
		var path = outputDir.plus_file("filelist_" + type + numberString + ".txt")
		if File.new().file_exists(path):
			existingFilelists.append(path)
	if existingFilelists.empty() == false or Directory.new().dir_exists(packFolderPath):
		pendingMapName = mapName
		pendingNumber = number
		if existingFilelists.empty():
			oTilesetPackConfirmDialog.dialog_text = "No filelists found.\n\nThe /pack" + numberString + "/ folder will be erased and remade using default filelists."
		else:
			oTilesetPackConfirmDialog.dialog_text = "Existing filelists found:\n" + PoolStringArray(existingFilelists).join("\n") + "\n\nThe /pack" + numberString + "/ folder will be erased and remade using these filelists as instructions for extraction.\n(if you'd like a full reset then you should go manually delete the filelist file first)"
		Utils.popup_centered(oTilesetPackConfirmDialog)
		return
	_export_pack(mapName, number)


func _on_TilesetPackConfirmDialog_confirmed():
	if pendingNumber < 0:
		return
	var mapName = pendingMapName
	var number = pendingNumber
	pendingNumber = -1
	_export_pack(mapName, number)


func _export_pack(mapName: String, number: int):
	var outputDir = get_output_directory().plus_file(mapName)
	var numberString = str(number).pad_zeros(3)
	var packName = "pack" + numberString
	var packFolderPath = outputDir.plus_file(packName)
	var directory = Directory.new()
	var rgbImages = {}
	for type in oTabTileset.TYPES:
		rgbImages[type] = oTMapLoader.create_rgb_image(oTabTileset.images[type])
		if rgbImages[type] == null or rgbImages[type].is_empty():
			oMessage.big("Error", "Could not create the editable PNG because the Tileset palette is unavailable.")
			return
	var filelists = {}
	var imageDictionary = {}
	for type in ExportFilelists:
		var filelistPath = outputDir.plus_file("filelist_" + type + numberString + ".txt")
		var file = File.new()
		var existing = file.file_exists(filelistPath)
		var content = ""
		if existing:
			if file.open(filelistPath, File.READ) != OK:
				oMessage.big("Error", "Could not read filelist: " + filelistPath)
				return
			content = file.get_as_text()
			file.close()
		else:
			content = ExportFilelists[type].CONTENT.replace("textures_pack_000", "textures_pack_" + numberString)
		var lines = Array(content.split("\n", false))
		if lines.empty() or lines[0].strip_edges().begins_with("textures_pack_") == false or lines.size() > 545:
			oMessage.big("Error", "Invalid filelist: " + filelistPath)
			return
		var header = lines.pop_front()
		var generatedContent = header
		for tileIndex in lines.size():
			var line = Array(lines[tileIndex].strip_edges().split("\t", false))
			if line.size() < 5:
				oMessage.big("Error", "Invalid filelist entry in: " + filelistPath)
				return
			var localPath = line[0] if existing else packName + "/" + line[0]
			var relativePath = localPath.substr(packName.length() + 1)
			if localPath.begins_with(packName + "/") == false or relativePath == "" or relativePath.find("\\") != -1 or Array(relativePath.split("/")).has(".."):
				oMessage.big("Error", "Filelist PNG must be inside /" + packName + "/: " + localPath)
				return
			for i in range(1, 5):
				if line[i].is_valid_integer() == false:
					oMessage.big("Error", "Invalid filelist entry in: " + filelistPath)
					return
			if int(line[1]) < 0 or int(line[2]) < 0 or int(line[3]) < 1 or int(line[4]) < 1 or int(line[3]) > 32 or int(line[4]) > 32:
				oMessage.big("Error", "Invalid tile size or position in: " + filelistPath)
				return
			if existing == false:
				generatedContent += "\n" + packName + "/" + lines[tileIndex]
			if imageDictionary.has(localPath) == false:
				imageDictionary[localPath] = {"max_x": 0, "max_y": 0, "tiles": []}
			var data = imageDictionary[localPath]
			data.max_x = max(data.max_x, int(line[1]) + int(line[3]))
			data.max_y = max(data.max_y, int(line[2]) + int(line[4]))
			data.tiles.append({"line": line, "index": tileIndex, "type": type})
		if existing == false:
			filelists[type] = generatedContent
	if directory.dir_exists(packFolderPath) and OS.move_to_trash(ProjectSettings.globalize_path(packFolderPath)) != OK:
		oMessage.big("Error", "Could not remove texture folder: " + packFolderPath)
		return
	if directory.make_dir_recursive(packFolderPath) != OK:
		oMessage.big("Error", "Could not create texture folder: " + packFolderPath)
		return
	for type in rgbImages:
		rgbImages[type].lock()
	for localPath in imageDictionary:
		var data = imageDictionary[localPath]
		if directory.make_dir_recursive(outputDir.plus_file(localPath).get_base_dir()) != OK:
			for type in rgbImages:
				rgbImages[type].unlock()
			oMessage.big("Error", "Could not create texture folder for: " + localPath)
			return
		var image = Image.new()
		image.create(data.max_x, data.max_y, false, Image.FORMAT_RGB8)
		image.lock()
		for tile in data.tiles:
			var line = tile.line
			image.blit_rect(rgbImages[tile.type], Rect2((tile.index % 8) * 32, (tile.index / 8) * 32, int(line[3]), int(line[4])), Vector2(int(line[1]), int(line[2])))
		image.unlock()
		if image.save_png(outputDir.plus_file(localPath)) != OK:
			for type in rgbImages:
				rgbImages[type].unlock()
			oMessage.big("Error", "Failed to save PNG: " + localPath)
			return
	for type in rgbImages:
		rgbImages[type].unlock()
	for type in filelists:
		var path = outputDir.plus_file("filelist_" + type + numberString + ".txt")
		var file = File.new()
		if file.open(path, File.WRITE) != OK:
			oMessage.big("Error", "Failed to save filelist: " + path)
			return
		file.store_string(filelists[type] + "\n")
		file.close()
	oTabTileset.register_editing_session(number, outputDir)
	open_texture_folder(outputDir)


func get_output_directory() -> String:
	return Settings.unearth_path.plus_file("textures") if Settings.unearth_path != "" else ProjectSettings.globalize_path("res://textures")


func open_texture_folder(folderPath: String):
	if Directory.new().dir_exists(folderPath) == false:
		oMessage.big("Error", "Editing folder no longer exists:\n" + folderPath)
		return
	if OS.shell_open(ProjectSettings.globalize_path(folderPath)) != OK:
		oMessage.big("Error", "Could not open texture folder: " + folderPath)
