extends MeshInstance
onready var oVoxelObjectView = $"../../../.."
onready var oVoxelCameraPivotPoint = $"../../../VoxelCameraPivotPoint"
onready var oAllVoxelObjects = $"../../AllVoxelObjects"
onready var oSelectedPivotPoint = $".."
onready var oHighlightBase = $"../../HighlightBase"

var rotationSensitivity = 0.5

func _input(event):
	if oVoxelObjectView.visible == false: return
	if Rect2( oVoxelObjectView.rect_global_position, oVoxelObjectView.rect_size ).has_point(oVoxelObjectView.get_global_mouse_position()) == false: return
	
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_left"):
		oSelectedPivotPoint.rotation_degrees.y += event.relative.x * rotationSensitivity
		oVoxelCameraPivotPoint.rotation_degrees.z -= event.relative.y * rotationSensitivity
		oAllVoxelObjects.visible = false
		visible = true
		oHighlightBase.visible = false

#func _process(delta):
#	translation -= Vector3(0, 0, rotation.y*delta)
