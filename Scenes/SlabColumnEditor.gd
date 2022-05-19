extends WindowDialog
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oColumnEditorTabs = Nodelist.list["oColumnEditorTabs"]
onready var oColumnEditorVoxelView = Nodelist.list["oColumnEditorVoxelView"]
onready var oCustomSlabVoxelView = Nodelist.list["oCustomSlabVoxelView"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oAllVoxelObjects = Nodelist.list["oAllVoxelObjects"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oColumnEditorControls = Nodelist.list["oColumnEditorControls"]
onready var oConfirmClmClearUnused = Nodelist.list["oConfirmClmClearUnused"]

func _ready():
	oColumnEditorTabs.set_tab_title(0, "Name is set below")
	oColumnEditorTabs.set_tab_title(1, "Add custom slab")

# When re-opening window or opening for first time
func _on_ColumnEditor_visibility_changed():
	if visible == true:
		oDataClm.update_all_utilized() # Run this before _on_ColumnEditorTabs_tab_changed()
		# Update spinbox for currently viewed column
		oColumnEditorControls.oUtilizedSpinBox.value = oDataClm.utilized[oColumnEditorControls.oColumnIndexSpinBox.value]
		
		oColumnEditorTabs.set_tab_title(0, oCurrentMap.path.get_file().get_basename() + ".clm")
		_on_ColumnEditorTabs_tab_changed(oColumnEditorTabs.current_tab)
		
		

func _on_ColumnEditorTabs_tab_changed(tab):
	match tab:
		0:
			oCustomSlabVoxelView.visible = false
			oColumnEditorVoxelView.visible = true
			oColumnEditorVoxelView.initialize()
			oPropertiesTabs.set_current_tab(2)
		1:
			oColumnEditorVoxelView.visible = false
			oCustomSlabVoxelView.visible = true
			oCustomSlabVoxelView.initialize()

func _on_ColumnEditorHelpButton_pressed():
	var helptxt = ""
	helptxt += "Use middle mouse to zoom in and out, left click and drag to rotate view. You can use the arrow keys to switch between columns faster and also use arrow keys while a field's selected to navigate cubes faster." #Holding left click on a field's little arrows while moving the mouse up or down provides speedy navigation too.
	helptxt += '\n'
	helptxt += '\n'
	helptxt += "If your column has multiple gaps then some of the top/bottom cube faces may not display in-game."
	oMessage.big("Help",helptxt)


func _on_ColumnEditorClearUnusedButton_pressed():
	Utils.popup_centered(oConfirmClmClearUnused)


func _on_ConfirmClmClearUnused_confirmed():
	oDataClm.clear_unused_entries()


func _on_ColumnEditorSortButton_pressed():
	oDataClm.sort_columns_by_utilized()
