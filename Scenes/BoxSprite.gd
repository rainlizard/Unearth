extends Sprite

onready var oCamera2D = Nodelist.list["oCamera2D"]
var accumulated_time = 0.0

func _process(delta):
	accumulated_time += delta
	get_material().set_shader_param("zoom", oCamera2D.zoom.x)
	get_material().set_shader_param("custom_time", accumulated_time)
