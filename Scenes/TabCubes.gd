extends VBoxContainer

onready var oEditor = Nodelist.list["oEditor"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]
onready var oCubeVoxelView = Nodelist.list["oCubeVoxelView"]
onready var oCubeIndexSpinBox = Nodelist.list["oCubeIndexSpinBox"]
onready var oCubeNameLineEdit = Nodelist.list["oCubeNameLineEdit"]
onready var oCubeNorthSpinBox = Nodelist.list["oCubeNorthSpinBox"]
onready var oCubeEastSpinBox = Nodelist.list["oCubeEastSpinBox"]
onready var oCubeSouthSpinBox = Nodelist.list["oCubeSouthSpinBox"]
onready var oCubeWestSpinBox = Nodelist.list["oCubeWestSpinBox"]
onready var oCubeTopSpinBox = Nodelist.list["oCubeTopSpinBox"]
onready var oCubeBottomSpinBox = Nodelist.list["oCubeBottomSpinBox"]
onready var oCubeCopyButton = Nodelist.list["oCubeCopyButton"]
onready var oCubePasteButton = Nodelist.list["oCubePasteButton"]
onready var oCubeFirstUnusedButton = Nodelist.list["oCubeFirstUnusedButton"]
onready var oCubeRevertButton = Nodelist.list["oCubeRevertButton"]
onready var oCubeRevertAllButton = Nodelist.list["oCubeRevertAllButton"]
onready var oCubeHelpButton = Nodelist.list["oCubeHelpButton"]
onready var oCurrentlyOpenCubes = Nodelist.list["oCurrentlyOpenCubes"]
onready var oModifiedCubesLabel = Nodelist.list["oModifiedCubesLabel"]
onready var oModifiedCubesPanelContainer = Nodelist.list["oModifiedCubesPanelContainer"]

onready var textureSpinBoxArray = [
	oCubeNorthSpinBox,
	oCubeEastSpinBox,
	oCubeSouthSpinBox,
	oCubeWestSpinBox,
	oCubeTopSpinBox,
	oCubeBottomSpinBox,
]

var clipboard = {
	"name": "",
	"textures": []
}
var isMouseOverTextureSide = -1
var map_graphics_update_timer = Timer.new()
var pending_map_graphics_cube_ids = []

func _ready():
	add_child(map_graphics_update_timer)
	map_graphics_update_timer.one_shot = true
	map_graphics_update_timer.wait_time = 0.25
	map_graphics_update_timer.connect("timeout", self, "_on_map_graphics_update_timer_timeout")
	connect("visibility_changed", self, "_on_TabCubes_visibility_changed")
	oCubeIndexSpinBox.connect("value_changed", self, "_on_CubeIndexSpinBox_value_changed")
	oCubeIndexSpinBox.connect("value_changed", oCubeVoxelView, "_on_CubeIndexSpinBox_value_changed")
	oCubeNameLineEdit.connect("text_changed", self, "_on_CubeNameLineEdit_text_changed")
	oCubeCopyButton.connect("pressed", self, "_on_CubeCopyButton_pressed")
	oCubePasteButton.connect("pressed", self, "_on_CubePasteButton_pressed")
	oCubeFirstUnusedButton.connect("pressed", self, "_on_CubeFirstUnusedButton_pressed")
	oCubeRevertButton.connect("pressed", self, "_on_CubeRevertButton_pressed")
	oCubeRevertAllButton.connect("pressed", self, "_on_CubeRevertAllButton_pressed")
	oCubeHelpButton.connect("pressed", self, "_on_CubeHelpButton_pressed")
	oModifiedCubesLabel.connect("meta_clicked", self, "_on_ModifiedCubesLabel_meta_clicked")
	for i in textureSpinBoxArray.size():
		textureSpinBoxArray[i].connect("value_changed", self, "_on_texture_value_changed", [i])
		textureSpinBoxArray[i].connect("mouse_entered", self, "_on_texture_mouse_entered", [i])
		textureSpinBoxArray[i].connect("mouse_exited", self, "_on_texture_mouse_exited")
	establish_maximum_cube_field_values()


func _on_TabCubes_visibility_changed():
	if visible == false:
		return
	just_opened()
	oCubeVoxelView.initialize()
	update_cube_revert_button_state()


func just_opened():
	establish_maximum_cube_field_values()
	_on_CubeIndexSpinBox_value_changed(oCubeIndexSpinBox.value)


func establish_maximum_cube_field_values():
	oCubeIndexSpinBox.min_value = 0
	oCubeIndexSpinBox.max_value = Cube.CUBE_ITEMS_MAX - 1
	for spinbox in textureSpinBoxArray:
		spinbox.min_value = 0
		spinbox.max_value = Cube.TEXTURE_ID_MAX


