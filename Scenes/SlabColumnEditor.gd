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


func _on_VoxelTabs_tab_changed(tab):
	match tab:
		0:
			oSlabVoxelView.initialize()
		1:
			oPropertiesTabs.set_current_tab(2)
			oColumnVoxelView.initialize()
