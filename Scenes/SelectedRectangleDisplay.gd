extends TextureRect

var boundToItem = null
var accumulated_time = 0.0

func _process(delta):
	accumulated_time += delta
	get_material().set_shader_param("custom_time", accumulated_time)
