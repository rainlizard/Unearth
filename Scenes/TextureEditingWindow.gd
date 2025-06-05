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

var filelistfile = File.new()
var fileListFilePath = ""
var editingImg = Image.new()
var fileTimes = []
var partsList = []
var modifiedCheck = File.new()
var getPackFolder = ""


func _ready():
	editingImg.create(8*32, 68*32, false, Image.FORMAT_L8)
	oExportTmapaButton.disabled = true
	oExportTmapaButton.set_tooltip("A filelist pack must be loaded first in order to export")
	oReloaderPathLabel.text = ""
	oReloaderPathPackLabel.text = ""


func reloader_loop():
	if fileListFilePath != "":
		execute()
	yield(get_tree().create_timer(0.25), "timeout")
	reloader_loop()


func _on_TextureEditingHelpButton_pressed():
	var helptxt = """After you load a tileset, a bunch of .PNG files will be saved to your hard drive. Edit these files in your favourite image editor.
Unearth will actively reload the textures in real-time as you edit and save those .PNGs. So any edits you make will be shown in real-time in Unearth. This applies to the 3D view too, so press Spacebar while in the 3D view to stop the camera from moving."""
	oMessage.big("Help", helptxt)


func initialize_filelist():
	partsList.clear()
	if filelistfile.open(fileListFilePath, File.READ) != OK: return
	var flContent = filelistfile.get_as_text()
	filelistfile.close()
	partsList = Array(flContent.split('\n', false))
	if partsList.empty() == false:
		partsList.pop_front()
	var validParts = []
	for i in partsList.size():
		var originalLine = partsList[i]
		var line_data = originalLine.split('\t', false)
		if line_data.size() >= 5:
			validParts.append(line_data)
		else:
			validParts.append([]) 
			printerr("Invalid line in filelist (line ", i+2, "): '", originalLine, "' - Marked as invalid.")
	partsList = validParts
	if fileTimes.size() != partsList.size():
		fileTimes.resize(partsList.size())
		fileTimes.fill(-1)
	var fn = get_tmapa_filename_number_string()
	if fn != null and oDataLevelStyle.data != int(fn):
		oDataLevelStyle.data = int(fn)
		oTMapLoader.apply_texture_pack()
		oEditor.mapHasBeenEdited = true
		oMessage.quick("Changed map's Tileset to show what you're currently editing")


func _find_closest_palette_index(targetColor: Color, paletteArray: Array) -> int:
	if paletteArray.empty():
		printerr("Palette is empty in _find_closest_palette_index.")
		return 0
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
			if minDistanceSq == 0.0:
				break
	return closestIndex


func _convert_rgb_image_to_l8(rgb_image: Image) -> Image:
	if rgb_image == null or rgb_image.is_empty():
		printerr("Input RGB image is null or empty for L8 conversion.")
		return null
	var localPaletteArray: Array = oReadPalette.get_palette_data()
	if localPaletteArray.empty():
		printerr("Palette data is empty, cannot convert RGB to L8.")
		return null
	var l8_image = Image.new()
	l8_image.create(rgb_image.get_width(), rgb_image.get_height(), false, Image.FORMAT_L8)
	var colorToIndexCache = {}
	rgb_image.lock()
	l8_image.lock()
	for y_coord in rgb_image.get_height():
		for x_coord in rgb_image.get_width():
			var rgb_color = rgb_image.get_pixel(x_coord, y_coord)
			var palette_index: int
			if colorToIndexCache.has(rgb_color):
				palette_index = colorToIndexCache[rgb_color]
			else:
				palette_index = _find_closest_palette_index(rgb_color, localPaletteArray)
				colorToIndexCache[rgb_color] = palette_index
			var gray_value = float(palette_index) / 255.0
			l8_image.set_pixel(x_coord, y_coord, Color(gray_value, gray_value, gray_value))
	rgb_image.unlock()
	l8_image.unlock()
	return l8_image


