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

var overheadImgData = Image.new()
var overheadTexData = ImageTexture.new()

var arrayOfColorRects = []

var thread = Thread.new()
var semaphore = Semaphore.new()
var mutex = Mutex.new()
var job_queue = []
var pixel_data = PoolByteArray()

func _ready():
	thread.start(self, "multi_threaded")


func update_full_overhead_map():
	if oUndoStates.performing_undo == false: # Remove black flicker from undoing
		make_image_black()
	
	var CODETIME_START = OS.get_ticks_msec()
	
	if arrayOfColorRects.empty() == true:
		initialize_display_fields()
	else:
		update_display_fields_size()
	
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	
	mutex.lock()
	job_queue.append(shapePositionArray)
	mutex.unlock()
	semaphore.post()  # Release the semaphore to signal the thread to process the job
	
	print('Overhead graphics done in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


func overhead2d_update_rect_single_threaded(shapePositionArray):
	#pixel_data = generate_pixel_data(pixel_data, shapePositionArray)
	
	var width = M.xSize * 3
	var height = M.ySize * 3
	pixel_data.resize(width * height * 3)  # Assuming RGB8 format
	for pos in shapePositionArray:
		var basePosX = pos.x * 3
		var basePosY = pos.y * 3
		for i in range(9):  # 3x3 subtiles
			var x = basePosX + (i % 3)
			var y = basePosY + (i / 3)
			var clmIndex = oDataClmPos.get_cell_clmpos_fast(x, y)
			var cubeFace = oDataClm.get_top_cube_face(clmIndex, 0)
			var pixelIndex = ((y * width) + x) * 3

			pixel_data[pixelIndex] = cubeFace >> 16 & 255
			pixel_data[pixelIndex + 1] = cubeFace >> 8 & 255
			pixel_data[pixelIndex + 2] = cubeFace & 255
	
	overheadImgData.create_from_data(M.xSize * 3, M.ySize * 3, false, Image.FORMAT_RGB8, pixel_data)
	overheadTexData.create_from_image(overheadImgData, 0)

func multi_threaded():
	while true:
		semaphore.wait()  # Acquire the semaphore before processing
		mutex.lock()
		var shapePositionArray = job_queue.pop_front()
		mutex.unlock()
		
		var newPixelData = PoolByteArray()
		var resulting_pixel_data = generate_pixel_data(newPixelData, shapePositionArray)
		call_deferred("thread_done", resulting_pixel_data)

func thread_done(resulting_pixel_data):
	pixel_data = resulting_pixel_data
	overheadImgData.create_from_data(M.xSize * 3, M.ySize * 3, false, Image.FORMAT_RGB8, pixel_data)
	overheadTexData.create_from_image(overheadImgData, 0)

func generate_pixel_data(pixData, shapePositionArray):
	var width = M.xSize * 3
	var height = M.ySize * 3
	pixData.resize(width * height * 3)  # Assuming RGB8 format
	for pos in shapePositionArray:
		var basePosX = pos.x * 3
		var basePosY = pos.y * 3
		for i in range(9):  # 3x3 subtiles
			var x = basePosX + (i % 3)
			var y = basePosY + (i / 3)
			var clmIndex = oDataClmPos.get_cell_clmpos_fast(x, y)
			var cubeFace = oDataClm.get_top_cube_face(clmIndex, 0)
			var pixelIndex = ((y * width) + x) * 3

			pixData[pixelIndex] = cubeFace >> 16 & 255
			pixData[pixelIndex + 1] = cubeFace >> 8 & 255
			pixData[pixelIndex + 2] = cubeFace & 255
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

func make_image_black():
	if overheadImgData.is_empty() == false:
		#overheadImgData.fill(Color(0,0,0,1))
		#overheadTexData.set_data(overheadImgData)
		overheadTexData = oQuickMapPreviewDisplay.texture
