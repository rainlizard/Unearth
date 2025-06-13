extends WindowDialog
onready var oChangelogMainVBox = Nodelist.list["oChangelogMainVBox"]
onready var scene = preload("res://Scenes/ChangelogSection.tscn")
onready var oGame = Nodelist.list["oGame"]

const txt = preload("res://changelog.gd").string

func _ready():
	# Wait for settings.gd to finish reading
	for i in 50:
		yield(get_tree(),'idle_frame')
	
	var CODETIME_START = OS.get_ticks_msec()
	var sections = parse_changelog_file()
	if sections.size() > 0:
		show_changelog_if_needed(sections)
	print('Changelog codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func parse_changelog_file():
	var sections = []
	var text = txt
	var current_version = ""
	var current_date = ""
	var current_body = PoolStringArray()
	var pos = 0
	var text_length = text.length()
	var line_start = 0
	var line_end = 0
	while pos < text_length:
		line_end = text.find("\n", pos)
		if line_end == -1:
			line_end = text_length
		var line = text.substr(line_start, line_end - line_start)
		if line.begins_with("-") == false and " - " in line:
			if current_version != "":
				sections.append({
					"version": current_version,
					"date": current_date,
					"body": current_body.join("\n")
				})
				current_body = PoolStringArray()
			var dash_pos = line.find(" - ")
			current_version = line.substr(0, dash_pos)
			current_date = line.substr(dash_pos + 3)
		elif line.begins_with("- "):
			current_body.append("• " + line.substr(2))
		pos = line_end + 1
		line_start = pos
	if current_version != "":
		sections.append({
			"version": current_version,
			"date": current_date,
			"body": current_body.join("\n")
		})
	return sections


func show_changelog_if_needed(sections):
	var last_displayed = Settings.get_setting("last_changelog_displayed")
	print("last_displayed: ", last_displayed)
	var current_version = sections[0]["version"]
	print("current_version: ", current_version)
	var should_display = true
	if oGame.EXECUTABLE_PATH == "":
		should_display = false
	if last_displayed == null:
		should_display = false
	if last_displayed == current_version:
		should_display = false
	if should_display == true:
		for section in sections:
			var section_node = scene.instance()
			oChangelogMainVBox.add_child(section_node)
			section_node.set_name_text(section.version)
			section_node.set_date_text(section.date)
			section_node.set_body_text(section.body)
		Utils.popup_centered(self)
	else:
		visible = false
	
	Settings.set_setting("last_changelog_displayed", current_version)


func _on_CloseButton_pressed():
	visible = false
