extends Node
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]

var flashingColumnIndex = -1
var flashTimer = 0.0
var columnPosImgData = Image.new()
var columnPosTexData = ImageTexture.new()


func _process(delta):
	update_column_flash(delta)


func update_column_flash(delta):
	if flashingColumnIndex >= 0 and is_instance_valid(oOverheadGraphics):
		flashTimer += delta
		var flashIntensity = (sin(flashTimer * 8.0) + 1.0) * 0.5
		for displayField in oOverheadGraphics.arrayOfColorRects:
			var material = displayField.material
			if is_instance_valid(material) and material is ShaderMaterial:
				material.set_shader_param("flashIntensity", flashIntensity)


func start_column_flash(columnIndex):
	flashingColumnIndex = columnIndex
	flashTimer = 0.0
	update_flash_shader_params()


func start_columnset_flash(columnsetIndex):
	flashingColumnIndex = columnsetIndex
	flashTimer = 0.0
	update_flash_shader_params()


func stop_column_flash():
	flashingColumnIndex = -1
	flashTimer = 0.0
	update_flash_shader_params()


func update_flash_shader_params():
	if is_instance_valid(oOverheadGraphics) == false:
		return
	
	var flashIntensity = 0.0
	if flashingColumnIndex >= 0:
		flashIntensity = (sin(flashTimer * 8.0) + 1.0) * 0.5
	
	for displayField in oOverheadGraphics.arrayOfColorRects:
		var material = displayField.material
		if is_instance_valid(material) and material is ShaderMaterial:
			material.set_shader_param("flashingColumn", flashingColumnIndex)
			material.set_shader_param("flashIntensity", flashIntensity)


func update_column_position_texture():
	if is_instance_valid(oOverheadGraphics):
		for displayField in oOverheadGraphics.arrayOfColorRects:
			displayField.material.set_shader_param("columnPosData", columnPosTexData)


func generate_column_position_texture():
	var width = M.xSize * 3
	var height = M.ySize * 3
	var columnPosPixelData = PoolByteArray()
	columnPosPixelData.resize(width * height * 3)
	
	var clmPosBuffer = oDataClmPos.buffer
	var clmPosWidth = oDataClmPos.width
	var bufferSize = clmPosBuffer.get_size()
	
	print("Generating column position texture: ", width, "x", height)
	
	for y in range(height):
		for x in range(width):
			var seekPos = (y * clmPosWidth + x) * 2
			var columnIndex = 0
			if seekPos >= 0 and seekPos + 1 < bufferSize:
				clmPosBuffer.seek(seekPos)
				columnIndex = abs(clmPosBuffer.get_16())
			
			var pixelIndex = (y * width + x) * 3
			columnPosPixelData[pixelIndex] = (columnIndex >> 8) & 0xFF
			columnPosPixelData[pixelIndex + 1] = columnIndex & 0xFF
			columnPosPixelData[pixelIndex + 2] = 0
	
	columnPosImgData.create_from_data(width, height, false, Image.FORMAT_RGB8, columnPosPixelData)
	columnPosTexData.create_from_image(columnPosImgData, 0)
	print("Column position texture generated")

