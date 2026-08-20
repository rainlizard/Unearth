extends VBoxContainer

onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oTMapNames = Nodelist.list["oTMapNames"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oTilesetIDSpinBox = Nodelist.list["oTilesetIDSpinBox"]
onready var oTilesetIDNameLabel = Nodelist.list["oTilesetIDNameLabel"]
onready var oTilesetTypeList = Nodelist.list["oTilesetTypeList"]
onready var oTilesetIDsLabel = Nodelist.list["oTilesetIDsLabel"]
onready var oCustomFilesPanel = Nodelist.list["oCustomFilesPanel"]
onready var oCustomFilesLabel = Nodelist.list["oCustomFilesLabel"]
onready var oTilesetStrip = Nodelist.list["oTilesetStrip"]
onready var oTilesetScrollContainer = Nodelist.list["oTilesetScrollContainer"]
onready var oTilesetZoom = Nodelist.list["oTilesetZoom"]
onready var oTilesetLoadDialog = Nodelist.list["oTilesetLoadDialog"]
onready var oTilesetSaveDialog = Nodelist.list["oTilesetSaveDialog"]
onready var oTilesetLiveReloading = Nodelist.list["oTilesetLiveReloading"]
onready var oTilesetExternalPathLabel = Nodelist.list["oTilesetExternalPathLabel"]
onready var oTilesetExternalConfirmDialog = Nodelist.list["oTilesetExternalConfirmDialog"]
onready var oTilesetEditingStatusLabel = Nodelist.list["oTilesetEditingStatusLabel"]
onready var oTilesetRevertButton = Nodelist.list["oTilesetRevertButton"]
onready var oTilesetRevertTilesetButton = Nodelist.list["oTilesetRevertTilesetButton"]
onready var oTilesetRevertAllButton = Nodelist.list["oTilesetRevertAllButton"]
onready var oTilesetRevertConfirmDialog = Nodelist.list["oTilesetRevertConfirmDialog"]
onready var oTeditSavePNG = Nodelist.list["oTeditSavePNG"]
onready var oTeditLiveReloadPNG = Nodelist.list["oTeditLiveReloadPNG"]
onready var oSlabStyle = Nodelist.list["oSlabStyle"]

const TYPES = ["tmapa", "tmapb"]
const IMAGE_SIZE = Vector2(256, 2176)
const TILE_SIZE = 32
const WAITING_STATUS = "Waiting for changes..."

var images = {"tmapa": null, "tmapb": null}
var inheritedImages = {"tmapa": null, "tmapb": null}
var sourcePaths = {"tmapa": "", "tmapb": ""}
var contentHeights = {"tmapa": int(IMAGE_SIZE.y), "tmapb": 0}
var modified = {"tmapa": false, "tmapb": false}
var differentFromInherited = {"tmapa": false, "tmapb": false}
var selectedIndices = {"tmapa": 0, "tmapb": 0}
var currentType = "tmapa"
var tilesetNumber = -1
var externalDialogConfirmed = false
var editingSession = {}
var revertScope = ""
var tilesetPathsToDelete = []


func _ready():
	oTilesetIDSpinBox.max_value = oTMapLoader.TMAP_COUNT - 1
	for i in TYPES.size():
		oTilesetTypeList.set_item_text(i, TYPES[i].to_upper())
	oTilesetStrip.set_zoom(1)
	_update_editing_session_ui()


func _on_TabTileset_visibility_changed():
	if is_visible_in_tree():
		if modified.tmapa == false and modified.tmapb == false:
			load_tileset(max(tilesetNumber, 0))
		else:
			_display_image()


func load_tileset(number: int):
	tilesetNumber = number
	_reset_tileset_data()
	var inheritedPaths = _get_inherited_paths()
	for identifier in inheritedPaths:
		if identifier[0] == number:
			inheritedImages[identifier[1]] = oTMapLoader.create_l8_image(inheritedPaths[identifier])
	for path in oTMapLoader.get_effective_tmap_data_from_cfgloader():
		if tilesetPathsToDelete.has(path):
			continue
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details != null and details.number == number:
			sourcePaths[details.type] = path
			images[details.type] = oTMapLoader.create_l8_image(path)
			contentHeights[details.type] = _decoded_height(path)
	for type in TYPES:
		if images[type] == null:
			images[type] = _create_blank_image()
		differentFromInherited[type] = _is_different_from_inherited(type)
	_display_image()


func _display_image():
	oTilesetIDSpinBox.set_block_signals(true)
	oTilesetIDSpinBox.value = tilesetNumber
	oTilesetIDSpinBox.set_block_signals(false)
	var tilesetName = oTMapNames.get_tileset_name(tilesetNumber)
	oTilesetIDNameLabel.text = tilesetName
	oTilesetIDNameLabel.visible = tilesetName != ""
	oTilesetTypeList.selected = TYPES.find(currentType)
	oTilesetIDSpinBox.modulate = Color(1.4,1.4,1.7) if differentFromInherited.tmapa or differentFromInherited.tmapb else Color(1,1,1)
	oTilesetTypeList.modulate = Color(1.4,1.4,1.7) if differentFromInherited[currentType] else Color(1,1,1)
	oTilesetIDsLabel.text = "IDs 0-543" if currentType == "tmapa" else "IDs 1000-1543"
	oTilesetStrip.textureIdOffset = 0 if currentType == "tmapa" else 1000
	oTilesetStrip.set_image(oTMapLoader.create_rgb_image(images[currentType]))
	oTilesetStrip.set_selected(selectedIndices[currentType])
	var inheritedPaths = _get_inherited_paths()
	var customFiles = {}
	for configType in [oConfigFileManager.LOAD_CFG_CAMPAIGN, oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
		for path in oConfigFileManager.paths_loaded.get(configType, []):
			var details = oTMapLoader.parse_tmap_path_details(path)
			if path == "" or details == null:
				continue
			var label = path.get_file()
			if configType == oConfigFileManager.LOAD_CFG_CAMPAIGN:
				label = "/" + path.get_base_dir().get_file() + "/" + label
			var inheritedPath = inheritedPaths.get([details.number, details.type], "")
			var isDifferent = inheritedPath == ""
			if inheritedPath != "":
				var customImage = oTMapLoader.create_l8_image(path)
				var inheritedImage = oTMapLoader.create_l8_image(inheritedPath)
				isDifferent = customImage == null or inheritedImage == null or customImage.get_data() != inheritedImage.get_data()
			customFiles[label] = {"path": path, "number": details.number, "type": details.type, "modified": isDifferent, "delete": tilesetPathsToDelete.has(path)}
	if modified.tmapa or modified.tmapb:
		if oCurrentMap.path == "":
			customFiles["Save map first"] = {"path": "Save the map first to create the custom Tileset files.", "number": -1, "modified": differentFromInherited.tmapa or differentFromInherited.tmapb}
		else:
			for type in TYPES:
				if modified[type]:
					var saveTarget = _get_save_target(type, oCurrentMap.path.get_file().get_basename(), oCurrentMap.path.get_base_dir())
					var targetPath = saveTarget[0]
					var deleteOnSave = differentFromInherited[type] == false and oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].has(sourcePaths[type])
					var label = "/" + targetPath.get_base_dir().get_file() + "/" + targetPath.get_file() if saveTarget[1] == oConfigFileManager.LOAD_CFG_CAMPAIGN else targetPath.get_file()
					if File.new().file_exists(targetPath) == false:
						label = "Save will create: " + label
					customFiles[label] = {"path": targetPath, "number": tilesetNumber, "type": type, "modified": differentFromInherited[type], "delete": deleteOnSave}
	var customFileLabels = customFiles.keys()
	customFileLabels.sort()
	var customFileLinks = []
	var deletedFileLinks = []
	var customFilePaths = []
	var containsModifiedFiles = false
	for label in customFileLabels:
		var fileDetails = customFiles[label]
		var link = "[url=" + str(fileDetails.number) + ":" + fileDetails.get("type", "") + "]" + label + "[/url]" if fileDetails.number >= 0 else label
		if fileDetails.get("delete", false):
			deletedFileLinks.append(link)
		else:
			customFileLinks.append(link)
		customFilePaths.append(fileDetails.path)
		containsModifiedFiles = containsModifiedFiles or fileDetails.modified and fileDetails.get("delete", false) == false
	oCustomFilesLabel.bbcode_text = "No modified tilesets" if customFileLinks.empty() else PoolStringArray(customFileLinks).join("\n")
	if deletedFileLinks.empty() == false:
		oCustomFilesLabel.bbcode_text += "\n\nSave will delete:\n" + PoolStringArray(deletedFileLinks).join("\n")
	oCustomFilesLabel.hint_tooltip = PoolStringArray(customFilePaths).join("\n")
	oCustomFilesPanel.modulate = Color(1.4,1.4,1.7) if containsModifiedFiles else Color(1,1,1)
	oTilesetRevertButton.text = "Revert " + currentType.to_upper()
	oTilesetRevertButton.disabled = _can_revert(currentType) == false
	oTilesetRevertTilesetButton.disabled = _can_revert("tmapa") == false and _can_revert("tmapb") == false
	oTilesetRevertAllButton.disabled = _can_revert_all() == false
	_update_editing_session_ui()
	oSlabsetWindow.update_window_title()


func get_source(type: String) -> String:
	if modified[type] or oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].has(sourcePaths[type]):
		return "local"
	if oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CAMPAIGN].has(sourcePaths[type]):
		return "campaign"
	return "default"


