extends Reference

const GdUnzip = preload("res://gdunzip/gdunzip.gd")

var zip_cache = {}
var active_zips = []
var file_checker = File.new()

func load_custom_sprite_zips(zip_paths):
	active_zips.clear()
	for zip_path in zip_paths:
		var zip_data = get_zip_data(zip_path)
		if zip_data != null:
			active_zips.append(zip_data)
	return active_zips.size()

func load_sprite_key(sprite_key, sprite_id):
	for index in range(active_zips.size() - 1, -1, -1):
		var zip_data = active_zips[index]
		if zip_data["sprites"].has(sprite_key):
			sprite_id[sprite_key] = zip_data["sprites"][sprite_key]
			return true
		var png_path = zip_data["sprite_paths"].get(sprite_key, "")
		if png_path == "":
			continue
		var texture = load_zip_png_texture(zip_data, png_path)
		if texture == null:
			continue
		zip_data["sprites"][sprite_key] = texture
		sprite_id[sprite_key] = texture
		return true
	return false

func get_zip_data(zip_path):
	if file_checker.file_exists(zip_path) == false:
		return null
	var modified_time = file_checker.get_modified_time(zip_path)
	if zip_cache.has(zip_path) and zip_cache[zip_path]["modified_time"] == modified_time:
		return zip_cache[zip_path]

	var zip = GdUnzip.new()
	if zip.load(zip_path) == false:
		print("Failed to load sprite zip: " + zip_path)
		return null

	var zip_data = {
		"modified_time": modified_time,
		"cache_dir": Settings.unearthdata.plus_file("sprite-zip-cache").plus_file(zip_path.to_lower().md5_text() + "_" + str(modified_time)),
		"zip": zip,
		"zip_files": {},
		"sprite_paths": {},
		"sprites": {},
	}
	for zip_file_name in zip.files.keys():
		zip_data["zip_files"][zip_file_name.replace("\\", "/").to_lower()] = zip_file_name

	for json_data in [["icons.json", ["file", "lowres"]], ["sprites.json", ["td", "fp"]]]:
		index_zip_json_textures(zip_data, zip_path, json_data[0], json_data[1])
	if zip_data["sprite_paths"].empty():
		for zip_file_name in zip.files.keys():
			if zip_file_name.to_lower().ends_with(".png"):
				zip_data["sprite_paths"][zip_file_name.get_file().get_basename().to_upper()] = zip_file_name
	if zip_data["sprite_paths"].empty():
		return null

	zip_cache[zip_path] = zip_data
	return zip_data

func index_zip_json_textures(zip_data, zip_path, json_file_name, image_keys):
	var actual_path = zip_data["zip_files"].get(json_file_name, "")
	if actual_path == "":
		return
	var bytes = zip_data["zip"].uncompress(actual_path)
	if not (bytes is PoolByteArray):
		return
	var result = JSON.parse(bytes.get_string_from_utf8())
	if result.error != OK:
		print("Failed to parse " + json_file_name + " in " + zip_path + ": " + result.error_string)
		return
	if not (result.result is Array):
		return

	for entry in result.result:
		if not (entry is Dictionary) or entry.has("name") == false:
			continue
		var png_path = ""
		for image_key in image_keys:
			png_path = get_first_png_path(entry.get(image_key, null))
			if png_path != "":
				break
		if png_path != "" and zip_data["zip_files"].has(png_path.replace("\\", "/").to_lower()):
			zip_data["sprite_paths"][str(entry["name"]).to_upper()] = png_path

func get_first_png_path(value):
	if value is String:
		return value if value.to_lower().ends_with(".png") else ""
	if value is Array:
		for item in value:
			var png_path = get_first_png_path(item)
			if png_path != "":
				return png_path
	elif value is Dictionary:
		if value.has("file"):
			var file_path = get_first_png_path(value["file"])
			if file_path != "":
				return file_path
		for key in value.keys():
			var png_path = get_first_png_path(value[key])
			if png_path != "":
				return png_path
	return ""

func load_zip_png_texture(zip_data, png_path):
	var actual_path = zip_data["zip_files"].get(png_path.replace("\\", "/").to_lower(), "")
	if actual_path == "":
		return null
	var image_path = zip_data["cache_dir"].plus_file(actual_path.md5_text() + ".png")
	var img = Image.new()
	var loaded = file_checker.file_exists(image_path) and img.load(image_path) == OK
	if loaded == false:
		var bytes = zip_data["zip"].uncompress(actual_path)
		if not (bytes is PoolByteArray):
			return null
		if img.load_png_from_buffer(bytes) != OK:
			return null
		img.convert(Image.FORMAT_RGBA8)
		var used_rect = img.get_used_rect()
		if used_rect.size.x > 0 and used_rect.size.y > 0:
			img = img.get_rect(used_rect)
		var dir = Directory.new()
		dir.make_dir_recursive(zip_data["cache_dir"])
		img.save_png(image_path)
	var texture = ImageTexture.new()
	texture.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
	return texture
