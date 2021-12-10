extends WindowDialog
onready var oChooseFileListFileDialog = Nodelist.list["oChooseFileListFileDialog"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oReloadEveryLineEdit = Nodelist.list["oReloadEveryLineEdit"]
onready var oReloaderContainer = Nodelist.list["oReloaderContainer"]
onready var oReloaderPathLabel = Nodelist.list["oReloaderPathLabel"]
onready var oExportTmapaDatDialog = Nodelist.list["oExportTmapaDatDialog"]
onready var oReadPalette = Nodelist.list["oReadPalette"]


var filelistfile = File.new()
var fileListFilePath = ""
var editingImg = Image.new()


func _ready():
	editingImg.create(8*32, 68*32, false, Image.FORMAT_RGB8)
	oReloaderContainer.visible = false

func _on_ChooseFileListFileDialog_file_selected(path):
	fileListFilePath = path
	oReloaderPathLabel.text = path
	
	oReloaderContainer.visible = true
	reloader_loop()

func reloader_loop():
	var timerNumber = float(oReloadEveryLineEdit.text)
	print(timerNumber)
	yield(get_tree().create_timer(timerNumber), "timeout")
	
	if fileListFilePath != "":
		execute()
	
	reloader_loop()

func _on_LoadFilelistButton_pressed():
	Utils.popup_centered(oChooseFileListFileDialog)
func _on_ExportTmapaButton_pressed():
	Utils.popup_centered(oExportTmapaDatDialog)


func execute():
	var baseDir = fileListFilePath.get_base_dir()
	
	if filelistfile.open(fileListFilePath, File.READ) != OK: return
	
	var content = filelistfile.get_as_text()
	filelistfile.close()
	
	var lineArray = Array(content.split('\n', false))
	lineArray.pop_front() # remove the first line: textures_pack_000	8	68	32	32
	
	for i in lineArray.size():
		lineArray[i] = Array(lineArray[i].split('\t', false))
		#print(lineArray[i].size())
	
	
	#img.fill(Color(1,1,1,1))
	editingImg.lock()
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
			
			editingImg.blit_rect(imgLoader,Rect2(x,y,width,height), destination)
			#for z in lineArray[i]:
			#	print(z)
	editingImg.unlock()
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	
	
	var tmapaNumber = fileListFilePath.right(fileListFilePath.length()-12).to_lower().trim_suffix(".txt")
	oTextureCache.load_image_into_cache(editingImg, tmapaNumber)
	oTextureCache.set_current_texture_pack()
#	var imgTex = ImageTexture.new()
#	imgTex.create_from_image(img,0)
#	$"../TextureRect".texture = imgTex



func _on_ExportTmapaDatDialog_file_selected(path):
	var buffer = StreamPeerBuffer.new()
	#print(oTextureCache.paletteData)
	var CODETIME_START = OS.get_ticks_msec()
	
	editingImg.lock()

	for y in 68*32:
		for x in 8*32:
			var col = editingImg.get_pixel(x,y)
			var R = floor(col.r8/4.0)*4
			var G = floor(col.g8/4.0)*4
			var B = floor(col.b8/4.0)*4
			
			var roundedCol = Color8(R,G,B)
			
			var paletteIndex = 255 # Purple should show easier as an issue to debug
			if oReadPalette.dictionary.has(roundedCol) == true:
				paletteIndex = oReadPalette.dictionary[roundedCol]
#			else:
#				print(str(roundedCol.r) + ', '+str(roundedCol.g) + ', '+str(roundedCol.b) + ', '+str(roundedCol.a))
			
			buffer.put_8(paletteIndex)
	editingImg.unlock()
	
	var file = File.new()
	file.open(path,File.WRITE)
	file.store_buffer(buffer.data_array)
	file.close()

	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
