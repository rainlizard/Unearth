extends Control
onready var oSelection = Nodelist.list["oSelection"]

var dataImage = Image.new()
var dataTexture = ImageTexture.new()

#var columns = [0,0,0, 0,0,0, 0,0,0]
var panelView = Slabs.PANEL_TOP_VIEW
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
	if Slabs.icons.has(slabID):
		$AspectRatioContainer/Icon.texture = Slabs.icons[slabID]
		if Slabs.doors.has(slabID) == false:
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
	if panelView == Slabs.PANEL_TOP_VIEW:
		if slabID < 1000:
			for y in 3:
				for x in 3:
					var clmIndex = columnArray[(y*3) + x]
					var cubeFace = Columnset.get_top_cube_face(clmIndex, slabID)
					var valueInput = cubeFace
					var r = clamp(valueInput, 0, 255)
					valueInput -= 255
					var g = clamp(valueInput, 0, 255)
					valueInput -= 255
					var b = clamp(valueInput, 0, 255)
					dataImage.set_pixel(x, y, Color8(r,g,b))
		else:
			var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
			for y in 3:
				for x in 3:
					var cubeFace = 0
					if oCustomSlabSystem.data.has(slabID):
						var indexIn3x3 = (y*3) + x
						cubeFace = oCustomSlabSystem.get_top_cube_face(indexIn3x3, slabID)
					
					var valueInput = cubeFace
					var r = clamp(valueInput, 0, 255)
					valueInput -= 255
					var g = clamp(valueInput, 0, 255)
					valueInput -= 255
					var b = clamp(valueInput, 0, 255)
					dataImage.set_pixel(x, y, Color8(r,g,b))
	
	if panelView == Slabs.PANEL_SIDE_VIEW or panelView == Slabs.PANEL_DOOR_VIEW:
		var y = 2
		if panelView == Slabs.PANEL_DOOR_VIEW: y = 1
		
		var sideViewZoffset = Slabs.data[slabID][Slabs.SIDE_VIEW_Z_OFFSET]
		
		for x in 3:
			for z in range(0, 3):
				var clmIndex = columnArray[(y*3) + x]
				
				var cubeID = Columnset.cubes[clmIndex][sideViewZoffset-z]
				var cubeFace = Cube.tex[cubeID][Cube.SIDE_SOUTH]
				
				var valueInput = cubeFace
				var r = clamp(valueInput, 0, 255)
				valueInput -= 255
				var g = clamp(valueInput, 0, 255)
				valueInput -= 255
				var b = clamp(valueInput, 0, 255)
				dataImage.set_pixel(x, z, Color8(r,g,b))
	
	dataImage.unlock()
	
	dataTexture.set_data(dataImage)
	
	material.set_shader_param("showOnlySpecificStyle", 0)
	material.set_shader_param("slxData", preload("res://Shaders/Black3x3.png"))
	material.set_shader_param("fieldSizeInSubtiles", Vector2(3, 3))
	material.set_shader_param("animationDatabase", preload("res://Shaders/textureanimationdatabase.png"))
	material.set_shader_param("viewTextures", dataTexture)

#func _process(delta):
#	print(material.get_shader_param("dkTextureMap_Split_A"))
