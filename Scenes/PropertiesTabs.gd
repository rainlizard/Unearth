extends TabContainer

func _on_PropertiesTabs_tab_changed(tab):
	$ThingDetails.oThingListData.clear()
