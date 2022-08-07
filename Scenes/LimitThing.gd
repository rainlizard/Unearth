extends GridContainer
onready var oSelection = Nodelist.list["oSelection"]

func _process(delta):
	var thingType = oSelection.paintThingType
	var subtype = oSelection.paintSubtype
	visible = true
	var limit = 0
	var typeName = ""
	var groupName = ""
	match thingType:
		#Things.TYPE.NONE:
		#	visible = false
		Things.TYPE.OBJECT:
			typeName = "Things"
			groupName = "Thing"
			limit = Things.THING_LIMIT
		Things.TYPE.CREATURE:
			typeName = "Creatures"
			groupName = "Creature"
			limit = Things.CREATURE_LIMIT
		Things.TYPE.EFFECT:
			typeName = "Things"
			groupName = "Thing"
			limit = Things.THING_LIMIT
		Things.TYPE.TRAP:
			typeName = "Things"
			groupName = "Thing"
			limit = Things.THING_LIMIT
		Things.TYPE.DOOR:
			typeName = "Things"
			groupName = "Thing"
			limit = Things.THING_LIMIT
		Things.TYPE.EXTRA:
			match subtype:
				1:
					typeName = "Action points"
					groupName = "ActionPoint"
					limit = Things.ACTION_POINT_LIMIT
				2:
					typeName = "Lights"
					groupName = "Light"
					limit = Things.LIGHT_LIMIT
		_:
			visible = false
	
	var count = get_tree().get_nodes_in_group(groupName).size()
	$LimitThingName.text = typeName
	$LimitThingNumber.modulate = Color(1,1,1) # Always show as white for lights
	
	if limit == -1: # For Lights, since I don't know what their limit is, don't show it
		$LimitThingNumber.text = str(count)
	else:
		$LimitThingNumber.text = str(count) + " / " + str(limit)
		if count > limit:
			$LimitThingNumber.modulate = Color(1,0.15,0.15)
