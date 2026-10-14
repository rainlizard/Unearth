extends Reference
class_name BasicScriptPatcher
# Edits single-line top-level DKScript commands and leaves everything else untouched.
# Every edit returns {"text": newText, "line": lineToHighlight}.

const COMMANDS = { # [argument count, identity argument count, group of lines it's inserted into]
	"LEVEL_VERSION": [1, 0, 0],
	"SET_GENERATE_SPEED": [1, 0, 1],
	"START_MONEY": [2, 1, 1],
	"MAX_CREATURES": [2, 1, 1],
	"COMPUTER_PLAYER": [2, 1, 2],
	"ADD_CREATURE_TO_POOL": [2, 1, 3],
	"CREATURE_AVAILABLE": [4, 2, 4],
	"ROOM_AVAILABLE": [4, 2, 5],
	"MAGIC_AVAILABLE": [4, 2, 6],
	"TRAP_AVAILABLE": [4, 2, 7],
	"DOOR_AVAILABLE": [4, 2, 8],
}

var order = {} # Ranks identity arguments, such as players and items, so new calls are inserted in order. Unranked ones go last.
var call_regex = RegEx.new()
var if_regex = RegEx.new()
var endif_regex = RegEx.new()


func _init():
	call_regex.compile("^[ \\t]*([A-Za-z_][A-Za-z0-9_]*)[ \\t]*\\(([^()]*)\\)")
	if_regex.compile("(?i)^[ \\t]*IF(_[A-Z0-9_]+)?[ \\t]*\\(")
	endif_regex.compile("(?i)^[ \\t]*ENDIF\\b")


# Only calls with the right argument count are kept, with uppercase arguments.
# error_line is the first unmatched IF/ENDIF line, or 0 when the script is valid.
func parse(source):
	var parsed = {"lines": [], "calls": [], "error_line": 0, "version": 0}
	var open_ifs = []
	var in_comment = false
	var start = 0
	for text in source.split("\n"):
		var line = {"number": parsed.lines.size() + 1, "start": start, "end": min(start + text.length() + 1, source.length()), "text": text.trim_suffix("\r"), "depth": open_ifs.size()}
		parsed.lines.append(line)
		start = line.end
		if in_comment or line.text.strip_edges().begins_with("/*"): # KeeperFX multiline comments
			in_comment = line.text.find("*/") < 0
			continue
		if endif_regex.search(line.text) != null:
			if open_ifs.empty() and parsed.error_line == 0:
				parsed.error_line = line.number
			open_ifs.pop_back()
			line.depth = open_ifs.size()
		var found = call_regex.search(line.text)
		var command = found.get_string(1).to_upper() if found != null else ""
		if COMMANDS.has(command) and found.get_string(2).count(",") == COMMANDS[command][0] - 1:
			var call = {"command": command, "args": [], "spans": [], "line": line}
			var offset = line.start + found.get_start(2)
			for raw in found.get_string(2).split(","):
				var leading = raw.length() - raw.strip_edges(true, false).length()
				call.args.append(raw.strip_edges().to_upper())
				call.spans.append([offset + leading, offset + leading + call.args.back().length()])
				offset += raw.length() + 1
			parsed.calls.append(call)
			if command == "LEVEL_VERSION": # KeeperFX preloads LEVEL_VERSION, even inside IF blocks
				parsed.version = int(call.args[0])
		if if_regex.search(line.text) != null:
			open_ifs.append(line.number)
	if parsed.error_line == 0 and open_ifs.empty() == false:
		parsed.error_line = open_ifs.back()
	return parsed


# Top-level calls whose leading arguments match identity.
func find(parsed, command, identity := []):
	var matches = []
	for call in parsed.calls:
		if call.command == command and call.line.depth == 0 and (identity.empty() or str(call.args.slice(0, identity.size() - 1)) == str(identity).to_upper()):
			matches.append(call)
	return matches


