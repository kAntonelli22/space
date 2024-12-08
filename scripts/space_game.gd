extends Node2D


# scenes
var ships = {
   "frigate": preload("res://scenes/ship.tscn"),
   "frigate2": preload("res://scenes/ship.tscn"),
}
var railgun_shell := preload("res://scenes/railgun_shell.tscn")

# variables
var obj_selected
var turn_counter : int = 0

# nodes
@onready var tile_board := $Board
@onready var tile_overlay := $Overlay
@onready var camera := $Camera2D

# astar pathfinding grid
var astar : AStarGrid2D = AStarGrid2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
   # get tilemap size, map as an array of integers, and size of tiles
   var map_size = tile_board.get_used_rect().end - tile_board.get_used_rect().position
   var map_rect = Rect2i(Vector2.ZERO, map_size)
   var tile_size = tile_board.tile_set.tile_size

   # set astar to integer map, set cell size, offset, movement style
   astar.region = map_rect
   astar.cell_size = tile_size
   astar.offset = tile_size / 2
   astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
   astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
   astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
   # update the astar grid to apply changes to settings
   astar.update()
   
   # loop through tilemap and set astar grid solid on asteriod tiles
   for i in map_size.x:
      for j in map_size.y:
         var coords = Vector2i(i, j)
         var tile_data = tile_board.get_cell_tile_data(coords)
         
         # if tile at coords is not an empty space, set solid
         if tile_data and tile_data.get_custom_data("Type") != "space":
            astar.set_point_solid(coords)
   # end of astar for loop ---------------------------------------------------
   instance_ship("USS Bing Bong", "frigate", 0, Vector2i(11, 9))
   instance_ship("RSS Hussein", "frigate", 1, Vector2i(10, 10))
   instance_ship("USS Dink Doink", "frigate", 0, Vector2i(8, 6))
   print(get_tree().get_nodes_in_group("EnemyShips"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
   pass


func instance_ship(ship_name : String, ship_type : String, faction : int, ship_position : Vector2i):
   var ship = ships[ship_type].instantiate()
   ship.name = ship_name
   ship.position = tile_board.map_to_local(ship_position)
   ship.faction = faction
   add_child(ship)
   # flip ship if faction is 1
   ship.ship_sprite.rotation += deg_to_rad(180 * faction)


# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# - Movement Overlay doesnt turn on when a ship is deselected through click
# - ships moved ontop of other ships when other ships are selected

# --- # --- # --- # --- # Issues -- # --- # --- # --- # --- #
# --- # --- # --- # --- # Todo List # --- # --- # --- # --- #
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
