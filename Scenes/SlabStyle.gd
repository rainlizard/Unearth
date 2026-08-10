extends PanelContainer
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oTMapNames = Nodelist.list["oTMapNames"]

var scnSlabStyleButton = preload("res://Scenes/SlabStyleButton.tscn")
var paintSlabStyle = 0 setget set_paintSlabStyle
var styleButtons = {}
onready var oSelectedRect = get_node("../../../../Clippy/SelectedRect")

func initialize_grid_items():
	if is_instance_valid(oDisplaySlxNumbers):
		oDisplaySlxNumbers.update_grid()
	styleButtons.clear()
	for style in oTMapLoader.cachedTextures.size()+1:
		if style == 0 or oTMapLoader.is_tileset_cached(style-1):
			add_style_button(style)

func update_style_button(map):
	var style = map+1
	if oTMapLoader.is_tileset_cached(map):
		add_style_button(style)
	elif styleButtons.has(style):
		var btnId = styleButtons[style]
		styleButtons.erase(style)
		btnId.get_parent().remove_child(btnId)
		btnId.queue_free()
		if paintSlabStyle == style:
			_on_SlabStyleButtonPressed(styleButtons[0], 0)

func add_style_button(style):
	if styleButtons.has(style): return
	var insertAt = 0
	for existingStyle in styleButtons:
		if existingStyle < style:
			insertAt += 1
	var btnId = scnSlabStyleButton.instance()
	btnId.connect("pressed", self, "_on_SlabStyleButtonPressed", [btnId,style])
	btnId.connect("mouse_entered", oPickSlabWindow, "_on_hovered_over_item", [btnId])
	btnId.connect("mouse_exited", oPickSlabWindow, "_on_hovered_none")

	var tileset = style-1
	btnId.text = "~" if style == 0 else str(tileset)
	btnId.set_meta("grid_item_text", "Default" if style == 0 else oTMapNames.texture_map_names.get(tileset, ""))

	if style == paintSlabStyle:
		btnId.pressed = true
	btnId.rect_min_size = oPickSlabWindow.grid_item_size * oPickSlabWindow.grid_window_scale
	styleButtons[style] = btnId
	var oGridContainer = current_grid_container()
	oGridContainer.add_child(btnId)
	oGridContainer.move_child(btnId, insertAt)

func set_paintSlabStyle(setval):
	paintSlabStyle = setval
	oDisplaySlxNumbers.update_grid()

func _on_SlabStyleButtonPressed(btnId,value):
	oSelectedRect.boundToItem = btnId
	oSelectedRect.visible = true
	set_paintSlabStyle(value)

func update_paint_for_slab_style(tile):
	set_paintSlabStyle(oDataSlx.get_tileset_value(tile.x,tile.y))
	if styleButtons.has(paintSlabStyle):
		var id = styleButtons[paintSlabStyle]
		id.pressed = true
		oSelectedRect.boundToItem = id
		oSelectedRect.visible = true

func current_grid_container():
	return $"ScrollContainer/GridContainer"
