extends Control
onready var oSelection = Nodelist.list["oSelection"]

var dataImage = Image.new()
var dataTexture = ImageTexture.new()

#var columns = [0,0,0, 0,0,0, 0,0,0]
func _ready():
	add_to_group("SlabDisplay") #Important for when changing texture pack
	var iconSize = 0.35
	$AspectRatioContainer.anchor_top -= iconSize
	$AspectRatioContainer.anchor_bottom += iconSize
	$AspectRatioContainer.anchor_left -= iconSize
	$AspectRatioContainer.anchor_right += iconSize

func set_visual(columnArray):
	
	var slabID = get_meta("ID_of_slab")
	
	$AspectRatioContainer/Icon.texture = null
	var slabName = Slabs.fetch_idname(slabID)
	if Slabs.icons.has(slabName):
		$AspectRatioContainer/Icon.texture = Slabs.icons.get(slabName, null)
		if Slabs.is_door(slabID) == false:
			$AspectRatioContainer.anchor_top -= 0.05
			$AspectRatioContainer.anchor_bottom -= 0.05
			$AspectRatioContainer.anchor_left += 0.01
			$AspectRatioContainer.anchor_right += 0.01
			if slabID == Slabs.DUNGEON_HEART:
				$AspectRatioContainer.anchor_left -= 0.02
				$AspectRatioContainer.anchor_right -= 0.02
	
	dataImage.create(3, 3, false, Image.FORMAT_RGB8)
	dataTexture.create_from_image(dataImage, 0)
	
	dataImage.lock()
	for y in 3:
		for x in 3:
			var cubeFace = 0
			if slabID >= 1000:
				# Fake slab
				if Slabs.fake_extra_data.has(slabID) == true:
					var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
					cubeFace = oCustomSlabSystem.get_top_fake_cube_face((y*3) + x, slabID)
			else:
				# Slabset slab (normal slab)
				cubeFace = Columnset.get_top_cube_face(columnArray[(y*3) + x])
			
			dataImage.set_pixel(x, y, Color8(cubeFace >> 16 & 255, cubeFace >> 8 & 255, cubeFace & 255))
	
	# Handle side view for doors and other tab slabs
	var isOtherTab = Slabs.data[slabID][Slabs.EDITOR_TAB] == Slabs.TAB_OTHER
	var isDoor = Slabs.is_door(slabID)
	
	if (isOtherTab and slabID < 50) or isDoor:
		var y
		var sideViewZoffset
		
		if isOtherTab:
			y = 2
			sideViewZoffset = 4
		elif isDoor:
			y = 1
			sideViewZoffset = 3
			if slabID == 56: #SecretDoor2
				y = 0
				sideViewZoffset = 3
		
		for x in 3:
			for z in range(0, 3):
				var clmIndex = columnArray[(y*3) + x]
				var cubeID = Columnset.cubes[clmIndex][sideViewZoffset-z]
				var cubeFace = Cube.tex[cubeID][Cube.SIDE_SOUTH]
				dataImage.set_pixel(x, z, Color8(cubeFace >> 16 & 255, cubeFace >> 8 & 255, cubeFace & 255))
	
	dataImage.unlock()
	
	dataTexture.set_data(dataImage)
	
	var oTextureAnimation = Nodelist.list["oTextureAnimation"]
	
	material.set_shader_param("showOnlySpecificStyle", 0)
	material.set_shader_param("slxData", preload("res://Shaders/Black3x3.png"))
	material.set_shader_param("fieldSizeInSubtiles", Vector2(3, 3))
	material.set_shader_param("animationDatabase", oTextureAnimation.animation_database_texture)
	material.set_shader_param("viewTextures", dataTexture)
	if slabID == 57:
		material.set_shader_param("slabIdData", preload("res://Shaders/Bedrock3x3.png"))
	else:
		material.set_shader_param("slabIdData", preload("res://Shaders/Black3x3.png"))

#func _process(delta):
#	print(material.get_shader_param("dkTextureMap_Split_A"))
