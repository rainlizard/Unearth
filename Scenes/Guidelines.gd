extends Node2D
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]

const TILE_SIZE = 96
var LINE_ALPHA:float = 0.03 setget set_line_alpha

func set_line_alpha(setVal):
	LINE_ALPHA = setVal
	update()

func _draw():
	if LINE_ALPHA == 0: return
	if oMirrorPlacementCheckBox.pressed == false: return
	for i in range(2):
		var size1 = M.xSize if i == 0 else M.ySize
		var size2 = M.ySize if i == 0 else M.xSize
		
		var center = floor(size1 * 0.5)
		var offset = 0.5 if size1 % 2 == 1 else 0.0
		var thickness = 0.15
		
		var start = Vector2(center + offset - thickness, 0)
		var end = Vector2(center + offset + thickness, size2)
		
		if i == 1:
			start = Vector2(start.y, start.x)
			end = Vector2(end.y, end.x)
		
		draw_rect(Rect2(start * TILE_SIZE, (end - start) * TILE_SIZE), Color(1, 1, 1, LINE_ALPHA), true)
