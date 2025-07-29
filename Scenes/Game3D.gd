extends Spatial
onready var oCamera3D = $'Player/Head/Camera3D'
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
onready var oReadPalette = Nodelist.list["oReadPalette"]

var materialArray = []
var accumulated_time = 0.0

func create_material_array(numberOfSlabStyles):
	materialArray.clear()
	for i in numberOfSlabStyles:
		var map = i-1
		if map == -1:
			map = oDataLevelStyle.data
		var mat = create_material(map)
		materialArray.append(mat)

func create_material(map):
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Shaders/display_texture_3d.shader")
	if oTMapLoader.cachedTextures.empty() or map < 0 or map >= oTMapLoader.cachedTextures.size() or oTMapLoader.cachedTextures[map] == null:
		printerr("View3D: Tileset ", map, " not available in oTMapLoader.cachedTextures. Max: ", oTMapLoader.cachedTextures.size() -1)
		return mat
	if oTMapLoader.cachedTextures[map][0] == null or \
	   oTMapLoader.cachedTextures[map][1] == null or \
	   oTMapLoader.cachedTextures[map][2] == null or \
	   oTMapLoader.cachedTextures[map][3] == null:
		printerr("View3D: One or more textures are null for tileset index: ", map)
		var blank_texture = oTMapLoader._create_blank_half_texture()
		mat.set_shader_param("tmap_A_top", oTMapLoader.cachedTextures[map][0] if oTMapLoader.cachedTextures[map][0] != null else blank_texture)
		mat.set_shader_param("tmap_A_bottom", oTMapLoader.cachedTextures[map][1] if oTMapLoader.cachedTextures[map][1] != null else blank_texture)
		mat.set_shader_param("tmap_B_top", oTMapLoader.cachedTextures[map][2] if oTMapLoader.cachedTextures[map][2] != null else blank_texture)
		mat.set_shader_param("tmap_B_bottom", oTMapLoader.cachedTextures[map][3] if oTMapLoader.cachedTextures[map][3] != null else blank_texture)
	else:
		mat.set_shader_param("tmap_A_top", oTMapLoader.cachedTextures[map][0])
		mat.set_shader_param("tmap_A_bottom", oTMapLoader.cachedTextures[map][1])
		mat.set_shader_param("tmap_B_top", oTMapLoader.cachedTextures[map][2])
		mat.set_shader_param("tmap_B_bottom", oTMapLoader.cachedTextures[map][3])

	mat.set_shader_param("palette_texture", oReadPalette.get_palette_texture())
	mat.set_shader_param("animationDatabase", oTextureAnimation.animation_database_texture)
	mat.set_shader_param("supersampling_level", Settings.get_setting("ssaa"))
	mat.set_shader_param("custom_time", accumulated_time)
	return mat

func enable_or_disable_mipmaps_on_all_materials(enabled):
	for mat in materialArray:
		mat.set_shader_param("use_mipmaps", enabled)

func update_ssaa_level(level):
	for mat in materialArray:
		mat.set_shader_param("supersampling_level", level)

func _process(delta):
	accumulated_time += delta
	for mat in materialArray:
		mat.set_shader_param("custom_time", accumulated_time)
