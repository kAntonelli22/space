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
   var fleet := ["frigate", "frigate", "frigate", "frigate", "frigate"]
   Global.update_pathfinding(self)
   Global.deploy_fleet(fleet, 0, Vector2(10, 13))
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
# - begin implementing action points
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