func execute():
	var anyChangesWereMade = false
	var imgLoader = Image.new()
	var baseDir = fileListFilePath.get_base_dir()
	var partsModifiedIndices = []
	for i in partsList.size():
		if partsList[i].empty(): continue
		var path = baseDir.plus_file(partsList[i][0])
		if modifiedCheck.file_exists(path) and modifiedCheck.get_modified_time(path) != fileTimes[i]:
			partsModifiedIndices.append(i)
	if partsModifiedIndices.empty() == false:
		var tmap_filename = get_tmapa_filename_from_path(fileListFilePath)
		var is_tmapb = tmap_filename != null and tmap_filename.begins_with("tmapb")
		
		if is_tmapb:
			execute_tmapb_reloading(partsModifiedIndices, baseDir, imgLoader)
		else:
			execute_tmapa_reloading(partsModifiedIndices, baseDir, imgLoader)
		anyChangesWereMade = true
	if anyChangesWereMade:
		var tmapa_full_filename = get_tmapa_filename_from_path(fileListFilePath)
		if tmapa_full_filename != null:
			var tmap_number_str = tmapa_full_filename.trim_prefix("tmapa").trim_prefix("tmapb")
			var tmap_number = int(tmap_number_str)
			var tmap_type = "tmapa" if tmapa_full_filename.begins_with("tmapa") else "tmapb"
			oTMapLoader.cache_loaded_image(editingImg, tmap_number, tmap_type)
			oTMapLoader.apply_texture_pack()


func execute_tmapa_reloading(partsModifiedIndices: Array, baseDir: String, imgLoader: Image):
	editingImg.lock()
	for i in partsModifiedIndices:
		var part_data = partsList[i]
		var path = baseDir.plus_file(part_data[0])
		fileTimes[i] = modifiedCheck.get_modified_time(path)
		if imgLoader.load(path) != OK:
			printerr("Failed to load image: ", path)
			continue
		imgLoader.convert(Image.FORMAT_RGB8)
		var src_rect_in_png = Rect2(int(part_data[1]), int(part_data[2]), int(part_data[3]), int(part_data[4]))
		var tile_sub_image_rgb = imgLoader.get_rect(src_rect_in_png)
		if tile_sub_image_rgb == null or tile_sub_image_rgb.is_empty():
			printerr("Failed to get_rect from ", path, " with rect ", src_rect_in_png)
			continue
		var tile_sub_image_l8 = _convert_rgb_image_to_l8(tile_sub_image_rgb)
		if tile_sub_image_l8 == null or tile_sub_image_l8.is_empty():
			printerr("Failed to convert tile to L8 from: ", path)
			continue
		var dest_tile_x = i % 8
		var dest_tile_y = i / 8
		var destination_coords = Vector2(dest_tile_x * 32, dest_tile_y * 32)
		editingImg.blit_rect(tile_sub_image_l8, Rect2(0,0, tile_sub_image_l8.get_width(), tile_sub_image_l8.get_height()), destination_coords)
	editingImg.unlock()


func execute_tmapb_reloading(partsModifiedIndices: Array, baseDir: String, imgLoader: Image):
	for i in partsModifiedIndices:
		var part_data = partsList[i]
		var path = baseDir.plus_file(part_data[0])
		fileTimes[i] = modifiedCheck.get_modified_time(path)
		if imgLoader.load(path) != OK:
			printerr("Failed to load image: ", path)
			continue
		imgLoader.convert(Image.FORMAT_RGB8)
		var src_rect_in_png = Rect2(int(part_data[1]), int(part_data[2]), int(part_data[3]), int(part_data[4]))
		var tile_sub_image_rgb = imgLoader.get_rect(src_rect_in_png)
		if tile_sub_image_rgb == null or tile_sub_image_rgb.is_empty():
			printerr("Failed to get_rect from ", path, " with rect ", src_rect_in_png)
			continue
		var tile_sub_image_l8 = _convert_rgb_image_to_l8(tile_sub_image_rgb)
		if tile_sub_image_l8 == null or tile_sub_image_l8.is_empty():
			printerr("Failed to convert tile to L8 from: ", path)
			continue
		editingImg.lock()
		editingImg.blit_rect(tile_sub_image_l8, Rect2(0,0, tile_sub_image_l8.get_width(), tile_sub_image_l8.get_height()), Vector2(int(part_data[1]), int(part_data[2])))
		editingImg.unlock()


func get_tmapa_filename_from_path(full_path_argument: String):
	var filename = full_path_argument.get_file()
	if (filename.begins_with("filelist_tmapa") or filename.begins_with("filelist_tmapb")) and filename.ends_with(".txt"):
		return filename.trim_prefix("filelist_").trim_suffix(".txt")
	return null


