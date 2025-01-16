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
   queue_redraw()
   pass

func _draw():
   Global.draw_paths(self, Global.player_ships, Color.SLATE_BLUE)
   Global.draw_paths(self, Global.friendly_ships, Color.MEDIUM_SEA_GREEN)
   Global.draw_paths(self, Global.neutral_ships, Color.DARK_GRAY)
   Global.draw_paths(self, Global.enemy_ships, Color.INDIAN_RED)

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# - added temp fix in show overlay variable for enemy ships showing overlay
# - ship selection is bugged after ending turn, should probably force deselection on end turn
# - can fire variables do not untoggle when deselected
# - railgun shells can still freeze after hitting a ship
# - tiles that cannot be pathed to are automatically highlighted by overlays # # Solved? #
# - fix isses with overlay and add missing r pieces
# - Camera zoom doesnt adjust clamp
# - frigate sprite has accidental background in between thrusters and is 16x16

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# --- # --- # --- # --- # Todo List # --- # --- # --- # --- #
# - ai_attack function
# - optimize check pathfinding and display functions
# - tilemap collision only astar grid for pathfinding function
# - 10x health and damage
# - highlight tile mouse is currently over?
# - minimum range?
# - merge action points and movement points?
# - add key binds for each ui button
# - visible health bars or health numbers when a ship or object is hit

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