func select_texture_id(textureId: int):
	if tilesetNumber == -1:
		load_tileset(0)
	if textureId >= 544 and textureId < 1000:
		var animationImage = oTextureAnimation.animation_database_texture.get_data()
		var animationIndex = textureId - 544
		if animationIndex < animationImage.get_height():
			animationImage.lock()
			var frame = animationImage.get_pixel(Random.randi_range(0, animationImage.get_width() - 1), animationIndex)
			animationImage.unlock()
			textureId = (int(frame.r * 255.0 + 0.5) << 16) | (int(frame.g * 255.0 + 0.5) << 8) | int(frame.b * 255.0 + 0.5)
	var index = textureId
	var type = ""
	if textureId >= 0 and textureId < 544:
		type = "tmapa"
	elif textureId >= 1000 and textureId < 1544:
		type = "tmapb"
		index -= 1000
	else:
		oMessage.quick("Texture ID " + str(textureId) + " is outside the texture maps.")
		return
	selectedIndices[type] = index
	_switch_tileset_view(tilesetNumber, type)
	var tileSize = TILE_SIZE * int(oTilesetZoom.value)
	oTilesetScrollContainer.scroll_horizontal = max(0, (index % 8) * tileSize - (oTilesetScrollContainer.rect_size.x - tileSize) / 2)
	oTilesetScrollContainer.scroll_vertical = max(0, (index / 8) * tileSize - (oTilesetScrollContainer.rect_size.y - tileSize) / 2)


