extends Node2D

onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oGridDataCheckBox1 = Nodelist.list["oGridDataCheckBox1"]
onready var oGridDataCheckBox2 = Nodelist.list["oGridDataCheckBox2"]
onready var oGridDataCheckBox3 = Nodelist.list["oGridDataCheckBox3"]
onready var oGridDataCheckBox4 = Nodelist.list["oGridDataCheckBox4"]
onready var oGridDataCheckBox5 = Nodelist.list["oGridDataCheckBox5"]
onready var oGridDataCheckBox6 = Nodelist.list["oGridDataCheckBox6"]
onready var oGridDataCheckBox7 = Nodelist.list["oGridDataCheckBox7"]

onready var tilemap_data = {
	"Wibble": {
		"extension": ".wib",
		"node": oDataWibble
	},
	"Liquid": {
		"extension": ".wlb",
		"node": oDataLiquid
	},
	"Slab": {
		"extension": ".slb",
		"node": oDataSlab
	},
	"Ownership": {
		"extension": ".own",
		"node": oDataOwnership
	},
	"ColumnPositions": {
		"extension": ".dat",
		"node": oDataClmPos
	},
	"CustomSlabs": {
		"extension": ".une",
		"node": oDataCustomSlab
	},
	"Style": {
		"extension": ".slx",
		"node": oDataSlx
	}
}

var tileDrawDist = 96  # Example value, adjust as needed
var dynamic_font = DynamicFont.new()  # Initialize DynamicFont

func _ready():
	dynamic_font.font_data = preload("res://Theme/ClassicConsole.ttf")
	dynamic_font.size = 36
	
	oGridDataCheckBox1.connect("pressed", self, "_on_checkbox", ["Slab"])
	oGridDataCheckBox2.connect("pressed", self, "_on_checkbox", ["Ownership"])
	oGridDataCheckBox3.connect("pressed", self, "_on_checkbox", ["Column Positions"])
	oGridDataCheckBox4.connect("pressed", self, "_on_checkbox", ["Wibble"])
	oGridDataCheckBox5.connect("pressed", self, "_on_checkbox", ["Liquid"])
	oGridDataCheckBox6.connect("pressed", self, "_on_checkbox", ["Style"])
	oGridDataCheckBox7.connect("pressed", self, "_on_checkbox", ["Custom Slabs"])

func _on_checkbox(aaa):
	print(aaa)

func _draw():
	return
	if is_instance_valid(oDataWibble) == false: return
	
	var node = tilemap_data["Slab"]["node"]
	
	for x in range(M.xSize):
		for y in range(M.ySize):
			var value = node.get_cell(x,y)
			var string = str(value)
			var pos = Vector2(x * tileDrawDist, y * tileDrawDist) + Vector2(tileDrawDist * 0.5, tileDrawDist * 0.5)
			pos.x -= dynamic_font.get_string_size(string).x * 0.5 # Center string
			pos.y += dynamic_font.get_string_size(string).y * 0.25
			draw_string(dynamic_font, pos, string, Color(1, 1, 1, 1))
