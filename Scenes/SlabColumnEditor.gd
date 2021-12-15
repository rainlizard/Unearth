extends WindowDialog
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oVoxelTabs = Nodelist.list["oVoxelTabs"]
onready var oColumnVoxelView = Nodelist.list["oColumnVoxelView"]
onready var oSlabVoxelView = Nodelist.list["oSlabVoxelView"]


func _ready():
	popup_centered()
	visible = false
	visible = true
	
	oVoxelTabs.set_tab_title(0, "Slabs")
	oVoxelTabs.set_tab_title(1, "Columns")
	
	yield(get_tree(),'idle_frame')
	_on_VoxelTabs_tab_changed(0)

func _on_VoxelTabs_tab_changed(tab):
	match tab:
		0:
			oColumnVoxelView.visible = false
			oSlabVoxelView.initialize()
			oSlabVoxelView.visible = true
		1:
			oPropertiesTabs.set_current_tab(2)
			oSlabVoxelView.visible = false
			oColumnVoxelView.initialize()
			oColumnVoxelView.visible = true