func _on_TilesetStrip_tile_selected(index: int):
	selectedIndices[currentType] = index


func _on_TilesetZoom_value_changed(value: float):
	oTilesetStrip.set_zoom(int(value))


func _on_TilesetIDSpinBox_value_changed(value: float):
	var number = int(value)
	if _can_modify_tileset(number) == false:
		oTilesetIDSpinBox.set_block_signals(true)
		oTilesetIDSpinBox.value = tilesetNumber
		oTilesetIDSpinBox.set_block_signals(false)
		return
	_switch_tileset_view(number, currentType)


func _on_TilesetTypeList_item_selected(index: int):
	_switch_tileset_view(tilesetNumber, TYPES[index])


func _on_CustomFilesLabel_meta_clicked(meta):
	var selection = str(meta).split(":")
	if selection.size() != 2 or TYPES.has(selection[1]) == false:
		return
	var number = int(selection[0])
	if _can_modify_tileset(number):
		_switch_tileset_view(number, selection[1])


func _on_TilesetLoadButton_pressed():
	if _is_current_session() and editingSession.liveReload:
		editingSession.liveReload = false
		oTeditLiveReloadPNG.set_enabled(false)
		_update_editing_session_ui()
	var path = sourcePaths[currentType]
	if path != "":
		oTilesetLoadDialog.current_dir = path.get_base_dir()
	Utils.popup_centered(oTilesetLoadDialog)


