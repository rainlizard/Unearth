extends WindowDialog

onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oUi = Nodelist.list["oUi"]
onready var oBackupList = Nodelist.list["oBackupList"]

var backupPaths = []


func get_backup_root():
	var backup_root = Settings.unearth_path
	if backup_root == "":
		backup_root = "."
	return backup_root.plus_file("backups")


func is_backup_path(file_path):
	var backup_root = ProjectSettings.globalize_path(get_backup_root()).replace("\\", "/").trim_suffix("/")
	var global_path = ProjectSettings.globalize_path(file_path).replace("\\", "/")
	return global_path.begins_with(backup_root + "/")


func open_window():
	populate_backup_list()
	Utils.popup_centered(self)


func _on_BackupList_item_activated(_index):
	load_selected_backup()


func _on_LoadBackup_pressed():
	load_selected_backup()


func _on_CloseBackup_pressed():
	hide()


func _on_visibility_changed():
	if is_instance_valid(oUi) == false:
		return
	if visible == true:
		oUi.hide_tools()
	else:
		oUi.show_tools()


func load_selected_backup():
	var selected = oBackupList.get_selected_items()
	if selected.empty() == true or selected[0] >= backupPaths.size():
		oMessage.quick("Select a backup to load.")
		return
	hide()
	oOpenMap.open_map(backupPaths[selected[0]], true, true, true)


func backup_existing_map_files(map_file_path):
	var base_directory = map_file_path.get_base_dir()
	var map_name_no_ext = map_file_path.get_file().get_basename()
	if base_directory == "" or map_name_no_ext == "":
		return true

	var dir = Directory.new()
	if dir.open(base_directory) != OK:
		print("Backup failed, could not access map directory: " + base_directory)
		return false

	var map_name_lower = map_name_no_ext.to_lower()
	var map_files = []
	var newest_modified_time = 0
	var file = File.new()
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() == false:
			var file_name_lower = file_name.to_lower()
			var belongs_to_map = file_name.get_basename().to_lower() == map_name_lower or file_name_lower.begins_with(map_name_lower + ".")
			if belongs_to_map == true:
				var source_path = base_directory.plus_file(file_name)
				if file.file_exists(source_path) == true:
					map_files.append(source_path)
					newest_modified_time = max(newest_modified_time, file.get_modified_time(source_path))
		file_name = dir.get_next()
	dir.list_dir_end()

	if map_files.empty() == true:
		return true

	var date = OS.get_datetime_from_unix_time(newest_modified_time)
	var folder_name = str(date["year"]).pad_zeros(4) + "-" + str(date["month"]).pad_zeros(2) + "-" + str(date["day"]).pad_zeros(2)
	folder_name += "-" + str(date["hour"]).pad_zeros(2) + "-" + str(date["minute"]).pad_zeros(2) + "-" + str(date["second"]).pad_zeros(2)
	var backup_root = get_backup_root()
	var backup_folder = backup_root.plus_file(folder_name)
	var backup_dir = Directory.new()
	var suffix = 2
	while backup_dir.dir_exists(backup_folder) == true:
		backup_folder = backup_root.plus_file(folder_name + " " + str(suffix))
		suffix += 1
	if backup_dir.make_dir_recursive(backup_folder) != OK:
		print("Backup failed, could not create: " + backup_folder)
		return false

	for source_path in map_files:
		var err = backup_dir.copy(source_path, backup_folder.plus_file(source_path.get_file()))
		if err != OK:
			print("Backup failed, could not copy: " + source_path + " Code: " + str(err))
			return false
	print("Backed up map files to: " + backup_folder)
	return true


func populate_backup_list():
	oBackupList.clear()
	backupPaths.clear()
	var backup_root = get_backup_root()
	var paths = []
	var dirs_to_check = [backup_root]
	var dir = Directory.new()
	while dirs_to_check.empty() == false:
		var current_dir = dirs_to_check.pop_back()
		if dir.open(current_dir) != OK:
			continue
		dir.list_dir_begin(true, false)
		var entry = dir.get_next()
		while entry != "":
			var full_path = current_dir.plus_file(entry)
			if dir.current_is_dir() == true:
				dirs_to_check.append(full_path)
			elif entry.get_extension().to_lower() == "slb":
				paths.append(full_path)
			entry = dir.get_next()
		dir.list_dir_end()
	paths.sort()
	paths.invert()
	for backup_path in paths:
		backupPaths.append(backup_path)
		var display_path = backup_path.trim_prefix(backup_root.plus_file(""))
		display_path = display_path.substr(0, display_path.length() - ".slb".length())
		oBackupList.add_item(display_path)
	if backupPaths.empty() == true:
		oBackupList.add_item("No backups found.")
