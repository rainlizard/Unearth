extends Node2D
# Outlines the map's edge so it can't be confused with the empty space around it

const TILE_SIZE = 96
const EDGE_COLOR = Color8(64, 61, 72)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(M.xSize, M.ySize) * TILE_SIZE), EDGE_COLOR, false) # Width 1 stays one screen pixel at any zoom