func _on_TilesetLoadDialog_file_selected(path: String):
	var extension = path.get_extension().to_lower()
	if extension == "dat":
		if _can_modify_tileset(tilesetNumber) == false:
			return
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details == null or details.type != currentType:
			oMessage.big("Error", "Select a " + currentType + " DAT file.")
			return
		var image = oTMapLoader.create_l8_image(path)
		if image == null or image.is_empty():
			oMessage.big("Error", "Could not load the texture map.")
			return
		images[currentType] = image
		contentHeights[currentType] = _decoded_height(path)
		_mark_modified(currentType)
	elif extension == "png":
		if _can_modify_tileset(tilesetNumber) == false:
			return
		var pngImage = Image.new()
		if pngImage.load(path) != OK:
			oMessage.big("Error", "Could not load the PNG.")
			return
		if pngImage.get_size() == IMAGE_SIZE:
			var convertedImage = oTMapLoader.create_l8_image_from_rgb(pngImage, images[currentType])
			if convertedImage == null or convertedImage.is_empty():
				oMessage.big("Error", "Could not convert the PNG using the Tileset palette.")
				return
			images[currentType] = convertedImage
			contentHeights[currentType] = int(IMAGE_SIZE.y)
		else:
			oMessage.big("Error", "PNG must be a full 256x2176 strip.")
			return
		_mark_modified(currentType)
	else:
		oMessage.big("Error", "Select a DAT or PNG file.")
		return
	_update_cache()
	if _is_current_session() and editingSession.liveReload == false:
		_activate_session()
	_display_image()


func _update_cache(type: String = currentType):
	var available = inheritedImages[type] != null or differentFromInherited[type]
	oTMapLoader.set_cached_image(images[type] if available else null, tilesetNumber, type)
	oSlabStyle.update_style_button(tilesetNumber)
	oTMapLoader.apply_texture_pack()


func _on_TilesetSaveButton_pressed():
	var path = sourcePaths[currentType]
	if path != "":
		oTilesetSaveDialog.current_dir = path.get_base_dir()
	oTilesetSaveDialog.current_file = _active_filename(".dat")
	Utils.popup_centered(oTilesetSaveDialog)


func _on_TilesetSaveDialog_file_selected(path: String):
	var extension = path.get_extension().to_lower()
	if extension == "dat":
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details == null or details.type != currentType:
			oMessage.big("Error", "Export with a " + currentType + " filename.")
			return
		if save_dat(path, currentType) == false:
			oMessage.big("Error", "Could not save the texture map.")
			return
	elif extension == "png":
		var rgbImage = oTMapLoader.create_rgb_image(images[currentType])
		if rgbImage == null or rgbImage.is_empty() or rgbImage.save_png(path) != OK:
			oMessage.big("Error", "Could not save the PNG.")
			return
	else:
		oMessage.big("Error", "The filename must end in .dat or .png.")
		return
	oMessage.quick("Exported " + path.get_file())


