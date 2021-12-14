extends Camera
onready var oSlabColumnEditor = Nodelist.list["oSlabColumnEditor"]
onready var oCameraPivotPoint = Nodelist.list["oCameraPivotPoint"]
onready var oCEViewportContainer = Nodelist.list["oCEViewportContainer"]

var rotationSensitivity = 0.5

func _input(event):
	if oSlabColumnEditor.visible == false: return
	if Rect2( oCEViewportContainer.rect_global_position, oCEViewportContainer.rect_size ).has_point(oSlabColumnEditor.get_global_mouse_position()) == false: return
	
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left"):
		oCameraPivotPoint.rotation_degrees.y -= event.relative.x * rotationSensitivity
		oCameraPivotPoint.rotation_degrees.z -= event.relative.y * rotationSensitivity
	
	if event.is_action_pressed("zoom_in"):
		size -= 3
		#translation.x += 1
	if event.is_action_pressed("zoom_out"):
		size += 3
		#translation.x -= 1
