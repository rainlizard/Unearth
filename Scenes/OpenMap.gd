extends Node
onready var oReadData = Nodelist.list["oReadData"]
onready var oConfirmDecompression = Nodelist.list["oConfirmDecompression"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oUniversalDetails = Nodelist.list["oUniversalDetails"]
onready var oDynamicMapTree = Nodelist.list["oDynamicMapTree"]
onready var oGame = Nodelist.list["oGame"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oUi = Nodelist.list["oUi"]
onready var oImageAsMapDialog = Nodelist.list["oImageAsMapDialog"]
onready var oDataLif = Nodelist.list["oDataLif"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oColumnEditor = Nodelist.list["oColumnEditor"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataKeeperFxLof = Nodelist.list["oDataKeeperFxLof"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oCustomObjectSystem = Nodelist.list["oCustomObjectSystem"]

var TOTAL_TIME_TO_OPEN_MAP

var compressedFiles = []
var ALWAYS_DECOMPRESS = false # Default to false

func start():
	
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	
	if oGame.EXECUTABLE_PATH == "": return # Silently wait for user to set executable path. No need to show an error.
	
	
	
	if OS.get_cmdline_args():
		# FILE ASSOCIATION
		var cmdLine = OS.get_cmdline_args()
		
		open_map(cmdLine[0])
	else:
		if OS.has_feature("standalone") == false:
			#yield(get_tree(), "idle_frame")
			#oCurrentMap.clear_map()
			open_map("D:/DungeonKeeper/levels/personal/map00002.slb")
		else:
			# initialize a cleared map
			oCurrentMap.clear_map()

func _on_files_dropped(_files, _screen):
	open_map(_files[0])

func open_map(filePath): # auto opens other files
	oCurrentMap.clear_map()
	# a filePath of "" means make a blank map.
	
	# This will replace \ with /, just for the sake of fixing ugliness
	filePath = filePath.replace("\\", "/")
	
	# Prevent opening any maps under any circumstance if you haven't set the dk exe yet. (Fix to launching via file association)
	if oGame.EXECUTABLE_PATH == "":
		oMessage.quick("Error: Cannot open map because executable path is not set")
		return
	
	# Prevent opening any maps under any circumstance if textures haven't been loaded. (Fix to launching via file association)
	if oTextureCache.texturesLoadedState != oTextureCache.LOADING_SUCCESS:
		oMessage.quick("Error: Cannot open map because textures haven't been loaded")
		return
	
	
	
	# Close windows that I want closed
	oMapSettingsWindow.visible = false
	oColumnEditor.visible = false
	
	TOTAL_TIME_TO_OPEN_MAP = OS.get_ticks_msec()
	var map = filePath.get_basename()
	
	load_cfg_stuff(map)
	
	# Open all map file types
	oCurrentMap.currentFilePaths = get_accompanying_files(map)
	
	compressedFiles.clear()
	for i in oCurrentMap.currentFilePaths.values():
		if oRNC.check_for_rnc_compression(i[oCurrentMap.PATHSTRING]) == true:
			compressedFiles.append(i[oCurrentMap.PATHSTRING])
	
	if compressedFiles.empty() == true:
		# Load files
		
		if oNewMapWindow.visible == true:
			oDataKeeperFxLof.use_size(oXSizeLine.text.to_int(), oYSizeLine.text.to_int())
			print("NEW MAPSIZE = " + str(M.xSize) + " " + str(M.ySize))
		
		for EXT in Filetypes.FILE_TYPES:
			if oCurrentMap.currentFilePaths.has(EXT) == true:
				
				# Don't bother reading original formats if keeperFX formats have been found
				if EXT == "TNG" and oCurrentMap.currentFilePaths.has("TNGFX") == true:
					continue
				if EXT == "APT" and oCurrentMap.currentFilePaths.has("APTFX") == true:
					continue
				if EXT == "LGT" and oCurrentMap.currentFilePaths.has("LGTFX") == true:
					continue
				
				Filetypes.read(oCurrentMap.currentFilePaths[EXT][oCurrentMap.PATHSTRING], EXT.to_upper())
			else:
				print("Missing " + EXT + " file, so create blank data for that one.")
				Filetypes.new_blank(EXT.to_upper())
				
				# Assign name data to any that's missing
				if EXT == "LIF":
					var mapName = oDataLif.get_special_lif_text(filePath)
					if mapName != "":
						oDataLif.set_map_name(mapName)
				
				# Some maps can function without WLB files. So build them here.
				# Generate WLB values from SLB. This is dependent on SLB being ordered before WLB inside Filetypes.FILE_TYPES
				if EXT == "WLB":
					for ySlab in M.ySize:
						for xSlab in M.xSize:
							var slabID = oDataSlab.get_cell(xSlab, ySlab)
							oDataLiquid.set_cell(xSlab, ySlab, Slabs.data[slabID][Slabs.REMEMBER_TYPE])
		
		finish_opening_map(map)
	else:
		if ALWAYS_DECOMPRESS == false:
			oConfirmDecompression.dialog_text = "In order to open this map, these files must be decompressed: \n\n" #'Unable to open map, it contains files which have RNC compression: \n\n'
			for i in compressedFiles:
				oConfirmDecompression.dialog_text += i + '\n'
			oConfirmDecompression.dialog_text += "\n" + "This will result in overwriting, continue?" + "\n" #Decompress these files? (Warning: they will be overwritten)
			Utils.popup_centered(oConfirmDecompression)
		else:
			# Begin decompression without confirmation dialog
			_on_ConfirmDecompression_confirmed()
#	else:
#		oMessage.quick("Error: Map files not found")

func load_cfg_stuff(map):
	Things.reset_thing_data_to_default()
	if Cube.tex.empty() == true:
		Cube.read_cubes_cfg()
	
	oCustomObjectSystem.load_file()
	
	var parentDirectory = map.get_base_dir().get_base_dir()
	var mainCfgName = map.get_base_dir().get_file() + ".cfg"
	print("Parent directory: " + parentDirectory)
	print("Main cfg name: " + mainCfgName)
	var fullPathToMainCfg = oGame.get_precise_filepath(parentDirectory, mainCfgName)
	if fullPathToMainCfg != "":
		Things.get_cfgs_directory(fullPathToMainCfg)

func finish_opening_map(map):
	oPickThingWindow.initialize_thing_grid_items()
	oCurrentMap.set_path_and_title(map)
	oDynamicMapTree.highlight_current_map()
	oEditor.update_boundaries()
	oEditor.mapHasBeenEdited = false
	oScriptEditor.initialize_for_new_map()
	oOverheadOwnership.start()
	oScriptHelpers.start()
	oCamera2D.reset_camera(M.xSize, M.ySize)
	
	oSlabPalette.start()
	
	oOverheadGraphics.update_map_overhead_2d_textures()
	oPickSlabWindow.add_slabs()
	oDataClm.count_filled_clm_entries()
	
	oTextureCache.set_current_texture_pack()
	
	if oCurrentMap.path == "":
		oMessage.quick('New map')
	else:
		oMessage.quick('Opened map')
	
	oEditor.set_view_2d()
	
	oMenu.add_recent(map)
	
	# When opening a map, be sure that column 0 is empty. Otherwise apply a fix.
	if oDataClm.permanent[0] != 0 or oDataClm.cubes[0] != [0,0,0,0, 0,0,0,0]:
		# Make column 0 empty while preserving the column that was there.
		oDataClm.sort_columns_by_utilized()
		oDataClm.delete_column(0)
		oEditor.mapHasBeenEdited = true
		oMessage.quick("Fixed column index 0, re-save your map.")
	
	print('TOTAL time to open map: '+str(OS.get_ticks_msec()-TOTAL_TIME_TO_OPEN_MAP)+'ms')

func _on_ConfirmDecompression_confirmed():
	#var CODETIME_START = OS.get_ticks_msec()
	print('Attempting to decompress...')
	# Decompress files
	#var dir = Directory.new()
	for path in compressedFiles:
		oRNC.decompress(path)
	#print('Decompressed in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	# Retry opening the map
	# (any of the compressed files will have the appropriate name)
	open_map(compressedFiles[0])

func _on_FileDialogOpen_file_selected(path):
	open_map(path)


func get_accompanying_files(map):
	var baseDir = map.get_base_dir()
	var mapName = map.get_file()
	
	var dict = {}
	var dir = Directory.new()
	if dir.open(baseDir) == OK:
		dir.list_dir_begin(true, false)

		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == false:
				if fileName.to_upper().begins_with(mapName.to_upper()): # Get file regardless of case (case insensitive)
					var EXT = fileName.get_extension().to_upper()
					if Filetypes.FILE_TYPES.has(EXT):
						var fullPath = baseDir.plus_file(fileName)
						var getModifiedTime = File.new().get_modified_time(fullPath)
						dict[EXT] = [fullPath, getModifiedTime]
			fileName = dir.get_next()
	return dict






#file.seek(2+(3*( x + (y*85))))
#	for x in 85:
#		for y in 85:
#			#1ms
#			value = file.get_8() #8ms
#			file.seek(1 * ( (y*(85)) + x ) ) #2ms
#			GridOwnership.set_cell(Vector2(x,y),value)


	# 8 bytes per subtile
	# 3 subtiles per tile
	# 85 tiles per side
	# 255 tiles total
	# + 2 subtiles * 85
	# + 2 subtiles * 85
#	var subtileY = 0
#	var subtileX = 0
#	var dataHeight = (85*3)+1
#	var dataWidth = (85*3)+1
#	while subtileY <= dataHeight:
#		while subtileX <= dataWidth:
#			file.seek( subtileX + (subtileY*dataWidth))
#			value = file.get_8()
#			GridOwnership.set_cell(Vector2(floor(subtileX/3),floor(subtileY/3)),value)
#			subtileX+=1
#		subtileX = 0
#		subtileY += 1



