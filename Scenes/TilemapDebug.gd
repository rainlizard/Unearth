extends Node2D
onready var DEBUG_THIS_TILEMAP_NODE = Nodelist.list["oDataWibble"]

var tileDrawDist = 32
var draw_grid = false
var dynamic_font = DynamicFont.new()

#oDataSlx.set_cellv(cursorTile, 4)

func _process(delta):
	if Input.is_action_just_pressed("debug_tilemap") and OS.has_feature("standalone") == false:
		draw_grid = !draw_grid
	update()

func _draw():
	if is_instance_valid(DEBUG_THIS_TILEMAP_NODE) == false: return
	if draw_grid == true:
		dynamic_font.font_data = preload("res://Theme/ClassicConsole.ttf")
		dynamic_font.size = tileDrawDist
		for x in 255: #get_size_x():
			for y in 255: #get_size_y():
				var value = DEBUG_THIS_TILEMAP_NODE.get_cell(x,y)
				var string = str(value)
				var pos = Vector2(x*tileDrawDist, y*tileDrawDist) + Vector2(tileDrawDist*0.5,tileDrawDist*0.5)
				pos.x -= dynamic_font.get_string_size(string).x * 0.5 # Center string
				pos.y += dynamic_font.get_string_size(string).y * 0.25
				
				pos.x -= 16
				pos.y -= 16
				
				var color = Color.white
#				match value:
#					0: color = Color.red
#					1: color = Color.blue
#					2: color = Color.green
#					3: color = Color.yellow
#					4: color = Color.cadetblue
#					5: color = Color.black
				
				draw_string(dynamic_font, pos, string, color)
