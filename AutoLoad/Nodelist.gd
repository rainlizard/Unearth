extends Node
var list = {}

func start(callingScene): #Called by Main
	Nodelist.list["oMain"] = callingScene # node_added signal doesn't include the root node, probably because it has no "owner"
	get_tree().connect("node_added",self,"node_added")

func done(): #Called by ViewportContainer
	get_tree().disconnect("node_added",self,"node_added")
	print('Nodes added to Nodelist: '+str(Nodelist.list.size()))

func node_added(nodeID):
	if nodeID.owner != null:
		Nodelist.list['o'+nodeID.name] = nodeID
