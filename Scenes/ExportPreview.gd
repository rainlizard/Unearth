extends WindowDialog
onready var oPlayer = Nodelist.list["oPlayer"]
onready var oSavePreviewMipmapsCheckbox = Nodelist.list["oSavePreviewMipmapsCheckbox"]
onready var oSavePreviewPngButton = Nodelist.list["oSavePreviewPngButton"]
onready var oSavePreviewTrimBlackCheckbox = Nodelist.list["oSavePreviewTrimBlackCheckbox"]
onready var oSavePreviewMsaaSlider = Nodelist.list["oSavePreviewMsaaSlider"]

onready var oMenu = Nodelist.list["oMenu"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oUi = Nodelist.list["oUi"]
onready var oCamera3D = Nodelist.list["oCamera3D"]
onready var oExportPreviewPngDialog = Nodelist.list["oExportPreviewPngDialog"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oUiMessages = Nodelist.list["oUiMessages"]
onready var oUiSystem = Nodelist.list["oUiSystem"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oUi3D = Nodelist.list["oUi3D"]
onready var oGame3D = Nodelist.list["oGame3D"]

var remember_original_msaa

func _on_ExportPreview_about_to_show():
	# Store the previous MSAA value
	remember_original_msaa = get_viewport().msaa
	modulate.a = 0
	# Generate
	oEditor.set_view_3d()
	oGenerateTerrain.start()
	oPlayer.switch_camera_type(0)
	oUiMessages.visible = false
	oUiSystem.visible = false
	oUiTools.visible = false
	oUi.hide_tools()
	oUi3D.visible = false
	yield(oGenerateTerrain, "terrain_finished_generating")
	modulate.a = 1.0
	_on_SavePreviewMipmapsCheckbox_toggled(oSavePreviewMipmapsCheckbox.pressed)
	_on_SavePreviewMsaaSlider_sliderChanged()
	set_basic_camera_stuff()

func _on_ExportPreview_hide():
	if is_instance_valid(oEditor) and modulate.a == 1.0:
		oEditor.set_view_2d()
		oUiMessages.visible = true
		oUiSystem.visible = true
		oUiTools.visible = true
		oUi3D.visible = true
		oGame3D.enable_or_disable_mipmaps_on_all_materials(1)
		get_viewport().msaa = remember_original_msaa

func set_basic_camera_stuff():
	# Set camera
	oPlayer.velocity = Vector3(0, 0, 0) # stop moving
	oCamera3D.projection = Camera.PROJECTION_ORTHOGONAL

	var terrain_size = Vector2(M.xSize * 3, M.ySize * 3)
	var terrain_center = terrain_size / 2.0

	# Orthogonal camera position and rotation
	oPlayer.rotation_degrees = Vector3(270, 0, 0) #Vector2(270, 45, 0)
	oPlayer.oHead.rotation_degrees = Vector3(0, 0, 0)

	oPlayer.translation = Vector3(terrain_center.x, 100, terrain_center.y)

	# Calculate the window's aspect ratio
	var window_aspect_ratio = OS.window_size.x / OS.window_size.y

	# Zoom out based on the dominant dimension
	if window_aspect_ratio > 1:  # Landscape mode
		oCamera3D.size = terrain_size.x * window_aspect_ratio
	else:  # Portrait mode
		oCamera3D.size = terrain_size.y
	
	oCamera3D.set_orthogonal(oCamera3D.size, 0.01, 8192)

func _on_SavePreviewPngButton_pressed():
	Utils.popup_centered(oExportPreviewPngDialog)
	oExportPreviewPngDialog.current_dir = Settings.unearth_path
	oExportPreviewPngDialog.current_path = Settings.unearth_path
	oExportPreviewPngDialog.current_file = oCurrentMap.path.get_file()

func _on_ExportPreviewPngDialog_file_selected(save_path):
	# Be sure the rendering is updated
	modulate.a = 0.0
	yield(get_tree(), "idle_frame")
	VisualServer.force_draw()
	
	# Capture the current viewport's texture
	var viewport_texture = get_viewport().get_texture()
	
	var img = viewport_texture.get_data()
	img.flip_y() # Image is flipped vertically, correct this
	
	if oSavePreviewTrimBlackCheckbox.pressed == true:
		# Trim the black pixels from the outside of the image
		img = trim_image(img)
	
	# Resize to new size
	#trimmed_img.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	
	# Save as a PNG file
	img.save_png(save_path)

	oMessage.quick("Saved preview to:" + save_path)
	modulate.a = 1.0


func is_near_black(pixel: Color, tolerance: float = 0.01) -> bool:
	return (pixel.r < tolerance and pixel.g < tolerance and pixel.b < tolerance)

func trim_image(img : Image) -> Image:
	img.lock()
	
	var left = img.get_width()
	var right = 0
	var top = img.get_height()
	var bottom = 0

	for i in range(img.get_width()):
		for j in range(img.get_height()):
			var pixel = img.get_pixel(i, j)
			if not is_near_black(pixel):
				left = min(left, i)
				right = max(right, i)
				top = min(top, j)
				bottom = max(bottom, j)

	img.unlock()

	# Check if the image was all black or nearly all black and couldn't be trimmed
	if left > right or top > bottom:
		print("Image couldn't be trimmed!")

	var trim_x = left
	var trim_y = top
	var trim_width = right - left + 1
	var trim_height = bottom - top + 1

	# Extract the non-black rectangle
	var trimmed_img = img.get_rect(Rect2(trim_x, trim_y, trim_width, trim_height))

	# Debugging messages
	print("Original Image Dimensions: %sx%s" % [img.get_width(), img.get_height()])
	print("Trimmed Image Dimensions: %sx%s" % [trimmed_img.get_width(), trimmed_img.get_height()])
	
	return trimmed_img

func _on_SavePreviewMsaaSlider_sliderChanged():
	match int(oSavePreviewMsaaSlider.value):
		0: get_viewport().msaa = Viewport.MSAA_DISABLED
		1: get_viewport().msaa = Viewport.MSAA_2X
		2: get_viewport().msaa = Viewport.MSAA_4X
		3: get_viewport().msaa = Viewport.MSAA_8X
		4: get_viewport().msaa = Viewport.MSAA_16X

func _on_SavePreviewMipmapsCheckbox_toggled(button_pressed):
	if button_pressed == true:
		oGame3D.enable_or_disable_mipmaps_on_all_materials(1)
	else:
		oGame3D.enable_or_disable_mipmaps_on_all_materials(0)
