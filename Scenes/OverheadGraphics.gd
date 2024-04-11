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

var pixelData = PoolByteArray()
func overhead2d_update_rect(shapePositionArray):
	var width = M.xSize * 3
	var height = M.ySize * 3
	pixelData.resize(width * height * 3)  # Assuming RGB8 format
	
	for pos in shapePositionArray:
		var basePosX = pos.x * 3
		var basePosY = pos.y * 3
		for i in range(9):  # 3x3 subtiles
			var x = basePosX + (i % 3)
			var y = basePosY + (i / 3)

			var clmIndex = oDataClmPos.get_cell_clmpos_fast(x,y)

			var col = oDataClm.topFace[clmIndex]
			var pixelIndex = ((y * width) + x) * 3
			pixelData[pixelIndex] = col.r8
			pixelData[pixelIndex + 1] = col.g8
			pixelData[pixelIndex + 2] = col.b8
	
	overheadImgData.create_from_data(width, height, false, Image.FORMAT_RGB8, pixelData)
	overheadTexData.set_data(overheadImgData)

#	for i in (height*width):
#		var x = i % width
#		var y = i / width
#		var clmIndex = oDataClmPos.get_cell_clmpos_fast(x, y)
#		var col = oDataClm.topFace[clmIndex]
#		var pixelIndex = i * 3
#		pixelData[pixelIndex] = col.r8
#		pixelData[pixelIndex + 1] = col.g8
#		pixelData[pixelIndex + 2] = col.b8


#func overhead2d_update_rect(shapePositionArray):
#	overheadImgData.lock()
#	for pos in shapePositionArray:
#		#var slabID = oDataSlab.get_cell(pos.x, pos.y)
#		for ySubtile in 3:
#			for xSubtile in 3:
#				var x = (pos.x * 3) + xSubtile
#				var y = (pos.y * 3) + ySubtile
#				var clmIndex = oDataClmPos.get_cell(x, y)
#				var col = oDataClm.topFace[clmIndex]
#				overheadImgData.set_pixel(x,y,col) #get_overhead_face_value(x, y, slabID)
#	overheadImgData.unlock()
#	overheadTexData.set_data(overheadImgData)
	
	#overheadImgData.save_png("res://viewTextures.png")


#func get_overhead_face_value(x, y, slabID):
#	# clmIndex is a position inside the 2048 column collection
#	var clmIndex = oDataClmPos.get_cell(x, y)
#
#	if clmIndex > 2048:
#		clmIndex = 0
#
#	# clmData is the 24 byte array.
#	var cubeFace = oDataClm.get_top_cube_face(clmIndex, slabID)
#
#	var valueInput = cubeFace
#	var r = clamp(valueInput, 0, 255)
#	valueInput -= 255
#	var g = clamp(valueInput, 0, 255)
#	valueInput -= 255
#	var b = clamp(valueInput, 0, 255)
#	return Color8(r,g,b)


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

#func _ready():
#	animImgData.create(8, 42, false, Image.FORMAT_RGB8)
#	animTexData.create_from_image(animImgData, 0)
#	map_anim_2d_textures()
#
#func map_anim_2d_textures():
#	var CODETIME_START = OS.get_ticks_msec()
#	animImgData.lock()
#	for y in 42:
#		for x in 8:
#			var col = get_anim_face_value(x, y)
#			animImgData.set_pixel(x,y,col)
#	animImgData.unlock()
#
#	animImgData.save_png("textureanimationdatabase.png")
#
#	animTexData.set_data(animImgData)
#	material.set_shader_param("animationDatabase", animTexData)
#
#	print('Anim graphics done in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

#func get_anim_face_value(x, y):
#	var cubeFace = Cube.texAnim[(y * 8) + x]
#	var valueInput = cubeFace
#	var r = clamp(valueInput, 0, 255)
#	valueInput -= 255
#	var g = clamp(valueInput, 0, 255)
#	valueInput -= 255
#	var b = clamp(valueInput, 0, 255)
#	#print(str(r)+' '+str(g)+' '+str(b))
#	return Color8(r,g,b)

#func _ready():
#	var CODETIME_START = OS.get_ticks_msec()
#	set_tex_anim_data_array()
#	material.set_shader_param("animationDatabase", array2texture(TMAPDATA_ANIMATION, Vector2(8,42)))
#	print('TMAPDATA_ANIMATION created in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

#func map_overhead_2d_textures():
#	var CODETIME_START = OS.get_ticks_msec()
#
#	#290ms
#	set_tex_data_array()
#	#4ms
#	material.set_shader_param("viewTextures", array2texture(TMAPDATA_OVERHEAD_2D, Vector2(255,255)))
#
#	print('TMAPDATA_OVERHEAD_2D created in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')




#func set_tex_data_array():
#	#Array size needs to precisely match the array_width and array_height
#	TMAPDATA_OVERHEAD_2D.clear()
#	var height = 255
#	var width = 255
#	TMAPDATA_OVERHEAD_2D.resize(height * width * 3)
#	for y in height: # Subtiles
#		for x in width:
#			update_overhead_face(x,y)
#
#func update_overhead_face(x, y):
#	var cubeFace
#	# clmIndex is a position inside the 2048 column collection
#	var clmIndex = oDataClmPos.get_cell(x,y)
#	# clmData is the 24 byte array.
#	var clmData = oDataClm.data[clmIndex]
#	#print(clmData)
#	# Get the cubeIDs from that array
#	var cubeID = oDataClm.get_highest_existing_cube(clmData)
#	# Get the highest cubeID
#	if cubeID != 0:
#		# Get one of the 6 faces of the cube from the massive array of cube sides.
#
#		cubeFace = Cube.tex[cubeID][Cube.SIDE_TOP]
#	else:
#		# Show floor texture because there were no cubes
#		cubeFace = oDataClm.get_base(clmData)
#
#	var valueInput = cubeFace
#
#	var r = clamp(valueInput, 0, 255)
#	valueInput -= 255
#	var g = clamp(valueInput, 0, 255)
#	valueInput -= 255
#	var b = clamp(valueInput, 0, 255)
#
#	var width = 255
#
#	var idx = ((y * width) + x) * 3
#	TMAPDATA_OVERHEAD_2D[idx+0] = r
#	TMAPDATA_OVERHEAD_2D[idx+1] = g
#	TMAPDATA_OVERHEAD_2D[idx+2] = b

#func set_tex_anim_data_array():
#	TMAPDATA_ANIMATION.clear()
#	var height = 42
#	var width = 8
#	TMAPDATA_ANIMATION.resize(height * width * 3)
#	for y in height:
#		for x in width:
#			var cubeFace = Cube.texAnim[(y * 8) + x]
#
#			var valueInput = cubeFace
#			var r = clamp(valueInput, 0, 255)
#			valueInput -= 255
#			var g = clamp(valueInput, 0, 255)
#			valueInput -= 255
#			var b = clamp(valueInput, 0, 255)
#			var idx = ((y * width) + x) * 3
#			TMAPDATA_ANIMATION[idx+0] = r
#			TMAPDATA_ANIMATION[idx+1] = g
#			TMAPDATA_ANIMATION[idx+2] = b
#
#func array2texture(array, size):
#	var byte_array = PoolByteArray(array)
#	var img = Image.new()
#	var texture = ImageTexture.new()
#
#	if array.size() > 0:
#		img.create_from_data(size.x, size.y, false, Image.FORMAT_RGB8, byte_array)
#		texture.create_from_image(img, 0)
#
#	#img.save_png("png.png")
#	return texture
