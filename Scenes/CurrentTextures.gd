extends Node
# 1. Read tmapa files from DK /data/ directory. Must always be done in case there are changes.
# Keep a list of date modified dates along with png filenames in Settings.
# 2. Scan /unearthdata/ for png files, making sure they match the dates in array of the original files
# 3. Load png files into cachedTextures, load cachedTextures into shaders.
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oGame = Nodelist.list["oGame"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oGame3D = Nodelist.list["oGame3D"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oColumnEditorVoxelView = Nodelist.list["oColumnEditorVoxelView"]
onready var oMapProperties = Nodelist.list["oMapProperties"]

const IMAGE_FORMAT = Image.FORMAT_RGB8
const textureWidth = 256
const textureHeight = 2176
enum {
	LOADING_NOT_STARTED
	LOADING_IN_PROGRESS
	LOADING_SUCCESS
}
var CODETIME_START

var paletteData = []
var REMEMBER_TMAPA_PATHS = {}
var cachedTextures = [] # Dynamically created based on what's in REMEMBER_TMAPA_PATHS
var texturesLoadedState = LOADING_NOT_STARTED


func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if texturesLoadedState != LOADING_IN_PROGRESS: # Don't do anything if it's already doing something
			# If anything differs, then reload
			if REMEMBER_TMAPA_PATHS.hash() != scan_dk_data_directory().hash():
				start()
	#		else:
	#			print('Nothing differs')
		
		for i in 100: # wait until file appears. an estimate is fine. this isn't super important, because the list is also refreshed whenever switching to the tab or reopening the window.
			yield(get_tree(),'idle_frame')
		oMapProperties._on_MapProperties_visibility_changed() # Refresh list of styles if it's visible

func _on_ReloadTextureMapsButton_pressed():
	if texturesLoadedState != LOADING_IN_PROGRESS: # Don't do anything if it's already doing something
		oMessage.quick("Reloading tilesets")
		REMEMBER_TMAPA_PATHS.clear()
		start()


func LOAD_TMAPA_PATHS_FROM_SETTINGS(dictionaryFromSettings):
	REMEMBER_TMAPA_PATHS = dictionaryFromSettings


func start():
	if oGame.EXECUTABLE_PATH == "": return
	if oGame.DK_DATA_DIRECTORY == "": return
	if oGame.GAME_DIRECTORY == "": return
	
	texturesLoadedState = LOADING_IN_PROGRESS
	
	paletteData = oReadPalette.read_palette(Settings.unearthdata.plus_file("palette.dat"))
	
	var tmapaDatDictionary = scan_dk_data_directory()
	var tmapaDatListSorted = tmapaDatDictionary.keys()
	tmapaDatListSorted.sort()
	
	# Remove any old entries
	for path in REMEMBER_TMAPA_PATHS.keys(): # Doing .keys() should allow erasing while iterating I think
		if tmapaDatDictionary.has(path) == false:
			REMEMBER_TMAPA_PATHS.erase(path)
	
	for path in tmapaDatListSorted:
		var modifiedTime = tmapaDatDictionary[path]
		var compareTime = -1
		if REMEMBER_TMAPA_PATHS.has(path):
			compareTime = REMEMBER_TMAPA_PATHS[path]
		
		if modifiedTime != compareTime: # Check if date differs or if has no entry (-1)
			var img = convert_tmapa_to_image(path)
			if img == null:
				continue
			save_image_as_png(img, path) # only the filename from "path" is used
			yield(get_tree(),'idle_frame')
		
		load_cache_filename(path) # only the filename from "path" is used
	
	Settings.set_setting("REMEMBER_TMAPA_PATHS", tmapaDatDictionary) # Do this last
	texturesLoadedState = LOADING_SUCCESS
	
	# This is important to do here if updating textures while a map is already open
	if oDataSlab.get_cell(0,0) != -1:
		set_current_texture_pack()

func scan_dk_data_directory():
	var path = oGame.DK_DATA_DIRECTORY
	var dictionary = {}
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == false:
				if fileName.to_upper().begins_with("TMAP") == true: # Get file regardless of case (case insensitive)
					if fileName.to_upper().get_extension() == "DAT":
						if fileName.to_upper().begins_with("TMAPANIM") == false:
							var getModifiedTime = File.new().get_modified_time(path.plus_file(fileName))
							dictionary[path.plus_file(fileName)] = getModifiedTime
			fileName = dir.get_next()
	return dictionary


func convert_tmapa_to_image(tmapaDatPath):
	if oRNC.check_for_rnc_compression(tmapaDatPath) == true:
		oRNC.decompress(tmapaDatPath)
	
	var file = File.new()
	if file.open(tmapaDatPath, File.READ) == OK:
		CODETIME_START = OS.get_ticks_msec()
		
		var img = Image.new()
		img.create(textureWidth, textureHeight, false, IMAGE_FORMAT)
		file.seek(0)
		img.lock()
		for y in textureHeight:
			for x in textureWidth:
				var paletteIndex = file.get_8()
				img.set_pixel(x,y,paletteData[paletteIndex])
		img.unlock()
		
		print('Converted tmapa*.dat to image in: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
		file.close()
		
		return img
	else:
		print("Failed to open file.")
		return null

func save_image_as_png(img, inputPath):
	var fileName = inputPath.get_file().get_basename().to_lower() + ".png"
	
	var imgTex = ImageTexture.new()
	imgTex.create_from_image(img, Texture.FLAG_MIPMAPS + Texture.FLAG_ANISOTROPIC_FILTER)
	var savePath = Settings.unearthdata.plus_file(fileName)
	ResourceSaver.save(savePath, imgTex)
	oMessage.quick("Caching tilesets : ".plus_file("unearthdata").plus_file(fileName))


func load_cache_filename(path):
	var fileName = path.get_file().get_basename().to_lower()
	var cachePath = Settings.unearthdata.plus_file(fileName + ".png")
	var tmapaNumber = int(fileName.to_lower().trim_prefix("tmapa")) # Get the specific position to create within the array
	
	if File.new().file_exists(cachePath) == true:
		# Need to call load() on an Image class if I want the save and load to work correctly (otherwise it saves too fast and doesn't load or something)
		var img = Image.new()
		img.load(cachePath)
		load_image_into_cache(img, tmapaNumber)
		#print('Loaded cache file: ' + cachePath)
		return OK
	else:
		print('Cache file not found: ' + cachePath)
		cachedTextures.clear()
		return FAILED

func load_image_into_cache(img, tmapaNumber):
	tmapaNumber = int(tmapaNumber)
	while cachedTextures.size() <= tmapaNumber: # Fill all array positions, in case a tmapa00#.dat file inbetween is deleted
		cachedTextures.append([null, null])
	cachedTextures[tmapaNumber] = convert_img_to_two_texture_arrays(img)

# SLICE COUNT being too high is the reason TextureArray doesn't work on old PC. (NOT IMAGE SIZE, NOT MIPMAPS EITHER)
# RES files might actually take longer to generate a TextureArray from than PNG, not sure.
func convert_img_to_two_texture_arrays(img):
	if img.get_format() != IMAGE_FORMAT:
		img.convert(IMAGE_FORMAT)
	
	var twoTextureArrays = [
		TextureArray.new(),
		TextureArray.new(),
		TextureArray.new(),
		TextureArray.new(),
	]
	var xSlices = 8
	var ySlices = 34
	var sliceWidth = 32 #img.get_width() / xSlices;
	var sliceHeight = 32 #img.get_height() / ySlices;
	twoTextureArrays[0].create(sliceWidth, sliceHeight, xSlices*ySlices, IMAGE_FORMAT, TextureLayered.FLAG_MIPMAPS+TextureLayered.FLAG_ANISOTROPIC_FILTER)
	twoTextureArrays[1].create(sliceWidth, sliceHeight, xSlices*ySlices, IMAGE_FORMAT, TextureLayered.FLAG_MIPMAPS+TextureLayered.FLAG_ANISOTROPIC_FILTER)
	twoTextureArrays[2].create(sliceWidth, sliceHeight, xSlices*ySlices, IMAGE_FORMAT, TextureLayered.FLAG_MIPMAPS+TextureLayered.FLAG_ANISOTROPIC_FILTER)
	twoTextureArrays[3].create(sliceWidth, sliceHeight, xSlices*ySlices, IMAGE_FORMAT, TextureLayered.FLAG_MIPMAPS+TextureLayered.FLAG_ANISOTROPIC_FILTER)
	
	for i in 4:
		var yOffset = 0
		if i == 1 or i == 3:
			yOffset = 34
		
		for y in ySlices:
			for x in xSlices:
				var slice = img.get_rect(Rect2(x*sliceWidth, (y+yOffset)*sliceHeight, sliceWidth, sliceHeight))
				slice.generate_mipmaps() #Important otherwise it's black when zoomed out
				twoTextureArrays[i].set_layer_data(slice, (y*xSlices)+x)
	
	return twoTextureArrays

func set_current_texture_pack():
	var value = oDataLevelStyle.data
	
	if cachedTextures.empty() == true:
		oMessage.big("Error", "No tilesets could be loaded. Try pressing the [Reload tileset cache] button in File->Preferences and then reopen the map.")
		return
	if cachedTextures[value] == null or cachedTextures[value][0] == null or cachedTextures[value][1] == null:
		oMessage.big("Error", "Unable to load tileset number " + str(value) + ". Try pressing the [Reload tileset cache] button in File->Preferences.")
		return
	
	# 2D
	if oOverheadGraphics.arrayOfColorRects.size() > 0:
		oOverheadGraphics.arrayOfColorRects[0].get_material().set_shader_param("dkTextureMap_Split_A1", cachedTextures[value][0])
		oOverheadGraphics.arrayOfColorRects[0].get_material().set_shader_param("dkTextureMap_Split_A2", cachedTextures[value][1])
		oOverheadGraphics.arrayOfColorRects[0].get_material().set_shader_param("dkTextureMap_Split_B1", cachedTextures[value][2])
		oOverheadGraphics.arrayOfColorRects[0].get_material().set_shader_param("dkTextureMap_Split_B2", cachedTextures[value][3])
	
	# 3D
	if oGame3D.materialArray.size() > 0:
		oGame3D.materialArray[0].set_shader_param("dkTextureMap_Split_A1", cachedTextures[value][0])
		oGame3D.materialArray[0].set_shader_param("dkTextureMap_Split_A2", cachedTextures[value][1])
		oGame3D.materialArray[0].set_shader_param("dkTextureMap_Split_A1", cachedTextures[value][2])
		oGame3D.materialArray[0].set_shader_param("dkTextureMap_Split_A2", cachedTextures[value][3])
	
	for nodeID in get_tree().get_nodes_in_group("VoxelViewer"):
		if nodeID.oAllVoxelObjects.mesh != null:
			nodeID.oAllVoxelObjects.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_A1", cachedTextures[value][0])
			nodeID.oAllVoxelObjects.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_A2", cachedTextures[value][1])
			nodeID.oAllVoxelObjects.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_B1", cachedTextures[value][2])
			nodeID.oAllVoxelObjects.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_B2", cachedTextures[value][3])
		if nodeID.oSelectedVoxelObject.mesh != null:
			nodeID.oSelectedVoxelObject.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_A1", cachedTextures[value][0])
			nodeID.oSelectedVoxelObject.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_A2", cachedTextures[value][1])
			nodeID.oSelectedVoxelObject.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_B1", cachedTextures[value][2])
			nodeID.oSelectedVoxelObject.mesh.surface_get_material(0).set_shader_param("dkTextureMap_Split_B2", cachedTextures[value][3])
	
	assign_textures_to_slab_window(value)


func assign_textures_to_slab_window(value): # Called by SlabStyleWindow
	for nodeID in get_tree().get_nodes_in_group("SlabDisplay"):
		nodeID.get_material().set_shader_param("dkTextureMap_Split_A1", cachedTextures[value][0])
		nodeID.get_material().set_shader_param("dkTextureMap_Split_A2", cachedTextures[value][1])
		nodeID.get_material().set_shader_param("dkTextureMap_Split_B1", cachedTextures[value][2])
		nodeID.get_material().set_shader_param("dkTextureMap_Split_B2", cachedTextures[value][3])






#func load_cached_textures(tmapaDatDictionary):
#	cachedTextures.clear()
#
#	CODETIME_START = OS.get_ticks_msec()
#
#	var keys = tmapaDatDictionary.keys()
#
#	for i in keys.size():
#		var fn = keys[i].get_file().get_basename().to_lower()
#		var cachePath = Settings.unearthdata.plus_file(fn + ".png")
#
#		if File.new().file_exists(cachePath) == true:
#			var tmapaNumber = int(fn.to_lower().trim_prefix("tmapa")) # Get the specific position to create within the array
#
#			# Fill all array positions, in case a tmapa00#.dat file is deleted
#			while cachedTextures.size() <= tmapaNumber:
#				cachedTextures.append(null)
#
#			# Need to call load() on an Image class if I want the save and load to work correctly (otherwise it saves too fast and doesn't load or something)
#			var img = Image.new()
#			img.load(cachePath)
#
#			var twoTexArr = convert_img_to_two_texture_arrays(img)
#			cachedTextures[tmapaNumber] = twoTexArr
#			#print('Loaded cache file: ' + cachePath)
#		else:
#			print('Cache file not found: ' + cachePath)
#			cachedTextures.clear()
#			return FAILED
#	print('Loaded cached .png textures: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#	return OK

	
	# Check if what's in TMAPA_PATHS (loaded from Settings) differs from what's in NEW_TMAPA_PATHS
	
#	if REMEMBER_TMAPA_PATHS.hash() == tmapaDatDictionary.hash(): # This compares dictionaries, checking if date modified is different or if there's a different number of file entries
#		#print("No changes.")
#		pass
#	else:
#		# They differ in either file count or date
#
#		# Remove any old entries
#		for path in REMEMBER_TMAPA_PATHS.keys(): # Doing .keys() should allow erasing while iterating I think
#			if tmapaDatDictionary.has(path) == false:
#				REMEMBER_TMAPA_PATHS.erase(path)
#
#		# Look for any changes
#		var sortedArr = tmapaDatDictionary.keys()
#		sortedArr.sort() # required for linux to create in a nice looking order
#		for path in sortedArr:
#			if REMEMBER_TMAPA_PATHS.has(path) == true:
#				if tmapaDatDictionary[path] != REMEMBER_TMAPA_PATHS[path]: # Check if date differs
#					var img = convert_tmapa_to_image(path)
#					if img != null: save_image_as_cached_png(img, path) # only the filename from "path" is used
#			else:
#				var img = convert_tmapa_to_image(path)
#				if img != null: save_image_as_cached_png(img, path) # only the filename from "path" is used
#
#			yield(get_tree(), "idle_frame")
#
#	var err = load_cached_textures(tmapaDatDictionary)
#	match err:
#		OK:
#			#print(cachedTextures)
#			Settings.set_setting("REMEMBER_TMAPA_PATHS", tmapaDatDictionary) # Do this last
#			#oMessage.quick("Texture cache loaded")
#			texturesLoadedState = LOADING_SUCCESS
#			# This is important to do here if updating textures while a map is already open
#			if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
#				set_current_texture_pack()
#		FAILED:
#			oMessage.quick("Cache failed loading")
#			tmapaDatDictionary.clear()
#			REMEMBER_TMAPA_PATHS.clear()
#			texturesLoadedState = LOADING_NOT_STARTED
#			start() # Redo


#func load_cache(path):
#	var fileName = path.get_file().get_basename().to_lower()
#
#	var cachePath = Settings.unearthdata.plus_file(fileName + ".png")
#
#	if File.new().file_exists(cachePath) == true:
#
#		var tmapaNumber = int(fileName.to_lower().trim_prefix("tmapa")) # Get the specific position to create within the array
#
#		# Need to call load() on an Image class if I want the save and load to work correctly (otherwise it saves too fast and doesn't load or something)
#		var img = Image.new()
#		img.load(cachePath)
#
#		var twoTexArr = convert_img_to_two_texture_arrays(img)
#
#		# Fill all array positions, in case a tmapa00#.dat file is deleted
#		while cachedTextures.size() <= tmapaNumber:
#			cachedTextures.append([null, null]) # Give it an entry of blank texture arrays
#
#		cachedTextures[tmapaNumber] = twoTexArr
#		#print('Loaded cache file: ' + cachePath)
#		return OK
#	else:
#		print('Cache file not found: ' + cachePath)
#		cachedTextures.clear()
#		return FAILED
