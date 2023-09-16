extends Node2D
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oSlabStyle = Nodelist.list["oSlabStyle"]

var tileDrawDist = 96
var draw_grid = false
var dynamic_font = DynamicFont.new()

func _ready():
	dynamic_font.font_data = preload("res://Theme/ClassicConsole.ttf")
	dynamic_font.size = 36

func update_grid():
	update()

func _draw():
	if oSlabStyle.visible == false: return
	
	oDataSlx.slxImgData.lock()
	for x in M.xSize:
		for y in M.ySize:
			var value = oDataSlx.slxImgData.get_pixel(x,y).r8
			if value > 0:
				var string = str(value-1)
				var pos = Vector2(x*tileDrawDist, y*tileDrawDist) + Vector2(tileDrawDist*0.5,tileDrawDist*0.5)
				pos.x -= dynamic_font.get_string_size(string).x * 0.5 # Center string
				pos.y += dynamic_font.get_string_size(string).y * 0.25
				var color
				if oSlabStyle.paintSlabStyle == value:
					color = Color(1,1,1,1)
				else:
					color = Color(1,1,1,0.5)
				
				draw_string(dynamic_font, pos, string, color)
	oDataSlx.slxImgData.unlock()
