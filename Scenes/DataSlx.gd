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

func resize_bottom_right(new_width: int, new_height: int, fillValue: int):
	var resized_image = Image.new()
	resized_image.create(new_width, new_height, false, slxImgData.get_format())
	
	var fill_color = Color8(fillValue, 0, 0)
	resized_image.fill(fill_color)
	
	var copy_width = min(slxImgData.get_width(), new_width)
	var copy_height = min(slxImgData.get_height(), new_height)
	
	resized_image.blit_rect(slxImgData, Rect2(0, 0, copy_width, copy_height), Vector2.ZERO)
	
	slxImgData = resized_image
