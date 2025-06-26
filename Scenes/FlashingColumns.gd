extends Node
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oSlabsetMapRegenerator = Nodelist.list["oSlabsetMapRegenerator"]

var flashingColumnIndex = -1
var flashingColumnsetIndex = -1
var flashingColumnsetIndexes = []
var flashingVariationIndex = -1
var lastGeneratedVariationIndex = -1
var lastGeneratedSlabID = -1
var lastGeneratedColumnsetIndex = -1
var flashTimer = 0.0
var columnPosImgData = Image.new()
var columnPosTexData = ImageTexture.new()
var columnsetPosImgData = Image.new()
var columnsetPosTexData = ImageTexture.new()
var variationPosImgData = Image.new()
var variationPosTexData = ImageTexture.new()
var columnsetTextureGenerated = false
var variationTextureGenerated = false


func _process(delta):
	if (flashingColumnIndex >= 0 or flashingColumnsetIndex >= 0 or flashingColumnsetIndexes.size() > 0 or flashingVariationIndex >= 0) and is_instance_valid(oOverheadGraphics):
		flashTimer += delta
		var flashIntensity = (sin(flashTimer * 8.0) + 1.0) * 0.5
		for displayField in oOverheadGraphics.arrayOfColorRects:
			var material = displayField.material
			if is_instance_valid(material) and material is ShaderMaterial:
				material.set_shader_param("flashIntensity", flashIntensity)


func start_column_flash(columnIndex):
	if flashingColumnIndex == columnIndex:
		return
	flashingColumnIndex = columnIndex
	flashingColumnsetIndex = -1
	flashingColumnsetIndexes.clear()
	flashingVariationIndex = -1
	flashTimer = 0.0
	generate_clmdata_texture()
	update_flash_shader_params()


func start_columnset_flash(columnsetIndex):
	if flashingColumnsetIndex == columnsetIndex:
		return
	flashingColumnsetIndex = columnsetIndex
	flashingColumnIndex = -1
	flashingColumnsetIndexes.clear()
	flashingVariationIndex = -1
	flashTimer = 0.0
	if lastGeneratedColumnsetIndex != columnsetIndex or columnsetTextureGenerated == false:
		lastGeneratedColumnsetIndex = columnsetIndex
		generate_columnset_texture()
	update_flash_shader_params()