func save_modified_tilesets(mapFilename: String, mapDirectory: String) -> bool:
	var currentMapPaths = oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP]
	var directory = Directory.new()
	var reloadTilesets = false
	for sourcePath in currentMapPaths.duplicate():
		var details = oTMapLoader.parse_tmap_path_details(sourcePath)
		if details == null or tilesetPathsToDelete.has(sourcePath) or (details.number == tilesetNumber and modified[details.type]):
			continue
		var targetPath = mapDirectory.plus_file(mapFilename + "." + details.type + str(details.number).pad_zeros(3) + ".dat")
		if sourcePath.to_upper() == targetPath.to_upper():
			continue
		if directory.copy(sourcePath, targetPath) != OK:
			return false
		currentMapPaths[currentMapPaths.find(sourcePath)] = targetPath
		if details.number == tilesetNumber and sourcePaths[details.type] == sourcePath:
			sourcePaths[details.type] = targetPath
		print("Copied map tileset file: " + targetPath.get_file())
		reloadTilesets = true
	var displayedTilesetWasSaved = modified.tmapa or modified.tmapb
	for type in TYPES:
		if modified[type] == false:
			continue
		var saveTarget = _get_save_target(type, mapFilename, mapDirectory)
		var path = saveTarget[0]
		if save_dat(path, type) == false:
			return false
		sourcePaths[type] = path
		modified[type] = false
		oConfigFileManager.notify_file_created(path, type + ".dat", saveTarget[1])
		if saveTarget[1] == oConfigFileManager.LOAD_CFG_CAMPAIGN:
			inheritedImages[type] = images[type].duplicate()
			differentFromInherited[type] = false
			reloadTilesets = true
	var inheritedPaths = _get_inherited_paths()
	var displayedTilesetFileWasDeleted = false
	var file = File.new()
	for queuedPath in tilesetPathsToDelete:
		var details = oTMapLoader.parse_tmap_path_details(queuedPath)
		if details == null:
			continue
		var path = mapDirectory.plus_file(mapFilename + "." + details.type + str(details.number).pad_zeros(3) + ".dat")
		for currentMapPath in oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
			var currentDetails = oTMapLoader.parse_tmap_path_details(currentMapPath)
			if currentMapPath.get_base_dir().to_upper() == mapDirectory.to_upper() and currentMapPath.get_file().to_upper().begins_with(mapFilename.to_upper() + ".") and currentDetails != null and currentDetails.number == details.number and currentDetails.type == details.type:
				path = currentMapPath
				break
		if file.file_exists(path):
			if OS.move_to_trash(ProjectSettings.globalize_path(path)) != OK:
				return false
			oConfigFileManager.notify_file_deleted(path, details.type + ".dat")
			print("Moved reverted " + details.type.to_upper() + " file to trash: " + path.get_file())
			reloadTilesets = true
		if details.number == tilesetNumber:
			displayedTilesetFileWasDeleted = true
	tilesetPathsToDelete.clear()
	for path in oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].duplicate():
		if path.get_base_dir().to_upper() != mapDirectory.to_upper() or path.get_file().to_upper().begins_with(mapFilename.to_upper() + ".") == false:
			continue
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details == null:
			continue
		var inheritedPath = inheritedPaths.get([details.number, details.type], "")
		if inheritedPath == "":
			if tilesetNumber != details.number or sourcePaths[details.type] != path or differentFromInherited[details.type]:
				continue
		else:
			var mapImage = oTMapLoader.create_l8_image(path)
			var inheritedImage = oTMapLoader.create_l8_image(inheritedPath)
			if mapImage == null or inheritedImage == null or mapImage.get_data() != inheritedImage.get_data():
				continue
		if OS.move_to_trash(ProjectSettings.globalize_path(path)) != OK:
			return false
		oConfigFileManager.notify_file_deleted(path, details.type + ".dat")
		print("Moved unmodified " + details.type.to_upper() + " file to trash: " + path.get_file())
		reloadTilesets = true
		if tilesetNumber == details.number:
			sourcePaths[details.type] = inheritedPath
			differentFromInherited[details.type] = false
			displayedTilesetFileWasDeleted = true
	if reloadTilesets:
		oTMapLoader.start()
		oTMapNames.update_texture_map_names()
		oTMapLoader.apply_texture_pack()
	if tilesetNumber >= 0 and (displayedTilesetWasSaved or displayedTilesetFileWasDeleted):
		_display_image()
	return true


func _get_save_target(type: String, mapFilename: String, mapDirectory: String) -> Array:
	var campaignPaths = oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CAMPAIGN]
	if campaignPaths.has(sourcePaths[type]):
		return [sourcePaths[type], oConfigFileManager.LOAD_CFG_CAMPAIGN]
	if oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].has(sourcePaths[type]) == false:
		for path in campaignPaths:
			if oTMapLoader.parse_tmap_path_details(path) != null:
				return [path.get_base_dir().plus_file(type + str(tilesetNumber).pad_zeros(3) + ".dat"), oConfigFileManager.LOAD_CFG_CAMPAIGN]
	return [mapDirectory.plus_file(mapFilename + "." + type + str(tilesetNumber).pad_zeros(3) + ".dat"), oConfigFileManager.LOAD_CFG_CURRENT_MAP]


func save_dat(path: String, type: String) -> bool:
	var height = int(IMAGE_SIZE.y) if type == "tmapa" else contentHeights[type]
	height = max(height, TILE_SIZE)
	var dataImage = images[type].get_rect(Rect2(Vector2.ZERO, Vector2(IMAGE_SIZE.x, height)))
	var file = File.new()
	if file.open(path, File.WRITE) != OK:
		return false
	file.store_buffer(dataImage.get_data())
	var error = file.get_error()
	file.close()
	return error == OK


func _decoded_height(path: String) -> int:
	var byteCount = int(oTMapLoader.decodedTmapSizes.get(path, int(IMAGE_SIZE.x * IMAGE_SIZE.y)))
	return int(ceil(float(byteCount) / IMAGE_SIZE.x))


