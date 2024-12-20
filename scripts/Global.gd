extends Node # singleton global script

# ship scenes for instancing - "ship_name": [player_ship, ai_ship]
var ships = {
   "frigate": [preload("res://scenes/frigate.tscn"), preload("res://scenes/cpu_frigate.tscn")],
   "destroyer": [preload("res://scenes/frigate.tscn"), preload("res://scenes/cpu_frigate.tscn")],
   "cruiser": [preload("res://scenes/frigate.tscn"), preload("res://scenes/cpu_frigate.tscn")],
   "battlecruiser": [preload("res://scenes/frigate.tscn"), preload("res://scenes/cpu_frigate.tscn")],
   "battleship": [preload("res://scenes/frigate.tscn"), preload("res://scenes/cpu_frigate.tscn")],
}
var ship_sprites = {
   "frigate": preload("res://assets/frigate.png"),
   "destroyer": preload("res://assets/frigate.png"),
   "cruiser": preload("res://assets/frigate.png"),
   "battlecruiser": preload("res://assets/frigate.png"),
   "battleship": preload("res://assets/frigate.png"),
}
var railgun_shell := preload("res://scenes/railgun_shell.tscn")
var text_popup := preload("res://scenes/popup_container.tscn")

# --- global signals --- #
signal next_turn
signal attributes_changed(object : Object)                                    # emitted when ships change attributes
# ship signals
signal obj_selected(new_selected : Object, old_selected : Object)             # emitted when ships are selected
signal obj_deselected(old_selected : Object)                                  # emitted when ships are deselected
signal damaged(obj_damaged : Object, num_damaged : int)                       # emitted when a ship is damaged
# weapon signals
signal obj_hit(obj : Object, weapon : Object, damage : int, origin : Object)  # emitted when a weapon hits an object
signal shell_destroyed(weapon : Object, origin : Object)                      # emitted when a shell calls queue_free()
# --- global signals --- #

# global variables
var main : Node2D
var map_size : Vector2i
var map_rect : Rect2i
var tile_size : Vector2i

var astar : AStarGrid2D = AStarGrid2D.new()
var current_selected : Object

# custom battle variables
var player_fleet : Array
var enemy_fleet : Array

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
   var ship
   ship = Global.ships[ship_type][0].instantiate()
   #if faction == 0:
      #ship = Global.ships[ship_type][0].instantiate()
   #else:
      #ship = Global.ships[ship_type][1].instantiate()
   ship.name = ship_type
   ship.position = map.tile_board.map_to_local(ship_position)
   ship.faction = faction
   map.add_child(ship)
   ship.sprite.rotation += deg_to_rad(180 * faction)
# end of instance ship function ----------------------------------------------

func instance_shell(target, ship, percent):
   # ensure that shell is fired within range
   if target == Vector2i(ship.position):
      return
   target = main.tile_board.map_to_local(target)
   # instantiate a new railgun shell and set its variables, then add it to the scene
   var shell = Global.railgun_shell.instantiate()
   shell.origin = ship
   shell.direction = ship.global_position.direction_to(target)
   shell.position = ship.position
   shell.percent = percent
   main.add_child(shell)

func display_movement(start_coord, movement_points, _faction):
   var tile_queue : Array
   var id_path : Array[Vector2i]
   # get all tiles in a square around ship based on movement points, +1 offset
   for i in range(-movement_points, movement_points + 1):
         for j in range(-movement_points, movement_points + 1):
            var tile_coords : Vector2i = Vector2i(start_coord.x + j, start_coord.y + i)
            tile_queue.append(tile_coords)
   # end of for loop ---------------------------------------------------------
   # fill in tiles
   while tile_queue:
      var current_tile : Vector2i = tile_queue.pop_front()
      id_path = []
      id_path = Global.astar.get_id_path(start_coord, current_tile)
      id_path.pop_front()        # remove the start coord from path
      
      # if id path size is less than movement points and current tile isnt solid -> apply movement overlay
      if id_path.size() <= movement_points and !Global.astar.is_point_solid(current_tile):
         main.tile_overlay.set_cell(current_tile, 3, Vector2i(0, 0))
   # end of tile queue while loop --------------------------------------------
# end of display movement function -------------------------------------------

# move ship
func move_ship(ship):
   # move global position of ship towards target
   ship.global_position = ship.global_position.move_toward(ship.target_position, 2)
   # rotate the sprite to face the target position
   if ship.global_position.direction_to(ship.target_position) != Vector2(0, 0):
      ship.sprite.look_at(ship.global_position - ship.global_position.direction_to(ship.target_position))
      ship.sprite.rotation += deg_to_rad(-90)

   # if global position equals next target point -> remove point from path
   if ship.global_position == ship.target_position:
      ship.current_id_path.pop_front()
      ship.current_point_path = ship.current_point_path.slice(1)
      
      # if path isnt empty -> get new target point
      if !ship.current_id_path.is_empty():
         ship.target_position = main.tile_board.map_to_local(ship.current_id_path.front())
      else: # else -> stop moving
         ship.is_moving = false
         ship.current_position = main.tile_board.local_to_map(ship.global_position)
         Global.astar.set_point_solid(ship.current_position)
         Global.display_movement(main.tile_board.local_to_map(ship.position), ship.movement_points, 0)
   # end of global position equals next target point if statement ------------
# end of move ship function --------------------------------------------------

# display text
func popup(text, position, color):
   var popup_instance = text_popup.instantiate()
   main.add_child(popup_instance)
   popup_instance.label.text = text
   popup_instance.position = position
   popup_instance.label.add_theme_color_override("font_color", color)

# called by map node after all new instances that access signals have been added
func connect_signals():
   connect("obj_hit", create_damage_popup)
   connect("next_turn", ai_move)

# signal functions
func create_damage_popup(object, _weapon, damage, _sender):
   if damage == 0:
      popup("Miss!", object.position, Color.GRAY)
   else:
      popup(str(damage), object.position, Color.RED)

# friendly ship ai movement function
func ai_move():
   pass

func ai_attack():
   pass
