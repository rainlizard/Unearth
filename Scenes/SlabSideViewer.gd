extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]

var sd

func update_side():
	pass
	#update()

#func _draw():
#	var slab_id_to_position = {3: 0, 5: 1, 4: 2, 6: 3, 7: 4, 8: 5, 9: 6}
#	var texture_width = 96
#
#	var pos
#	var tileDrawDist = 96
#
#	var viewport_size = get_viewport_rect().size
#	var screen_start = oCamera2D.get_camera_screen_center() - (viewport_size * 0.5) * oCamera2D.zoom
#	var screen_end = oCamera2D.get_camera_screen_center() + (viewport_size * 0.5) * oCamera2D.zoom
#
#	var my_texture = preload("res://Art/viewwallsides.png")
#
#	for x in range(max(0, floor(screen_start.x / tileDrawDist)), min(M.xSize * 3, ceil(screen_end.x / tileDrawDist))):
#		for y in range(max(0, floor(screen_start.y / tileDrawDist)), min(M.ySize * 3, ceil(screen_end.y / tileDrawDist))):
#			pos = Vector2(x * tileDrawDist, y * tileDrawDist)
#
#			var slabID = oDataSlab.get_cell(x, y)
#			if slab_id_to_position.has(slabID):
#				var image_index = slab_id_to_position[slabID]
#				var source_rect = Rect2(image_index * texture_width, 0, texture_width, texture_width)
#				draw_texture_rect_region(my_texture, Rect2(pos, Vector2(96, 96)), source_rect)
