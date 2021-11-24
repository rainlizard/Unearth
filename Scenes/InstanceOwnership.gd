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
]

func _ready():
	#print(materialInstanceOwnership)
	for i in 6:
		materialInstanceOwnership[i].set_shader_param("ownerCol", Constants.ownershipColors[i])
		materialInstanceOwnership[i].set_shader_param("alphaFilled", 0.5)

func _process(delta):
	for i in 6: # 0 to 5
		materialInstanceOwnership[i].set_shader_param("fadeAlpha", 1.0-oOverheadOwnership.alphaFadeColor[i])
		if i == 5:
			materialInstanceOwnership[i].set_shader_param("ownerCol", Constants.ownershipColors[Random.choose([0,1,2,3])])
