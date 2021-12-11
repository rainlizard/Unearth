extends WindowDialog
onready var oChooseFileListFileDialog = Nodelist.list["oChooseFileListFileDialog"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oReloadEveryLineEdit = Nodelist.list["oReloadEveryLineEdit"]
onready var oReloaderContainer = Nodelist.list["oReloaderContainer"]
onready var oReloaderPathLabel = Nodelist.list["oReloaderPathLabel"]
onready var oExportTmapaDatDialog = Nodelist.list["oExportTmapaDatDialog"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oChooseTmapaFileDialog = Nodelist.list["oChooseTmapaFileDialog"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]


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
	oChooseFileListFileDialog.current_dir = Settings.unearth_path.plus_file("textures").plus_file("")
	oChooseFileListFileDialog.current_path = Settings.unearth_path.plus_file("textures").plus_file("")
	oChooseFileListFileDialog.current_file = "filelist_tmapa000.txt"

func _on_ExportTmapaButton_pressed():
	Utils.popup_centered(oExportTmapaDatDialog)
	oExportTmapaDatDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportTmapaDatDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oExportTmapaDatDialog.current_file = get_tmapa_filename()+".dat"

func _on_CreateFilelistButton_pressed():
	Utils.popup_centered(oChooseTmapaFileDialog)
	oChooseTmapaFileDialog.current_dir = oGame.DK_DATA_DIRECTORY.plus_file("")
	oChooseTmapaFileDialog.current_path = oGame.DK_DATA_DIRECTORY.plus_file("")
	oChooseTmapaFileDialog.current_file = "tmapa000.dat"

func execute():
	var baseDir = fileListFilePath.get_base_dir()
	
	if filelistfile.open(fileListFilePath, File.READ) != OK: return
	
	var flContent = filelistfile.get_as_text()
	filelistfile.close()
	
	var lineArray = Array(flContent.split('\n', false))
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
	
	
	
	var tmapaNumber = get_tmapa_filename()
	oTextureCache.load_image_into_cache(editingImg, tmapaNumber)
	oTextureCache.set_current_texture_pack()
#	var imgTex = ImageTexture.new()
#	imgTex.create_from_image(img,0)
#	$"../TextureRect".texture = imgTex

func get_tmapa_filename():
	return fileListFilePath.right(fileListFilePath.length()-12).to_lower().trim_suffix(".txt")


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
	
	oMessage.quick("Exported : " + path)
	
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')



func _on_ChooseTmapaFileDialog_file_selected(path):
	var sourceImg = oTextureCache.convert_tmapa_to_image(path)
	if sourceImg == null: return
	var CODETIME_START = OS.get_ticks_msec()
	
	var outputDir = Settings.unearth_path.plus_file("textures")
	
	var filelistFile = File.new()
	if filelistFile.open(Settings.unearthdata.plus_file("exportfilelist.txt"), File.READ) != OK:
		return
	
	# Split the Filelist into usable arrays
	
	var flContent = filelistFile.get_as_text()
	var numberString = path.get_file().get_basename().trim_prefix('tmapa')
	flContent = flContent.replace("subdir", "pack" + numberString)
	flContent = flContent.replace("textures_pack_number", "textures_pack_" + numberString)
	filelistFile.close()
	
	
	var lineArray = Array(flContent.split('\n', false))
	lineArray.pop_front() # For the array remove the first line: textures_pack_number	8	68	32	32
	
	for i in lineArray.size():
		lineArray[i] = Array(lineArray[i].split('\t', false))
	
	# The strings can be out of order, so create a dictionary that looks like this - "subdir/earth_standard.png" : []
	# Calculate the maxWidth and maxHeight by figuring out the largest destination positions that are in the list for each string
	var imageDictionary = {}
	for i in lineArray.size():
		var localPath = lineArray[i][0]
		
		if imageDictionary.has(localPath) == true:
			var compareWidth = int(lineArray[i][1]) + 32 #int(lineArray[i][3])
			var compareHeight = int(lineArray[i][2]) + 32 #int(lineArray[i][4])
			
			if imageDictionary[localPath][0] < compareWidth:
				imageDictionary[localPath][0] = compareWidth
			if imageDictionary[localPath][1] < compareHeight:
				imageDictionary[localPath][1] = compareHeight
		else:
			imageDictionary[localPath] = [32, 32] # 1 tile - minimum sized image
	
	# Replace the width and height array with an Image.
	for i in imageDictionary:
		var createNewImage = Image.new()
		var w = imageDictionary[i][0]
		var h = imageDictionary[i][1]
		createNewImage.create(w,h,false,Image.FORMAT_RGB8)
		imageDictionary[i] = createNewImage
	
	# Make images
	for i in lineArray.size():
		var sourceTileY = i / 8
		var sourceTileX = i - (sourceTileY * 8)
		
		var localPath = lineArray[i][0]
		var destX = lineArray[i][1]
		var destY = lineArray[i][2]
#		var width = lineArray[i][3]
#		var height = lineArray[i][4]
		var createNewImage = imageDictionary[localPath]
		createNewImage.lock()
		createNewImage.blit_rect(sourceImg, Rect2(sourceTileX*32,sourceTileY*32, 32,32), Vector2(destX, destY))
		createNewImage.unlock()
	
	# Save PNGs (separate loop so we're iterating once on each file, rather than every single filelist line)
	var dir = Directory.new()
	for localPath in imageDictionary:
		
		var savePath = outputDir.plus_file(localPath)
		var packFolder = savePath.get_base_dir()
		
		if dir.dir_exists(packFolder) == false:
			dir.make_dir_recursive(packFolder)
		
		var createNewImage = imageDictionary[localPath]
		createNewImage.save_png(savePath)
		oMessage.quick("Exported : textures/" + localPath)
	
	save_new_filelist_txt_file(flContent, numberString, outputDir) # This goes after the "make_dir_recursive" commands
	OS.shell_open(outputDir)
	
	print('Exported Filelist in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func save_new_filelist_txt_file(flContent, numberString, outputDir):
	var file = File.new()
	file.open(outputDir.plus_file("filelist_tmapa"+numberString+".txt"), File.WRITE)
	file.store_string(flContent)
	file.close()

#	for y in 68:
#		for x in 8:
#
#			pass
#editingImg.lock()
#	var imgLoader = Image.new()
#	var CODETIME_START = OS.get_ticks_msec()
#	for i in lineArray.size():
#		#if i == 40:
#			#print(lineArray[i])
#			var path = lineArray[i][0]
#			var x = lineArray[i][1]
#			var y = lineArray[i][2]
#			var width = lineArray[i][3]
#			var height = lineArray[i][4]
#			imgLoader.load(baseDir.plus_file(path))
#
#			var destY = i/8
#			var destX = i-(destY*8)
#
#			var destination = Vector2(destX*32,destY*32)
#
#			editingImg.blit_rect(imgLoader,Rect2(x,y,width,height), destination)
#			#for z in lineArray[i]:
#			#	print(z)
#	editingImg.unlock()