func _active_filename(extension: String) -> String:
	var path = sourcePaths[currentType]
	if path != "":
		return path.get_file().get_basename() + extension
	return currentType + str(tilesetNumber).pad_zeros(3) + extension


func _on_TilesetStripButton_pressed():
	_start_external_edit("strip")


func _on_TilesetPackButton_pressed():
	_start_external_edit("pack")


func _start_external_edit(format: String):
	if _can_modify_tileset(tilesetNumber) == false:
		return
	if _is_current_session() and editingSession.liveReload:
		editingSession.liveReload = false
		oTeditLiveReloadPNG.set_enabled(false)
		_update_editing_session_ui()
	var rgbImage = oTMapLoader.create_rgb_image(images[currentType])
	if rgbImage == null or rgbImage.is_empty():
		oMessage.big("Error", "Could not create the editable PNG because the Tileset palette is unavailable.")
		return
	var folderName = _active_filename("").replace(".", "_")
	oTeditSavePNG.handle_tmap_export(rgbImage, folderName, folderName + ".png" if format == "strip" else "")


func _on_TilesetLiveReloading_toggled(buttonPressed: bool):
	if _is_current_session() == false:
		return
	editingSession.liveReload = buttonPressed
	if buttonPressed:
		_activate_session()
	else:
		oTeditLiveReloadPNG.set_enabled(false)
	_update_editing_session_ui()


func _on_TilesetExternalPathLabel_meta_clicked(meta):
	if _is_current_session() == false:
		Directory.new().make_dir_recursive(str(meta))
	oTeditSavePNG.open_texture_folder(str(meta))


func _on_TilesetHelpButton_pressed():
	var helpText = """To see the effects of your edits, be sure to set your map's Tileset in Map Settings.

TMAPA contains texture IDs 0-543. TMAPB contains IDs 1000-1543.
Edit as strip creates one PNG. Edit as texture pack creates a folder of PNGs. Unearth watches the selected format and reloads changes into the 2D and 3D views.

Import TMAP accepts DAT files and full 256x2176 PNG strips. Export TMAP writes a standalone DAT or PNG without changing the map's save state.
Texture maps are saved in the campaign cfg folder when it already contains texture maps. Map-local overrides and maps without campaign texture maps are saved as mapname.tmapa###.dat and mapname.tmapb###.dat, where ### is the Tileset ID."""
	oMessage.big("Tileset", helpText)


func _on_TilesetRevertButton_pressed():
	revertScope = "type"
	oTilesetRevertConfirmDialog.window_title = "Revert " + currentType.to_upper()
	oTilesetRevertConfirmDialog.dialog_text = ("Discard unsaved changes to " if modified[currentType] else "Revert the local override for ") + currentType.to_upper() + "?"
	Utils.popup_centered(oTilesetRevertConfirmDialog)


func _on_TilesetRevertTilesetButton_pressed():
	revertScope = "tileset"
	oTilesetRevertConfirmDialog.window_title = "Revert tileset"
	oTilesetRevertConfirmDialog.dialog_text = "Revert TMAPA and TMAPB for Tileset " + str(tilesetNumber) + "?"
	Utils.popup_centered(oTilesetRevertConfirmDialog)


func _on_TilesetRevertAllButton_pressed():
	revertScope = "all"
	oTilesetRevertConfirmDialog.window_title = "Revert all tilesets"
	oTilesetRevertConfirmDialog.dialog_text = "Revert all modified tilesets?"
	Utils.popup_centered(oTilesetRevertConfirmDialog)


func _on_TilesetRevertConfirmDialog_confirmed():
	if revertScope == "all":
		_revert_all_tilesets()
		return
	var types = TYPES if revertScope == "tileset" else [currentType]
	var reverted = true
	for type in types:
		if _can_revert(type) and _revert_type(type) == false:
			reverted = false
	for type in types:
		_update_cache(type)
	_display_image()
	if reverted:
		oMessage.quick("Reverted Tileset " + str(tilesetNumber) if revertScope == "tileset" else "Reverted " + currentType.to_upper())


