tool
extends EditorExportPlugin

 # You could make these into project settings
var include_dirs = ["res://unearthdata/"]
var include_files = []

var output_root_dir
var theExportFeatures

func _export_begin(features, is_debug, export_path, flags):
	theExportFeatures = features
	output_root_dir = export_path.get_base_dir()
	
	# Export all the PNGs in /thing-images/
	for i in dir_contents("res://unearthdata/custom-object-images/"):
		_export_file_our_way(i)

func _export_end():
	print("Unearth v" + Constants.VERSION)
	
	if OS.get_name() == "Windows":
		zip_it_up(output_root_dir)

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

func zip_it_up(folder_to_zip_up):
	var createFileName
	if theExportFeatures.has("Windows") == true: # On 3.5, it's capitalized "Windows", on 4.0 it's lowercase "windows"
		createFileName = "Unearth v" + Constants.VERSION + ".zip"
	else:
		createFileName = "UnearthLinux v" + Constants.VERSION + ".zip"
	
	var output_zip_filepath = folder_to_zip_up.get_base_dir().plus_file(createFileName)
	
	# Create new zip file
	run_minizip(folder_to_zip_up, output_zip_filepath)
	
	# Delete the directory we zipped up
	#delete_files_and_folders(source_folder_path)
	
	# Open the directory of the zip file we created
	OS.shell_open(folder_to_zip_up.get_base_dir())

func run_minizip(folder_to_zip_up: String, output_zip_filepath: String):
	print("output_zip_filepath: " + output_zip_filepath)
	print("folder_to_zip_up: " + folder_to_zip_up)
	
    # Construct the command in parts for clarity
	var command = ""
	command += "cd /d \"" + folder_to_zip_up.get_base_dir() + "\""
	command += " && "
	command += ProjectSettings.globalize_path("res://addons/IncludeOnExport/minizip.exe") + " -o -i \"" + output_zip_filepath.get_base_dir().plus_file(output_zip_filepath.get_file()) + "\" \"" + folder_to_zip_up.get_file() + "\""
	print(command)
	
	var output = Array()
	var err_output = Array()
	var exit_code = OS.execute("cmd.exe", ["/C", command], true, output)

	if exit_code == 0:
		print("Minizip executed successfully")
		#print("Output: ", output)
	else:
		print("Minizip execution failed")
		#print("Error output: ", output)
