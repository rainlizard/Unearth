extends Node2D
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oColorRectSlabOwner = Nodelist.list["oColorRectSlabOwner"]
onready var oInstanceOwnership = Nodelist.list["oInstanceOwnership"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]

onready var oMain = Nodelist.list["oMain"]
var OWNERSHIP_ALPHA = 0.5 setget set_ownership_alpha_graphics
onready var TILE_SIZE = Constants.TILE_SIZE
onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE
#Bright

var alphaFadeColor = [1.00,1.00,1.00,1.00,1.00,1.00,1.00,1.00,1.00]
const fadeSpeed = 4
var slabOwnershipImage = Image.new()
var slabOwnershipTexture = ImageTexture.new()

onready var mat = oColorRectSlabOwner.get_material()

func _ready():
	mat.set_shader_param("color0", Constants.ownerRoomCol[0])
	mat.set_shader_param("color1", Constants.ownerRoomCol[1])
	mat.set_shader_param("color2", Constants.ownerRoomCol[2])
	mat.set_shader_param("color3", Constants.ownerRoomCol[3])
	mat.set_shader_param("color4", Constants.ownerRoomCol[4])
	mat.set_shader_param("color5", Constants.ownerRoomCol[5])
	mat.set_shader_param("color6", Constants.ownerRoomCol[6])
	mat.set_shader_param("color7", Constants.ownerRoomCol[7])
	mat.set_shader_param("color8", Constants.ownerRoomCol[8])
	
	set_ownership_alpha_graphics(OWNERSHIP_ALPHA)

func set_ownership_alpha_graphics(value):
	OWNERSHIP_ALPHA = value
	mat.set_shader_param("outlineThickness", 5.0)
	mat.set_shader_param("alphaOutline", clamp(OWNERSHIP_ALPHA*2.0, 0.0, 1.0))
	mat.set_shader_param("alphaFilled", OWNERSHIP_ALPHA)
	for i in Constants.PLAYERS_COUNT:
		oInstanceOwnership.materialInstanceOwnership[i].set_shader_param("alphaFilled", value)

func clear():
	if slabOwnershipImage.get_size().x > 0:
		slabOwnershipImage.fill(Constants.ownerRoomCol[5])
		slabOwnershipTexture.create_from_image(slabOwnershipImage, 0)

func start():
	var CODETIME_START = OS.get_ticks_msec()
	slabOwnershipImage.create(M.xSize,M.ySize,false,Image.FORMAT_RGBA8)
	# Read ownership data as pixels
	slabOwnershipImage.lock()
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			var getOwner = oDataOwnership.get_cell_ownership(xSlab,ySlab)
			if getOwner < Constants.PLAYERS_COUNT:
				slabOwnershipImage.set_pixel(xSlab, ySlab, Constants.ownerRoomCol[getOwner])
	slabOwnershipImage.unlock()
	
	slabOwnershipTexture.create_from_image(slabOwnershipImage, 0)
	oColorRectSlabOwner.rect_size = Vector2(M.xSize*TILE_SIZE, M.ySize*TILE_SIZE)
	#yield(get_tree(),'idle_frame')
	#print(oColorRectSlabOwner.rect_scale)
	#oColorRectSlabOwner.rect_position = Vector2(96,96)
	print('overhead ownership (start): ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func ownership_paint_shape(shapePositionArray, ownership):
	
	var setColour = Constants.ownerRoomCol[ownership]
	
	slabOwnershipImage.lock()
	for pos in shapePositionArray:
		var slabID = oDataSlab.get_cell(pos.x, pos.y)
		if oSlabPlacement.slabID_is_ownable(slabID) == true:
			oDataOwnership.set_cellv_ownership(pos, ownership) # Set cell data
			slabOwnershipImage.set_pixelv(pos, setColour)  # Set image data
	slabOwnershipImage.unlock()
	
	slabOwnershipTexture.set_data(slabOwnershipImage)

func update_ownership_image_based_on_shape(shapePositionArray):
	slabOwnershipImage.lock()
	for pos in shapePositionArray:
		var ownership = oDataOwnership.get_cellv_ownership(pos) # Get cell data
		var setColour = Constants.ownerRoomCol[ownership]
		slabOwnershipImage.set_pixelv(pos, setColour)  # Set image data
	slabOwnershipImage.unlock()
	
	slabOwnershipTexture.set_data(slabOwnershipImage)


func ownership_update_things(shapePositionArray, paintOwnership):
	# Change ownership of spellbooks when placing slab ownership (Ownership tab)
	for id in get_tree().get_nodes_in_group("Spellbook"):
		var slabPos = Vector2(int(id.locationX/3),int(id.locationY/3))
		if slabPos in shapePositionArray:
			id.ownership = paintOwnership

#func ownership_update_rect(rectStart, rectEnd, ownership):
#	rectStart = Vector2(clamp(rectStart.x, 0, 84), clamp(rectStart.y, 0, 84))
#	rectEnd = Vector2(clamp(rectEnd.x, 0, 84), clamp(rectEnd.y, 0, 84))
#
#	var setColour = Constants.ownerRoomCol[ownership]
#
#	slabOwnershipImage.lock()
#	for ySlab in range(rectStart.y, rectEnd.y+1):
#		for xSlab in range(rectStart.x, rectEnd.x+1):
#			oDataOwnership.set_cell(xSlab, ySlab, ownership) # Set cell data
#			slabOwnershipImage.set_pixel(xSlab, ySlab, setColour)  # Set image data
#	slabOwnershipImage.unlock()
#
#	slabOwnershipTexture.set_data(slabOwnershipImage)

func _process(delta):
	var cursorOnColor
	mat.set_shader_param("territoryTexture", slabOwnershipTexture)
	mat.set_shader_param("zoom", oCamera2D.zoom.x)
	if oSelector.visible == true:
		if slabOwnershipImage.get_size().x > 0:
			var cursorPos = oSelector.cursorTile
			if cursorPos.x < 0 or cursorPos.x >= M.xSize: return
			if cursorPos.y < 0 or cursorPos.y >= M.ySize: return
			
			slabOwnershipImage.lock()
			cursorOnColor = slabOwnershipImage.get_pixel(cursorPos.x, cursorPos.y)
			slabOwnershipImage.unlock()
			mat.set_shader_param("cursorOnColor", cursorOnColor)
	
	for i in Constants.PLAYERS_COUNT:
		if cursorOnColor == Constants.ownerRoomCol[i]:
			alphaFadeColor[i] = lerp(alphaFadeColor[i], 1.00, fadeSpeed*delta)
		else:
			alphaFadeColor[i] = lerp(alphaFadeColor[i], 0.00, fadeSpeed*delta)
		mat.set_shader_param("alphaFadeColor"+str(i), alphaFadeColor[i])




#	update()

#func _draw():
#	draw_texture_rect(slabOwnershipTexture, Rect2(0,0,85*TSIZE,85*TSIZE), false, Color( 1, 1, 1, 1 ), false, null)


