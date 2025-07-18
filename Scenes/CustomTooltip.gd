extends Control
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]

var offset = Vector2(0,-35)

func _ready():
	visible = false
	yield(get_tree(),'idle_frame')
	visible = false

func _process(delta):
	if visible == true:
		rect_global_position = get_global_mouse_position() + offset

func set_text(txt):
	$PanelContainer/HBoxContainer/TooltipPicture.visible = false
	$PanelContainer/HBoxContainer/Label.text = txt
	if txt == "":
		visible = false
	else:
		visible = true
		VisualServer.canvas_item_set_z_index(get_canvas_item(), 10)
	#$TooltipPicture.visible = false
#	yield(get_tree(),'idle_frame')
#	yield(get_tree(),'idle_frame')
#	rect_size = Vector2(0,0)
	
func get_text():
	return $PanelContainer/HBoxContainer/Label.text

func set_floortexture(floorTextureValue):
	var oTooltipPic = $PanelContainer/HBoxContainer/TooltipPicture
	oTooltipPic.visible = true
	
	visible = true
	VisualServer.canvas_item_set_z_index(get_canvas_item(), 10)
	#$PanelContainer/Label.text = ""
	
	var dataImage = Image.new()
	var dataTexture = ImageTexture.new()
	dataImage.create(1, 1, false, Image.FORMAT_RGB8)
	dataTexture.create_from_image(dataImage, 0)

	dataImage.lock()
	dataImage.set_pixel(0, 0, Color8(int(floorTextureValue) >> 16 & 255, int(floorTextureValue) >> 8 & 255, int(floorTextureValue) & 255))
	dataImage.unlock()
	dataTexture.set_data(dataImage)
	
	# Get required texture resources
	var oTMapLoader = Nodelist.list["oTMapLoader"]
	var oReadPalette = Nodelist.list["oReadPalette"]
	var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
	
	oTooltipPic.material.set_shader_param("showOnlySpecificStyle", 0)
	oTooltipPic.material.set_shader_param("slxData", preload("res://Shaders/Black3x3.png"))
	oTooltipPic.material.set_shader_param("slabIdData", preload("res://Shaders/Black3x3.png"))
	oTooltipPic.material.set_shader_param("fieldSizeInSubtiles", Vector2(1, 1))
	oTooltipPic.material.set_shader_param("animationDatabase", oTextureAnimation.animation_database_texture)
	oTooltipPic.material.set_shader_param("viewTextures", dataTexture)
	
	if oTMapLoader.cachedTextures.size() > 0 and oDataLevelStyle.data >= 0 and oDataLevelStyle.data < oTMapLoader.cachedTextures.size():
		var currentPack = oTMapLoader.cachedTextures[oDataLevelStyle.data]
		if currentPack != null:
			oTooltipPic.material.set_shader_param("tmap_A_top", currentPack[0])
			oTooltipPic.material.set_shader_param("tmap_A_bottom", currentPack[1])
			oTooltipPic.material.set_shader_param("tmap_B_top", currentPack[2])
			oTooltipPic.material.set_shader_param("tmap_B_bottom", currentPack[3])
	
	var paletteTexture = oReadPalette.get_palette_texture()
	if paletteTexture != null:
		oTooltipPic.material.set_shader_param("palette_texture", paletteTexture)
