extends Spatial
onready var oCamera3D = $'Player/Head/Camera3D'
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]

var materialArray = []

func create_material_array(numberOfSlabStyles):
	materialArray.clear()
	# Slab styles
	for i in numberOfSlabStyles:
		var map = i-1
		if map == -1:
			map = oDataLevelStyle.data
		var mat = create_material(map)
		materialArray.append(mat)

func create_material(map):
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Shaders/display_texture_3d.shader")
	mat.set_shader_param("dkTextureMap_Split_A", oTextureCache.cachedTextures[map][0])
	mat.set_shader_param("dkTextureMap_Split_B", oTextureCache.cachedTextures[map][1])
	mat.set_shader_param("animationDatabase", preload("res://Shaders/textureanimationdatabase.png"))
	return mat

func enable_or_disable_mipmaps_on_all_materials(enabled): # set to 0 or 1
	for mat in materialArray:
		mat.set_shader_param("use_mipmaps", enabled)
