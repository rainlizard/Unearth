extends WindowDialog
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oVBoxContainerConfigLocalMap = Nodelist.list["oVBoxContainerConfigLocalMap"]
onready var oVBoxContainerConfigFxdata = Nodelist.list["oVBoxContainerConfigFxdata"]
onready var oVBoxContainerConfigCampaign = Nodelist.list["oVBoxContainerConfigCampaign"]
onready var oVBoxContainerConfigData = Nodelist.list["oVBoxContainerConfigData"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oReadCfg = Nodelist.list["oReadCfg"]

func _on_ConfigFilesListWindow_about_to_show():
	update_everything()


func update_everything():
	print("update_everything")
	for currentContainer in [oVBoxContainerConfigData, oVBoxContainerConfigFxdata, oVBoxContainerConfigCampaign, oVBoxContainerConfigLocalMap]:
		for childNode in currentContainer.get_children():
			childNode.queue_free()
	for configType in [oConfigFileManager.LOAD_CFG_DATA, oConfigFileManager.LOAD_CFG_FXDATA, oConfigFileManager.LOAD_CFG_CAMPAIGN, oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
		if oConfigFileManager.paths_loaded.has(configType) == false:
			continue
		var targetGrid
		match configType:
			oConfigFileManager.LOAD_CFG_DATA:
				targetGrid = oVBoxContainerConfigData
			oConfigFileManager.LOAD_CFG_FXDATA:
				targetGrid = oVBoxContainerConfigFxdata
			oConfigFileManager.LOAD_CFG_CAMPAIGN:
				targetGrid = oVBoxContainerConfigCampaign
			oConfigFileManager.LOAD_CFG_CURRENT_MAP:
				targetGrid = oVBoxContainerConfigLocalMap
		for filePath in oConfigFileManager.paths_loaded[configType]:
			if filePath:
				add_linkbutton(filePath, targetGrid)


func add_linkbutton(filePath, targetGrid):
	var linkButtonNode = LinkButton.new()
	linkButtonNode.connect("pressed", self, "_on_linkbutton_pressed", [filePath])
	linkButtonNode.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
	linkButtonNode.text = filePath.get_file()
	linkButtonNode.hint_tooltip = filePath
	targetGrid.add_child(linkButtonNode)
	var horizontalSeparatorNode = HSeparator.new()
	targetGrid.add_child(horizontalSeparatorNode)


func _on_linkbutton_pressed(filePath):
	OS.shell_open(filePath)


func get_campaign_main_data(mapPathArgument):
	if mapPathArgument == "" or mapPathArgument == null:
		return {}
	var levelsDirectoryPath = mapPathArgument.get_base_dir().get_base_dir()
	var parentDirectoryName = levelsDirectoryPath.get_file()
	if parentDirectoryName != "levels" and parentDirectoryName != "campgns":
		return {}
	var listOfCampaignFiles = Utils.get_filetype_in_directory(levelsDirectoryPath, "cfg")
	for campaignFilePath in listOfCampaignFiles:
		var configData = oReadCfg.read_dkcfg_file(campaignFilePath)
		var levelsLocation = configData.get("common", {}).get("LEVELS_LOCATION", null)
		if levelsLocation and oGame.GAME_DIRECTORY.plus_file(levelsLocation).to_lower() == mapPathArgument.get_base_dir().to_lower():
			return configData
	return {}


func try_open_directory(directoryPath, logDescription):
	if directoryPath == null or directoryPath == "":
		print(logDescription + " path is not set or empty.")
		return false
	var directoryAccess = Directory.new()
	if directoryAccess.dir_exists(directoryPath):
		OS.shell_open(directoryPath)
		return true
	else:
		print(logDescription + " directory does not exist: " + directoryPath)
		return false


func _on_ConfigLinkLocalMap_pressed():
	if oCurrentMap.path != "" and oCurrentMap.path != null:
		var mapDirectory = oCurrentMap.path.get_base_dir()
		try_open_directory(mapDirectory, "Local map")
	else:
		print("No map loaded, cannot open local map directory.")


func _on_ConfigLinkFxData_pressed():
	try_open_directory(oGame.DK_FXDATA_DIRECTORY, "FXData")


func _on_ConfigLinkData_pressed():
	try_open_directory(oGame.DK_DATA_DIRECTORY, "Data")


func _on_ConfigLinkCampaign_pressed():
	var determinedCampaignConfigPath = ""
	if oCurrentMap.path != "" and oCurrentMap.path != null:
		var campaignData = get_campaign_main_data(oCurrentMap.path)
		var configsLocation = campaignData.get("common", {}).get("CONFIGS_LOCATION", "")
		if configsLocation != "":
			determinedCampaignConfigPath = oGame.GAME_DIRECTORY.plus_file(configsLocation)
		else:
			print("Campaign 'CONFIGS_LOCATION' is empty, using main game directory.")
			determinedCampaignConfigPath = oGame.GAME_DIRECTORY
	else:
		print("No map loaded, using main game directory for campaign.")
		determinedCampaignConfigPath = oGame.GAME_DIRECTORY

	var openedSuccessfully = try_open_directory(determinedCampaignConfigPath, "Determined campaign")
	if openedSuccessfully == false and determinedCampaignConfigPath != oGame.GAME_DIRECTORY:
		print("Fallback: Trying main game directory for campaign.")
		try_open_directory(oGame.GAME_DIRECTORY, "Main game (as campaign fallback)")
