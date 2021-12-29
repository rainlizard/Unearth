extends WindowDialog
onready var oDynamicSlabVoxelView = Nodelist.list["oDynamicSlabVoxelView"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 2:
		yield(get_tree(),'idle_frame')
	Utils.popup_centered(self)
	
	oDynamicSlabVoxelView.initialize()
