extends Node2D

func _ready():
	readSlabsOBJ_part1()
	readSlabsOBJ_part2()
	#readSlabsTNG()

func readSlabsOBJ_part1():
	var textFile = File.new()
	textFile.open("res://slabobj_part1.txt", File.WRITE)
	
	var file = File.new()
	var path = "res://unearthdata/slabs.obj"
	file.open(path, File.READ)
	
	file.seek(2)
	for i in 1176:
		if i % 28 == 0:
			textFile.store_line(str(i/28)+'-----------')
		var value = file.get_16()
		textFile.store_line(str(value))
		
	
	textFile.close()

func readSlabsOBJ_part2():
	var file = File.new()
	var path = "res://unearthdata/slabs.obj"
	file.open(path, File.READ)
	
	file.seek(0)
	var numberOfObj = file.get_16()
	print('Number of obj: ' + str(numberOfObj))
	
	var textFile = File.new()
	textFile.open("res://slabobj_part2.txt", File.WRITE)
	
	
	var dataList = 10
	
	numberOfObj = 250
	file.seek((42 * 28) * 2) # 2352
	for entry in numberOfObj:
		var byteArray = []
		byteArray.resize(dataList)
		for i in dataList:
			byteArray[i] = file.get_8()
		textFile.store_line(str(byteArray))
	
	textFile.close()


func readSlabsTNG():
	#var array = []
	var file = File.new()
	var path = "res://unearthdata/slabs.tng"
	file.open(path, File.READ)
	
	file.seek(0)
	var numberOfThings = file.get_16()+5
	print('Number of things: '+str(numberOfThings))
	
	var textFile = File.new()
	textFile.open("res://bytelist2.txt", File.WRITE)
	
	
	var dataList = 13
	
	file.seek(2 + (1304*2))
	for entry in numberOfThings:
		# Skip the first two bytes when seeking.
		#var pos = 2 + (entry * dataList)
		var byteArray = [0,0,0, 0,0,0,0,0, 0,0,0,0,0]
		for i in dataList:
			#file.seek(pos+i)
			byteArray[i] = file.get_8()
		#array.append(byteArray)
		textFile.store_line(str(byteArray))
	
	textFile.close()
	#save_text_file(str(array), "res://bytelist.txt")

func readSlabsCLM():
	var array = []
	var file = File.new()
	file.open("res://slabs.clm",File.READ)
	
	file.seek(0)
	var numberOfClmEntries = file.get_16()
	print('Number of clm entries: '+str(numberOfClmEntries))
	
	var dataList = 24
	for entry in numberOfClmEntries:
		var twentyFourByteArray = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0]
		var pos = 8 + (entry * dataList)
		for i in dataList:
			file.seek(pos+i)
			twentyFourByteArray[i] = file.get_8()
		
		array.append(twentyFourByteArray)
	
	save_text_file(str(array), "res://bytelist.txt")



func readSlabsDAT():
	var array = []
	var file = File.new()
	file.open("res://slabs.dat",File.READ)
	
	file.seek(0)
	var numberOfSets = file.get_16()
	print(numberOfSets)
	
	var dataList = 9
	for entry in numberOfSets:
		for i in dataList:
			file.seek(2 * (1 + (entry * dataList) + i))
			var value = 65536-file.get_16()
			array.append(value)
	
	save_text_file(str(array), "res://bytelist.txt")

func save_text_file(text, path):
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		printerr("Could not write file, error code ", err)
		return
	f.store_string(text)
	f.close()
