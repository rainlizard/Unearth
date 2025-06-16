extends Node

onready var oChooseTmapFileDialog = Nodelist.list["oChooseTmapFileDialog"]
onready var oGame = Nodelist.list["oGame"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oTeditSavePNG = Nodelist.list["oTeditSavePNG"]
onready var oTextureEditingWindow = Nodelist.list["oTextureEditingWindow"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oTeditSaveDAT = Nodelist.list["oTeditSaveDAT"]


func start_file_selection():
	Utils.popup_centered(oChooseTmapFileDialog)
	var filePath = find_best_tmap_file()
	var baseDir = filePath.get_base_dir().plus_file("")
	oChooseTmapFileDialog.current_dir = baseDir
	oChooseTmapFileDialog.current_path = baseDir
	var fileName = filePath.get_file()
	oChooseTmapFileDialog.current_file = fileName


func find_best_tmap_file() -> String:
	if oCfgLoader.paths_loaded.has(oCfgLoader.LOAD_CFG_CURRENT_MAP):
		for filePath in oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CURRENT_MAP]:
			if filePath.ends_with("dat"):
				var lowerPath = filePath.to_lower()
				if "tmapa" in lowerPath or "tmapb" in lowerPath:
					return filePath
	if oCfgLoader.paths_loaded.has(oCfgLoader.LOAD_CFG_CAMPAIGN):
		for filePath in oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_CAMPAIGN]:
			if filePath.ends_with("dat"):
				var lowerPath = filePath.to_lower()
				if "tmapa" in lowerPath or "tmapb" in lowerPath:
					return filePath
	if oCfgLoader.paths_loaded.has(oCfgLoader.LOAD_CFG_DATA):
		for filePath in oCfgLoader.paths_loaded[oCfgLoader.LOAD_CFG_DATA]:
			if filePath.ends_with("dat"):
				var lowerPath = filePath.to_lower()
				if "tmapa" in lowerPath or "tmapb" in lowerPath:
					return filePath
	var fallbackPath = oGame.DK_DATA_DIRECTORY
	return fallbackPath


func _on_ChooseTmapFileDialog_file_selected(pathArgument: String):
	var sourceRgbImage = convert_dat_to_rgb_image(pathArgument)
	if sourceRgbImage == null or sourceRgbImage.is_empty():
		oMessage.big("Error", "Failed to load or convert TMAP.DAT to image.")
		return
	var folderNameString = generate_folder_name(pathArgument)
	var isTmapbFile = is_tmapb_file(pathArgument)
	store_original_dat_info(pathArgument)
	export_texture_pack(sourceRgbImage, folderNameString, isTmapbFile)


func is_tmapb_file(pathArgument: String) -> bool:
	var datBasename = pathArgument.get_file().get_basename()
	return datBasename.to_lower().find('tmapb') != -1


func generate_folder_name(pathArgument: String) -> String:
	var datBasename = pathArgument.get_file().get_basename()
	var isTmapbFile = is_tmapb_file(pathArgument)
	var mapType = 'tmapb' if isTmapbFile else 'tmapa'
	var mapTypeWithDot = '.' + mapType
	var mapTypeIndex = datBasename.to_lower().find(mapTypeWithDot)
	var folderName = ""
	if mapTypeIndex != -1:
		var mapName = datBasename.substr(0, mapTypeIndex)
		var numberPart = datBasename.substr(mapTypeIndex + mapTypeWithDot.length())
		folderName = mapName + "_" + mapType + numberPart
	else:
		folderName = datBasename
	return folderName


func export_texture_pack(sourceRgbImage: Image, folderNameString: String, isTmapbFile: bool):
	oTeditSavePNG.handle_tmap_export(sourceRgbImage, folderNameString)


func store_original_dat_info(pathArgument: String):
	var originalDatFilename = pathArgument.get_file()
	var originalDatDir = pathArgument.get_base_dir().plus_file("")
	var originalDatPath = pathArgument.get_base_dir().plus_file("")
	oTeditSaveDAT.set_original_dat_info(originalDatFilename, originalDatDir, originalDatPath)


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
