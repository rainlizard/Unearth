extends WindowDialog
onready var oChooseFileListFileDialog = Nodelist.list["oChooseFileListFileDialog"]
onready var oTextureCache = Nodelist.list["oTextureCache"]


var filelistfile = File.new()
var fileListFilePath = ""

func _on_LoadFilelistButton_pressed():
	Utils.popup_centered(oChooseFileListFileDialog)



func _on_ConvertCachedButton_pressed():
	# convert cached
	pass


func _on_ChooseFileListFileDialog_file_selected(path):
	fileListFilePath = path
	execute()

func execute():
	var baseDir = fileListFilePath.get_base_dir()
	
	filelistfile.open(fileListFilePath, File.READ)
	var content = filelistfile.get_as_text()
	filelistfile.close()
	
	var lineArray = Array(content.split('\n', false))
	lineArray.pop_front() # remove the first line: textures_pack_000	8	68	32	32
	
	for i in lineArray.size():
		lineArray[i] = Array(lineArray[i].split('\t', false))
		#print(lineArray[i].size())
	
	var img = Image.new()
	img.create(8*32, 68*32, true, Image.FORMAT_RGB8)
	#img.fill(Color(1,1,1,1))
	img.lock()
	var imgLoader = Image.new()
	var CODETIME_START = OS.get_ticks_msec()
	for i in lineArray.size():
		#if i == 40:
			#print(lineArray[i])
			var path = lineArray[i][0]
			var x = lineArray[i][1]
			var y = lineArray[i][2]
			var width = lineArray[i][3]
			var height = lineArray[i][4]
			imgLoader.load(baseDir.plus_file(path))
			
			var destY = i/8
			var destX = i-(destY*8)
			
			var destination = Vector2(destX*32,destY*32)
			
			img.blit_rect(imgLoader,Rect2(x,y,width,height), destination)
			#for z in lineArray[i]:
			#	print(z)
	img.unlock()
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	
	
	var fileName = fileListFilePath.right(fileListFilePath.length()-12).to_lower().trim_suffix(".txt")
	
	print(fileName)
	
	oTextureCache.save_image_as_cached_png(img, fileName)
	
#	var imgTex = ImageTexture.new()
#	imgTex.create_from_image(img,0)
#	$"../TextureRect".texture = imgTex
