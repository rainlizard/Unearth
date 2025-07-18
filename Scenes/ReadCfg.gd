extends Node

func read_dkcfg_file(file_path: String) -> Dictionary:
	var config = {}
	var comments = {}
	var current_section = ""
	
	var file = File.new()
	if not file.file_exists(file_path):
		return {"config": config, "comments": comments}
	
	var start_time = OS.get_ticks_msec()
	
	if file.open(file_path, File.READ) != OK:
		return {"config": config, "comments": comments}
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	var pending_comments = []
	var filename = file_path.get_file()
	var is_rules_cfg = filename == "rules.cfg"
	
	for line in lines:
		var stripped = line.strip_edges()
		
		if stripped.empty():
			continue
		if stripped.begins_with(";"):
			pending_comments.append(stripped)
			continue
		
		if stripped.begins_with("["):
			current_section = stripped.substr(1, stripped.length() - 2)
			if is_rules_cfg and (current_section == "sacrifices" or current_section == "research"):
				config[current_section] = []
			else:
				config[current_section] = {}
			pending_comments.clear()
			continue
		
		var delimiter_pos = stripped.find("=")
		if delimiter_pos == -1:
			continue
		
		var key = stripped.substr(0, delimiter_pos).strip_edges()
		var value = stripped.substr(delimiter_pos + 1).strip_edges()
		
		if key == "Name":
			config[current_section][key] = value
		elif is_rules_cfg and current_section == "sacrifices":
			var items = value.split(" ")
			if items.size() > 1:
				var sacrifice_array = [key, items[0]]
				for i in range(1, items.size()):
					var item = items[i].strip_edges()
					if not item.empty():
						sacrifice_array.append(item)
				config[current_section].append(sacrifice_array)
		elif is_rules_cfg and current_section == "research":
			var items = value.split(" ")
			var filtered_items = []
			for item in items:
				var clean_item = item.strip_edges()
				if not clean_item.empty():
					filtered_items.append(clean_item)
			
			if filtered_items.size() >= 3:
				var research_array = [filtered_items[0], filtered_items[1]]
				research_array.append(int(filtered_items[2]) if filtered_items[2].is_valid_integer() else filtered_items[2])
				config[current_section].append(research_array)
		else:
			var items = value.split(" ")
			if items.size() > 1:
				var result = []
				for item in items:
					var clean_item = item.strip_edges()
					if not clean_item.empty():
						result.append(int(clean_item) if clean_item.is_valid_integer() else clean_item)
				config[current_section][key] = result
			else:
				config[current_section][key] = int(value) if value.is_valid_integer() else value
		
		if pending_comments.size() > 0:
			if not comments.has(current_section):
				comments[current_section] = {}
			comments[current_section][key] = pending_comments.duplicate()
			pending_comments.clear()
	
	var elapsed_time = OS.get_ticks_msec() - start_time
	print("Read " + filename + " dkcfg with comments in : " + str(elapsed_time) + "ms")
	
	return {"config": config, "comments": comments}
