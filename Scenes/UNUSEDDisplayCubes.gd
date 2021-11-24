extends Control
#
#onready var texSheet = preload("res://Cubes/TMAPA003.bmp")
#const sheetItemsX = 8
#const sheetItemsY = 68
#var spr = []
#var face = []
#
#
#func _ready():
#	Cube.array[cubeID][side]
#	createSprites()
#	createFaces()
#
#	var index = 80
#
#	for i in 8:
#		# Convert index number to x y positions within sheet.
#		var y = index/sheetItemsX
#		var x = index-(y*sheetItemsX)
#
#		face[i].region = Rect2( x*32, y*32, 32, 32 )
#
#	for i in 8:
#		spr[i].texture = face[i]
#
#func createSprites():
#	for i in 8:
#		var newSprite = Sprite.new()
#		newSprite.position.y = i * 32
#		newSprite.centered = false
#		add_child(newSprite)
#		spr.append(newSprite)
#func createFaces():
#	for i in 8:
#		var newAtlas = AtlasTexture.new()
#		newAtlas.atlas = texSheet
#		face.append(newAtlas)