func _revert_all_tilesets():
	var revertedTilesets = {}
	revertedTilesets[tilesetNumber] = true
	for path in oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details != null and tilesetPathsToDelete.has(path) == false:
			tilesetPathsToDelete.append(path)
			revertedTilesets[details.number] = true
	modified = {"tmapa": false, "tmapb": false}
	differentFromInherited = {"tmapa": false, "tmapb": false}
	oEditor.mapHasBeenEdited = oEditor.SET_EDITED_WITHOUT_SAVING_STATE
	load_tileset(tilesetNumber)
	var inheritedPaths = _get_inherited_paths()
	for number in revertedTilesets:
		for type in TYPES:
			var inheritedPath = inheritedPaths.get([number, type], "")
			oTMapLoader.set_cached_image(oTMapLoader.create_l8_image(inheritedPath) if inheritedPath != "" else null, number, type)
		oSlabStyle.update_style_button(number)
	oTMapLoader.apply_texture_pack()
	oMessage.quick("Reverted all tilesets")


func _revert_type(type: String) -> bool:
	if modified[type] == false:
		images[type] = inheritedImages[type]
		if images[type] == null:
			images[type] = _create_blank_image()
		contentHeights[type] = int(IMAGE_SIZE.y) if type == "tmapa" else 0
		var inheritedPath = _get_inherited_paths().get([tilesetNumber, type], "")
		if inheritedPath != "":
			contentHeights[type] = _decoded_height(inheritedPath)
		_mark_modified(type)
		differentFromInherited[type] = false
		return true
	var path = sourcePaths[type]
	if path == "":
		images[type] = _create_blank_image()
		contentHeights[type] = int(IMAGE_SIZE.y) if type == "tmapa" else 0
	else:
		var image = oTMapLoader.create_l8_image(path)
		if image == null or image.is_empty():
			oMessage.big("Error", "Could not reload " + path.get_file() + ".")
			return false
		images[type] = image
		contentHeights[type] = _decoded_height(path)
	modified[type] = false
	differentFromInherited[type] = _is_different_from_inherited(type)
	if editingSession.get("number") == tilesetNumber and editingSession.get("type") == type:
		_activate_session()
	return true


func _can_revert(type: String) -> bool:
	return modified[type] or differentFromInherited[type] and oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].has(sourcePaths[type])


func _can_revert_all() -> bool:
	if modified.tmapa or modified.tmapb:
		return true
	for path in oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
		if tilesetPathsToDelete.has(path) == false and oTMapLoader.parse_tmap_path_details(path) != null:
			return true
	return false


func register_editing_session(type: String, number: int, format: String, path: String, content: String):
	editingSession = {
		"type": type,
		"number": number,
		"format": format,
		"path": path,
		"content": content,
		"liveReload": true,
		"status": ""
	}
	if tilesetNumber != number or currentType != type:
		load_tileset(number)
		currentType = type
	_activate_session()
	_display_image()


func set_reload_status(type: String, number: int, status: String):
	if editingSession.get("type") == type and editingSession.get("number") == number:
		if status == WAITING_STATUS:
			oMessage.quick(status)
			status = ""
		editingSession.status = status
		_update_editing_session_ui()


func show_confirmation_dialog(message: String) -> bool:
	oTilesetExternalConfirmDialog.dialog_text = message
	externalDialogConfirmed = false
	Utils.popup_centered(oTilesetExternalConfirmDialog)
	while oTilesetExternalConfirmDialog.visible:
		yield(get_tree(), "idle_frame")
	return externalDialogConfirmed


func _on_TilesetExternalConfirmDialog_confirmed():
	externalDialogConfirmed = true


func apply_external_image(type: String, number: int, image: Image, height: int) -> bool:
	if _can_modify_tileset(number) == false:
		return false
	if tilesetNumber != number:
		load_tileset(number)
	images[type] = image.duplicate()
	contentHeights[type] = max(contentHeights[type], height)
	_mark_modified(type)
	_update_cache(type)
	_display_image()
	return true


func _is_current_session() -> bool:
	return editingSession.get("number") == tilesetNumber and editingSession.get("type") == currentType


func _switch_tileset_view(number: int, type: String):
	if _can_modify_tileset(number) == false:
		return
	if number != tilesetNumber:
		load_tileset(number)
	currentType = type
	if _is_current_session():
		_activate_session()
	else:
		if editingSession.empty() == false:
			editingSession.liveReload = false
		oTeditLiveReloadPNG.stop_session()
	_display_image()