func start_variation_flash(fullVariation, slabID = -1):
	if flashingVariationIndex == fullVariation:
		return
	flashingVariationIndex = fullVariation
	flashingColumnsetIndex = -1
	flashingColumnIndex = -1
	flashingColumnsetIndexes.clear()
	flashTimer = 0.0
	if lastGeneratedVariationIndex != fullVariation or lastGeneratedSlabID != slabID or variationTextureGenerated == false:
		lastGeneratedVariationIndex = fullVariation
		lastGeneratedSlabID = slabID
		var CODETIME_START = OS.get_ticks_msec()
		generate_variation_texture()
		print('generate_variation_position_texture Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	update_flash_shader_params()


func stop_column_flash():
	flashingColumnIndex = -1
	flashingColumnsetIndex = -1
	flashingColumnsetIndexes.clear()
	flashingVariationIndex = -1
	flashTimer = 0.0
	update_flash_shader_params()


func update_flash_shader_params():
	if is_instance_valid(oOverheadGraphics) == false:
		return
	var flashIntensity = 0.0
	if flashingColumnIndex >= 0 or flashingColumnsetIndex >= 0 or flashingColumnsetIndexes.size() > 0 or flashingVariationIndex >= 0:
		flashIntensity = (sin(flashTimer * 8.0) + 1.0) * 0.5
	for displayField in oOverheadGraphics.arrayOfColorRects:
		var material = displayField.material
		if is_instance_valid(material) and material is ShaderMaterial:
			material.set_shader_param("flashingColumn", flashingColumnIndex)
			material.set_shader_param("flashingColumnset", flashingColumnsetIndex)
			material.set_shader_param("flashingVariation", flashingVariationIndex)
			for i in 9:
				var paramName = "flashingColumnset" + str(i)
				var value = -1
				if i < flashingColumnsetIndexes.size():
					value = flashingColumnsetIndexes[i]
				material.set_shader_param(paramName, value)
			material.set_shader_param("flashIntensity", flashIntensity)


func generate_clmdata_texture():
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
	if is_instance_valid(oOverheadGraphics):
		for displayField in oOverheadGraphics.arrayOfColorRects:
			displayField.material.set_shader_param("columnPosData", columnPosTexData)
	print("Column position texture generated")


func generate_columnset_texture():
	var CODETIME_START = OS.get_ticks_msec()
	var width = M.xSize * 3
	var height = M.ySize * 3
	var columnsetPosPixelData = PoolByteArray()
	columnsetPosPixelData.resize(width * height * 3)
	columnsetPosPixelData.fill(0)
	if flashingColumnsetIndex >= 0 or flashingColumnsetIndexes.size() > 0:
		var targetColumnsetIndexes = []
		if flashingColumnsetIndex >= 0:
			targetColumnsetIndexes.append(flashingColumnsetIndex)
		targetColumnsetIndexes.append_array(flashingColumnsetIndexes)
		var oDataSlab = Nodelist.list["oDataSlab"]
		var oDataOwnership = Nodelist.list["oDataOwnership"]
		var oSlabPlacement = Nodelist.list["oSlabPlacement"]
		for y in M.ySize:
			for x in M.xSize:
				var slabID = oDataSlab.get_cell(x, y)
				var tilePos = Vector2(x, y)
				var ownership = oDataOwnership.get_cellv_ownership(tilePos)
				var surrID = oSlabPlacement.get_surrounding_slabIDs(x, y)
				var surrOwner = oSlabPlacement.get_surrounding_ownership(x, y)
				var bitmaskType = Slabs.data[slabID][Slabs.BITMASK_TYPE]
				var bitmask = oSlabsetMapRegenerator.get_bitmask(bitmaskType, slabID, ownership, surrID, surrOwner, tilePos)
				var slabsetIndexGroup = oSlabPlacement.make_slab(slabID * 28, bitmask)
				if bitmaskType == Slabs.BITMASK_REINFORCED:
					oSlabPlacement.modify_wall_based_on_nearby_room_and_liquid(slabsetIndexGroup, surrID, slabID)
				else:
					oSlabPlacement.modify_for_liquid(slabsetIndexGroup, surrID, slabID)
				for subtileY in 3:
					for subtileX in 3:
						var pixelX = x * 3 + subtileX
						var pixelY = y * 3 + subtileY
						var subtileIndex = subtileY * 3 + subtileX
						var variation = slabsetIndexGroup[subtileIndex] / 9
						var columnsetIndex = Slabset.fetch_columnset_index(variation, subtileIndex)
						if columnsetIndex in targetColumnsetIndexes:
							var pixelIndex = (pixelY * width + pixelX) * 3
							columnsetPosPixelData[pixelIndex] = (columnsetIndex >> 8) & 0xFF
							columnsetPosPixelData[pixelIndex + 1] = columnsetIndex & 0xFF
							columnsetPosPixelData[pixelIndex + 2] = 0
	columnsetPosImgData.create_from_data(width, height, false, Image.FORMAT_RGB8, columnsetPosPixelData)
	columnsetPosTexData.create_from_image(columnsetPosImgData, 0)
	columnsetTextureGenerated = true
	if is_instance_valid(oOverheadGraphics):
		for displayField in oOverheadGraphics.arrayOfColorRects:
			displayField.material.set_shader_param("columnsetPosData", columnsetPosTexData)
	print('generate_columnset_texture Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func generate_variation_texture():
	var width = M.xSize * 3
	var height = M.ySize * 3
	var variationPosPixelData = PoolByteArray()
	variationPosPixelData.resize(width * height * 3)
	variationPosPixelData.fill(0)
	if flashingVariationIndex >= 0:
		var oDataSlab = Nodelist.list["oDataSlab"]
		var oDataOwnership = Nodelist.list["oDataOwnership"]
		var oSlabPlacement = Nodelist.list["oSlabPlacement"]
		for y in M.ySize:
			for x in M.xSize:
				var slabID = oDataSlab.get_cell(x, y)
				if Slabs.data.has(slabID) and slabID < 1000:
					var tilePos = Vector2(x, y)
					var ownership = oDataOwnership.get_cellv_ownership(tilePos)
					var surrID = oSlabPlacement.get_surrounding_slabIDs(x, y)
					var surrOwner = oSlabPlacement.get_surrounding_ownership(x, y)
					var bitmaskType = Slabs.data[slabID][Slabs.BITMASK_TYPE]
					var bitmask = oSlabsetMapRegenerator.get_bitmask(bitmaskType, slabID, ownership, surrID, surrOwner, tilePos)
					var slabsetIndexGroup = oSlabPlacement.make_slab(slabID * 28, bitmask)
					if bitmaskType == Slabs.BITMASK_REINFORCED:
						oSlabPlacement.modify_wall_based_on_nearby_room_and_liquid(slabsetIndexGroup, surrID, slabID)
					else:
						oSlabPlacement.modify_for_liquid(slabsetIndexGroup, surrID, slabID)
					for subtileY in 3:
						for subtileX in 3:
							var pixelX = x * 3 + subtileX
							var pixelY = y * 3 + subtileY
							var subtileIndex = subtileY * 3 + subtileX
							var variation = slabsetIndexGroup[subtileIndex] / 9
							var pixelIndex = (pixelY * width + pixelX) * 3
							variationPosPixelData[pixelIndex] = (variation >> 8) & 0xFF
							variationPosPixelData[pixelIndex + 1] = variation & 0xFF
							variationPosPixelData[pixelIndex + 2] = 0
	variationPosImgData.create_from_data(width, height, false, Image.FORMAT_RGB8, variationPosPixelData)
	variationPosTexData.create_from_image(variationPosImgData, 0)
	variationTextureGenerated = true
	if is_instance_valid(oOverheadGraphics):
		for displayField in oOverheadGraphics.arrayOfColorRects:
			displayField.material.set_shader_param("variationPosData", variationPosTexData)


func invalidate_columnset_texture():
	columnsetTextureGenerated = false


func invalidate_variation_texture():
	variationTextureGenerated = false

