extends Node
onready var oGame2D = Nodelist.list["oGame2D"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oQuickMapPreviewDisplay = Nodelist.list["oQuickMapPreviewDisplay"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
onready var oReadPalette = Nodelist.list["oReadPalette"]

signal column_graphics_completed

var overheadImgData = Image.new()
var overheadTexData = ImageTexture.new()

var arrayOfColorRects = []

var thread = Thread.new()
var semaphore = Semaphore.new()
var mutex = Mutex.new()
var job_queue = []
var pixel_data = PoolByteArray()

func update_full_overhead_map():
	var CODETIME_START = OS.get_ticks_msec()
	
	if arrayOfColorRects.empty() == true:
		initialize_display_fields()
	else:
		update_display_fields_size()
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	
	for i in 2: # Helps prevent the column updating from freezing the editor so much.
		yield(get_tree(),'idle_frame')
	call_deferred("overhead2d_update_rect_single_threaded", shapePositionArray)
	print('Overhead graphics done in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


# Using a single threaded version for updating partial graphics.
# and a multi-threaded version for updating the entire map's graphics.
func overhead2d_update_rect_single_threaded(shapePositionArray):
	pixel_data = generate_pixel_data(pixel_data, shapePositionArray)
	overheadImgData.create_from_data(M.xSize * 3, M.ySize * 3, false, Image.FORMAT_RGB8, pixel_data)
	overheadTexData.create_from_image(overheadImgData, 0)
	emit_signal("column_graphics_completed")

const subtile3x3 = [
	Vector2(0,0), Vector2(1,0), Vector2(2,0),
	Vector2(0,1), Vector2(1,1), Vector2(2,1),
	Vector2(0,2), Vector2(1,2), Vector2(2,2)
]

func generate_pixel_data(pixData, shapePositionArray):
	var CODETIME_START = OS.get_ticks_msec()
	var width = M.xSize * 3
	var height = M.ySize * 3
	
	pixData.resize(width * height * 3)  # Assuming RGB8 format
	
	for pos in shapePositionArray:
		var basePosX = pos.x * 3
		var basePosY = pos.y * 3
		var slabID = oDataSlab.get_cellv(pos)
		for offset in subtile3x3:  # 3x3 subtiles
			var x = basePosX + offset.x
			var y = basePosY + offset.y
			var clmIndex = oDataClmPos.get_cell_clmpos(x, y)
			var cubeFace = oDataClm.get_top_cube_face(clmIndex, slabID)
			var pixelIndex = ((y * width) + x) * 3

			pixData[pixelIndex] = cubeFace >> 16 & 255
			pixData[pixelIndex + 1] = cubeFace >> 8 & 255
			pixData[pixelIndex + 2] = cubeFace & 255
	print('pixData Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	return pixData


func initialize_display_fields():
	arrayOfColorRects.clear() # just in case
	
	# Default
	if oTMapLoader.cachedTextures.size() > 0:
		createDisplayField(oDataLevelStyle.data, 0) # 0 means "Show Default Style"
	
	# Slab styles
	for map in oTMapLoader.cachedTextures.size():
		createDisplayField(map, map+1)

func createDisplayField(setMap, showStyle):
	var displayField = ColorRect.new()
	displayField.rect_size = Vector2(M.xSize * 96, M.ySize * 96)
	#displayField.visible = false # FPS is only saved when setting visible to false. FPS is not saved by making image transparent
	displayField.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Shaders/display_texture_2d.shader")
	displayField.material = mat
	
	if showStyle != 0: # Do not change the texturemap for default style
		mat.set_shader_param("tmap_A_top", oTMapLoader.cachedTextures[setMap][0])
		mat.set_shader_param("tmap_A_bottom", oTMapLoader.cachedTextures[setMap][1])
		mat.set_shader_param("tmap_B_top", oTMapLoader.cachedTextures[setMap][2])
		mat.set_shader_param("tmap_B_bottom", oTMapLoader.cachedTextures[setMap][3])
	
	mat.set_shader_param("showOnlySpecificStyle", showStyle)
	mat.set_shader_param("fieldSizeInSubtiles", Vector2((M.xSize*3), (M.ySize*3)))
	mat.set_shader_param("animationDatabase", oTextureAnimation.animation_database_texture)
	mat.set_shader_param("viewTextures", overheadTexData)
	mat.set_shader_param("slxData", oDataSlx.slxTexData)
	mat.set_shader_param("slabIdData", oDataSlab.idTexData)
	mat.set_shader_param("palette_texture", oReadPalette.palette_image_texture)
	
	arrayOfColorRects.append(displayField)
	
	oGame2D.add_child_below_node(self, displayField)

func update_display_fields_size():
	for displayField in arrayOfColorRects:
		displayField.rect_size = Vector2(M.xSize * 96, M.ySize * 96)
		displayField.material.set_shader_param("fieldSizeInSubtiles", Vector2((M.xSize*3), (M.ySize*3)))