func _on_CubeIndexSpinBox_value_changed(value):
	if Cube.tex.empty():
		return
	var cubeID = clamp(int(value), 0, Cube.CUBE_ITEMS_MAX - 1)
	if cubeID != int(value):
		oCubeIndexSpinBox.value = cubeID
		return
	Cube.ensure_cube_exists(cubeID)
	establish_maximum_cube_field_values()
	oCubeNameLineEdit.set_block_signals(true)
	for spinbox in textureSpinBoxArray:
		spinbox.set_block_signals(true)
	oCubeNameLineEdit.text = Cube.names[cubeID]
	for i in textureSpinBoxArray.size():
		textureSpinBoxArray[i].value = Cube.tex[cubeID][i]
	oCubeNameLineEdit.set_block_signals(false)
	for spinbox in textureSpinBoxArray:
		spinbox.set_block_signals(false)
	adjust_ui_color_if_different()


func _on_CubeNameLineEdit_text_changed(new_text):
	var cubeID = int(oCubeIndexSpinBox.value)
	Cube.ensure_cube_exists(cubeID)
	Cube.names[cubeID] = new_text
	set_cube_cfg_value(cubeID, "Name", new_text)
	cube_changed()


func _on_texture_value_changed(value, side):
	if isMouseOverTextureSide == side:
		oCustomTooltip.set_floortexture(value)
	var cubeID = int(oCubeIndexSpinBox.value)
	Cube.ensure_cube_exists(cubeID)
	Cube.tex[cubeID][side] = clamp(int(value), 0, Cube.TEXTURE_ID_MAX)
	set_cube_cfg_value(cubeID, "Textures", Cube.tex[cubeID].duplicate(true))
	cube_changed()
	if pending_map_graphics_cube_ids.find(cubeID) == -1:
		pending_map_graphics_cube_ids.append(cubeID)
	map_graphics_update_timer.stop()
	map_graphics_update_timer.start()


func _on_map_graphics_update_timer_timeout():
	refresh_map_graphics(pending_map_graphics_cube_ids)
	pending_map_graphics_cube_ids.clear()


func _on_texture_mouse_entered(side):
	isMouseOverTextureSide = side
	oCustomTooltip.set_floortexture(textureSpinBoxArray[side].value)


func _on_texture_mouse_exited():
	isMouseOverTextureSide = -1
	oCustomTooltip.set_text("")


func set_cube_cfg_value(cubeID, key, value):
	var section = "cube" + str(cubeID)
	if Cube.cfg_data.has(section) == false:
		Cube.cfg_data[section] = {}
	Cube.cfg_data[section][key] = value


func cube_changed():
	oEditor.mapHasBeenEdited = true
	Cube.mark_modified()
	oCubeVoxelView.update_cube_view()
	adjust_ui_color_if_different()
	update_cube_revert_button_state()


func refresh_map_graphics(cubeIDs):
	if cubeIDs is Array and cubeIDs.empty():
		return
	oPickSlabWindow.add_slabs()
	if oDataClm.cubes.empty():
		return
	var refreshAllCubes = false
	var cubeIDList = []
	if cubeIDs is Array:
		cubeIDList = cubeIDs
	else:
		refreshAllCubes = cubeIDs == -1
		cubeIDList = [cubeIDs]
	var shapePositions = {}
	for y in range(M.ySize * 3):
		for x in range(M.xSize * 3):
			var clmIndex = oDataClmPos.get_cell_clmpos(x, y)
			if refreshAllCubes:
				shapePositions[Vector2(x / 3, y / 3)] = true
			else:
				for cubeID in cubeIDList:
					if oDataClm.cubes[clmIndex].has(cubeID):
						shapePositions[Vector2(x / 3, y / 3)] = true
						break
	if shapePositions.empty() == false:
		oOverheadGraphics.overhead2d_update_rect_single_threaded(shapePositions.keys())
	if oEditor.currentView == oEditor.VIEW_3D:
		oGenerateTerrain.start()


func _on_CubeCopyButton_pressed():
	var cubeID = int(oCubeIndexSpinBox.value)
	clipboard = {
		"name": Cube.names[cubeID],
		"textures": Cube.tex[cubeID].duplicate(true)
	}
	oMessage.quick("Cube copied to clipboard")


