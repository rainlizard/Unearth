extends Node
onready var oSlabStyle = Nodelist.list["oSlabStyle"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]

var slxImgData = Image.new()
var slxTexData = ImageTexture.new()

func clear_img():
	if slxImgData.get_size().x > 0:
		slxImgData.fill(Color(0,0,0,1))
		slxTexData.set_data(slxImgData)

func set_tileset_shape(shapePositionArray):
	var value = Color8(oSlabStyle.paintSlabStyle,0,0)
	slxImgData.lock()
	for pos in shapePositionArray:
		slxImgData.set_pixelv(pos,value)
	slxImgData.unlock()
	slxTexData.set_data(slxImgData)
	oDisplaySlxNumbers.update_grid()

func get_tileset_value(x,y):
	slxImgData.lock()
	var r = slxImgData.get_pixel(x,y).r8
	slxImgData.unlock()
	return r

func resize_bottom_right(new_width: int, new_height: int, fillValue: int, offset_x: int = 0, offset_y: int = 0):
	var resized_image = Image.new()
	resized_image.create(new_width, new_height, false, slxImgData.get_format())
	
	var fill_color = Color8(fillValue, 0, 0)
	resized_image.fill(fill_color)
	
	var copy_width = slxImgData.get_width()
	var copy_height = slxImgData.get_height()
	var source_x = max(0, -offset_x)
	var source_y = max(0, -offset_y)
	var dest_x = max(0, offset_x)
	var dest_y = max(0, offset_y)
	copy_width = min(copy_width - source_x, new_width - dest_x)
	copy_height = min(copy_height - source_y, new_height - dest_y)
	if copy_width > 0 and copy_height > 0:
		resized_image.blit_rect(slxImgData, Rect2(source_x, source_y, copy_width, copy_height), Vector2(dest_x, dest_y))
	
	slxImgData = resized_image
	slxTexData.create_from_image(slxImgData, 0)
