extends WindowDialog
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oVBoxContainerConfigLocalMap = Nodelist.list["oVBoxContainerConfigLocalMap"]
onready var oVBoxContainerConfigFxdata = Nodelist.list["oVBoxContainerConfigFxdata"]
onready var oVBoxContainerConfigCampaign = Nodelist.list["oVBoxContainerConfigCampaign"]
onready var oVBoxContainerConfigData = Nodelist.list["oVBoxContainerConfigData"]


func _on_ConfigFilesListWindow_about_to_show():
	update_everything()

func update_everything():
	print("update_everything")
	for container in [oVBoxContainerConfigData, oVBoxContainerConfigFxdata, oVBoxContainerConfigCampaign, oVBoxContainerConfigLocalMap]:
		for child in container.get_children():
			child.queue_free()
	
	for cfg_type in [oCfgLoader.LOAD_CFG_DATA, oCfgLoader.LOAD_CFG_FXDATA, oCfgLoader.LOAD_CFG_CAMPAIGN, oCfgLoader.LOAD_CFG_CURRENT_MAP]:
		if oCfgLoader.paths_loaded.has(cfg_type) == false:
			continue
		
		var addToGrid
		
		match cfg_type:
			oCfgLoader.LOAD_CFG_DATA:
				addToGrid = oVBoxContainerConfigData
			oCfgLoader.LOAD_CFG_FXDATA:
				addToGrid = oVBoxContainerConfigFxdata
			oCfgLoader.LOAD_CFG_CAMPAIGN:
				addToGrid = oVBoxContainerConfigCampaign
			oCfgLoader.LOAD_CFG_CURRENT_MAP:
				addToGrid = oVBoxContainerConfigLocalMap
		
		for path in oCfgLoader.paths_loaded[cfg_type]:
			if path:
				add_linkbutton(path, addToGrid)


func add_linkbutton(path, addToGrid):
	var id = LinkButton.new()
	id.connect("pressed", self, "_on_linkbutton_pressed", [path])
	id.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
	id.text = path.get_file()
	id.hint_tooltip = path
	addToGrid.add_child(id)
	
	var hsepID = HSeparator.new()
	addToGrid.add_child(hsepID)
	

func _on_linkbutton_pressed(path):
	OS.shell_open(path)
