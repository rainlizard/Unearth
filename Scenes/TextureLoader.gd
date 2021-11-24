extends Node2D
#onready var oDataLevelStyle = $'../ReadData/GridLevelStyle'
#
##onready var oTextures = $'../Textures'
#
#var tileSetsArray = []
#
#var currentPack = ''
#
#func _ready():
#	get_all_tilesets(get_tree().get_root())
#	#print(tileSetsArray.size())
#
#func get_all_tilesets(parent):
#	for i in parent.get_children():
#		if i.get_child_count():
#			get_all_tilesets(i)
#		if i is TileMap: # Get TileSet that's inside of TileMap
#			#print(i.name)
#			if i.name != "UiSlabTile" and i.name != "CLMGraphics":
#				tileSetsArray.append(i.get_tileset())
#
#
#func update_tileset_paths():
#	var value = oDataLevelStyle.data
#	if value < 0 or value > 7: return
#	var newPack = "pack00" + str(value)
#	if currentPack == newPack: return
#
#	var CODETIME_START = OS.get_ticks_msec()
#
#	for tileSetID in tileSetsArray: # For each TileSet
#		for tileID in tileSetID.get_tiles_ids(): # For each tileID inside TileSet. (tileID do not neccessarily start from 0)
#			var tex = tileSetID.tile_get_texture(tileID)
#			var texturePath = tex.get_path()
#
#			# Allows files on hard drive to be swapped in, I think?
#			texturePath = texturePath.trim_prefix("res://") 
#
#			# Swap to new pack
#			texturePath = texturePath.replace(currentPack, newPack)
#
#			tileSetID.tile_set_texture(tileID, load(texturePath))
#
#			# When exported, the directory on hard disk must be /dk_images/
#			#if OS.has_feature("standalone") == true:
#			#	texturePath = texturePath.replace("dk_images_internal", "dk_images")
#			#if texturePath.begins_with("dk_images") == true:
#			#tileSetID.tile_set_texture(tileID, oTextures.tex[texturePath])
#
#	currentPack = newPack
#	print('Loaded style : ' + newPack)
#	print('Redirected tileset paths in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
