extends Camera
onready var oSlabColumnEditor = Nodelist.list["oSlabColumnEditor"]
onready var oCameraPivotPoint = Nodelist.list["oCameraPivotPoint"]

var rotationSensitivity = 0.5



func _input(event):
	if oSlabColumnEditor.visible == false: return
	
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left"):
		oCameraPivotPoint.rotation_degrees.y -= event.relative.x * rotationSensitivity
		#oCameraPivotPoint.rotation_degrees.y -= event.relative.x * rotationSensitivity
		#oCameraPivotPoint.rotation_degrees.x = clamp(oCameraPivotPoint.rotation_degrees.x - event.relative.y * rotationSensitivity, -90, 90)
