extends Node
onready var oReadData = Nodelist.list["oReadData"]

var data

func _ready():
	clear()

func clear():
	var dateDictionary = OS.get_date()
	
	var constructString = "Unnamed "
	constructString += str(dateDictionary["year"])+'.'+str(dateDictionary["month"])+'.'+str(dateDictionary["day"])
	constructString += " map"
	
	data = constructString


func lif_name_text(pathString):
	var buffer = Filetypes.file_path_to_buffer(pathString)
	var array = oReadData.lif_buffer_to_array(buffer)
	var mapName = oReadData.lif_array_to_map_name(array)
	return mapName


func get_special_lif_text(pathString): # Uses the path only as a string rather than reading it as a file
	
	var PATH_UPPERCASE = pathString.to_upper()
	# No lif name found, so check dklevels.lof and ddisk1.lif
	var readSpecial = ""
	if "KEEPORIG" in PATH_UPPERCASE or "ORIGPLUS" in PATH_UPPERCASE:
		readSpecial = Settings.unearthdata.plus_file("dklevels.lof")
	elif "DEEPDNGN" in PATH_UPPERCASE:
		readSpecial = Settings.unearthdata.plus_file("ddisk1.lif")

	if readSpecial != "":
		var buffer = Filetypes.file_path_to_buffer(readSpecial)
		var lifArray = oReadData.lif_buffer_to_array(buffer)
		
		if lifArray.empty() == false:
			var mapNumber = PATH_UPPERCASE.get_file().trim_prefix("MAP")
			for line in lifArray.size():
				if mapNumber == lifArray[line][0].pad_zeros(5):
					return lifArray[line][1]
	return ""
