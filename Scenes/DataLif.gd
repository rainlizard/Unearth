extends Node

var data

func _ready():
	clear()

func clear():
	var dateDictionary = OS.get_date()
	
	var constructString = "Unnamed "
	constructString += str(dateDictionary["year"])+'.'+str(dateDictionary["month"])+'.'+str(dateDictionary["day"])
	constructString += " map"
	
	data = constructString