func _on_CubePasteButton_pressed():
	if clipboard["textures"].empty():
		oMessage.quick("Clipboard is empty. Copy a cube first.")
		return
	var cubeID = int(oCubeIndexSpinBox.value)
	Cube.ensure_cube_exists(cubeID)
	Cube.names[cubeID] = clipboard["name"]
	Cube.tex[cubeID] = Cube.normalize_textures(clipboard["textures"])
	set_cube_cfg_value(cubeID, "Name", Cube.names[cubeID])
	set_cube_cfg_value(cubeID, "Textures", Cube.tex[cubeID].duplicate(true))
	cube_changed()
	refresh_map_graphics(cubeID)
	_on_CubeIndexSpinBox_value_changed(cubeID)
	oMessage.quick("Pasted cube from clipboard")


func _on_CubeFirstUnusedButton_pressed():
	var cubeID = Cube.find_first_unused_cube()
	if cubeID == -1:
		oMessage.quick("There are no unused cubes")
		return
	oCubeIndexSpinBox.value = cubeID


func _on_CubeRevertButton_pressed():
	var cubeID = int(oCubeIndexSpinBox.value)
	Cube.revert_cube(cubeID)
	cube_changed()
	refresh_map_graphics(cubeID)
	_on_CubeIndexSpinBox_value_changed(cubeID)
	oMessage.quick("Reverted cube to default")


func _on_CubeRevertAllButton_pressed():
	for cubeID in Cube.get_all_export_cube_ids():
		Cube.revert_cube(cubeID)
	Cube.mark_modified()
	oEditor.mapHasBeenEdited = true
	_on_CubeIndexSpinBox_value_changed(oCubeIndexSpinBox.value)
	oCubeVoxelView.refresh_entire_view()
	refresh_map_graphics(-1)
	update_cube_revert_button_state()
	oMessage.quick("Reverted all cubes")


func update_cube_revert_button_state():
	var modified_cube_ids = Cube.get_all_export_cube_ids()
	var cubeID = clamp(int(oCubeIndexSpinBox.value), 0, Cube.CUBE_ITEMS_MAX - 1)
	oCubeRevertButton.disabled = not Cube.is_cube_export_different(cubeID)
	oCubeRevertAllButton.disabled = modified_cube_ids.empty()
	var file_path = oCurrentMap.existing_cubes_file
	var final_text = ""
	var tooltip_text = ""
	if modified_cube_ids.empty():
		if Cube.modified_since_load and file_path != "" and file_path.get_file() != "cubes.cfg":
			final_text = "Save will delete: " + file_path.get_file()
			tooltip_text = file_path
		else:
			final_text = ""
	elif file_path != "":
		var filename = file_path.get_file()
		if filename == "cubes.cfg":
			final_text = "Loaded: /" + file_path.get_base_dir().get_file() + "/" + filename
		else:
			final_text = "Loaded: " + filename
		tooltip_text = file_path
		if Cube.modified_since_load and oCurrentMap.path != "" and filename == "cubes.cfg":
			var local_file_path = oCurrentMap.path.get_basename() + ".cubes.cfg"
			final_text = "Save target: " + local_file_path.get_file()
			tooltip_text = "Loaded: " + file_path + "\nSave target: " + local_file_path
	else:
		if oCurrentMap.path == "":
			final_text = "Save map first"
			tooltip_text = "Save the map first to create a local cubes.cfg override."
		else:
			var local_file_path = oCurrentMap.path.get_basename() + ".cubes.cfg"
			final_text = "Save will create: " + local_file_path.get_file()
			tooltip_text = local_file_path
	oCurrentlyOpenCubes.text = final_text
	oCurrentlyOpenCubes.hint_tooltip = tooltip_text
	Utils.set_id_links_label(modified_cube_ids, oModifiedCubesLabel, oModifiedCubesPanelContainer, "No modified cubes")


func _on_ModifiedCubesLabel_meta_clicked(meta):
	oCubeIndexSpinBox.value = int(meta)


func adjust_ui_color_if_different():
	var cubeID = int(oCubeIndexSpinBox.value)
	var default_name = Cube.default_names[cubeID] if cubeID < Cube.default_names.size() else ""
	oCubeNameLineEdit.modulate = Color(1.4,1.4,1.7) if Cube.names[cubeID] != default_name else Color(1,1,1)
	for i in textureSpinBoxArray.size():
		var default_value = -1
		if cubeID < Cube.default_tex.size() and i < Cube.default_tex[cubeID].size():
			default_value = Cube.default_tex[cubeID][i]
		textureSpinBoxArray[i].modulate = Color(1.4,1.4,1.7) if Cube.tex[cubeID][i] != default_value else Color(1,1,1)


func _on_CubeHelpButton_pressed():
	var helptxt = ""
	helptxt += "cubes.cfg controls the six texture IDs used by each cube face.\n\n"
	helptxt += "Cube changes are saved as a local map override when you save the map.\n\n"
	helptxt += "Texture order is North, East, South, West, Top, Bottom."
	oMessage.big("Help", helptxt)
