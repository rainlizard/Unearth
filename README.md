# Description

A map editor made for Dungeon Keeper 1 and KeeperFX, prioritizing ease of use and extending map editing capabilities. When running the editor, the game will be detected, maps will be browsable and playable using the 'Play' button. To see all editor controls check the Help menu.

You can set up file association on Windows with any of the map file types (.slb, .clm, .tng, etc) and the editor will open the map when you open the file in Windows. You can also drag a file into the editor window to open the map.

Report all bugs and feature requests to the [issues page](https://github.com/rainlizard/Unearth/issues).

# Installation instructions
Download the .zip from the [releases page](https://github.com/rainlizard/Unearth/releases), then extract the archive into the game directory.

If you extract somewhere other than the game directory, then Unearth will prompt you to locate the game executable.

For Linux: make the binary executable with `chmod +x Unearth.x86_64` after extracting.

# Development

To edit this project:
1. Clone this repository:
   - Command line: `git clone https://github.com/rainlizard/Unearth.git`
   - Or use [Github Desktop](https://desktop.github.com/)
2. Download [Godot 3.5.3](https://godotengine.org/download/archive/3.5.3-stable/) (4.0+ is unsupported)
3. Open the project in Godot, be aware that it may take a moment for the main scene to appear

If you submit a pull request, an automatic build will be generated for it.
