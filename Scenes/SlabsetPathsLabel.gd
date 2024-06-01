extends PanelContainer
onready var oCfgLoader = Nodelist.list["oCfgLoader"]

onready var containerForLabels = $ScrollContainer/VBoxContainer

# THIS SCRIPT IS USED BY BOTH SlabsetPathsLabel AND ColumnsetPathsLabel

func start():
	var fileName
	match name:
		"SlabsetPathsLabel": fileName = "slabset.toml"
		"ColumnsetPathsLabel": fileName = "columnset.toml"
	
	for i in containerForLabels.get_children():
		i.queue_free()
	
	for cfg_type in [oCfgLoader.LOAD_CFG_FXDATA, oCfgLoader.LOAD_CFG_CAMPAIGN, oCfgLoader.LOAD_CFG_CURRENT_MAP]:
		if oCfgLoader.paths_loaded.has(cfg_type) == false:
			continue
		
		for path in oCfgLoader.paths_loaded[cfg_type]:
			if path:
				if path.to_lower().ends_with(fileName):
					add_linkbutton(path)

func add_linkbutton(path):
	var id = LinkButton.new()
	id.connect("pressed", self, "_on_linkbutton_pressed", [path])
	id.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
	id.text = path.get_base_dir().get_file().plus_file(path.get_file())
	containerForLabels.add_child(id)

func _on_linkbutton_pressed(path):
	OS.shell_open(path)


#		match cfg_type:
#			oCfgLoader.LOAD_CFG_FXDATA:
#			oCfgLoader.LOAD_CFG_CAMPAIGN:
#			oCfgLoader.LOAD_CFG_CURRENT_MAP:
