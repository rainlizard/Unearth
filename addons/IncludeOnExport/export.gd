tool
extends EditorExportPlugin

 # You could make these into project settings
var include_dirs = ["res://unearthdata/"]
var include_files = []

var output_root_dir

func _export_end():
	print("Unearth v" + Constants.VERSION)

func _export_begin(features, is_debug, path, flags):
	output_root_dir = path.get_base_dir()
	
	# Export all the PNGs in /object-images/
	for i in dir_contents("res://unearthdata/object-images/"):
		_export_file_our_way(i)

func _export_file(path, type, features):
	#print(path)
	for file in include_files:
		if path == file:
			_export_file_our_way(path)
			return
	for dir in include_dirs:
		
		dir = dir.rstrip("/")
		if path.begins_with(dir) and (len(path) == len(dir) || path[len(dir)] == "/"):
			_export_file_our_way(path)
			return

func _export_file_our_way(path):
	print('Included file: ' + path)
	
	skip() # This prevents Godot's Export from exporting this file, and instead we export using the code below

	# Copy to the output directory

	var rfile = File.new()
	rfile.open(path, File.READ)
	var buffer = rfile.get_buffer(rfile.get_len())
	rfile.close()

	var output_path = output_root_dir.plus_file(path.trim_prefix("res://"))
	var output_dir = output_path.get_base_dir()

	var dir = Directory.new()
	if not dir.dir_exists(output_dir):
		dir.make_dir_recursive(output_dir)

	var wfile = File.new()
	wfile.open(output_path, File.WRITE)
	wfile.store_buffer(buffer)
	wfile.close()


func dir_contents(path):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.get_extension().to_upper() == "PNG":
					array.append(path.plus_file(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return array