func get_tmapa_filename_number_string():
	if fileListFilePath.empty(): return null
	var tmapa_file_part = get_tmapa_filename_from_path(fileListFilePath)
	if tmapa_file_part != null and (tmapa_file_part.begins_with("tmapa") or tmapa_file_part.begins_with("tmapb")):
		return tmapa_file_part.trim_prefix("tmapa").trim_prefix("tmapb")
	return null


func _on_ExportTmapaDatDialog_file_selected(path_argument: String):
	var buffer = StreamPeerBuffer.new()
	if editingImg.is_empty() or editingImg.get_format() != Image.FORMAT_L8:
		oMessage.big("Error", "Cannot export. Internal image is not in L8 format or is empty.")
		return
	editingImg.lock()
	for y_coord in editingImg.get_height():
		for x_coord in editingImg.get_width():
			var pixel_color = editingImg.get_pixel(x_coord, y_coord)
			var palette_index = int(pixel_color.r * 255.0 + 0.5)
			buffer.put_8(palette_index)
	editingImg.unlock()
	var file = File.new()
	if file.open(path_argument, File.WRITE) == OK:
		file.store_buffer(buffer.data_array)
		file.close()
		oMessage.quick("Exported : " + path_argument.get_file())
	else:
		oMessage.big("Error", "Failed to open file for writing: " + path_argument)


func _on_ModifyTexturesButton_pressed():
	match OS.get_name():
		"Windows": OS.shell_open(getPackFolder.replace("/", "\\"))
		"X11", "OSX": OS.shell_open(getPackFolder)


func _on_ExportTmapaButton_pressed():
	Utils.popup_centered(oExportTmapaDatDialog)
	oExportTmapaDatDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportTmapaDatDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	var tmapa_filename = get_tmapa_filename_from_path(fileListFilePath)
	if tmapa_filename != null:
		oExportTmapaDatDialog.current_file = tmapa_filename + ".dat"
	else:
		oExportTmapaDatDialog.current_file = "tmapa000.dat"


func _on_CreateFilelistButton_pressed():
	Utils.popup_centered(oChooseTmapaFileDialog)
	oChooseTmapaFileDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oChooseTmapaFileDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oChooseTmapaFileDialog.current_file = "tmapa000.dat"


func _on_ChooseTmapaFileDialog_file_selected(path_argument: String):
	var source_rgb_image = _convert_dat_to_rgb_image(path_argument)
	if source_rgb_image == null or source_rgb_image.is_empty():
		oMessage.big("Error", "Failed to load or convert TMAPA.DAT to image.")
		return
	
	var dat_basename = path_argument.get_file().get_basename()
	var number_string_from_dat = dat_basename.trim_prefix('tmapa').trim_prefix('tmapb')
	var is_tmapb_file = dat_basename.begins_with('tmapb')
	
	if is_tmapb_file:
		handle_tmapb_export(source_rgb_image, number_string_from_dat, path_argument)
	else:
		handle_tmapa_export(source_rgb_image, number_string_from_dat, path_argument)


