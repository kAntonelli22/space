extends Node # singleton global script

# scenes
var ships = {
   "frigate": preload("res://scenes/ship.tscn"),
   "frigate2": preload("res://scenes/ship.tscn"),
}
var railgun_shell := preload("res://scenes/railgun_shell.tscn")

# --- global signals --- #
signal next_turn
# ship signals
signal obj_selected(new_selected : Object, old_selected : Object)
signal obj_deselected(old_selected : Object)
signal damaged(obj_damaged : Object, num_damaged : int)
# weapon signals
signal obj_hit(obj : Object, weapon : Object, origin : Object)
signal shell_destroyed(weapon : Object, origin : Object)
# --- global signals --- #

# global variables
var main : Node2D
var map_size : Vector2i
var map_rect : Rect2i
var tile_size : Vector2i

var astar : AStarGrid2D = AStarGrid2D.new()
var current_selected : Object

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
   pass

func update_pathfinding(main_node):
   main = main_node
   map_size = main.tile_board.get_used_rect().end - main.tile_board.get_used_rect().position
   map_rect = Rect2i(Vector2.ZERO, map_size)
   tile_size = main.tile_board.tile_set.tile_size

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
         var tile_data = main.tile_board.get_cell_tile_data(coords)
         
         # if tile at coords is not an empty space, set solid
         if tile_data and tile_data.get_custom_data("Type") != "space":
            astar.set_point_solid(coords)
   # end of astar for loop ---------------------------------------------------
# end of update pathfinding function -----------------------------------------

func check_collision_with_group(group : String, coords : Vector2):
   for object in get_tree().get_nodes_in_group(group):
      if object.position == coords:
         return true
   return false
# end of check collision with group function ---------------------------------

# takes a fleet array and deploys it to the given coordinates
func deploy_fleet(fleet : Array, faction : int, coords : Vector2):
   var alternator : bool = true
   instance_ship(main, fleet[0], faction, coords)
   for i in range(1, fleet.size()):
      if alternator:
         alternator = false
         instance_ship(main, fleet[i], faction, coords + Vector2(i + 1, 0))
      else:
         alternator = true
         instance_ship(main, fleet[i], faction, coords + Vector2(-i, 0))
# end of deploy fleet function -----------------------------------------------

# creates a new instance of a ship, sets its position, names it, sets its faction, and adds it to the scene
func instance_ship(map, ship_type : String, faction : int, ship_position : Vector2i):
   var ship = Global.ships[ship_type].instantiate()
   ship.name = ship_type
   ship.position = map.tile_board.map_to_local(ship_position)
   ship.faction = faction
   map.add_child(ship)
   ship.ship_sprite.rotation += deg_to_rad(180 * faction)
# end of instance ship function ----------------------------------------------

# called by map node after all new instances that access signals have been added
func connect_signals():
   pass
   #connect("obj_selected", obj_selected_signal)
   #connect("obj_deselected", obj_deselected_signal)
