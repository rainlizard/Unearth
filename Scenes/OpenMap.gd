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
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oUi = Nodelist.list["oUi"]
onready var oImageAsMapDialog = Nodelist.list["oImageAsMapDialog"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oColumnEditor = Nodelist.list["oColumnEditor"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oSetNewFormat = Nodelist.list["oSetNewFormat"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oGuidelines = Nodelist.list["oGuidelines"]
onready var oResizeCurrentMapSize = Nodelist.list["oResizeCurrentMapSize"]
onready var oOwnerSelection = Nodelist.list["oOwnerSelection"]
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]
onready var oOnlyOwnership = Nodelist.list["oOnlyOwnership"]
onready var oCfgLoader = Nodelist.list["oCfgLoader"]


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
			#for i in 200:
			#	yield(get_tree(), "idle_frame")
			#oCurrentMap.clear_map()
			open_map("C:/Games/Dungeon Keeper/levels/classic/map00254.slb")
			#open_map("C:/Games/Dungeon Keeper/levels/personal/map00001.slb")
			#open_map("C:/Games/Dungeon Keeper/campgns/dk2/map00200.slb")
		else:
			# initialize a cleared map
			oCurrentMap.clear_map()
			
			for i in 2:
				yield(get_tree(),'idle_frame')
			oMapBrowser._on_BrowseMapsMenu_pressed()

func _on_files_dropped(_files, _screen):
	open_map(_files[0])

func open_map(filePath):
	
	# a filePath of "" means make a blank map.
	
	# This will replace \ with /, just for the sake of fixing ugliness
	filePath = filePath.replace("\\", "/")
	
	# Prevent opening any maps under any circumstance if you haven't set the dk exe yet. (Fix to launching via file association)
	if oGame.EXECUTABLE_PATH == "":
		oMessage.quick("Error: Cannot open map because game executable is not set. Set in File -> Preferences")
		return
	
	# Prevent opening any maps under any circumstance if textures haven't been loaded. (Fix to launching via file association)
#	if oTMapLoader.texturesLoadedState != oTMapLoader.LOADING_SUCCESS:
#		oMessage.quick("Error: Cannot open map because textures haven't been loaded")
#		return
	
	print("----------- Opening map ------------")
	TOTAL_TIME_TO_OPEN_MAP = OS.get_ticks_msec()
	
	# Always begin by clearing map
	oCurrentMap.clear_map()
	
	var map = filePath.get_basename()
	
	# Open all map file types
	oCurrentMap.currentFilePaths = get_accompanying_files(map)
	oCurrentMap.DKScript_enabled = oCurrentMap.currentFilePaths.has("TXT")
	oCurrentMap.LuaScript_enabled = oCurrentMap.currentFilePaths.has("LUA")
	
	compressedFiles.clear()
	for i in oCurrentMap.currentFilePaths.values():
		if oRNC.check_for_rnc_compression(i[oCurrentMap.PATHSTRING]) == true:
			compressedFiles.append(i[oCurrentMap.PATHSTRING])
	
	oCfgLoader.start(filePath)
	
	if compressedFiles.empty() == true:
		# Load files
		
		if oNewMapWindow.visible == true:
			oDataLof.use_size(oXSizeLine.text.to_int(), oYSizeLine.text.to_int())
			print("NEW MAPSIZE = " + str(M.xSize) + " " + str(M.ySize))
		
		
		# Set map format
		if map == "": # If it's a new map, then map format is set to the format you selected on New Map window
			oCurrentFormat.selected = oSetNewFormat.selected
		else:
			if oCurrentMap.currentFilePaths.has("TNGFX") == true:
				oCurrentFormat.selected = Constants.KfxFormat
			else:
				oCurrentFormat.selected = Constants.ClassicFormat
		
		for EXT in oBuffers.FILE_TYPES:
			if oCurrentMap.currentFilePaths.has(EXT) == true:
				
				# Don't bother reading original formats if KFX format files have been found
				if EXT == "TNG" and oCurrentMap.currentFilePaths.has("TNGFX") == true: continue
				if EXT == "APT" and oCurrentMap.currentFilePaths.has("APTFX") == true: continue
				if EXT == "LGT" and oCurrentMap.currentFilePaths.has("LGTFX") == true: continue
				if EXT == "LIF" and oCurrentMap.currentFilePaths.has("LOF") == true: continue
				
				var readPath = oCurrentMap.currentFilePaths[EXT][oCurrentMap.PATHSTRING]
				oBuffers.read(readPath, EXT.to_upper())
			else:
				print("Missing " + EXT + " file, so create blank data for that one.")
				oBuffers.new_blank(EXT.to_upper())
				
				# Assign name data to any that's missing
				if EXT == "LIF":
					var mapName = oDataMapName.get_special_lif_text(filePath)
					if mapName != "":
						print("LIF was missing so assign the special name: " + mapName)
						oDataMapName.set_map_name(mapName)
				
				# Some maps can function without WLB files. So build them here.
				# Generate WLB values from SLB. This is dependent on SLB being ordered before WLB inside Filetypes.FILE_TYPES
				if EXT == "WLB":
					for ySlab in M.ySize:
						for xSlab in M.xSize:
							var slabID = oDataSlab.get_cell(xSlab, ySlab)
							oDataLiquid.set_cell(xSlab, ySlab, Slabs.data[slabID][Slabs.LIQUID_TYPE])
		
		continue_load(map)
		continue_load_openmap(map)
		print('TOTAL time to open map: '+str(OS.get_ticks_msec()-TOTAL_TIME_TO_OPEN_MAP)+'ms')
		print("----------------------------------------------")
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

func continue_load(map):
	# initialize_editor_components
	oPickThingWindow.initialize_thing_grid_items()
	oEditor.update_boundaries()
	oScriptEditor.initialize_for_new_map()
	oOverheadOwnership.start()
	oScriptHelpers.start()
	
	oTMapLoader.start()
	oOverheadGraphics.update_full_overhead_map() # 'Display fields' are created for each texture loaded
	oTMapLoader.apply_texture_pack()
	
	oDataClm.count_filled_clm_entries()
	
	# finalize_map_opening
	oEditor.set_view_2d()

	oMenu.add_recent(map)
	
	# Update for Undo
	
	oDisplaySlxNumbers.update()
	
	if oResizeCurrentMapSize.visible == true:
		oResizeCurrentMapSize._on_ResizeCurrentMapSize_about_to_show()
	
	if is_instance_valid(oInspector.inspectingInstance):
		oInspector.deselect()


func continue_load_openmap(map):
	oEditor.mapHasBeenEdited = false
	oOwnerSelection.update_ownership_head_icons()
	oScriptGenerator.update_options_based_on_mapformat()
	oPickSlabWindow.add_slabs()
	oOnlyOwnership.update_grid_items()
	oDynamicMapTree.highlight_current_map()
	oCurrentMap.set_path_and_title(map)
	oUndoStates.clear_history()
	oGuidelines.update()
	oMapSettingsWindow.visible = false
	if map == "":
		oMessage.quick('New map')
	else:
		oMessage.quick('Opened map')
	
	# When opening a map, be sure that column 0 is empty. Otherwise apply a fix.
	if oDataClm.permanent[0] != 0 or oDataClm.cubes[0] != [0,0,0,0, 0,0,0,0]:
		# Make column 0 empty while preserving the column that was there.
		oDataClm.sort_columns_by_utilized()
		oDataClm.delete_column(0)
		oEditor.mapHasBeenEdited = true
		oMessage.quick("Fixed column index 0, re-save your map.")
	oDataClm.store_default_data()
	
	for i in 3:
		yield(get_tree(),'idle_frame')
	oCamera2D.reset_camera(M.xSize, M.ySize)


func _on_ConfirmDecompression_confirmed():
	print('Attempting to decompress...')
	
	for path in compressedFiles:
		oRNC.decompress(path)
	
	# Retry opening the map
	open_map(compressedFiles[0])


func _on_FileDialogOpen_file_selected(path):
	open_map(path)


func get_accompanying_files(map):
	var CODETIME_START = OS.get_ticks_msec()
	var baseDir = map.get_base_dir()
	var mapName = map.get_file().get_basename() # Get the map name without the extension
	
	var dict = {}
	var dir = Directory.new()
	if dir.open(baseDir) == OK:
		dir.list_dir_begin(true, false)

		var fileName = dir.get_next()
		while fileName != "":
			if dir.current_is_dir() == false:
				var fileBaseName = fileName.get_basename() # Get the file name without the extension
				if fileBaseName.to_upper() == mapName.to_upper():
					var EXT = fileName.get_extension().to_upper()
					if oBuffers.FILE_TYPES.has(EXT):
						var fullPath = baseDir.plus_file(fileName)
						var getModifiedTime = File.new().get_modified_time(fullPath)
						dict[EXT] = [fullPath, getModifiedTime]
			fileName = dir.get_next()
	print('get_accompanying_files: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	return dict
