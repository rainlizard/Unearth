extends TileMap

#onready var oDataSlab = $'../../../ReadData/GridSlab'
#onready var oDataOwnership = $'../../../ReadData/GridOwnership'
#
#
#const WALL_TILE = 4
#const EARTH_TILE = 7
#
#var fadeWallGraphics = 0
#
#func fadeOut(delta):
#	fadeWallGraphics = lerp(fadeWallGraphics, 0.0, 4*delta)
#	modulate = Color( 1, 1, 1, fadeWallGraphics )
#func fadeIn(delta):
#	fadeWallGraphics = lerp(fadeWallGraphics, 1.0, 4*delta)
#	modulate = Color( 1, 1, 1, fadeWallGraphics )
