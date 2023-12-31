extends Node2D
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]

const a = preload("res://Shaders/MaterialInstanceOwnership.tres")
var materialInstanceOwnership = [
	a.duplicate(), # 0
	a.duplicate(), # 1
	a.duplicate(), # 2
	a.duplicate(), # 3
	a.duplicate(), # 4 
	a.duplicate(), # 5
	a.duplicate(), # 6
	a.duplicate(), # 7
	a.duplicate(), # 8
]

func _ready():
	#print(materialInstanceOwnership)
	for i in Constants.PLAYERS_COUNT:
		materialInstanceOwnership[i].set_shader_param("ownerCol", Constants.ownerRoomCol[i])
		materialInstanceOwnership[i].set_shader_param("alphaFilled", 0.5)

func _process(delta):
	for i in Constants.PLAYERS_COUNT: # 0 to 8
		materialInstanceOwnership[i].set_shader_param("fadeAlpha", 1.0-oOverheadOwnership.alphaFadeColor[i])
		if i == 5:
			materialInstanceOwnership[i].set_shader_param("ownerCol", Constants.ownerRoomCol[Random.choose([0,1,2,3])])
