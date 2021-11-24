extends TileMap
#onready var oWallStuff = $'WallStuff'
#onready var oRoomStuff = $'RoomStuff'
#onready var oDataOwnership = $'../../ReadData/GridOwnership'
#onready var oDataSlab = $'../../ReadData/GridSlab'
#
#
#var CODETIME_START
#func update_all_graphics():
#	CODETIME_START = OS.get_ticks_msec()
#	# Subtiles (3x3)
#	for x in 85:
#		for y in 85:
#			var value = oDataSlab.get_cell(x,y)
#			place_slab(x,y,value)
#	print('Slabs placed in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#	CODETIME_START = OS.get_ticks_msec()
#	apply_autotile(Vector2(0,0),Vector2(255,255))
#	print('Autotiled in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#func clear_all_graphics():
#	clear()
#	oWallStuff.clear()
#	oRoomStuff.clear()
#
#func apply_autotile(regionStart, regionEnd): # ALL tilemaps must have their bitmask region updated for autotiling to work.
#	if regionStart == Vector2(0,0) and regionEnd == Vector2(255,255):
#		#This is faster for some reason
#		update_bitmask_region()
#		oWallStuff.update_bitmask_region()
#		oRoomStuff.update_bitmask_region()
#	else:
#		update_bitmask_region(regionStart, regionEnd)
#		oWallStuff.update_bitmask_region(regionStart, regionEnd)
#		oRoomStuff.update_bitmask_region(regionStart, regionEnd)
#
#func place_slab(x,y,slabID):
#	var tile = Slabs.array[slabID][Slabs.GRAPHIC]
#
#	if Slabs.array[slabID][Slabs.GRAPHIC_SIZE] == 0:
#		# Paint 3x3 32x32 subtiles
#		for Xsubtile in 3:
#			for Ysubtile in 3:
#				set_cell((x*3)+Xsubtile, (y*3)+Ysubtile, tile)
#	else:
#		# Paint 1x1 96x96 tile
#		set_cell(x*3, y*3, tile)
#
#	if Slabs.array[slabID][Slabs.SIDE_OF] == Slabs.SIDE_SLAB:
#		for Xsubtile in 3:
#			for Ysubtile in 3:
#				oWallStuff.set_cell((x*3)+Xsubtile, (y*3)+Ysubtile, oWallStuff.WALL_TILE)
#		if slabID == Slabs.EARTH_WITH_TORCH:
#			for Xsubtile in 3:
#				for Ysubtile in 3:
#					oWallStuff.set_cell((x*3)+Xsubtile, (y*3)+Ysubtile, oWallStuff.EARTH_TILE)
#
#func erase_slab(x,y):
#	for Xsubtile in 3:
#		for Ysubtile in 3:
#			set_cell((x*3)+Xsubtile, (y*3)+Ysubtile, -1)
#			oRoomStuff.set_cell((x*3)+Xsubtile, (y*3)+Ysubtile, -1)
#			oWallStuff.set_cell((x*3)+Xsubtile, (y*3)+Ysubtile, -1)
#
#func is_subtile_middle(x,y,tileId):
#	if get_cell(x+3,y) != tileId: return false
#	if get_cell(x-3,y) != tileId: return false
#	if get_cell(x,y+3) != tileId: return false
#	if get_cell(x,y-3) != tileId: return false
#	if get_cell(x+3,y+3) != tileId: return false
#	if get_cell(x+3,y-3) != tileId: return false
#	if get_cell(x-3,y+3) != tileId: return false
#	if get_cell(x-3,y-3) != tileId: return false
#	return true
#
#func set_room_graphic(x,y,tile,autotile):
#	oRoomStuff.set_cell(x,y,tile,false,false,false,autotile)
#
#func is_subtile_edge(x,y,tileId):
#	if get_cell(x+1,y) != tileId: return true
#	if get_cell(x-1,y) != tileId: return true
#	if get_cell(x,y+1) != tileId: return true
#	if get_cell(x,y-1) != tileId: return true
#	if get_cell(x+1,y+1) != tileId: return true
#	if get_cell(x+1,y-1) != tileId: return true
#	if get_cell(x-1,y+1) != tileId: return true
#	if get_cell(x-1,y-1) != tileId: return true
#	return false
