extends Node

const string = """
<version> - <date>
- Fixed 'Edit tilesets' window
0.61.811 - 26/7/2025
- All custom specials now have access to the CustomBox field
- Fixed loading classic format
- Fixed loading campaign CFGs
0.60.804 - 24/7/2025
- Attempt to auto-detect keeperfx.exe or keeper.exe in current folder and parent folder
- Added link to keeperfx.net/workshop in File menu
- Fix herogate numbers missing in Classic format
- Slightly more accurate herogate shader
- Fixed issues with subwindows breaking when the main window is resized too small
- Fixed neutral creatures not flashing on map load, slowed down flashing
- Lowercase folder and executable
0.59.789 - 9/7/2025
- Respect desired windows size/position
- Fixed some default window positioning
- Fixed an issue where non-keeperfx installations were crashing on opening/new maps
- Removed dernc.exe executable and added a gdscript implementation of the algorithm
- Improved RNC decompression confirmation window
0.58.784 - 6/7/2025
- Editing Slabset or Columnset will now instantly update slabs on the map to use those new columns
- Auto save map0000*.slabset.toml and map0000*.columnset.toml files when you save your map (if they've been modified)
- In Slabset window, flash all affected columns on the map
- In Properties window's Column tab, when you click on the map the Slabset window will automatically open and go to that column
- Slabset window title changes depending on whether you have local or campaign file open and displays "No saved file" status
- Added preference "Show CLM data tab" which is disabled by default
- Added list of modified Columnset IDs in the Columnset window
- Slabs are placed 40% faster
- Some small optimizations to overhead 2D graphics
- Mark map as edited when modifying slabset/columnset
- Added reserved columnset space and slabset space for future default keeperfx additions (if you already have custom column/slab IDs within this space, then you need to move them out)
- When you run out of clm entries, directly ask if the user wants to "Clear unused"
- Calculate a column's Height and Lintel fields automatically, like how Solid mask is auto calculated
- Slabset window's "Near water" & "Near lava" text replaced with "Room face variation" on certain slabIDs like LAIR_WALL
- In overhead 2D view, always display highest cube of a column (previously it was relying on the "height" value which led to confusion)
- Fixed an issue where viewing certain Slabset variations would cause them to be marked as modified
- Disable editing column 0
- Display 'Columnset' and 'Variation' in Properties 'Column' tab
- Small UI theme adjustments
- Slabset window size & position stored in settings, defaults to being a smaller window on the side
- Fixed an issue where shaders would sometimes go dark
- If the Slabset window is open, their textures will now be updated when switching tileset
- Better detection for when windows are offscreen
- 'Go to unused' button now works in 'Classic format'
- Fixed Things going dark on map when viewed in Slabset window
- For slabset.toml only export the variations that were altered, instead of all 28 variations
- Fixed a slabset bug where lights were incorrectly marking the variation as modified
- Moved column editor's 'Utilized' to advanced section
- Removed ColumnsCount and [common] header from exported columnset.toml
0.57.742 - 19/6/2025
- Added Changelog window
- New map window: added player placement
- New map window: added pizza symmetry option
- Fixed visual artifacts in 3D view
- Added SSAA setting to Preferences -> Graphics
- 3D view starts at current 2D position
- Lintel is calculated for columns, fixing a bug where portals had a hole in them in the in-game map view. (if you still have this bug you'll need to click 'Clear unused' in the column editor)
- Fake slabs: Changed "Slab ID" text to "Masquerade as"
- Spam protection for duplicate messages
- Fixed some console errors (potentially solves a crash)
- Fixed 'failed to load objects' error
0.56.725 - 8/6/2025
- TmapB tilesets can now be edited
- Refactored texture editing code
- Fixed UI bug with drop-menu click-through
- Added Help menu item: 'Report bugs & submit suggestions'
0.55.714 - 31/5/2025
- Fixed slab styles
0.55.712 - 31/5/2025
- Massive texture loading refactor, TextureMaps (tmapa000.dat files) now open with your map.
- TextureMap files are read more directly and now load in only a few milliseconds each! The indexed palette rendering was offloaded to the shaders
- Mipmaps aren't compatible with the new shader code so 2x2 SSAA was added to help mitigate the new aliasing issues and MSAA defaults to x8
- External texture maps for Tileset selection and Slab style selection have more informative names
- Big updates to the Config files window which now displays all relevant files
- Implemented tabbing to next UI element
- Possibly less latency when dragging windows
- Fixed bugged symmetrical placement, fixed locked door symmetry, added warning messages for obstructions
- Slabset editor now displays which slab IDs have been edited
- How the Slabset editor checks which slabs exist has been changed
- Fixed a Slabset editor bug where viewing an object could change its position and mark it as "changed"
- Custom bridges are now possible
- Objects get an arrow showing their orientation, "arrow scale" and "arrow max zoom" have been added to Preferences->Camera
- Slightly better flames and hero gates transparency
- Added ScriptHelper icons to map: SET_DOOR, PLACE_DOOR, PLACE_TRAP, ADD_OBJECT_TO_LEVEL_AT_POS
- Fixed a longstanding bug where if you right-clicked a creature/object, any values that were 0 would not be "grabbed"
- The default UI scale is now set relative to the user's resolution
- Small adjustment to the default lua script
- Various code refactoring
0.54.679 - 14/5/2025
- Updated some warning messages
0.54.676 - 11/5/2025
- Fixed everything not being clickable
0.54.675 - 10/5/2025
- Fixed script UI for unsaved maps
0.54.674 - 10/5/2025
- New script management, you now must click a button to explicitly create txt/lua files
- When you press the script delete button they'll only be removed when you save the map
- View -> Script file will decide which file to open based on which files are available. A prompt will appear if both files are available.
- Tabs removed from Map Settings, Script Editor and Script Generator now have their own windows
- Save Map code refactored
- Added default lua file text
- Top menu (File,Edit,View,etc) will now display over the top of other windows
0.53.670 - 5/5/2025
- Fixed a bug where you'd lose external edits to your script if you pressed Undo in Unearth
- Edit->Undo also no longer affects scripts at all. The internal script editor handles its own Undo states.
- Blank .lua files are created on save
- .lua files are monitored and loaded into memory as you edit them. Doing Save As will copy the lua file data to your new directory.
- If the .lua file is not blank, then you won't get the error about your map having no script.
0.52.662 - 10/2/2025
- Fixed Herogates breaking when pressing 'Undo'
0.52.661 - 09/2/2025
- Merged Spatulade's PR: "Update timebomb.png"
- Dense Gold tests
0.51.655 - 30/1/2025
- Merged Spatulade's PR: "added gfx for new keeper spells"
- Linked up spellbook icons and some code refactoring
- Fixed Unearth not working on non-keeperfx
0.51.649 - 28/1/2025
- Read full byte of .slx to handle more slab styles
- Loobinex PR merged: Added Midas door icon
- Loobinex PR merged: Hero gates and spellbooks dynamically filled
- Darkened Bedrock to distinguish from Impenetrable (editor only)
- Added string names for Midas Door and its workshop box
- Refactored slab display code in slab window
- Refactored object code to internally use GENRE
- Load effects.toml as an included file (such as map00001.effects.toml file, or campaign file)
- Load textureanim.toml as an included file
- Texture animations correctly read from textureanim.toml
0.50.631 - 30/7/2024
- Column count set correctly for Classic Format
0.50.630 - 30/7/2024
- Wall Torch: don't pick torch side that is facing towards room
- Column Editor's 'Sort' function updated to always put blank columns at the end
- Fixed being unable to remove fake slabs by right-clicking on them in Slab Window
- Column count increased to 8192
- Fixed manually placed torches attaching to correct wall (if you have floating torches you will need to replace them)
0.49.624 - 4/6/2024
- Fixed .exe details
- Increased stability by adjusting how the column graphics are generated
- Reduce FPS when window unfocused
- Added Secret Door sprite and fixed a bug which messed up some image offsets
- Slabset: Fixed 'Save slabset'
- Slabset: Fixed Rotate button, objects were being incorrectly rotated before
- Slabset: Billboard sprites now shown in the voxel view
- Slabset: Added path links to the slabset.toml files
- Slabset: Added blue highlight to spinboxes for SlabID and Variation that have been edited
- Slabset: When saving, the default filename will be map00001.slabset.toml (same with columnsets)
- Slabset: When saving, display a message list of the Slab IDs that were saved
- Slabset: Disable certain buttons while they're unusable
- Slabset: Copy and paste buttons are now separate, added revert button for Slab IDs
- Slabset: Added 'Delete & revert' button to delete the map00001.slabset.toml file
- Slabset: ThingType now sticks to either Objects (1) or Effectgens (7), since the other ThingTypes seem to have no effect
- Slabset: Up and Down keys now change Slab ID (Left and Right change variation)
- Slabset: Fixed a crash
0.48.601 - 29/5/2024
- Fixed all issues with .cfg fallbacks (campaign objects weren't loading unless they had certain fields like 'Genre')
- Removed all code related to custom_objects.cfg
- cubes.cfg loading refactor
0.48.599 - 28/5/2024
- Added 'Creature stats' to 'View'
- Added 'Config files' to 'View'
- Reading terrain.cfg new slabs and doors correctly
- Some slab code refactoring
- You can now click on the Slab name text in the Properties window to see its terrain.cfg name ("Impenetrable Rock" changes to "HARD")
- Removed 'Slabset slabs' from Add slab window, because they're automatically loaded in from your terrain.cfg file now
- Slab window's 'Custom slabs' tab renamed to 'Fake slabs'
- Help text updated in slabset editor
- Import button removed from slabset editor, 'Export' renamed to 'Save'
- slabset.toml, columnset.toml and cubes.cfg are loaded in automatically just like the other config files, so they're read from fxdata directory, campaign directory and local map directory
- Fixed an Undo crash
0.47.582 - 21/5/2024
- Fixed loading images from /unearthdata/custom-object-images/
- Fixed Tileset Editing real-time reloading
- Simplified Tileset Editing
- Right clicking on an object will grab all of its values for the 'Create' tab
0.46.580 - 17/5/2024
- Fixed camera movement lag
- Fixed ownership drop-down (inspector) list incorrectly containing extra players in Classic Format
- Refactored objects system
- Object config files will be loaded from /fxdata/, campaign, and local map (map00001.objects.cfg)
- 'Add Custom Object' window has been removed
- Added extra ID/Name entry to Properties window
- Font size adjusted in Properties window for long words
- Added another error message when attempting to use a non-existent tileset
0.45.563 - 2/5/2024
- Fixed a texture caching issue (new player textures appearing as black)
- Window title UI colours for new players
0.45.561 - 1/5/2024
- Merged qqluqq's additional players feature and tmapb support
- Improved speed of tileset caching
- Fixed 'Use slab ownership' checkbox incorrectly showing up in slab mode
- Put a panel grid around Thing and Ownership icons
0.44.531 - 28/4/2024
- On the map coordinates selector window, input is fixed so you can single-click instead of click & drag
- LOF Map Settings adjustments
- Bottom of Thing window draggable again
- ESC no longer attempts to close program
- Fixed circumstances where a wall torch and door would overlap
- 'Use slab ownership' defaults to checked
- Clicking ownership icon now unchecks 'Use slab ownership'
- Collectibles (Spells, Boxes, Specials, Gold) have their ownership automatically set when placing them or when updating nearby slabs
- Action Point list now has its own window in 'View'
- Fixed the ordering of action points so that it's always in order
- Added Hero Gates to Action Point list
- Script marker added for IF_SLAB_TYPE coords
- Undo added
- Optimized writing speed
- Refactored reading and writing buffers
- Multi-threaded undo state saving (but not loading)
- Multi-threaded column graphics in editor (for the initial load)
- Removed 'unknown data' setting
- Added Ctrl+S save shortcut
- When dragging an instance over UI, reset its position
- Mirrored ownership-only adjustments respect 'Ownable natural terrain'
- Fixed Fill on fortified walls
- Added symmetry guidelines setting
- Resize Map now updates every slab on the map, this solves some issues
- You can no longer use blank columns in fake slabs, this prevents an issue where new columns get indexed onto the blank columns being used by the fake slab
0.43.500 - 5/4/2024
- Fixed trying to open a file like "map12002_backup2.txt" instead of "map12002.txt"
- Give more detailed error when Clm entries are full
- Changed the way column height is calculated
- When you use the 'reload map' button, keep the camera and zoom position
- When adjusting slab ownership (in ownership tab of Slab Window) this will now adjust the ownership of things on the slabs as well
- When stacking effects or objects on the same subtile in the Slabset editor, Unearth will place all of them now instead of only one of them
- Retrieve keeperfx executable file version with powershell on windows and exiftool on linux
- Added Action Point list to make it easier to find Action Points
- Improved LOF fields in Map Settings, including a landview coordinates selector
- Fixed Treasury Hoard text to match the values in the latest KeeperFX alpha
- Script markers fixed for QUICK_INFORMATION_WITH_POS and QUICK_OBJECTIVE_WITH_POS
0.42.485 - 27/3/2024
- Added 'KeeperFX file format reference' to help menu
- Fixed Map size not being capped to 170 if enable border was unchecked
- By default enabled some 'rounded corners near liquid' preferences
- Support selecting keeperfx_hvlog.exe
- Added some tooltips to column editor. Hid orientation as it's not used.
- When painting with ownership (in Ownership tab of Slab window), obey the rules of 'Ownable Natural Terrain' setting
- Added a warning message when placing a Door Thing without a Door Slab
- Prevent 'Place door as locked' from affecting nearby doors
- Map browser now expands /levels/ and /campgns/ folders by default
- Removed map browser's ugly font
- Only show exit prompt when map has unsaved changes
- Enter/Y/N keys now work in confirmation dialogs
- Show the map browser after selecting the exe
- Allow bridges to have their ownership replaced when 'only build bridges on liquid' is enabled
- Suppress duplicate confirmation dialog warnings
- Fix Lantern Post offset
- Prevent mouse edge panning when drawing/clicking
- Updated script commands link
- Make 'Door locked' a checkbox instead of a drop down
0.41.472 - 19/3/2024
- Fixed prisons placing prison bars in incorrect places
- Fixed bug when manually typing a Thing's Position in a non-square map
0.41.426 - 10/12/2023
- slabset.cfg renamed to slabset.toml and columnset.cfg renamed to columnset.toml
If you've created these files, you'll need to rename them for the latest alpha patch of keeperfx to be able to recognize them.
0.40.424 - 6/12/2023
- Always save script files (attempt at stopping a rare issue where the script file isn't saved)
- Fixed Export Preview sometimes not working. Also changed its default preset.
0.40.412 - 4/12/2023
- Stop walls from forcefully updating as much (Note: Fortify must be unchecked)
0.40.410 - 3/12/2023
- Slabset improvements
- 'Add Custom Slab' improvements, can now add Slabset Slab
- Lots of refactoring to Slab placements and the Slabset system
- Added Edit->Resize map
- Added View->Grid data
- Added File->Export preview
- Column Editor improvements
- Fixed right-clicking not always grabbing new ownership
- When Add Custom Slab window is open, don't hijack the Properties Column tab
- Fortify checkbox now remembers its state after closing and reopening Unearth
- Fortify no longer fortifies natural terrain when Ownable Natural Terrain is checked
- Added confirmation box when removing custom slabs
- Brighter selection in Thing/Slab Window
- When dragging an object, set map as edited (displays 'Save & Play')
- You can no longer drag an object in Slab mode
- Mirrored placements respect 'Place things anywhere' checkbox
- Big rewrite to how Torch Slabs are handled
- Torch Slabs moved from Other tab to Main tab
- Automatic torch slabs checkbox added to Placement settings
- Creature Orientation removed for being useless
- Impenetrable Rock is no longer selected by default when you first open a map
- Attached lights now correctly spawn (Library wall, Prison wall and Workshop wall, possibly others)
- Lights now display their "Attached to" field (ParentTile)
- .lgtfx file format now uses ParentTile field
- Help button icon added
- Fixed bug when manually typing in a Thing's Position on a non-square map, it would always clamp position to the width of the map and never the height
- Deselect inspected instances when opening map browser
- Fixed message spam when adjusting ranges with mousewheel while holding alt
- Style numbers no longer stay when switching to thing-mode
- Use correct sprites for Treasury Gold variants
- Edited UI for Map Settings
- Removed checkbox for editing level overview file
- Fixed error message popup about old keeperfx version
- Fixed custom creature level being tiny if it had no creature sprite
- Added 'Place Path stones' percent to Placement settings
- Merged some sprite adjustments and custom object images
- Fixed casted sight anim displaying for Ensign, Room Flag, Power Lightning
0.39 - 14/10/2023
- Fixed an archiving issue that broke downloads on keeperfx.net
- Map Browser opens on startup
0.38g - 2/10/2023
- Fixed a long standing  issue where all slabs got marked as Unknown: 65535 when saving an old map
0.38f - 16/9/2023
- When dragging an object from one height to another, adjust its Z position correctly
0.38e - 15/9/2023
- More Properties issues fixed
0.38d - 15/9/2023
- Fixed Properties adjustments (you were unable to set Creature Level)
0.38c - 14/9/2023
- Adjust range of currently inspected object with Alt + Mouse wheel instead
- When dragging from a stack, the currently inspected object will be dragged. So you can press shift to choose the specific object you want to drag out of the stack.
- Fixed place overlapping (Ctrl+click)
0.38b - 14/9/2023
- Action points and Lights can now always be placed anywhere, excluded from the 'Place things anywhere' setting
0.38 - 14/9/2023
- Big maps have been re-enabled. Be sure to update to the latest alpha patch from keeperfx.net
- Prevent crash and provide a warning if you try to start a new map without the correct DK executable selected
- 'Frail columns' setting divided up into its various rules and disabled by default
- Max brush size increased
- Pressing Enter in Save As window no longer skips the autofill
- Stop showing popup warning about KeeperFX version if it's a compiled/debug version
- Don't allow opening map settings when no map is loaded
- Added 'Place things anywhere' setting in Preferences->Placements. When unchecked you cannot place things on columns with a height of 5 or higher
- In browse maps, maps of all sizes now display correctly and a border was added
- Added some images into the custom-object-images folder
- Move placed things by mouse dragging
- 'Fill' tool optimized
- While holding Alt, with an inspected object, scroll the mouse wheel to adjust range on Action Points, Lights and EffectGens
0.37b - 23/7/2023
- Right-clicking on natural terrain won't change the currently selected ownership (as long as 'Ownable Natural Terrain' is unchecked)
- Only fortify diagonal walls if there's a directional wall (N/S/E/W wall) that is fortified
- Added Fortify checkbox
0.37 - 19/7/2023
- Walls are now fortified by default. Place Earth to remove fortified walls.
- Fixed spinning keys being invisible in KFX format
- Fixed keys being misplaced too high above doors
- 'Kind' is now a dropdown when editing LOF in Map settings
- Wait 0.25 seconds after focusing window before registering mouse clicks on the field
- Added tier-4 Treasury Gold sprite to match KeeperFX
- Removed blur filter from animated sprites
- Fixed 'Health %' showing in Column tab
0.36 - 3/7/2023
- Fixed creatures sometimes not displaying the new fields when switching between map formats in Map Settings
- Gold Pile values now use correct defaults when switching between map formats
- Fixed creature names becoming uppercase
- Possibly fixed neutral creatures not flashing
- Map preview distinguishes editor background from Impenetrable
- Clicking 'Delete' button in UI with mouse will make the editor consider the map as edited (and prompt with 'Save and Play')
- Pressing shift to cycle will now also auto-select the subtile
- Fixed crash when using Fill tool on outside the boundaries of the map
- Image to Map error messages improved and a crash fixed
- 'Clear unused' will update all Utilized values first for better accuracy
- Display error when failing to write files. For example, saving in /Program Files/ will no longer fail silently.
- Fixed default Map Browser buttons
- Opening a map will now always set its name correctly for /deepdngn/ and /keeporig/ maps
- Do not display keeperfx version error if map format is set to Classic
- New map window will default to Classic format selection if your keeperfx version is old
- Fixed the display of creature names that were pulled from creature.cfg: Bug -> Beetle, Sorcerer -> Warlock, Horny -> Horned Reaper, Demonspawn -> Demon Spawn, Dwarfa -> Dwarf
0.35c - 20/5/2023
- Uncapped Gold held and Gold value from 255
- Fixed Orientation so it applies to more object types
- Gold value now sets its value based on the gold pile you're placing
0.35b - 20/5/2023
- Fixed the version check requirement to require alpha 3372
- Show unparsable error message if .tngfx, .lgtfx or .aptfx fail to load
- Swapped Play and Edit in Map browser
- Fixed a map-breaking KFX file format bug where creature names were not being saved correctly
0.35 - 20/5/2023
- In Properties window renamed object "Name" to "ID"
- Increased vertical spacing for the listed fields in Properties window
- KeeperFX version detected and displayed in Preferences
- The 'Create' tab remembers more fields
- Prevent deselection when changing Door locked state to the value it already was
- Added CreatureGold for Creatures, "Gold held" for short
- Added Orientation for Objects, EffectGens, Traps and Creatures
- Added CreatureInitialHealth, "Health %" for short
- Added CreatureName, "Name" for short
- Added GoldValue for gold pile objects
- Whether these new object fields are visible depends on the map's current format
- Removed the version note from "New map" window
- KeeperFX version check will provide a warning message if your KFX Formatted Map is not playable in KeeperFX
- Disabled editing map size until the game-breaking pathfinding bug is fixed. (middle click on it if you really need to edit it)
- When you left click on the map size field you get a message about the pathfinding bug
- Added new Druid images
- Fixed "Editable borders" setting
- 'NAME_TEXT' field in lof file is correctly set
0.34 - 24/3/2023
- Fixed replacing doors with other doors and the locked state
- Manually deleting a key will now change the door's locked state as well
- Overlapping things are now kept symmetrically in sync when removed
- Custom slab symmetry placements no longer update surroundings, like the original
- Doors no longer update surroundings, as it messes up keys of nearby doors
0.33d - 24/3/2023
- View 'Log file' menu item added
0.33c - 21/3/2023
- Show error message instead of crashing when starting new map without setting the executable
- Show message about requiring latest KeeperFX alpha on new map window
0.33b - 11/3/2023
- Default to KFX format if running KeeperFX
- Warning changed to quick message: "For KFX format to function correctly you may need the latest KeeperFX alpha"
- Max map size set to 170x170
0.33 - 11/3/2023
- Laterite Cavern tileset named (download latest KeeperFX alpha to use)
- 'Dungeon style' and 'Texture maps' renamed to 'Tileset' and 'Cached tileset'
- When writing a number into a spinbox, the caret cursor is moved to the end of the field instead of the beginning
- The /unearthdata/custom-object-images/ folder works differently now, added a readme.txt in there for a full explanation but basically you set the .png filenames to the object names
- Custom images included inside /custom-object-images/ folder
- Removed image field from 'Add custom object' window, added shortcut button to /custom-object-images/ folder
- New creatures loaded from creature.cfg
- New objects that use an existing AnimationID will use the existing image
0.32c - 13/2/2023
- Preferences->'Play button arguments' no longer stretches out the window
- Renamed Performance tab back to Graphics
- Allow Map settings and Play button to be hovered
0.32b - 13/2/2023
- Fixed some menu items being disabled (greyed out) when they shouldn't be
0.32 - 13/2/2023
- [do not use] text is now next to KeeperFX Format option
- Texture Editing: Fixed a bug which broke autoreloading of Texture Editing depending on image editor used. If it didn't work for you before, it should now
- Texture Editing: Display bright purple for any colours that are not part of the DK palette
- Texture Editing: Autoreloading is now less laggy, but it does take a little longer to initialize now
- Texture Editing: Automatically change your map's current Dungeon Style to show what you're currently editing
- Rearranged menus, most notably 'Map Settings' has taken the place of 'Settings', which has been renamed to 'Preferences' and moved under 'File'
- Some adjustments to menu theme
- Include -nocd by default in command line
- Added setting 'Open map settings for new map' in Preferences -> UI
- Hide the brush highlight in same situations as Selector graphic
0.31d - 10/2/2023
- Linux version can save maps again
0.31c - 5/2/2023
- Fixed visual glitch where slab IDs were sometimes read as -1
0.31b - 26/1/2023
- Fixed a crash when using the map browser
0.31 - 23/1/2023
- Symmetry: changing a Thing's ownership using the drop-down menu will change it correctly for the other Things too
- Pencil and brush size won't change at the same time when pressing the number keys
- Fixed a crash when alt-tabbing back into editor while no map is loaded
- Allow Play button in Map Browser to work while no map is loaded
- Random chance to place Dripping Water and Lava effect while placing lava and water, set in 'Placement options'
- Display pencil and brush highlight
- Rectangle tool (and brush) highlight effect changed to be multiplicative
- Display fill icon on cursor tile while Fill is selected
- Fixed issue that prevented using Tab key to switch between Thing and Slab mode
- Update brush size faster as you type the number into the field
0.30b - 20/1/2023
- Symmetry: ownership that's not present in the symmetry UI colours will not be changed when placed
- Symmetry: swap other two colours as well when placing an opposing colour in opposing area
- Remove arrow key adjustments to Brush Size (can conflict a little with panning the map)
0.30 - 20/1/2023
- Symmetry: allow main ownership selection to be changed and prioritize placing with it
- Symmetry: place opposing ownership when placing within the opposite area
- Symmetry: right click to cycle backwards through the symmetry colours UI
- Symmetry: style placement now symmetrical
- Symmetry: thing objects now symmetrical
- Loading bar visual updates based on actual PC speed
- Prevent some inputs while loading bar is visible
- Heroes/white colour is now actually white instead of the beige colour you see in-game, to differentiate from Yellow player more
- Fix text looking faded in script generator
- Custom slabs respect ownership selection
- When using brush size and creature level shortcut keys there's now a little flash to the field that changed
0.29 - 14/1/2023
- Keyboard shortcut for brush size should work more often now
- Generate border is now a checkbox
- Fixed a border preview display bug
- You can now click the border preview to randomize its seed
- Symmetrical border feature
- Old format renamed to Classic format
- No more deleting .LOF files
- Map settings: Prevent editing .LOF fields while in Classic format
- Added Distance slider to border generation
- Added Tapered checkbox to border generation, stops tunnels from looking like spikes
0.28 - 13/1/2023
- Added Brush tool
- Brush and pencil size adjustable by number keys [0-9]
- Added Symmetry feature for slab placement
- Hide object counts while in slab mode
- Paint bucket can no longer affect the border (unless you have editable borders on)
0.27c - 10/1/2023
- Disallow editing map size in old format
- Removed a flicker when clicking map size fields
0.27b - 8/1/2023
- Warn about KeeperFX format being unusable
- Fix default filename of Save As dialog
0.27 - 7/1/2023
- WORST BUG IN THE HISTORY OF BUGS: Save As was broken, sorry about this one!
- Fixed Things displaying over the top of quick map preview in map browser
- Added Play and Edit tabs to Map Browser
- Hide map spoilers for Play tab's map preview
- Added "Play random map" button to Map browser
0.26b - 6/1/2023
- Fixed Save As "File exists, overwrite" message
- Set file format correctly when loading a map
0.26 - 6/1/2023
- Map file format added
- "Effect" renamed to "EffectGen" for keeperfx to read it correctly from .tngfx
- Added MAP_FORMAT_VERSION to .lof, this can hopefully help with fixing any format issues in the future
- When saving, delete files that are not of the correct format (.TNG and .TNGFX won't exist side by side)
- View map size in Map Settings (still only editable for New Map though)
- 'Creating a new campaign' github link added to Help menu
- Help menu now disables links based on whether KeeperFX is detected
- Map browser now specifically scans /levels/ and /campgns/ directories for increased speed
- Map browser can now read map name from .lof
- 'Use slab ownership' tooltip
- Brush size added
- Added Paint bucket tool
- When placing Door slabs you can now initially set them as locked
- If Thing has no image, then display its name
- Reduced white diamond size
- Play button shows error when attempting to play a map with KeeperFX format without the keeperfx.exe executable
- Settings menu now tells you whether KeeperFX was detected (based on executable chosen)
- Save As dialog now tells you which directory your map will be playable from
- Save As dialog sets default filename to the next available map number in the directory
- Remove remembering last directory a file was saved to, instead use /levels/personal/ or the currently opened map's directory if it's already been saved
- Fixed map names not being detected in Recent
0.25 - 30/12/2022
- Fixed a crash when opening a new map while a currently opened map had too many Things in it
- Read and write .lof files
- Support for custom map sizes (NOTE: currently under heavy development)
- Adjusted 1st person start position to be 0x,0y
- Fixed 'Show camera coordinates' setting
- Fixed small tooltip display bug
- More map settings, related to .lof
- Dungeon Style now a drop down menu
- Controls menu neater, creature levels shortcut [0-9] documented
- 'Browse' reads MAPSIZE from the browsed map's .lof file
- Autoload some Thing entries from /fxdata/ and campaigns .cfg files
- Read and write .tngfx .aptfx .lgtfx files
- Adjustments to 'Load image as map'
- Disable some editor features if you do not select keeperfx.exe when prompted for game executable
- Loading bar when adding mass slabs and also when creating New map
0.24c - 07/8/2022
- Fixed manually placed torches floating in the air after you dig their slab. The downside is that in the editor they're no longer labelled as "Manually placed" but I don't think there's much to do about that without a dedicated solution. Manually placed torches also disappear easily when updating nearby slabs - so keep in mind that you'll want to place them last.
- Fixed possible crash when reading cubes.cfg
- Added sliders to settings menu
- Adjusting ui scale is safer
- Settings window now has a minimum size
- Added font size setting for both general editor and script editor
- When 'Use slab ownership' is checked hide the little blue rectangle selection of current owner colour
- Properties: in Create tab, display Thing limit, Action point limit or Creature limit depending on what you're placing
- Added help guide to custom object window
- In column editor help, mention not to edit column index 0
- Fixed Duplicate column button's tooltip
0.24b - 08/8/2022
- Bugfix to how the Thing limit is counted and count Lights separately
0.24c - 09/8/2022
- Fixed all cubes being purple for DOS version of Dungeon Keeper
0.23c - 14/7/2022
- In column editor and slabset editor you can now set cube values beyond 510
0.23b - 12/7/2022
- Load cubes from /fxdata/cubes.cfg, if you don't have KeeperFX the standard cube set will be loaded instead
- Any changes made to cubes.cfg are now reflected in the editor in real-time
0.23 - 11/7/2022
- Properties window: Thing & Placing renamed to Inspect & Create
- Properties window: Keyboard keys 0-9 can be used as a shortcut to set creature level
- Properties window: Level field will no longer always set itself to 10 when writing a number in it
- Rewrote Frail Columns stuff
- 1st person 3D view: pressing spacebar toggles mouse capture instead of switching to overhead view. This should make texture editing easier.
- Texture Editing window: show Export button as disabled instead of hiding it. Slightly changed text explanation.
- Map Settings: dungeon style list now includes filename of tmapa file
- Map Settings: dungeon style list refreshes if it's already open while you're altering files
- Placement options: hid Damaged Wall stuff, it's even less functional since I rewrote some code a few versions back
0.22 - 10/7/2022
- Column index 0 will no longer be used, it was causing a map breaking bug where door columns would turn into impenetrable columns after they've been opened too many times. If column index 0 is detected to contain anything columns will now be moved/sorted to apply the fix (upon opening your map).
- Column editor: Sort button now preserves column index 0
- Thing window: Moved 'Workshop Item' to Misc tab
- Trap & door boxes now show the object inside of them as an alpha overlay
- Don't show tooltip box while choosing DK executable
- Added animations for various objects
0.21b - 2/6/2022
- Column editor: fixed duplicate button
0.21 - 2/6/2022
- Fixed 'Save & Play' button so that it can say 'Play' again (maps were being incorrectly marked as having been edited)
- Properties window: fixed fields not being editable in Thing tab
- Properties window: use spinboxes for setting some values in Thing tab
- Properties window: update values instantly while typing them
- Column editor: hide spinbox arrows for Utilized field
- When placing a slab directly on a Thing, don't select it
- Custom slabs: right clicking on the map while the custom slab menu is open will copy column index numbers into the window
0.20 - 28/5/2022
- Placing door slabs now correctly updates door Thing ownership
- 'Treasury Gold 5 (2000)' correctly renamed to 'Treasury Gold 5 (2400)'
- Texture map 12 named as 'Lava Cavern' (it's a tileset file included with latest KeeperFX)
- Stray Door & Key Thing objects will be removed if they're not on door slabs
- Gold ownership is updated to be the same as treasury ownership if on a treasury slab
- If you delete a thing by pressing Delete key, allow placing on that same tile without needing to move the cursor off of it
- Reduced lag for dragging some windows around
- New map: now has preview
- Script editor: remove all zero-width-spaces
- Script editor: the first state of the text editor's undo history will now be the text of the loaded script (bugfix)
- Map Browser: fixed highlighting currently opened map text and scrolling to it when reopening map browser
- Map Browser: the currently opened map will no longer show quick map preview (thought this was already implemented but I guess I forgot)
- Map browser: clicking Open button will now close the map browser. Double clicking on a map's text name will still keep the map browser open.
- Open recent: trim game directory from path to make it look nicer
- Open recent: add maps to the recent list upon being saved, in addition to when they're opened
- Added cube names for Column Editor and Properties column tab, they are read from DK's /fxdata/cubes.cfg if this file exists
- Properties: fixed a bug where the selected Thing would sometimes not show its status
- Properties: added a 'Placing tips' button in placing tab, its purpose is to drill into you any unintuitive controls and then get out of the way (disappears permanently)
- Column editor: for a more user friendly UI Cube 0 is now renamed to Cube 1, and so on
- Column editor: added tooltips for cube names and floor textures when hovering cursor over values
- Column editor: added 'Show all' checkbox, these values you don't need to change yourself are now hidden by default
0.19 - 21/5/2022
- Open recent: menu now clickable without opening another map
- Added buttons for exporting slabset cfg and column cfg (useless for now but might come in handy one day)
- Open recent: map name now displayed next to path
- Open recent: don't put blank_map in recently opened list
- Add custom object: now supports images
- blank_map.txt included in /unearthdata/ (fixes a potential issue)
- Script editor: lose focus when clicking outside and don't allow keyboard camera panning if Script editor has focus
- Possible bugfix: Ensure any files being removed are definitely files and never directories
- When placing 'Floor' slabs, things that were previously on the slab will be no longer be deleted. Placing a Solid/Tall slab will still delete things.
- Things will update their Z position based on their slab height when editing surrounding slabs. This fixes a bug where if a Thing was placed on top of a Library bookcase and then the Library was slightly shrunk so that the bookcase disappears, the Thing's Z position wasn't updating in that circumstance.
- Use room colours instead of floor colours for ownership shader
- Prevent placing something on map when clicking to close a menu
- Browse maps: prevent keyboard camera panning if browser is open
- Browse maps: display quick map preview when selecting a map with single-click (or use keyboard)
- Properties window: action points won't display Z field anymore
- Properties window: 'Attached to' now includes slab name and field value 'None' has been renamed to 'Manually placed'
- When manually placing Things their 'Attached to' value is now always set to 'Manually placed'
- Added Slabset column editor
- Column editor tab name reflects .clm file name
- Mouse panning: reduced pan zone, made pan zone the same for all sides, continue panning when not moving cursor (it felt clunky)
- Mouse panning: stop panning when cursor is outside window. This makes panning in windowed mode difficult - might revert this.
- Added shortcut button to each column field to instantly open column editor to that column index
- Added Duplicate button to column editor
- Added 'Use for custom slab' button to slabs.dat editor
- Added Utilized field to column editor, made it non-editable
- Update all Utilized values whenever opening the column editor
- WASD now uses Physical Key positions on keyboard for the sake of alternate keyboard layouts
- Refresh script lines markers whenever manually adding or deleting an action point
- Big adjustments to how Unearth internally handles columns. Instead of fully packing a map's .clm file upon opening it, entries are now added to the .clm file only when they're needed. (so whenever you place a slab)
- Rewritten the way columns are built and indexed, might be a little slower but it's much more flexible like this
- If script file has been externally modified then reload it when the Unearth window becomes focused (possibly fixes a bug)
- Don't resave script file (.txt) if it hasn't been edited in unearth
- Placement options: added 'Frail impenetrable' and 'Frail solo slabs' settings. These were both adjustments made by Unearth so if you disable them then you'll be placing unchanged/default slabs from the slabset.
- Added 'Clear unused' button which deletes all columns which aren't utilized on the map
- Added 'Sort columns' button which sorts columns by their utilized value. Changes their index on the map too.
- New map: blank_map.clm has been edited to only provide the columns needed. The columns have been sorted too.
- Right-clicking on icons in Thing picker window now only removes them if they're custom objects
- Properties window: 'Clm entries' updates more often
- Added 'Export slabs.clm' button to Slabset column editor
0.18 - 06/5/2022
- Slightly zoomed out the slab/column viewer by default
- Renamed some menus
- When opening maps that have no .WLB file (such as level 10 of original campaign), generate a correct WLB file on save
- Treasury Gold is now locked to center of slabs in order to always be functional
- Added gold count to Treasury Gold's name
- Adjusted text in Thing selection window to be 2 lines at most
- Load image as map: Help text moved to window
- "/" will now always be used instead of "\" in filepaths. Just cosmetic.
- New map: added an option to generate a border based on noise
- slabs.dat/slabs.clm/slabs.tng are now loaded directly from DK directory. Copies will no longer be kept in /unearthdata/.
- Slabset: slab ID 42 and above actually have 8 variations, not 4. (the second 4 are just purple)
- Slabset: can now edit slabs
- Slabset: can now export slabs.dat
0.17 - 30/1/2022
- Fixed an issue where a wall near water and room would create an incorrect column (in sync with the KeeperFX fix)
- Fixed editor window sometimes becoming unclosable after pressing Play button
- Script generator: Removed White AI checkbox (useless)
- Script generator: Research order spinbox steps increased to 100
- Script generator: 'Send to clipboard' button added
- Script generator: Research order now draggable by holding left click (instead of clicking)
- Added 'Open recent' menu
- Script helpers: Ignore lines that begin with 'REM'
- Script helpers: Added functions that use 'location' as an argument
- Script helpers: Merge helpers if they overlap the same position
- Adjusted LineEdit theme for more space
- Properties: Position now editable
- Read and write .UNE files to keep track of custom slabs
- Right-click eye-dropper now works with custom slabs
- Custom slab name is displayed in Properties window
- Fixed editor window being potentially remembered off screen
- Fixed Slab/Thing window position going off screen when changing UI scale
- Added Framerate limit setting
- Slab ownership tab: Fixed an issue where slabs weren't being updated when changing ownership
- Slab ownership tab: Change ownership of spellbooks too
- Add custom object: Code improved to better recognize which IDs you've removed
- Add custom object: Custom objects now stored inside of custom_objects.cfg instead of settings.cfg (you'll have to re-add anything you've added before, sorry)
- Add custom slab: Cleaned up custom slabs config format (again, you'll have to recreate)
- Add custom slab: Renamed unearthcustomslabs.cfg to custom_slabs.cfg
0.16 - 8/1/2022
- 'Add new' button added to Custom Slabs tab
- Fixed the write permissions error not popping up
- When pressing Play button, prevent pressing again for a few seconds and display "Launching..." quick message
- When hovering mouse over tabs, use a custom tooltip instead of changing tab title
- Fixed arrow keys not working in text fields
- In the column editor, speed up the camera shift movement when changing the index value by a lot
- Added Research Order to Script Generator
- Texture 11 "Swamp Serpent" named
- Added scripting links to Help menu
- Updated 'About' section with hyperlinks, included Github
- 'Unrecognized Slab ID' renamed to 'Unknown' (too long for UI)
- Use buffers when reading files from /unearthdata/
- Added 'Modify dynamic slabs' to Edit menu. However it's only a viewer at the moment.
- Added script icons throughout the map for script commands which have coordinates as arguments
- Fixed a crash when opening maps that have custom objects
- When texture maps can't be loaded, error message now also instructs to reopen the map
- Slab and column editor's tabs renamed to: "Add custom slab" and "Edit columns"
0.15 - 23/12/2021
- Rewrote 3D generation code to be cleaner
- Overhead 3D view now has orthogonal camera
- 3D camera positioned and rotated to face north corner
- Fix to writing TXT
- Added UI scaling to Settings. You may want to adjust this value right away if the editor now appears too small for you.
- Default pan speed 1500 -> 2250 (taking into consideration UI scaling)
- Thicker blue selector
- Improved Save As dialog to force a correct map name
- Added column editor
- Added custom slabs
- Fixed panning with arrow keys
- No longer automatically calculating every column's 'Solid mask' upon save (still do for 'Utilized', though)
- Using a different method of reading and writing the byte containing lintel/permanent/height
0.14c - 12/12/2021
- Fix to LineEdit (text fields) registering clicks while moving the mouse quickly
- Added Reload map to File menu
- Fixed Script Generator ADD_CREATURE_TO_POOL() not working
- Improved tooltips appearance
0.14 - 10/12/2021
- Replaced some tab icons
- Rearranged tab icons
- Show tab name on hover
- Food, Power and Door combined into Misc
- .TXT files now save and load
- Fixed bitmasks not taking into consideration ownership, two rooms side by side with different owners were looking like one room
- Unified some slab placement code, this may introduce bugs
- Mysterious Box "Custom box" field can be set
- In Save As window, display error "Use only digits in map name" when typing letters
- Don't render Thing instances outside view (performance)
- Floating Spirit icon now used instead of Ghost
- Creature/trap/door index added
- Added icons for Hand of Evil and Slap
- Fixed Unearth editor freezing when launching DK
- LIF: fixed Map Name prefixing with spaces
- Externally modified .TXT files will auto-reload in the editor
- Map properties renamed to Map settings
- Added script generator and script editor as tabs in Map settings
- Display creature icon on mouse hover in Thing window
- If you have no script, give warning after saving
- Fixed a crash (probably)
- Rewritten/reorganized the texture caching code again
- Added 'Texture editing' feature to Edit menu, as long as you have the required filelist_tmapa000.txt and pack000 folder it'll auto-update them within the editor
0.13 - 02/12/2021
- Saving now writes to a buffer instead of directly to the hard drive
- Loading now reads from a buffer instead of directly from the hard drive
- Tab system: Mouse wheel while cursor is on tabs will scroll through them
- Tab system: Clicking the tab buttons on the side now goes to the next/previous tab
- Tab system: Added icons
- Higher resolution PNGs for Action Points and white diamonds (Thing Instances without images)
- Bugfix to 'Play' button being greyed out when it shouldn't be
- Ask to save changes before exiting and added 'Exit' to File menu
- Show error if there are no write permissions (write permissions are needed for settings.cfg and for saving maps in Dungeon Keeper directory)
- Changed message when starting a new map ("Opened map" -> "New map")
- Message system can now show popup windows (only used for write permission errors at the moment)
- When scanning for DK's tmapa###.dat files, be sure the extension is .DAT
- Fixed MSAA setting not working this whole time (go adjust it now!)
- Full linux compatibility
- Map browser: Rewritten some code for linux compatibility
- Map browser: Now opens 70% faster on Windows (not sure about Linux)
- Settings: Show full Play button command line
- Fixed crash when attempting to load blank texture array
- Prevent UI from popping up if executable isn't set
- Map names for campaigns 'keeporig', 'origplus' and 'deepdngn' will now correctly appear in the Map properties window (these campaigns in particular read their names from ddisk1.lif and dklevels.lof)
- The 2D camera is now a little less restricted
- Prevent crashes for texture maps without names and some clearer errors
- Fixed remembering custom objects (was only remembering one)
0.12 - 23/11/2021
- Bridges placed over liquid will work correctly now
- Added "Place bridges only on liquid" checkbox to Slab settings
- Settings window: Slab & Thing window scale setting now have a minimum and maximum (setting to 0 would cause crash)
- Slab window: Icons added
- Slab window: Slab50 and Purple Path moved to 'Other' tab
- Slab window: Scale size default decreased from 0.8 -> 0.76
- Slab window: Offset slab style names and ownership names
- Slab window: Slab style numbers now only shown if Style tab is selected
- Thing window: When you click on something in Thing Window, deselect on the map
- Properties window: Less switching to Placing tab
- Properties window: Slight edit to Rectangle tool icon
- Map properties: Names given to texture maps
- Deleting things: Once again allow holding delete to constantly delete everything under cursor (I had changed it to single press)
- Deleting things: Added a 'Delete' UI button in the properties window next to "Selected"
- Deleting things: Added Ctrl+Delete keybind for deleting one specific thing
- Load image as map: Fixed a bug where colours with 0 alpha could be treated differently depending on their RGB components
- Load image as map: Fixed up button/colour assignment. The way it should work is multiple colours can be assigned to one button, but multiple buttons cannot be assigned to one colour.
- Load image as map: 'Apply all' button added, you can now re-use previous assignment settings for different images or new maps
- Load image as map: Made the highlighted colour flash a little more obvious
- Load image as map: Fixed a crash and added "Click on a pixel within the image first." message
- Quick message: Fixed message disappearing too early
- Quick message: Allow multiple messages to display at once
- Texture maps: Rewritten caching code to be clearer and less error prone
- Texture maps: Date Modified of tmapa00#.dat files is now stored inside Settings.cfg (so it can detect any changes even when editor is closed)
- Texture maps: Switched to using single PNG files for texture maps (internally using two TextureArrays, it's still the best solution)
- Upon pressing ESC detect a window which has a close ("X") button and close it instead of asking to quit
- Gate number displayed
- Changed saving/loading code again, v0.11 may have had issues
- Version number added to window title and About menu
- Fixed two bugs with .LIF number not being correct
- Unified placement code of rectangle, pencil and "Load image as map" (groundwork done for shape placements like circular brushes)
- Fixed an issue with Torch Earth slabs not being placed
0.11 - 16/11/2021
- Fixed crash when placing slabs near edges or outside of the map
- Mode Switch window removed, button now top center
- Redone "quick message" appearance
- Added "Load image as map"
- Some dialogs will now hide other UI while they're open
- Map browser shows end of filepath when resizing
- Prevent windows from being moved over top menu
- Properties window now remains a consistent size (and slightly smaller than before)
- Windows can no longer be dragged off screen
- Removed window shadows (I can add an option if requested)
- Clicking windows will bring them to the front over other windows
- Added "Open script file" to Edit menu
- Combined "Dungeon Style" and "Map name" into "Map properties", also rearranged Edit menu
- Default to opening Thing tab in Properties instead of Column tab
- Slab style is now a tab in the Slab window
- Data from "unearthdata\blank_map.xxx" is now used when loading a map which has missing files (SLB files can now be loaded on their own without crashing)
- Added "Placing" tab to Properties window
- Ownership window merged into Properties window
- Rectangle tool and pencil tool added
- Added "Editable borders" option to Slab settings
- Ownership alpha will now continue to fade while cursor is on UI
- Added ownership-only placement as a tab in Slab window
- Added "Font size" to Settings (don't expect it to be very useful)
- Custom objects window: prefill the next empty subtype ID
- Custom objects window: show warning if you type an ID that is already in use (by the editor)
- Added Creature level font size "scale" and "max zoom" Settings
- Added "Purple Path" slab (slab ID 54)
- Unknown Slab IDs will now display their name as "Unrecognized Slab ID" in Properties instead of "Wall Automatic"
- Prevent mouse edge panning while middle click is being held
- 3D view now has two states, 1st person mode and non-1st person mode (this doesn't really change much for now)
0.10 - 04/11/2021
- .WIB files now save and load
- .WLB files now save and load
- .SLX files now save and load
- .LIF files now save and load
- Renamed "Wall" tab in Slabs window to "Other" (use the Auto Wall in Main)
- Fixed Alt+Enter to fullscreen (accidentally removed)
- Fixed F5 to test (spammed open DK if you held it)
- "Auto-generate clm/dat" renamed to "Update all slabs" and its confirmation message changed
- Fixed Dungeon Style window creating duplicate entries
- Wibble implemented, updates as you place slabs or if you press Edit -> Update all slabs
- Added "Slab Style window" (access in Edit menu)
- Slab style is visible in 2D and 3D view
- Damaged Wall % now defaults to 0, added warning label
- Fixed when switching from 3D to 2D mode the map sometimes went dark due to incorrect colour space
- Renamed "Map" menu to "File" menu
- Added "Open map folder" to Edit menu (greyed out when no map opened)
- Added "Help" menu, contains "Controls" and "About"
- Set "Map name" (.LIF) in edit menu
- Store and remember "last saved path" for Save As window
- Names of overlapping objects displayed in popup
- Allow cycling through overlapping objects under cursor by pressing Shift key
- Hold Ctrl and press Left click to place overlapping Thing objects
- Door objects will no longer reset their settings when a Slab is placed nearby
- Spinning Key is created/removed when changing a Door's locked state
- Prevent the Play button from being clicked if the map is not in the correct directory (there are still edge cases however)
- Added "Ownable natural terrain" checkbox to Slab settings, placing natural terrain will always be Ownership "None"
- The settings in "Slab settings" are now saved and remembered upon restarting editor
- Action point number graphic now updated when changing number value
- Thing window items should now initially resize properly
- Show subtype ID next to Type in Properties window
- Show slab ID next to slab name in Properties window
- Show IDs in Properties window as you hover mouse in Thing window
- Custom objects added (Edit menu)
0.09 - 23/10/2021
- Laggy arrow keys camera bug fixed
- Diagonal pans normalized
- Mouse edge panning enabled by default
- Directional pan speed default 2000 -> 1500
- Only mouse-edge-pan if mouse stops moving, is not hovering over UI and the window is focused
- Prevent placing a slab when clicking outside of settings window
- Prevent camera movement while Settings window is open
- Hide tile Selection cursor if mouse is hovering over any UI
- Selection cursor position now updates while panning the camera
- You can now alternatively zoom in or out using Ctrl + Arrow keys instead of mouse wheel
- Save As: prevent OK button from being clicked unless your map filename is in the correct format ("map#####")
- Display filenames as lowercase in Map Browser window (just for appearance sake)
- Tooltip font colour now a readable white
- Fixed map names showing "translation IDs" in the Map Browser
- Library wall cube texture fixed alongside the keeperfx fix
- "Details" window renamed to "Properties" window
- Properties window can no longer be dragged off screen
- Added mode-switching button to switch between Slab and Thing windows. Right clicking on something or pressing TAB will also switch modes.
- Properties window also switches its selected tab depending on mode
- Added "Hide unknown data" setting for Thing properties
- Mouse cursor now changes to hand cursor whenever hovering a Thing instance
- Added cheats to Play command line by default
- Slab window now has tabs
- Added in all the "Room wall" slabs that I had left out before because they were cluttering
- Fixed appearance of Damaged Wall
- Name of hovered slab added to Properties window
- Added "Wall Automatic" slab.
- When right clicking on any wall on the map, Wall Automatic will now always be selected. In order to place specific Walls you must choose them within the Slab window (Wall tab).
- When placing Wall Automatic slabs or anything non-solid (floor/water), nearby Wall SlabIDs will also be changed. These include: Torch Wall, Banner Wall, Twins Wall, Woman Wall, Pair Wall and Damaged Wall. They're automatically placed so they're also automatically updated. If you want manual placement for them then you'll need to specifically place them again.
- When placing Earth slabs, place Torch Earth slabs automatically. Also if you dig through Earth by placing a non-solid.
- When right clicking on a Torch Earth slab, select Earth slab. (just like Torch Wall slab)
- Added "Slab" checkbox to Owner window. When placing Thing objects it'll always set the ownership of the Thing to the slab you're placing it on.
- Added slider in Ownership window to change ownership colour alpha
- Fixed camera bug when loading up Unearth in fullscreen
- See Action Point and Light data in Properties window (Thing tab)
- Added Action Points and Lights, placeable from Thing tab
- Display Effect range and Action Point range when hovering over object, or object selected
- .LGT files now save and load
- Allow range and intensity to be set for lights
- You can now left click on things to "select them" (allowing for editing in Properties window) and click again to deselect. The last thing you've placed will be auto-selected.
- Selection status is shown in Properties window
- Clearer values for Door locked and Door orientation (True/False, N/S and E/W)
- The following fields are now editable in Properties window: Level, Owner, Effect Range, Light range, Point range, Point number, Herogate number, Light intensity, Door locked
- Added "Slab settings" to menu. It allows you to set options for "Wall Automatic". Options include: Damage Wall % and setting Twins/Woman/Pair to Grouped or Random.
0.08 - 6/10/2021
- Added Thing window
- When right-clicking a Thing on the map, the Thing Window will switch tabs and select it
- Implemented basic Thing placement. You cannot place overlapping Things (for now)
- Delete Thing objects by placing Slabs on them. Also delete Thing objects by pressing the "Delete" key and whatever is under the cursor will be erased
- Fixed some object images to use the correct ones and changed some object names
- Creature level number display fixed
- Default to red ownership
- F5 is now a shortcut for "Play" (or "Save & Play")
- Hero gate numbers calculated
- When manually placing a Torch object, its position will hug the wall. (to be consistent with normal Torch positions)
- Added warning window popup for certain placements
- Doors are now implemented, when you place a Door Slab it will determine the correct orientation for the slab and its accompanying Thing object
0.07 - 26/6/2021
- Window colour theme changes depending on ownership selected
- Increased the resizable-clickable area on window edges
- Settings window now has its sections separated into tabs
- Added "Details viewer", the "Column details" is now a tabbed section contained within it
- Added "Thing details"
- Improved 3D generation speed
- Added loading bar for 3D view
- Thing objects are now placed along with their slabs (reading from slabs.tng)
- Various bugfixes
0.06 - 12/6/2021
- Auto detects when a tmapa###.dat file is changed in the Dungeon Keeper data directory and reloads the texture map for that file
- In 3D view press spacebar to unlock mouse capture
- Added "Edit" menu
- Added menu option to auto-generate clm/dat
- Added menu option to change dungeon style
0.05 - 10/6/2021
- Added slab placement with ownership and randomized columns
- Improved speed of opening maps
- Small speed up for opening 3D view (still slow though)
- Now using a more standard horizontal main menu
- Better looking window theme and new font
- The editor window's position, size, maximized state and fullscreen state is remembered upon subsequent launches
- Added "New" menu option to finally create a new empty map filled with earth
- "Play" button now becomes "Save & Play" if you've edited the map
- Fixed 3D Camera not always initially facing the right direction
- Fixed purple pixels in textures issue (was incorrectly using main.pal instead of palette.dat)
- Added "Save", "Save as" and "Open" menu options. The old "Open" has been renamed to "Browse"
- Fixed texture caching looping forever when opening a map via file association in Windows
- Added errors (and prevent open map) for "Executable path not set" and "Textures haven't been loaded". This fixes issues with launching via file association without running the editor once beforehand
- Fixed Column Details window not always displaying the correct information
- Improved settings menu
0.04 - 16/5/2021
- Switched RNC decompressor from ancient.exe to dernc.exe. There unfortunately seems to be two different strands of RNC decompression going on, keeperfx has its own unique brand of RNC compression applied to some files and so ancient.exe isn't working in all circumstances, it was only working on the original game files.
- Renamed Unearth's /data/ subdirectory to /unearthdata/ (mentioning this so you can delete Unearth's /data/ directory if you want to)
- Now scanning for all tmapa000.dat files in DK's /data/ directory, decompressing them, reading them, saving them as .res files in /unearthdata/ for the purpose of quickly loading next time you open the editor
- Added "Reload texture maps" button to settings menu if you want to read the tmapa000.dat files again from DK's /data/ directory (updates the cached files)
- Slight speed boost to reading some map files
- Added icon (it's a little different from the original texture btw)
- Added 3D .clm viewer
- Added Mouse sensitivity setting
- Added Field of view setting
- Added 3D info setting
- Added Show column details setting
0.03 - 6/5/2021
- Map menu improved
- Decompression implemented
- Settings menu added
- Play button now uses keeperfx's new -campaign command to play levels
- Reading dungeon styles again
- Added directional panning of 2D view
0.02 - 28/4/2021
- Quick fix for how files are being read
0.01 - 28/4/2021
- First release
"""
