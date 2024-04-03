extends WindowDialog

onready var oMapProperties = Nodelist.list["oMapProperties"]
onready var oEnsignFlagImg = Nodelist.list["oEnsignFlagImg"]
onready var oLandviewAspectRatioContainer = Nodelist.list["oLandviewAspectRatioContainer"]
onready var oLandviewImage = Nodelist.list["oLandviewImage"]
onready var oEnsignPositionX = Nodelist.list["oEnsignPositionX"]
onready var oEnsignPositionY = Nodelist.list["oEnsignPositionY"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oChooseLandviewImageFileDialog = Nodelist.list["oChooseLandviewImageFileDialog"]
onready var oLandViewFlagPosLabel = Nodelist.list["oLandViewFlagPosLabel"]

var imageData = Image.new()
var textureData = ImageTexture.new()

var image_resolution = Vector2()
var holding_left_click = false
var normalized_flag_position = Vector2(0.5, 0.5) # Default to center


func _ready():
	update_image_resolution()
	update_aspect_ratio()
	update_flag_position()


func _on_LandviewImage_resized():
	update_flag_size()
	update_flag_position()


func update_image_resolution():
	image_resolution = oLandviewImage.texture.get_data().get_size()


func update_aspect_ratio():
	oLandviewAspectRatioContainer.ratio = image_resolution.x / image_resolution.y


func update_flag_size():
	var adjustScale = oLandviewImage.rect_size / image_resolution
	oEnsignFlagImg.rect_scale = Vector2(adjustScale.x, adjustScale.x)


func update_flag_position():
	var flag_position = normalized_flag_position * oLandviewImage.rect_size
	oEnsignFlagImg.rect_position = flag_position - oEnsignFlagImg.rect_pivot_offset
	
	var new_set_pos = image_resolution * normalized_flag_position
	new_set_pos.x = int(new_set_pos.x)
	new_set_pos.y = int(new_set_pos.y)
	
	oMapProperties.set_flag_pos_by_landview_img(new_set_pos)
	oLandViewFlagPosLabel.text = "(" + str(new_set_pos.x) + ", " + str(new_set_pos.y) + ")"

func _on_CloseMapCoordButton_pressed():
	visible = false


func _on_LandviewImage_gui_input(event):
	if visible == false: return

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			holding_left_click = true
		else:
			holding_left_click = false

	if event is InputEventMouseMotion:
		if holding_left_click == true:
			var clamped_position = Vector2()
			clamped_position.x = clamp(event.position.x, 0, oLandviewImage.rect_size.x)
			clamped_position.y = clamp(event.position.y, 0, oLandviewImage.rect_size.y)

			normalized_flag_position = clamped_position / oLandviewImage.rect_size
			update_flag_position()


func _on_ChangeImageCoordButton_pressed():
	Utils.popup_centered(oChooseLandviewImageFileDialog)


func _on_MapCoordinatesWindow_visibility_changed():
	if visible == true:
		var flag_position_x = int(oEnsignPositionX.text)
		var flag_position_y = int(oEnsignPositionY.text)
		var flag_position = Vector2(flag_position_x, flag_position_y)
		normalized_flag_position = flag_position / image_resolution
		update_flag_position()
	else:
		if oMessage == null: return

func _on_ChooseLandviewImageFileDialog_file_selected(path):
	var err = imageData.load(path)
	if err != OK:
		oMessage.quick("Error loading file.")
		return
	textureData = ImageTexture.new()
	textureData.create_from_image(imageData, 0) # flags off
	oLandviewImage.texture = textureData
	
	update_image_resolution()
	update_aspect_ratio()
	update_flag_position()
