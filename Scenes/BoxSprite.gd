extends Sprite

onready var oCamera2D = Nodelist.list["oCamera2D"]

func _process(delta):
	get_material().set_shader_param("zoom", oCamera2D.zoom.x)
