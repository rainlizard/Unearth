extends PanelContainer
onready var oUniversalListData = Nodelist.list["oUniversalListData"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oDataSlab = Nodelist.list["oDataSlab"]


var clmEntryCount = 0

func _process(delta):
	oUniversalListData.clear()
	oUniversalListData.add_item("Tile", str(oSelector.cursorTile).lstrip('(').rstrip(')'))
	
	oUniversalListData.add_item("Subtile", str(oSelector.cursorSubtile).lstrip('(').rstrip(')'))
	oUniversalListData.add_item("Clm entries", str(clmEntryCount)+' / ' + str(oDataClm.column_count))

func _on_TimerUpdateColumnEntries_timeout():
	var newCount = oDataClm.count_filled_clm_entries()
	var msg = ""
	if newCount > clmEntryCount:
		msg = str(abs(newCount-clmEntryCount)) + " Column entries added"
	if newCount < clmEntryCount:
		msg = str(abs(newCount-clmEntryCount)) + " Column entries removed"
	clmEntryCount = newCount
	
	if msg != "":
		oMessage.quick(msg)
