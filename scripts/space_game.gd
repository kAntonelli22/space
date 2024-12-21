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
      Global.deploy_fleet(Global.enemy_fleet, 1, Vector2(10, 7))
   else:
      Global.deploy_fleet(fleet, 0, Vector2(10, 13))
      Global.deploy_fleet(fleet, 1, Vector2(10, 7))
   # connect signal system together after ships have been instanced
   Global.connect_signals()
   ui.connect_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
   pass

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# - movement overlay bugs out when it hits edge of the map

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# --- # --- # --- # --- # Todo List # --- # --- # --- # --- #
# - add one pixel outline to the tilemap
# - visible health bars when a ship or object is hit
# - limit attack directions?
# - - railgun, torpedo, and pdc attack buttons
# - - attack range and area overlay

# - create seperate ingame UI scene?
# - on player end turn emit signal to global
# - - ai move function that takes faction and moves each ship
# - - - ships move to closest position that would allow it to fire on the weakest ship
# - - ai fire function that loops through ships and fires
# - - - targets ship with the highest damage - health?

# - move code from path.gd to Global movement
# - seperate global ship functions into ship singleton

# --- # --- # --- # --- # Todo List # --- # --- # --- # --- # 
# --- # --- # --- # --- # Major --- # --- # --- # --- # --- #
# - More art assets
# - UI and Menu overhall
# - different ships
# - animations, particle effects, thrusters, nicer overlay
# - Deployment Phase
# - Guide Scene
# - Settings Scene

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
