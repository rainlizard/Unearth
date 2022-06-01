extends TabContainer
onready var oThingDetails = Nodelist.list["oThingDetails"]

func _on_PropertiesTabs_tab_changed(tab):
	oThingDetails.update_details()
