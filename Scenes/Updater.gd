extends Node
onready var oUiSystem = Nodelist.list["oUiSystem"]
onready var oEditor = Nodelist.list["oEditor"]

const LATEST_RELEASE_URL = "https://api.github.com/repos/rainlizard/Unearth/releases/latest"

# The script waits for Unearth to close, copies the extracted release over the install directory, then relaunches Unearth if asked to.
const PLATFORMS = {
	"Windows": {
		"asset": "-windows.zip",
		"shell": "powershell.exe",
		"args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File"],
		"file": "update.ps1",
		"script": """param($ProcessId, $Zip, $Install, $Relaunch)
Wait-Process -Id $ProcessId -ErrorAction SilentlyContinue
$Dir = Split-Path $Zip
Expand-Archive -LiteralPath $Zip -DestinationPath "$Dir/extracted" -Force
Copy-Item -Path "$Dir/extracted/unearth/*" -Destination $Install -Recurse -Force
Remove-Item -LiteralPath $Dir -Recurse -Force
if ($Relaunch -eq "1") { Start-Process -FilePath "$Install/unearth.exe" -WorkingDirectory $Install }
""",
	},
	"X11": {
		"asset": "-linux.zip",
		"shell": "sh",
		"args": [],
		"file": "update.sh",
		"script": """trap '' HUP
while kill -0 "$1" 2>/dev/null; do sleep 1; done
cd "$(dirname "$2")" && (unzip -oq "$2" || python3 -m zipfile -e "$2" .) && cp -rf unearth/. "$3/" && chmod +x "$3/unearth.x86_64"
rm -rf "$(dirname "$2")"
[ "$4" = 1 ] && cd "$3" && ./unearth.x86_64 >/dev/null 2>&1 &
""",
	},
}

var http = HTTPRequest.new()
var update_dir = Settings.unearth_path.plus_file("update")
var update_ready = false
var relaunch = false

func start(): # Called by Main after settings are read
	# Patch is only set by release builds, it stays 0000 when running from the Godot editor
	if Version.patch.to_int() == 0 or PLATFORMS.has(OS.get_name()) == false or Settings.get_setting("automatic_updates") == false:
		return
	add_child(http)
	http.connect("request_completed", self, "_on_latest_release_received", [], CONNECT_ONESHOT)
	http.request(LATEST_RELEASE_URL)


func _on_latest_release_received(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var release = parse_json(body.get_string_from_utf8())
	if typeof(release) != TYPE_DICTIONARY or release.get("tag_name", "").get_slice(".", 2).to_int() <= Version.patch.to_int():
		return
	for asset in release.get("assets", []):
		if asset["name"].ends_with(PLATFORMS[OS.get_name()]["asset"]):
			download_update(release["tag_name"], asset["browser_download_url"])
			return


func download_update(new_version, url): # Downloads in the background, the user is only asked once it's ready
	Directory.new().make_dir_recursive(update_dir)
	http.download_file = update_dir.plus_file("update.zip")
	http.connect("request_completed", self, "_on_update_downloaded", [new_version], CONNECT_ONESHOT)
	http.request(url)


func _on_update_downloaded(result, response_code, headers, body, new_version):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	update_ready = true
	var dialog = ConfirmationDialog.new()
	dialog.window_title = "New version available"
	dialog.dialog_text = "Unearth v" + new_version + " is ready to install."
	dialog.get_ok().text = "Restart & update"
	dialog.get_cancel().text = "Later"
	oUiSystem.add_child(dialog)
	dialog.connect("confirmed", self, "restart_to_update")
	Utils.popup_centered(dialog)
	dialog.connect("popup_hide", dialog, "queue_free")


func restart_to_update():
	# Goes through the normal quit flow so unsaved changes can still be saved. Set relaunch afterwards since the quit request clears it.
	oEditor.notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	relaunch = true


func _exit_tree(): # Unearth is closing, hand the downloaded update over to the install script
	if update_ready == false:
		return
	var platform = PLATFORMS[OS.get_name()]
	var script_path = update_dir.plus_file(platform["file"])
	var file = File.new()
	file.open(script_path, File.WRITE)
	file.store_string(platform["script"])
	file.close()
	OS.execute(platform["shell"], platform["args"] + [script_path, str(OS.get_process_id()), http.download_file, Settings.unearth_path, str(int(relaunch))], false)
