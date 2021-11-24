extends Node
#onready var oTextures = $'..'
#
#var aaa = Thread.new()
#
#func start(files):
#	aaa.start(self, "loadimages", files, 2)
#
#func loadimages(files):
#	var tex = {}
#	for i in files.size():
#		var img = Image.new()
#		var imgTex = ImageTexture.new()
#
#		img.load(files[i])
#		imgTex.create_from_image(img, 0)
#
#		tex[files[i]] = imgTex
#	oTextures.call_deferred("done",tex)