# Updates the value arguments of every matching call, or inserts the call in order within its group: before the first call that sorts after it,
# otherwise after the group, or after the nearest earlier group.
func set_call(source, command, args):
	var parsed = parse(source)
	var identity = args.duplicate()
	identity.resize(COMMANDS[command][1])
	var matches = find(parsed, command, identity)
	if matches.empty():
		var text = command + "(" + PoolStringArray(args).join(",") + ")"
		var key = sort_key(command, args)
		var group = COMMANDS[command][2]
		var at = 0 if command == "LEVEL_VERSION" else source.length()
		var newGroup = true
		for call in parsed.calls:
			var other = COMMANDS[call.command][2]
			if call.line.depth != 0 or other > group or (other < group and newGroup == false):
				continue
			if other == group and sort_key(call.command, call.args) > key:
				return insert(source, call.line.start, text, false)
			at = call.line.end
			newGroup = other < group
		return insert(source, at, text, newGroup)
	matches.invert() # Edited from the end, so earlier spans stay valid
	for call in matches:
		for i in range(args.size() - 1, identity.size() - 1, -1):
			source = source.substr(0, call.spans[i][0]) + str(args[i]) + source.substr(call.spans[i][1])
	return {"text": source, "line": matches.back().line.number}


# The command's place in COMMANDS, then its identity arguments ranked by order.
func sort_key(command, args):
	var key = "%02d" % COMMANDS.keys().find(command)
	for i in COMMANDS[command][1]:
		key += "%03d" % order.get(str(args[i]).to_upper(), 999)
	return key


func remove_call(source, command, identity):
	var matches = find(parse(source), command, identity)
	matches.invert()
	for call in matches:
		source = source.substr(0, call.line.start) + source.substr(call.line.end)
	return {"text": source, "line": 0}


# KeeperFX reads CREATURE_AVAILABLE differently from level version 1, so existing lines are converted as well.
func set_level_version(source):
	var parsed = parse(source)
	if parsed.version != 0:
		return {"text": source, "line": 0}
	parsed.calls.invert()
	for call in parsed.calls:
		if call.command == "CREATURE_AVAILABLE":
			source = source.substr(0, call.spans[2][0]) + call.args[3] + ",0" + source.substr(call.spans[3][1])
	return set_call(source, "LEVEL_VERSION", ["1"])


# Finds a multi-line block at top level, ignoring whitespace and case. Returns the [start, end] of each, along with the blank line insert() put before it.
func find_block(parsed, block):
	var found = []
	for i in parsed.lines.size() - block.size() + 1:
		var same = parsed.lines[i].depth == 0
		for j in block.size():
			same = same and squash(parsed.lines[i + j].text) == squash(block[j])
		if same:
			var first = parsed.lines[i - 1] if i > 0 and parsed.lines[i - 1].text.strip_edges() == "" else parsed.lines[i]
			found.append([first.start, parsed.lines[i + block.size() - 1].end])
	return found


# Adds the block at the end unless it's already there, or removes every copy of it.
func set_block(source, block, enabled):
	var found = find_block(parse(source), block)
	if enabled:
		return insert(source, source.length(), PoolStringArray(block).join("\n"), true) if found.empty() else {"text": source, "line": 0}
	found.invert()
	for span in found:
		source = source.substr(0, span[0]) + source.substr(span[1])
	return {"text": source, "line": 0}


func insert(source, at, text, new_group):
	var newline = "\r\n" if "\r\n" in source else "\n"
	var before = source.substr(0, at)
	var after = source.substr(at)
	if before != "" and before.ends_with("\n") == false:
		before += newline
	if new_group and before.strip_edges() != "" and before.ends_with(newline + newline) == false:
		before += newline
	return {"text": before + text.replace("\n", newline) + (newline if after != "" else "") + after, "line": before.count("\n") + 1}


func squash(text):
	return text.replace(" ", "").replace("\t", "").to_upper()
