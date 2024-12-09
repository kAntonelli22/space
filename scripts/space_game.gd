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
   Global.update_pathfinding(self)
   instance_ship("USS Bing Bong", "frigate", 0, Vector2i(11, 9))
   instance_ship("RSS Hussein", "frigate", 1, Vector2i(10, 10))
   instance_ship("USS Dink Doink", "frigate", 0, Vector2i(8, 6))
   Global.connect_signals()
   ui.connect_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
   pass

func instance_ship(ship_name : String, ship_type : String, faction : int, ship_position : Vector2i):
   var ship = Global.ships[ship_type].instantiate()
   ship.name = ship_name
   ship.position = tile_board.map_to_local(ship_position)
   ship.faction = faction
   add_child(ship)
   # flip ship if faction is 1
   ship.ship_sprite.rotation += deg_to_rad(180 * faction)


# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# - Ships cannot be reselected after being deselected through right click outside of movement zone
# - random
# - movement overlay bugs out when it hits boarders of the map

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# --- # --- # --- # --- # Todo List # --- # --- # --- # --- #
# - lock player actions until railgun shell hits target or leaves map
# - add scroll zooming
# - 
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
