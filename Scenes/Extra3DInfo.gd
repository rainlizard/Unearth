extends Label
onready var oPlayer = Nodelist.list["oPlayer"]
onready var oCamera3D = Nodelist.list["oCamera3D"]
onready var oHead = Nodelist.list["oHead"]

var displayInfo = true

func _ready():
	set_process(displayInfo)

func _process(delta):
	var cx = 'x '+str(oPlayer.translation.x)
	var cz = 'z '+str(oPlayer.translation.z)
	var cy = 'y '+str(oPlayer.translation.y)
	
	var textline1 = ''#'Draw distance : '+str(oCamera3D.far) + '\n'
	var textline2 = compass() + '\n'
	var textline3 = cx+'\n'
	var textline4 = cz+'\n'
	var textline5 = cy+'\n'
	var textline6 = ''
	var textline7 = ''#'Vertex attributes '+str(get_tree().get_root().get_render_info(Viewport.RENDER_INFO_VERTICES_IN_FRAME))+'\n'
	
	text = textline1+textline2+textline3+textline4+textline5+textline6+textline7

func compass():
	#print(oHead.rotation_degrees)
	var degrees = fposmod(oPlayer.rotation_degrees.y+180.0, 360.0)
	if degrees >= 45 and degrees < 135:
		return 'East'
	if degrees >= 135 and degrees < 225:
		return 'North'
	if degrees >= 225 and degrees < 315:
		return 'West'
	if degrees >= 315 or degrees < 45:
		return 'South'
