extends WindowDialog
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oVoxelTabs = Nodelist.list["oVoxelTabs"]
onready var oColumnVoxelView = Nodelist.list["oColumnVoxelView"]
onready var oSlabVoxelView = Nodelist.list["oSlabVoxelView"]

func _ready():
	oVoxelTabs.set_tab_title(0, "Edit columns")
	oVoxelTabs.set_tab_title(1, "Add custom slab")

# When re-opening window or opening for first time
func _on_ColumnEditor_visibility_changed():
	if visible == true:
		_on_VoxelTabs_tab_changed(oVoxelTabs.current_tab)

func _on_VoxelTabs_tab_changed(tab):
	match tab:
		0:
			oSlabVoxelView.visible = false
			oColumnVoxelView.visible = true
			oColumnVoxelView.initialize()
			oPropertiesTabs.set_current_tab(2)
		1:
			oColumnVoxelView.visible = false
			oSlabVoxelView.visible = true
			oSlabVoxelView.initialize()
