extends Node

onready var oMessage = Nodelist.list["oMessage"]
onready var oTabTileset = Nodelist.list["oTabTileset"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]

const ExportFilelists = {
	"tmapa": preload("res://Scenes/exportfilelist_tmapa.gd"),
	"tmapb": preload("res://Scenes/exportfilelist_tmapb.gd"),
}

func handle_tmap_export(mapName: String, number: int):
	var outputDir = get_output_directory().plus_file(mapName)
	var numberString = str(number).pad_zeros(3)
	var packName = "pack" + numberString
	var packFolderPath = outputDir.plus_file(packName)
	var directory = Directory.new()
	for type in ExportFilelists:
		if File.new().file_exists(outputDir.plus_file("filelist_" + type + numberString + ".txt")):
			oTabTileset.register_editing_session(number, outputDir, true)
			open_texture_folder(outputDir)
			return
	if directory.dir_exists(packFolderPath):
		oMessage.big("Incomplete texture pack", "The filelists are missing from:\n" + outputDir)
		return
	var rgbImages = {}
	for type in oTabTileset.TYPES:
		rgbImages[type] = oTMapLoader.create_rgb_image(oTabTileset.images[type])
		if rgbImages[type] == null or rgbImages[type].is_empty():
			oMessage.big("Error", "Could not create the editable PNG because the Tileset palette is unavailable.")
			return
	var filelists = {}
	var imageDictionary = {}
	for type in ExportFilelists:
		var content = ExportFilelists[type].CONTENT.replace("textures_pack_000", "textures_pack_" + numberString)
		var lines = Array(content.split("\n", false))
		var header = lines.pop_front()
		content = header
		for tileIndex in lines.size():
			var line = Array(lines[tileIndex].split("\t", false))
			var localPath = packName + "/" + line[0]
			content += "\n" + packName + "/" + lines[tileIndex]
			if imageDictionary.has(localPath) == false:
				imageDictionary[localPath] = {"max_x": 0, "max_y": 0, "tiles": []}
			var data = imageDictionary[localPath]
			data.max_x = max(data.max_x, int(line[1]) + int(line[3]))
			data.max_y = max(data.max_y, int(line[2]) + int(line[4]))
			data.tiles.append({"line": line, "index": tileIndex, "type": type})
		filelists[type] = content
	if directory.make_dir_recursive(packFolderPath) != OK:
		oMessage.big("Error", "Could not create texture folder: " + packFolderPath)
		return
	for type in rgbImages:
		rgbImages[type].lock()
	for localPath in imageDictionary:
		var data = imageDictionary[localPath]
		var image = Image.new()
		image.create(data.max_x, data.max_y, false, Image.FORMAT_RGB8)
		image.lock()
		for tile in data.tiles:
			var line = tile.line
			image.blit_rect(rgbImages[tile.type], Rect2((tile.index % 8) * 32, (tile.index / 8) * 32, 32, 32), Vector2(int(line[1]), int(line[2])))
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
