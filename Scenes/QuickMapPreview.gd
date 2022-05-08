extends Sprite

var img = Image.new()
var tex = ImageTexture.new()

const colourDict = {
	0 : Color(1,1,1,1),
	1 : Color(1,0,1,1),
	2 : Color(0,1,1,1),
	3 : Color(0,0,1,1),
	4 : Color(0,1,0,1),
	5 : Color(1,1,0,1),
}

func _ready():
	img.create(85, 85, false, Image.FORMAT_RGB8)
	tex.create_from_image(img, 0)

func update_img(filePath):
	
	if File.new().file_exists(filePath) == false:
		print("File not found : " + filePath)
		return
	
	var CODETIME_START = OS.get_ticks_msec()
	
	var buffer = Filetypes.file_path_to_buffer(filePath)
	buffer.seek(0)
	
	img.lock()
	for y in 85:
		for x in 85:
			var value = buffer.get_u8()
			buffer.get_u8() # skip second byte
			if colourDict.has(value):
				img.set_pixel(x,y,colourDict[value])
			else:
				img.set_pixel(x,y,Color(0,0,0,1))
	img.unlock()
	
	tex.set_data(img)
	texture = tex
	
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
