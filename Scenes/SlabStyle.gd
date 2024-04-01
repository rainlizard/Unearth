extends PanelContainer
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]

var scnSlabStyleButton = preload("res://Scenes/SlabStyleButton.tscn")
var paintSlabStyle = 0 setget set_paintSlabStyle
onready var oSelectedRect = get_node("../../../../Clippy/SelectedRect")

func initialize_grid_items():
	if is_instance_valid(oDisplaySlxNumbers):
		oDisplaySlxNumbers.update_grid()
	var oGridContainer = current_grid_container()
#	# Add children
	for i in oTextureCache.cachedTextures.size()+1: # +1 is for "Default"
		var btnId = scnSlabStyleButton.instance()
		btnId.connect("pressed", self, "_on_SlabStyleButtonPressed", [btnId,i])
		
		btnId.connect("mouse_entered", oPickSlabWindow, "_on_hovered_over_item", [btnId])
		btnId.connect("mouse_exited", oPickSlabWindow, "_on_hovered_none")
		
		
		if i == 0:
			btnId.text = "~" #"Default"
			btnId.set_meta("grid_item_text","Default")
		else:
			var val = i-1
			btnId.text = str(val) #"tmapa" + str(i).pad_zeros(3) + ".dat"
			if Constants.TEXTURE_MAP_NAMES.has(val) == true:
				btnId.set_meta("grid_item_text", Constants.TEXTURE_MAP_NAMES[val])
			else:
				btnId.set_meta("grid_item_text", "")
		
		if i == paintSlabStyle:
			btnId.pressed = true
		
		oGridContainer.add_child(btnId)
#aaa.text = Constants.TEXTURE_MAP_NAMES[i]
func set_paintSlabStyle(setval):
	paintSlabStyle = setval
	oDisplaySlxNumbers.update_grid()

func _on_SlabStyleButtonPressed(btnId,value):
	oSelectedRect.boundToItem = btnId
	oSelectedRect.visible = true
	set_paintSlabStyle(value)

func update_paint_for_slab_style(tile):
	set_paintSlabStyle(oDataSlx.get_tileset_value(tile.x,tile.y))
	# Select grid item in window
	for id in current_grid_container().get_children():
		if id is Button:
			if id.text == str(paintSlabStyle-1):
				id.pressed = true
				oSelectedRect.boundToItem = id
				oSelectedRect.visible = true
			elif id.text == '~' and paintSlabStyle == 0:
				id.pressed = true
				oSelectedRect.boundToItem = id
				oSelectedRect.visible = true

func current_grid_container():
	return $"ScrollContainer/GridContainer"


#	var setStyle
#	if setval == 0:
#		setStyle = oDataLevelStyle.data
#	else:
#		setStyle = setval-1
#	oTextureCache.assign_textures_to_slab_window(setStyle)

#	if visible == false:
#		if is_instance_valid(oTextureCache):
#			oTextureCache.assign_textures_to_slab_window(oDataLevelStyle.data)
#		return

