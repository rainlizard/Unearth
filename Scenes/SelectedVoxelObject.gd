extends MeshInstance
onready var oVoxelObjectView = $"../../../.."
onready var oVoxelCameraPivotPoint = $"../../../VoxelCameraPivotPoint"
onready var oAllVoxelObjects = $"../../AllVoxelObjects"
onready var oSelectedPivotPoint = $".."
onready var oHighlightBase = $"../../HighlightBase"

var rotationSensitivity = 0.5

var clickedOnVoxelView = false
#event is InputEventMouseMotion and 
func _input(event):
	if oVoxelObjectView.visible == false: return
	
	if event.is_action_pressed("mouse_left"):
		if Rect2( oVoxelObjectView.rect_global_position, oVoxelObjectView.rect_size ).has_point(oVoxelObjectView.get_global_mouse_position()) == true:
			clickedOnVoxelView = true
	
	if event.is_action_released("mouse_left"):
		clickedOnVoxelView = false
	
	if event is InputEventMouseMotion and clickedOnVoxelView == true:
		oSelectedPivotPoint.rotation_degrees.y += event.relative.x * rotationSensitivity
		oVoxelCameraPivotPoint.rotation_degrees.z -= event.relative.y * rotationSensitivity
		oAllVoxelObjects.visible = false
		visible = true
		oHighlightBase.visible = false
