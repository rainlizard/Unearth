extends Node
onready var oGame2D = Nodelist.list["oGame2D"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oQuickMapPreviewDisplay = Nodelist.list["oQuickMapPreviewDisplay"]
onready var oMessage = Nodelist.list["oMessage"]


signal graphics_thread_completed

var thread_currently_processing = false

var overheadImgData = Image.new()
var overheadTexData = ImageTexture.new()

var arrayOfColorRects = []

var thread = Thread.new()
var semaphore = Semaphore.new()
var mutex = Mutex.new()
var job_queue = []
var pixel_data = PoolByteArray()

enum {
	SINGLE_THREADED,
	MULTI_THREADED,
}

func _ready():
	thread.start(self, "multi_threaded")


func update_full_overhead_map(threadType):
	var CODETIME_START = OS.get_ticks_msec()
	
	if arrayOfColorRects.empty() == true:
		initialize_display_fields()
	else:
		update_display_fields_size()
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	
	match threadType:
		SINGLE_THREADED:
			if thread_currently_processing == false:
				overhead2d_update_rect_single_threaded(shapePositionArray)
		MULTI_THREADED:
			mutex.lock()
			job_queue.append(shapePositionArray.duplicate(true)) # This duplicate somehow fixes a crash, or maybe just helps improve a race condition
			mutex.unlock()
	print('Overhead graphics done in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


# Using a single threaded version for updating partial graphics.
# and a multi-threaded version for updating the entire map's graphics.
func overhead2d_update_rect_single_threaded(shapePositionArray):
	pixel_data = generate_pixel_data(pixel_data, shapePositionArray)
	overheadImgData.create_from_data(M.xSize * 3, M.ySize * 3, false, Image.FORMAT_RGB8, pixel_data)
	overheadTexData.create_from_image(overheadImgData, 0)


func multi_threaded():
	while true:
		if job_queue.size() == 0:
			continue
		thread_currently_processing = true
		print("graphics multi_threaded start")
		
		mutex.lock()
		var shapePositionArray = job_queue.pop_front()
		mutex.unlock()
		
		var newPixelData = PoolByteArray()
		print("graphics multi_threaded 1")
		var resulting_pixel_data = generate_pixel_data(newPixelData, shapePositionArray)
		print("graphics multi_threaded 2")
		call_deferred("thread_done", resulting_pixel_data)
		print("graphics multi_threaded end")


func thread_done(resulting_pixel_data):
	if resulting_pixel_data != null:
		pixel_data = resulting_pixel_data
		overheadImgData.create_from_data(M.xSize * 3, M.ySize * 3, false, Image.FORMAT_RGB8, pixel_data)
		overheadTexData.create_from_image(overheadImgData, 0)
	else:
		oMessage.quick("thread crashed")
	
	thread_currently_processing = false
	emit_signal("graphics_thread_completed")
	
func generate_pixel_data(pixData, shapePositionArray):
	print("generate_pixel_data START")
	var width = M.xSize * 3
	var height = M.ySize * 3
	pixData.resize(width * height * 3)  # Assuming RGB8 format
	
	for pos in shapePositionArray:
		var basePosX = pos.x * 3
		var basePosY = pos.y * 3
		var slabID = oDataSlab.get_cellv(pos)
		for i in range(9):  # 3x3 subtiles
			var x = basePosX + (i % 3)
			var y = basePosY + (i / 3)
			var clmIndex = oDataClmPos.get_cell_clmpos(x, y)
			var cubeFace = oDataClm.get_top_cube_face(clmIndex, slabID)
			var pixelIndex = ((y * width) + x) * 3

			pixData[pixelIndex] = cubeFace >> 16 & 255
			pixData[pixelIndex + 1] = cubeFace >> 8 & 255
			pixData[pixelIndex + 2] = cubeFace & 255
	print("generate_pixel_data END")
	return pixData


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
		mat.set_shader_param("dkTextureMap_Split_A1", oTextureCache.cachedTextures[setMap][0])
		mat.set_shader_param("dkTextureMap_Split_A2", oTextureCache.cachedTextures[setMap][1])
		mat.set_shader_param("dkTextureMap_Split_B1", oTextureCache.cachedTextures[setMap][2])
		mat.set_shader_param("dkTextureMap_Split_B2", oTextureCache.cachedTextures[setMap][3])
	
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

