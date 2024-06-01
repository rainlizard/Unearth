extends PanelContainer
onready var oCfgLoader = Nodelist.list["oCfgLoader"]

onready var containerForLabels = $ScrollContainer/VBoxContainer

func start():
	for i in containerForLabels.get_children():
		i.queue_free()
	
	for cfg_type in [oCfgLoader.LOAD_CFG_FXDATA, oCfgLoader.LOAD_CFG_CAMPAIGN, oCfgLoader.LOAD_CFG_CURRENT_MAP]:
		if oCfgLoader.paths_loaded.has(cfg_type) == false:
			continue
		
#		var addToGrid
		
#		match cfg_type:
#			oCfgLoader.LOAD_CFG_FXDATA:
#				addToGrid = oFileListGridA
#			oCfgLoader.LOAD_CFG_CAMPAIGN:
#				addToGrid = oFileListGridB
#			oCfgLoader.LOAD_CFG_CURRENT_MAP:
#				addToGrid = oFileListGridC
		
		for path in oCfgLoader.paths_loaded[cfg_type]:
			if path:
				if path.to_lower().ends_with("slabset.toml"):
					add_linkbutton(path)

func add_linkbutton(path):
	var id = LinkButton.new()
	id.connect("pressed", self, "_on_linkbutton_pressed", [path])
	id.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
	id.text = path.get_base_dir().get_file().plus_file(path.get_file())
	containerForLabels.add_child(id)

func _on_linkbutton_pressed(path):
	OS.shell_open(path)
