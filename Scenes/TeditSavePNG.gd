extends Node

onready var oMessage = Nodelist.list["oMessage"]
onready var oTabTileset = Nodelist.list["oTabTileset"]

const ExportFilelists = {
	"tmapa": preload("res://Scenes/exportfilelist_tmapa.gd"),
	"tmapb": preload("res://Scenes/exportfilelist_tmapb.gd"),
}

func handle_tmap_export(sourceRgbImage: Image, folderNameString: String, stripFilename: String = ""):
	var outputDir = get_output_directory()
	var isStrip = stripFilename != ""
	var texturePackNumber = str(oTabTileset.tilesetNumber).pad_zeros(3)
	var packContent = ""
	if isStrip:
		packContent = "textures_pack_" + texturePackNumber
		for i in 544:
			packContent += "\n%s\t%d\t%d\t32\t32" % [stripFilename, (i % 8) * 32, (i / 8) * 32]
	else:
		packContent = ExportFilelists[oTabTileset.currentType].CONTENT.replace("textures_pack_000", "textures_pack_" + texturePackNumber)
	
	var imageDictionary = {}
	var lines = Array(packContent.split('\n', false))
	lines.pop_front()
	for tileIndex in lines.size():
		var line = Array(lines[tileIndex].split('\t', false))
		var path = line[0]
		if imageDictionary.has(path) == false:
			imageDictionary[path] = {"max_x": 0, "max_y": 0, "image": Image.new(), "tiles": []}
		var data = imageDictionary[path]
		data.max_x = max(data.max_x, int(line[1]) + int(line[3]))
		data.max_y = max(data.max_y, int(line[2]) + int(line[4]))
		data.tiles.append({"line": line, "index": tileIndex})
	var packFolderPath = outputDir if isStrip else outputDir.plus_file(folderNameString)
	var directory = Directory.new()
	var outputExists = isStrip and File.new().file_exists(packFolderPath.plus_file(stripFilename))
	for localPath in imageDictionary:
		var path = packFolderPath.plus_file(localPath).get_base_dir()
		outputExists = outputExists or isStrip == false and directory.dir_exists(path)
	if outputExists:
		var replacedPath = packFolderPath.plus_file(stripFilename) if isStrip else packFolderPath.plus_file("")
		var message = "The PNG already exists and will be overwritten: \n" if isStrip else "The folder of .PNGs already exists, they will be overwritten: \n"
		message += replacedPath + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
		var userConfirmed = yield(oTabTileset.show_confirmation_dialog(message), "completed")
		if userConfirmed == false:
			oMessage.quick("Cancelled")
			return
	sourceRgbImage.lock()
	for localPath in imageDictionary:
		var data = imageDictionary[localPath]
		directory.make_dir_recursive(packFolderPath.plus_file(localPath).get_base_dir())
		data.image.create(data.max_x, data.max_y, false, Image.FORMAT_RGB8)
		data.image.lock()
		for tile in data.tiles:
			var line = tile.line
			data.image.blit_rect(sourceRgbImage, Rect2((tile.index % 8) * 32, (tile.index / 8) * 32, 32, 32), Vector2(int(line[1]), int(line[2])))
		data.image.unlock()
		if data.image.save_png(packFolderPath.plus_file(localPath)) != OK:
			oMessage.big("Error", "Failed to save PNG: " + localPath)
			sourceRgbImage.unlock()
			return
	sourceRgbImage.unlock()
	oTabTileset.register_editing_session(oTabTileset.currentType, oTabTileset.tilesetNumber, "strip" if isStrip else "pack", packFolderPath, packContent)
	yield(get_tree(), "idle_frame")
	open_texture_folder(packFolderPath)


func get_output_directory() -> String:
	return Settings.unearth_path.plus_file("textures") if Settings.unearth_path != "" else ProjectSettings.globalize_path("res://textures")


func open_texture_folder(folderPath: String):
	if Directory.new().dir_exists(folderPath) == false:
		oMessage.big("Error", "Editing folder no longer exists:\n" + folderPath)
		return
	if OS.shell_open(ProjectSettings.globalize_path(folderPath)) != OK:
		oMessage.big("Error", "Could not open texture folder: " + folderPath)
