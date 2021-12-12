extends Node

#const sheetItemsX = 8
#const sheetItemsY = 68

enum {North, East, South, West, Top, Bottom}
var vertex = [0,1,2,3,4,5]
var normal = [0,1,2,3,4,5]
var uv = [0,1,2,3,4,5]
var blankArray = initalize_blank_array()

func _ready():
	vertices()
	normals()
	uvs()

func initalize_blank_array():
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_INDEX] = []
	array[Mesh.ARRAY_VERTEX] = []
	array[Mesh.ARRAY_TEX_UV] = []
	array[Mesh.ARRAY_TEX_UV2] = []
	array[Mesh.ARRAY_NORMAL] = []
	return array

func uvs():
	uv[North] = [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	]
	uv[South] = [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	]
	uv[East] = [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	]
	uv[West] = [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	]
	uv[Top] = [
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	]
	uv[Bottom] = [
		Vector2(1, 1),
		Vector2(0, 1),
		Vector2(0, 0),
		Vector2(1, 0),
	]

func vertices():
	vertex[North] = [
		Vector3(1, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 0, 0),
		Vector3(1, 0, 0),
	]
	vertex[South] = [
		Vector3(0, 1, 1),
		Vector3(1, 1, 1),
		Vector3(1, 0, 1),
		Vector3(0, 0, 1),
	]
	vertex[East] = [
		Vector3(1, 1, 1),
		Vector3(1, 1, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 1),
	]
	vertex[West] = [
		Vector3(0, 1, 0),
		Vector3(0, 1, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 0),
	]
	vertex[Top] = [
		Vector3(0, 1, 0),
		Vector3(1, 1, 0),
		Vector3(1, 1, 1),
		Vector3(0, 1, 1),
	]
	
	vertex[Bottom] = [
		Vector3(1, 0, 0),
		Vector3(0, 0, 0),
		Vector3(0, 0, 1),
		Vector3(1, 0, 1),
	]

func normals():
	normal[North] = [
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
	]
	normal[South] = [
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
	]
	normal[East] = [
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
	]
	normal[West] = [
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
	]
	normal[Top] = [
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
	]
	normal[Bottom] = [
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
	]



#func uniqueUvs():
#	var sheetItemsTotal = sheetItemsX*sheetItemsY
#	texUV.resize(sheetItemsTotal)
#	var sepX = (1.0/sheetItemsX)
#	var sepY = (1.0/sheetItemsY)
#	var i = 0
#	for y in sheetItemsY:
#		for x in sheetItemsX:
#			if i >= sheetItemsTotal:
#				break
#			var UVx1 = (x*sepX)
#			var UVx2 = ((x*sepX)+sepX)
#			var UVy1 = (y*sepY)
#			var UVy2 = ((y*sepY)+sepY)
#			texUV[i] = [
#				Vector2(UVx1, UVy1),
#				Vector2(UVx2, UVy1),
#				Vector2(UVx2, UVy2),
#				Vector2(UVx1, UVy2),
#			])
#			i += 1
