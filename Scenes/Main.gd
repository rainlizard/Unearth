extends Node2D
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]

func _enter_tree():
	print("Unearth v"+Constants.VERSION)
	Nodelist.start(self)

func _ready():
	Nodelist.done()
	Settings.initialize_settings()
	get_parent().initialize_window_settings()
	$TextureCache.start() # Needs to be run after Settings initialized so that the GAME_DIRECTORY is correctly set
	$OpenMap.start()
	
	# Auto switch to 3D while devving
	for i in 2:
		yield(get_tree(),'idle_frame')
	$Editor._on_ButtonViewType_pressed()








#func get_mipmap(img, level): # Doesn't need to care about formats, but can't handle the smallest MIP level
#	if img.has_mipmaps() == false: return
#
#	if img.is_compressed():
#		img.decompress()
#
#	var mip_offset = img.get_mipmap_offset(level)
#	var next_offset = img.get_mipmap_offset(level + 1)
#	assert (mip_offset >= 0 and next_offset > 0)
#
#	var buffer = img.get_data().subarray(mip_offset, next_offset - 1)
#
#	var size = img.get_size()
#	var new_width = int(size.x / pow(2, level))
#	var new_height = int(size.y / pow(2, level))
#
#	var mipmapImage = Image.new()
#	mipmapImage.create_from_data(new_width, new_height, false, img.get_format(), buffer)
#	assert (mipmapImage.get_size() == Vector2(new_width, new_height))
#	return mipmapImage