func _activate_session():
	set_reload_status(editingSession.type, editingSession.number, WAITING_STATUS)
	oTeditLiveReloadPNG.initialize_pack(editingSession.content, editingSession.path, editingSession.type, editingSession.number)
	oTeditLiveReloadPNG.set_enabled(editingSession.liveReload)


func _update_editing_session_ui():
	var hasSession = _is_current_session()
	var session = editingSession if hasSession else {}
	oTilesetLiveReloading.set_block_signals(true)
	oTilesetLiveReloading.pressed = session.liveReload if hasSession else true
	oTilesetLiveReloading.disabled = hasSession == false
	oTilesetLiveReloading.set_block_signals(false)
	var folderPath = session.path if hasSession else oTeditSavePNG.get_output_directory()
	oTilesetExternalPathLabel.clear()
	oTilesetExternalPathLabel.push_meta(folderPath)
	oTilesetExternalPathLabel.push_underline()
	oTilesetExternalPathLabel.add_text(session.path if hasSession else "Open editing folder")
	oTilesetExternalPathLabel.pop()
	oTilesetExternalPathLabel.pop()
	oTilesetExternalPathLabel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	oTilesetExternalPathLabel.hint_tooltip = folderPath
	oTilesetEditingStatusLabel.text = currentType.to_upper() + " - " + session.format.capitalize() + " - " + ("Live reload on" if session.liveReload else "Live reload off") + ("\n" + session.status if session.status != "" else "") if hasSession else "Choose an editing format."


func _mark_modified(type: String):
	for path in tilesetPathsToDelete.duplicate():
		var details = oTMapLoader.parse_tmap_path_details(path)
		if details != null and details.number == tilesetNumber and details.type == type:
			tilesetPathsToDelete.erase(path)
	modified[type] = true
	differentFromInherited[type] = true if inheritedImages[type] == null else images[type].get_data() != inheritedImages[type].get_data()
	if type == "tmapb" and sourcePaths.tmapa == "":
		modified.tmapa = true
		differentFromInherited.tmapa = true
	oEditor.mapHasBeenEdited = oEditor.SET_EDITED_WITHOUT_SAVING_STATE


func _can_modify_tileset(number: int) -> bool:
	if number < 0 or number >= oTMapLoader.TMAP_COUNT:
		return false
	if modified.tmapa == false and modified.tmapb == false or tilesetNumber == number:
		return true
	oMessage.big("Unsaved Tileset", "Save or revert Tileset " + str(tilesetNumber) + " before using or editing Tileset " + str(number) + ".")
	return false


func clear_modified_tileset():
	_reset_tileset_data()
	tilesetNumber = -1
	currentType = "tmapa"
	selectedIndices = {"tmapa": 0, "tmapb": 0}
	editingSession.clear()
	tilesetPathsToDelete.clear()
	oTeditLiveReloadPNG.stop_session()


func _reset_tileset_data():
	images = {"tmapa": null, "tmapb": null}
	inheritedImages = {"tmapa": null, "tmapb": null}
	sourcePaths = {"tmapa": "", "tmapb": ""}
	contentHeights = {"tmapa": int(IMAGE_SIZE.y), "tmapb": 0}
	modified = {"tmapa": false, "tmapb": false}
	differentFromInherited = {"tmapa": false, "tmapb": false}


func _create_blank_image() -> Image:
	var image = Image.new()
	image.create(int(IMAGE_SIZE.x), int(IMAGE_SIZE.y), false, Image.FORMAT_L8)
	var emptyValue = float(oTMapLoader.EMPTY_TEXTURE_INDEX) / 255.0
	image.fill(Color(emptyValue, emptyValue, emptyValue))
	return image


func _is_different_from_inherited(type: String) -> bool:
	return sourcePaths[type] != "" if inheritedImages[type] == null else images[type].get_data() != inheritedImages[type].get_data()


func _get_inherited_paths() -> Dictionary:
	var paths = {}
	for configType in [oConfigFileManager.LOAD_CFG_DATA, oConfigFileManager.LOAD_CFG_CAMPAIGN]:
		for path in oConfigFileManager.paths_loaded[configType]:
			var details = oTMapLoader.parse_tmap_path_details(path)
			if details != null:
				paths[[details.number, details.type]] = path
	return paths
