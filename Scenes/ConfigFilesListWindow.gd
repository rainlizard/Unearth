extends WindowDialog
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oFileListGridA = Nodelist.list["oFileListGridA"]
onready var oFileListGridB = Nodelist.list["oFileListGridB"]
onready var oFileListGridC = Nodelist.list["oFileListGridC"]


func _on_ConfigFilesListWindow_about_to_show():
	update_everything()

func update_everything():
	print("update_everything")
	for gridParent in [oFileListGridA, oFileListGridB, oFileListGridC]:
		for child in gridParent.get_children():
			child.queue_free()
	
	
	for cfg_type in [oCfgLoader.LOAD_CFG_FXDATA, oCfgLoader.LOAD_CFG_CAMPAIGN, oCfgLoader.LOAD_CFG_CURRENT_MAP]:
		if oCfgLoader.paths_loaded.has(cfg_type) == false:
			continue
		
		var addToGrid
		
		match cfg_type:
			oCfgLoader.LOAD_CFG_FXDATA:
				addToGrid = oFileListGridA
			oCfgLoader.LOAD_CFG_CAMPAIGN:
				addToGrid = oFileListGridB
			oCfgLoader.LOAD_CFG_CURRENT_MAP:
				addToGrid = oFileListGridC
		
		for path in oCfgLoader.paths_loaded[cfg_type]:
			if path:
				add_linkbutton(path, addToGrid)

func add_linkbutton(path, addToGrid):
	var id = LinkButton.new()
	id.connect("pressed", self, "_on_linkbutton_pressed", [path])
	id.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
	id.text = path
	addToGrid.add_child(id)

func _on_linkbutton_pressed(path):
	OS.shell_open(path)
