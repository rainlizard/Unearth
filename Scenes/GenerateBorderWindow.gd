extends WindowDialog
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oNoiseOctaves = Nodelist.list["oNoiseOctaves"]
onready var oNoisePeriod = Nodelist.list["oNoisePeriod"]
onready var oNoisePersistence = Nodelist.list["oNoisePersistence"]
onready var oNoiseLacunarity = Nodelist.list["oNoiseLacunarity"]

var noise = OpenSimplexNoise.new()

func _ready():
	popup_centered()


func _process(delta):
	if visible == false: return
	
	noise.octaves = oNoiseOctaves.value
	noise.period = oNoisePeriod.value
	noise.persistence = oNoisePersistence.value
	noise.lacunarity = oNoiseLacunarity.value

func _on_NoiseButtonApply_pressed():
	# Clear previous
	for x in range(1, 84):
		for y in range(1, 84):
			oDataSlab.set_cell(x,y, Slabs.EARTH)
	
	randomize()
	noise.seed = randi()
	
	var fullMapSize = 84.0 #84.0
	var halfMapSize = fullMapSize * 0.5
	var mapCenter = Vector2(halfMapSize,halfMapSize) # this -0.5 makes the edges even somehow.
	
	for x in range(1, 84):
		for y in range(1, 84):
			var edgeDistPercent = 1.0 - (max(abs(x-mapCenter.x), abs(y-mapCenter.y)) / halfMapSize)
			if abs(noise.get_noise_2d(x/fullMapSize, y/fullMapSize)) >= edgeDistPercent:
				oDataSlab.set_cell(x,y, Slabs.ROCK)
	
	oSlabPlacement.generate_slabs_based_on_id(Vector2(0,0), Vector2(84,84), true)
