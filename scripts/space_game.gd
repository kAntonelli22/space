extends Node2D

# variables
var turn_counter : int = 0

# nodes
@onready var tile_board := $Board
@onready var tile_overlay := $Overlay
@onready var camera := $Camera2D
@onready var ui := $UI

# Called when the node enters the scene tree for the first time.
func _ready():
   # debugging fleet
   var fleet := ["frigate", "frigate", "frigate", "frigate", "frigate"]
   Global.update_pathfinding(self)
   # if battle scene has been normally -> spawn chosen fleets, else -> spawn debug fleet
   if Global.player_fleet.size() > 0:
      Global.deploy_fleet(Global.player_fleet, 0, Vector2(10, 13))
   else:
      Global.deploy_fleet(fleet, 0, Vector2(10, 13))
   # connect signal system together after ships have been instanced
   Global.connect_signals()
   ui.connect_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
   pass

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# - random error message about point out of bounds, one for each ship
# - movement overlay bugs out when it hits edge of the map

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# --- # --- # --- # --- # Todo List # --- # --- # --- # --- #
# - add scroll zooming
# - continue switch to signal system
# - Fleet Picker Menu
# - Deployment Phase
# - Guide Scene
# - Settings Scene
# - Basic ship ui (name, hp, move points, etc.)
# - Combat System (fire railgun, pdc, torpedo, do damage)

# --- # --- # --- # --- # Todo List # --- # --- # --- # --- # 
# --- # --- # --- # --- # Major --- # --- # --- # --- # --- #
# - More art assets
# - UI and Menu overhall
# - different ships

# --- # --- # --- # --- # Major --- # --- # --- # --- # --- #
# --- # --- # --- # --- # Control - # --- # --- # --- # --- #
# - Left Mouse Button Selection
# - UI Buttons and Hotkeys for attacks
# - Right Mouse Button for Actions (Attack, Move, etc.)

# --- # --- # --- # --- # Control - # --- # --- # --- # --- #
# --- # --- # --- # --- # Game Info # --- # --- # --- # --- #
# - tile size -> 32x32
# - map size -> 20x20

# --- # --- # --- # --- # Game Info # --- # --- # --- # --- #