func handle_tmapb_export(sourceRgbImage: Image, numberStringArgument: String, pathArgument: String):
	var CODETIME_START = OS.get_ticks_msec()
	var outputDir = ""
	if OS.has_feature('editor'):
		outputDir = OS.get_user_data_dir().plus_file("UnearthEditorTextureCache")
	else:
		outputDir = Settings.unearth_path.plus_file("textures")
	
	var dir = Directory.new()
	var packFolder = outputDir.plus_file("tmapb" + numberStringArgument)
	
	if dir.dir_exists(packFolder):
		var confirmDialog = ConfirmationDialog.new()
		confirmDialog.dialog_text = "The folder already exists, files will be overwritten: \n" + packFolder + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
		confirmDialog.window_title = "Confirm File Replacement"
		confirmDialog.popup_exclusive = true
		add_child(confirmDialog)
		var confirmationHolder = [false]
		confirmDialog.connect("confirmed", self, "mark_dialog_confirmed", [confirmationHolder, 0])
		confirmDialog.popup_centered()
		yield(confirmDialog, "popup_hide")
		yield(get_tree(), "idle_frame")
		var userConfirmed = confirmationHolder[0]
		confirmDialog.queue_free()
		if userConfirmed == false:
			oMessage.quick("Cancelled")
			return
	else:
		dir.make_dir_recursive(packFolder)
	
	editingImg = Image.new()
	editingImg.create(256, 2176, false, Image.FORMAT_L8)
	editingImg.fill(Color(0, 0, 0))
	var sourceL8Image = _convert_rgb_image_to_l8(sourceRgbImage)
	if sourceL8Image != null and sourceL8Image.is_empty() == false:
		editingImg.blit_rect(sourceL8Image, Rect2(0, 0, sourceL8Image.get_width(), sourceL8Image.get_height()), Vector2(0, 0))
	
	var pngPath = packFolder.plus_file("tmapb" + numberStringArgument + ".png")
	var err_code = sourceRgbImage.save_png(pngPath)
	if err_code == OK:
		oMessage.quick("Exported : tmapb" + numberStringArgument + ".png")
	else:
		printerr("Failed to save PNG: ", pngPath, " Error code: ", err_code)
		oMessage.big("Error", "Failed to save PNG: tmapb" + numberStringArgument + ".png")
		return
	
	getPackFolder = packFolder
	oReloaderPathPackLabel.text = getPackFolder
	
	var filelistContent = "tmapb" + numberStringArgument + ".png\t0\t0\t256\t2176"
	save_new_filelist_txt_file(filelistContent, numberStringArgument, outputDir, "tmapb")
	print('Exported TMAPB Filelist in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	reloader_loop()


func handle_tmapa_export(sourceRgbImage: Image, numberStringArgument: String, pathArgument: String):
	var CODETIME_START = OS.get_ticks_msec()
	var outputDir = ""
	if OS.has_feature('editor'):
		outputDir = OS.get_user_data_dir().plus_file("UnearthEditorTextureCache")
	else:
		outputDir = Settings.unearth_path.plus_file("textures")
	var filelistTemplateFile = File.new()
	if filelistTemplateFile.open(Settings.unearthdata.plus_file("exportfilelist.txt"), File.READ) != OK:
		oMessage.big("Error", "Could not open exportfilelist.txt template.")
		return
	var flContent = filelistTemplateFile.get_as_text()
	filelistTemplateFile.close()
	flContent = flContent.replace("subdir", "tmapa" + numberStringArgument)
	flContent = flContent.replace("textures_pack_number", "textures_pack_" + numberStringArgument)
	var raw_lines = Array(flContent.split('\n', false))
	if raw_lines.empty() == false:
		raw_lines.pop_front()
	var parsedLineArray = []
	for i in raw_lines.size():
		var items = Array(raw_lines[i].split('\t', false))
		if items.size() >=5:
			parsedLineArray.append({"data": items, "original_index": parsedLineArray.size()})
	var imageDictionary = {}
	for i_idx in parsedLineArray.size():
		var line_item = parsedLineArray[i_idx]
		var line_data_array = line_item["data"]
		var original_flat_index = line_item["original_index"]
		var localPath = line_data_array[0]
		var posX = int(line_data_array[1]) + int(line_data_array[3])
		var posY = int(line_data_array[2]) + int(line_data_array[4])
		if imageDictionary.has(localPath) == false:
			imageDictionary[localPath] = {"max_x":0, "max_y":0, "image_obj":null, "tiles_info":[]}
		imageDictionary[localPath]["max_x"] = max(posX, imageDictionary[localPath]["max_x"])
		imageDictionary[localPath]["max_y"] = max(posY, imageDictionary[localPath]["max_y"])
		imageDictionary[localPath]["tiles_info"].append({
			"line_data": line_data_array, 
			"source_flat_index": original_flat_index 
		})
	for localPath in imageDictionary:
		var img_data = imageDictionary[localPath]
		var createNewImage = Image.new()
		createNewImage.create(img_data["max_x"], img_data["max_y"], false, Image.FORMAT_RGB8)
		img_data["image_obj"] = createNewImage
	sourceRgbImage.lock()
	for localPath in imageDictionary:
		var img_data = imageDictionary[localPath]
		var current_png_image:Image = img_data["image_obj"]
		current_png_image.lock()
		for tile_entry in img_data["tiles_info"]:
			var line_data_array = tile_entry["line_data"]
			var source_tile_flat_index = tile_entry["source_flat_index"]
			var source_tile_y = source_tile_flat_index / 8
			var source_tile_x = source_tile_flat_index % 8
			var dest_x_in_png = int(line_data_array[1])
			var dest_y_in_png = int(line_data_array[2])
			current_png_image.blit_rect(sourceRgbImage, Rect2(source_tile_x*32, source_tile_y*32, 32,32), Vector2(dest_x_in_png, dest_y_in_png))
		current_png_image.unlock()
	sourceRgbImage.unlock()
	var promptedForOverwrite = false
	var dir = Directory.new()
	for localPath in imageDictionary:
		var savePath = outputDir.plus_file(localPath)
		var packFolder = savePath.get_base_dir()
		if dir.dir_exists(packFolder) == false:
			dir.make_dir_recursive(packFolder)
		else:
			if promptedForOverwrite == false:
				var confirmDialog = ConfirmationDialog.new()
				confirmDialog.dialog_text = "The folder of .PNGs already exists, they will be overwritten: \n" + packFolder + "\n\n If overwriting the files here causes you data loss then Cancel and go backup the folder."
				confirmDialog.window_title = "Confirm File Replacement"
				confirmDialog.popup_exclusive = true
				add_child(confirmDialog)
				var confirmationHolder = [false]
				confirmDialog.connect("confirmed", self, "mark_dialog_confirmed", [confirmationHolder, 0])
				confirmDialog.popup_centered()
				yield(confirmDialog, "popup_hide")
				yield(get_tree(), "idle_frame")
				var userConfirmed = confirmationHolder[0]
				confirmDialog.queue_free()
				if userConfirmed == false:
					oMessage.quick("Cancelled")
					return
				promptedForOverwrite = true
		var image_to_save: Image = imageDictionary[localPath]["image_obj"]
		if image_to_save != null and image_to_save is Image:
			var err_code = image_to_save.save_png(savePath)
			if err_code == OK:
				oMessage.quick("Exported : textures/" + localPath)
			else:
				printerr("Failed to save PNG: ", savePath, " Error code: ", err_code)
				oMessage.big("Error", "Failed to save PNG: " + localPath)
		else:
			printerr("Cannot save PNG, image_obj is null or not an Image for path: ", localPath, ". Object is: ", image_to_save)
		getPackFolder = packFolder
	oReloaderPathPackLabel.text = getPackFolder
	save_new_filelist_txt_file(flContent, numberStringArgument, outputDir, "tmapa")
	print('Exported Filelist in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	reloader_loop()


func save_new_filelist_txt_file(flContentArgument: String, numberStringArgument: String, outputDirArgument: String, tmapTypeArgument: String = "tmapa"):
	var file = File.new()
	var path = outputDirArgument.plus_file("filelist_" + tmapTypeArgument + numberStringArgument + ".txt")
	if file.open(path, File.WRITE) == OK:
		file.store_string(flContentArgument)
		file.close()
		fileListFilePath = path
		oReloaderPathLabel.text = path
		oExportTmapaButton.disabled = false
		oExportTmapaButton.set_tooltip("")
		initialize_filelist()
	else:
		oMessage.big("Error", "Could not write new filelist: " + path)


func _convert_dat_to_rgb_image(dat_path_argument: String) -> Image:
	var l8_full_image: Image = oTMapLoader.create_l8_image(dat_path_argument)
	if l8_full_image == null or l8_full_image.is_empty():
		printerr("Failed to create L8 image from DAT in _convert_dat_to_rgb_image: ", dat_path_argument)
		return null
	var rgb_full_image = Image.new()
	rgb_full_image.create(l8_full_image.get_width(), l8_full_image.get_height(), false, Image.FORMAT_RGB8)
	var palette_colors: Array = oReadPalette.get_palette_data()
	if palette_colors.empty():
		printerr("Palette array is empty. Cannot convert L8 to RGB in _convert_dat_to_rgb_image.")
		return null
	l8_full_image.lock()
	rgb_full_image.lock()
	for y_px in l8_full_image.get_height():
		for x_px in l8_full_image.get_width():
			var palette_index = int(l8_full_image.get_pixel(x_px, y_px).r * 255.0 + 0.5)
			if palette_index >= 0 and palette_index < palette_colors.size():
				rgb_full_image.set_pixel(x_px, y_px, palette_colors[palette_index])
			else:
				rgb_full_image.set_pixel(x_px, y_px, Color(1,0,1))
	l8_full_image.unlock()
	rgb_full_image.unlock()
	return rgb_full_image


func mark_dialog_confirmed(arrayReference: Array, valueIndex: int):
	arrayReference[valueIndex] = true
