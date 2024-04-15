extends Node
onready var oGame2D = Nodelist.list["oGame2D"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]

var overheadImgData = Image.new()
var overheadTexData = ImageTexture.new()

var arrayOfColorRects = []

func update_map_overhead_2d_textures():
	var CODETIME_START = OS.get_ticks_msec()
	
	if arrayOfColorRects.empty() == true:
		initialize_display_fields()
	else:
		update_display_fields_size()

	overheadImgData.create((M.xSize*3), (M.ySize*3), false, Image.FORMAT_RGB8)
	overheadTexData.create_from_image(overheadImgData, 0)
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	
	overhead2d_update_rect(shapePositionArray)
	
	print('Overhead graphics done in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

#	for ySubtile in height:
#		for xSubtile in width:


var thread = Thread.new()
var semaphore = Semaphore.new()


func overhead2d_update_rect(shapePositionArray):
	thread.start(self, "multi_threaded", shapePositionArray)
	semaphore.post()  # Release the semaphore after starting the thread


func thread_done(pixelData):
	var width = M.xSize * 3
	var height = M.ySize * 3
	overheadImgData.create_from_data(width, height, false, Image.FORMAT_RGB8, pixelData)
	overheadTexData.set_data(overheadImgData)

func multi_threaded(shapePositionArray):
	while true:
		semaphore.wait()  # Acquire the semaphore before processing
		var width = M.xSize * 3
		var height = M.ySize * 3
		var pixelData = PoolByteArray()
		pixelData.resize(width * height * 3)  # Assuming RGB8 format
		for pos in shapePositionArray:
			var basePosX = pos.x * 3
			var basePosY = pos.y * 3
			for i in range(9):  # 3x3 subtiles
				var x = basePosX + (i % 3)
				var y = basePosY + (i / 3)
				var clmIndex = oDataClmPos.get_cell_clmpos_fast(x, y)
				var cubeFace = oDataClm.get_top_cube_face(clmIndex, 0)
				var pixelIndex = ((y * width) + x) * 3

				pixelData[pixelIndex] = cubeFace >> 16 & 255
				pixelData[pixelIndex + 1] = cubeFace >> 8 & 255
				pixelData[pixelIndex + 2] = cubeFace & 255
		call_deferred("thread_done", pixelData)

func initialize_display_fields():
	arrayOfColorRects.clear() # just in case
	
	# Default
	if oTextureCache.cachedTextures.size() > 0:
		createDisplayField(oDataLevelStyle.data, 0) # 0 means "Show Default Style"
	
	# Slab styles
	for map in oTextureCache.cachedTextures.size():
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
		mat.set_shader_param("dkTextureMap_Split_A", oTextureCache.cachedTextures[setMap][0])
		mat.set_shader_param("dkTextureMap_Split_B", oTextureCache.cachedTextures[setMap][1])
	
	mat.set_shader_param("showOnlySpecificStyle", showStyle)
	mat.set_shader_param("fieldSizeInSubtiles", Vector2((M.xSize*3), (M.ySize*3)))
	mat.set_shader_param("animationDatabase", preload("res://Shaders/textureanimationdatabase.png"))
	mat.set_shader_param("viewTextures", overheadTexData)
	mat.set_shader_param("slxData", oDataSlx.slxTexData)
	
	arrayOfColorRects.append(displayField)
	oGame2D.add_child_below_node(self, displayField)

func update_display_fields_size():
	for displayField in arrayOfColorRects:
		displayField.rect_size = Vector2(M.xSize * 96, M.ySize * 96)
		displayField.material.set_shader_param("fieldSizeInSubtiles", Vector2((M.xSize*3), (M.ySize*3)))

func clear_img():
	if overheadImgData.is_empty() == false:
		overheadImgData.fill(Color(0,0,0,1))
		overheadTexData.set_data(overheadImgData)
