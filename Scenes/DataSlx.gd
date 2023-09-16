extends Node
onready var oSlabStyle = Nodelist.list["oSlabStyle"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]
onready var oSelection = Nodelist.list["oSelection"]

var slxImgData = Image.new()
var slxTexData = ImageTexture.new()

func clear_img():
	if slxImgData.get_size().x > 0:
		slxImgData.fill(Color(0,0,0,1))
		slxTexData.set_data(slxImgData)

#func set_tileset_value(x,y):
#	var value = Color8(oSlabStyle.paintSlabStyle,0,0)
#	slxImgData.lock()
#	slxImgData.set_pixel(x,y,value)
#	slxImgData.unlock()
#	slxTexData.set_data(slxImgData)
#	oDisplaySlxNumbers.update_grid()

func set_tileset_shape(shapePositionArray, style):
	var value = Color8(style,0,0)
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
