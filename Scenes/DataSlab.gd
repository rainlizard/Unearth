extends TileMap

#func _ready():
#	tileDrawDist = 96

func subtile2grid(x,y):
	return get_cell( int(x/3), int(y/3) )

#var IS_FLOOR = Slabs.IS_FLOOR
#var SLAB_TYPE = Slabs.SLAB_TYPE
#func is_touching_floor(x,y):
#	if Slabs.array[subtile2grid(x+1,y)][SLAB_TYPE] == IS_FLOOR: return true
#	if Slabs.array[subtile2grid(x-1,y)][SLAB_TYPE] == IS_FLOOR: return true
#	if Slabs.array[subtile2grid(x,y+1)][SLAB_TYPE] == IS_FLOOR: return true
#	if Slabs.array[subtile2grid(x,y-1)][SLAB_TYPE] == IS_FLOOR: return true
#	return false
