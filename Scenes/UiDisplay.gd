extends VBoxContainer

onready var oTextureRect = Nodelist.list["oTextureRect"]
onready var oLabel = Nodelist.list["oLabel"]
onready var oSelection = Nodelist.list["oSelection"]

#func _ready():
#	oTextureRect.texture = null

func set_instance_display(arrayData):
	pass
	#oUiSlabTile.set_cell(0,0,-1)
#	match oSelection.get_instance_type(arrayData):
#		oSelection.INSTANCE_THING: # Thing
#			oLabel.get("custom_styles/normal").bg_color = Constants.ownershipColors[arrayData[Things.OWNERSHIP]]
#			oLabel.text = Thing.thing_text(arrayData)
#			oTextureRect.texture = Thing.thing_portrait(arrayData)
#		oSelection.INSTANCE_ACTIONPOINT: # ActionPoint
#			oTextureRect.texture = null
#			oLabel.text = "Action Point"
#			oLabel.get("custom_styles/normal").bg_color = Constants.ownershipColors[5]

func set_slab_display(slabID, slabOwner):
	oLabel.text = Slabs.data[slabID][Slabs.NAME]
	oLabel.get("custom_styles/normal").bg_color = Constants.ownershipColors[slabOwner]
	
#	var slabPortraitTexture = Slabs.array[slabID][Slabs.PORTRAIT]
#	if slabPortraitTexture != null:
#		oTextureRect.texture = slabPortraitTexture
#	else:
#		oUiSlabTile.set_cell(0,0,Slabs.array[slabID][Slabs.GRAPHIC])
	
	oTextureRect.texture = null
