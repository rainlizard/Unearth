extends ColorRect
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oRNC = Nodelist.list["oRNC"]
onready var oReadData = Nodelist.list["oReadData"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oMapBrowserTabContainer = Nodelist.list["oMapBrowserTabContainer"]


var img = Image.new()
var tex = ImageTexture.new()


#42, 43, 44, 45, 46, 47, 48, 49

#11:
#if (OwnRNC = true) then
#Color.Gray
#else
#begin
#if (Own[Y, X] = 5) then
#Color("$042434")
#else
#SlabColours[Own[Y, X]];
#end;
#end;

const colourDict = {
	0: Color.black,
	2 : Color("241800"),
	3 : Color("241800"),
	50 : Color("241800"),
	
	1 : Color("605C10"),
	
	4: Color("40301C"),
	5: Color("40301C"),
	6: Color("40301C"),
	7: Color("40301C"),
	8: Color("40301C"),
	9: Color("40301C"),
	17: Color("40301C"),
	19: Color("40301C"),
	21: Color("40301C"),
	23: Color("40301C"),
	25: Color("40301C"),
	27: Color("40301C"),
	29: Color("40301C"),
	31: Color("40301C"),
	33: Color("40301C"),
	35: Color("40301C"),
	37: Color("40301C"),
	39: Color("40301C"),
	41: Color("40301C"),
	
	10: Color("342404"),
	12 : Color("381C00"),
	13 : Color("54403C"),
	
	# Portal
	#14 : Color(1,1,1,1),
	
	#Opened door: A8B060
	#? door: 909850
	# Doors
	42 : Color("FC986C"),
	43 : Color("FC986C"),
	44 : Color("FC986C"),
	45 : Color("FC986C"),
	46 : Color("FC986C"),
	47 : Color("FC986C"),
	48 : Color("FC986C"),
	49 : Color("FC986C"),
	
	
	52 : Color("D890BF"),
	54 : Color.purple, #Color.fuchsia
}
const spoilerColor = Color8(20,16,0) #Color(0.125, 0.125, 0.175, 1.0)
var spoiledSlabs = {
	Slabs.ROCK:null,
	Slabs.GOLD:null,
	Slabs.GEMS:null,
}

func _ready():
	visible = false
	img.create(M.xSize, M.ySize, false, Image.FORMAT_RGB8)
	tex.create_from_image(img, 0)


func update_img(slbFilePath):
	var hideSpoilers = false
	if oMapBrowserTabContainer.current_tab == 1: # Play
		hideSpoilers = true
	
	if File.new().file_exists(slbFilePath) == false:
		print("File not found : " + slbFilePath)
		return
	
	var lofFilePath = ""
	if File.new().file_exists(slbFilePath.get_basename()+".lof") == true:
		lofFilePath = slbFilePath.get_basename()+".lof"
	elif File.new().file_exists(slbFilePath.get_basename()+".LOF") == true:
		lofFilePath = slbFilePath.get_basename()+".LOF"
	
	var lofBuffer = Filetypes.file_path_to_buffer(lofFilePath)
	var xy = oReadData.read_mapsize_from_lof(lofBuffer)
	#print(xy)
	
	
	
	#var CODETIME_START = OS.get_ticks_msec()
	
	var ownFilePath = ""
	if File.new().file_exists(slbFilePath.get_basename()+".own") == true:
		ownFilePath = slbFilePath.get_basename()+".own"
	elif File.new().file_exists(slbFilePath.get_basename()+".OWN") == true:
		ownFilePath = slbFilePath.get_basename()+".OWN"
	
	if oRNC.check_for_rnc_compression(slbFilePath) == true: return
	if oRNC.check_for_rnc_compression(ownFilePath) == true: return
	
	var ownBuffer = null
	if ownFilePath != "":
		ownBuffer = Filetypes.file_path_to_buffer(ownFilePath)
		ownBuffer.seek(0)
	
	var slbBuffer = Filetypes.file_path_to_buffer(slbFilePath)
	slbBuffer.seek(0)
	
	var slabID
	var ownership = 5
	
	img.create(xy.x, xy.y, false, Image.FORMAT_RGB8)
	img.lock()
	for y in xy.y:
		for x in xy.x:
			slabID = slbBuffer.get_u8()
			slbBuffer.get_u8() # skip second byte
			
			if ownBuffer != null:
				var dataWidth = (xy.x*3)+1
				ownBuffer.seek( (((x*3)+1)+(y*3*dataWidth)))
				ownership = ownBuffer.get_u8()
			
			if hideSpoilers == false:
				if colourDict.has(slabID):
					img.set_pixel(x,y,colourDict[slabID])
				else:
					if slabID == 11 and ownership != 255: # Is claimed floor
						img.set_pixel(x,y,Constants.ownerFloorCol[ownership])
					else:
						if ownership == 5:
							img.set_pixel(x,y,Color(1,1,1,1)) # Neutral room. Use shader to flash it.
						else:
							img.set_pixel(x,y,Constants.ownerRoomCol[ownership])
			else:
				var pixelHasBeenSet = false
				if colourDict.has(slabID):
					if spoiledSlabs.has(slabID) or ownership == 0:
						img.set_pixel(x,y,colourDict[slabID])
						pixelHasBeenSet = true
				else:
					if ownership == 0:
						if slabID == 11 and ownership != 255 and ownership == 0: # Is claimed floor
							img.set_pixel(x, y, Constants.ownerFloorCol[ownership])
							pixelHasBeenSet = true
						else:
							img.set_pixel(x,y,Constants.ownerRoomCol[ownership])
							pixelHasBeenSet = true
					elif ownership == 5:
						if slabID == Slabs.PORTAL or slabID == Slabs.PORTAL_WALL:
							img.set_pixel(x,y,Color(1,1,1,1)) # Neutral room. Use shader to flash it.
							pixelHasBeenSet = true
				
				if pixelHasBeenSet == false:
					img.set_pixel(x,y,spoilerColor)


	#if ownership < 5:
	img.unlock()
	
	tex.set_data(img)
	$QuickMapPreviewDisplay.texture = tex
	$QuickMapPreviewDisplay.rect_size = Vector2(xy.x*96, xy.y*96)
	#$QuickMapPreviewDisplay.rect_position = Vector2(xy.x*96*0.5, xy.y*96*0.5)
	
	oCamera2D.reset_camera(xy.x, xy.y)
	
	rect_size = Vector2(M.xSize*96, M.ySize*96) # Cover current map in darkness
	
	#print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	return OK
