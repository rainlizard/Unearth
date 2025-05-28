extends Spatial
onready var oCamera3D = $'Player/Head/Camera3D'
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]

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
	mat.set_shader_param("dkTextureMap_Split_A1", oTMapLoader.cachedTextures[map][0])
	mat.set_shader_param("dkTextureMap_Split_A2", oTMapLoader.cachedTextures[map][1])
	mat.set_shader_param("dkTextureMap_Split_B1", oTMapLoader.cachedTextures[map][2])
	mat.set_shader_param("dkTextureMap_Split_B2", oTMapLoader.cachedTextures[map][3])
	mat.set_shader_param("animationDatabase", oTextureAnimation.animation_database_texture)
	return mat

func enable_or_disable_mipmaps_on_all_materials(enabled): # set to 0 or 1
	for mat in materialArray:
		mat.set_shader_param("use_mipmaps", enabled)
