extends Node2D
onready var oBrushPreviewDisplay = Nodelist.list["oBrushPreviewDisplay"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oEditingTools = Nodelist.list["oEditingTools"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oUi = Nodelist.list["oUi"]
onready var oPreferencesWindow = Nodelist.list["oPreferencesWindow"]
onready var oQuickMapPreview = Nodelist.list["oQuickMapPreview"]
onready var oDataSlab = Nodelist.list["oDataSlab"]

var img = Image.new()
var tex = ImageTexture.new()

var brushShapeArray = []
var offsetBrushPos = 0

func _ready():
	img.create(1, 1, false, Image.FORMAT_RGBA8)
	tex.create_from_image(img, 0)
	yield(get_tree(),'idle_frame')
	update_img()

func update_img():
	if is_instance_valid(oEditingTools) == false:
		yield(get_tree(),'idle_frame')
	
	img.resize(oEditingTools.BRUSH_SIZE,oEditingTools.BRUSH_SIZE, Image.INTERPOLATE_NEAREST)
	var imgW = img.get_width()
	var imgH = img.get_height()
	
	match oEditingTools.TOOL_SELECTED:
		oEditingTools.PENCIL:
			brushShapeArray = make_brush_shape(oSelection.CONSTRUCT_PENCIL)
		oEditingTools.BRUSH:
			brushShapeArray = make_brush_shape(oSelection.CONSTRUCT_BRUSH)
		oEditingTools.RECTANGLE:
			brushShapeArray = []
		oEditingTools.PAINTBUCKET:
			brushShapeArray = []
	if oSelector.mode == oSelector.MODE_SUBTILE:
		brushShapeArray = []
	
	img.fill(Color(0,0,0,0))
	
	img.lock()
	
	for pos in brushShapeArray:
		img.set_pixelv(pos, Color(1,1,1,0.25))
	img.unlock()

	tex.set_data(img)
	
	var halfSize = ((oEditingTools.BRUSH_SIZE)-1) / 2.0
	offsetBrushPos = -Vector2(floor(halfSize),floor(halfSize))
	
	oBrushPreviewDisplay.texture = tex
	oBrushPreviewDisplay.rect_size = Vector2(imgW*96, imgH*96)
	

func _process(delta):
	oBrushPreviewDisplay.rect_position = (oSelector.cursorTile+offsetBrushPos) * Vector2(96,96)
	visible = true
	if oUi.mouseOnUi == true: visible = false
	if oEditor.fieldBoundary.has_point(oSelector.cursorTile) == false: visible = false
	if oEditor.currentView == oEditor.VIEW_3D: visible = false
	if oPreferencesWindow.visible == true: visible = false
	if oQuickMapPreview.visible == true: visible = false



func make_brush_shape(constructType):
	var array = []
	
	
	var beginPos = Vector2(0,0)
	var endPos = Vector2(oEditingTools.BRUSH_SIZE-1, oEditingTools.BRUSH_SIZE-1)
	var brushSize = (beginPos-endPos).abs()
	var center = Vector2(brushSize.x*0.5, brushSize.y*0.5)
	print("brushSize: " + str(brushSize))
	for y in range(beginPos.y, endPos.y+1):
		for x in range(beginPos.x, endPos.x+1):
			if constructType == oSelection.CONSTRUCT_BRUSH:
				print(Vector2(x,y).distance_to(center))
				if Vector2(x,y).distance_to(center) < max(brushSize.x+1,brushSize.y+1)*0.47:
					array.append(Vector2(x,y))
			else:
				array.append(Vector2(x,y))
	return array



	# Clamp inside map
#	if clampInsideMap == true:
#		beginTile.x = clamp(beginTile.x, oEditor.fieldBoundary.position.x, oEditor.fieldBoundary.end.x-1)
#		beginTile.y = clamp(beginTile.y, oEditor.fieldBoundary.position.y, oEditor.fieldBoundary.end.y-1)
#		endTile.x = clamp(endTile.x, oEditor.fieldBoundary.position.x, oEditor.fieldBoundary.end.x-1)
#		endTile.y = clamp(endTile.y, oEditor.fieldBoundary.position.y, oEditor.fieldBoundary.end.y-1)
	
