extends Control
#onready var oSelection = Nodelist.list["oSelection"]
#onready var oItemList = Nodelist.list["oItemList"]
#
#var currentlyLookingAtNode = null
#var instanceType = 0
#
#func _process(delta):
#
#	#var node = 
#
#	if node != null:
#		if currentlyLookingAtNode != node:
#			currentlyLookingAtNode = node
#
#			var description
#			oItemList.clear()
#			for i in node.data.size():
#				var byteNumber = str(i).pad_zeros(2)
##				match oSelection.get_instance_type(node.data):
##					oSelection.INSTANCE_THING: description = Thing.dataFieldName[i]
##					oSelection.INSTANCE_ACTIONPOINT: description = ActionPoint.dataFieldName[i]
#
#				oItemList.add_item(byteNumber + " : " + description + " : " + str(node.data[i]))
#	else:
#		currentlyLookingAtNode = null
#		oItemList.clear()
