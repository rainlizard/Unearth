extends Node2D
onready var oUi = Nodelist.list["oUi"]
onready var oEditor = Nodelist.list["oEditor"]

var ts = Constants.TILE_SIZE

var beginTile = Vector2()
var endTile = Vector2()

func _ready():
	visible = false

func set_initial_position(tilePos):
	tilePos.x = clamp(tilePos.x, oEditor.fieldBoundary.position.x, oEditor.fieldBoundary.end.x-1)
	tilePos.y = clamp(tilePos.y, oEditor.fieldBoundary.position.y, oEditor.fieldBoundary.end.y-1)
	
	visible = true
	beginTile = tilePos
	endTile = tilePos

func update_positions(tilePos):
	if visible == false: return
	tilePos.x = clamp(tilePos.x, oEditor.fieldBoundary.position.x, oEditor.fieldBoundary.end.x-1)
	tilePos.y = clamp(tilePos.y, oEditor.fieldBoundary.position.y, oEditor.fieldBoundary.end.y-1)
	
	endTile = tilePos

func _process(delta):
	update()

func _draw():
	var rect = Rect2(beginTile*ts, ((endTile*ts) - (beginTile*ts))+Vector2(1,1))
	
	if endTile.x >= beginTile.x:
		rect = rect.grow_individual(0,0,1*ts,0)
	else:
		rect = rect.grow_individual(-1*ts,0,0,0)
	
	if endTile.y >= beginTile.y:
		rect = rect.grow_individual(0,0,0,1*ts)
	else:
		rect = rect.grow_individual(0,-1*ts,0,0)
	
	draw_rect(rect,Color(1,1,1,0.25),true)

func clear():
	visible = false
