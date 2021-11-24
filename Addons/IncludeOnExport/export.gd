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
	# EditorExportPlugin function that tells it not to export the file
	skip()

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
