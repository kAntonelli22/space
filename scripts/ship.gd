extends CharacterBody2D

# ship logic variables
var faction : int = 0
var is_selected : bool = false
var is_moving : bool = false
var over_object : bool = false

# constant variables
var MAX_HEALTH : int = 10
var MAX_MOVEMENT : int = 4
var RAILGUN_RANGE : Vector2i = Vector2i(5, 5)

# movement variables
var movement_points : int = MAX_MOVEMENT
var target_position : Vector2
var current_id_path : Array[Vector2i]
var current_point_path : PackedVector2Array

# assorted variables
var health_points : int = MAX_HEALTH

# signals
signal ship_selected
signal deselected_manually
signal deselected_automatically

# main node reference
@onready var main_node = get_parent()
@onready var UI = main_node.get_node("UI")
@onready var ship_sprite = $Sprite2D
@onready var collider = $CollisionShape2D
@onready var turn_button = main_node.get_node("UI/BottomRight/TurnButton")

func _ready():
   add_to_group("Ships")
   if faction == 0:
      add_to_group("PlayerShips")
   elif faction == 1:
      add_to_group("EnemyShips")
   elif faction == 2:
      add_to_group("AlliedShips")
   elif faction == 3:
      add_to_group("NeutralShips")
      
   turn_button.connect("pressed", next_turn)

# handles movement logic, activates when any event activates
func _input(event):
   var mouse_position = get_global_mouse_position()
   var tile = main_node.tile_board.local_to_map(mouse_position)
   var snapped_mouse = main_node.tile_board.map_to_local(tile)
   over_object = true
   
   # check if mouse_position collides with any ships or asteroids
   over_object = Global.check_collision_with_group(get_tree().get_nodes_in_group("Ship"), snapped_mouse)
   if main_node.astar.is_point_solid(tile):
      over_object = true
   # fire railgun shell
   if event.is_action_pressed("RMB") and is_selected and over_object:
      instance_shell()
   # if user clicks while ship selected -> move
   if event.is_action_pressed("RMB") and is_selected and !over_object:
      var id_path
      main_node.tile_overlay.clear()    # clear movement overlay
      
      # if ship currently moving -> create new path from next tile
      if is_moving:
         id_path = main_node.astar.get_id_path(
            main_node.tile_board.local_to_map(target_position),
            main_node.tile_board.local_to_map(get_global_mouse_position()),
         )
      # else -> create new path from current tile, not including current tile
      else:
         id_path = main_node.astar.get_id_path(
            main_node.tile_board.local_to_map(global_position),
            main_node.tile_board.local_to_map(get_global_mouse_position()),
         ).slice(1)
       # end of ship moving if statement -------------------------------------
         
      # if local path var isnt empty -> set global path var and point path var
      if !id_path.is_empty() and id_path.size() <= movement_points:
         movement_points -= id_path.size()
         current_id_path = id_path
         
         # if ship currently moving -> create new point path from next tile
         if is_moving:
            current_point_path = main_node.astar.get_point_path(
               main_node.tile_board.local_to_map(target_position),
               main_node.tile_board.local_to_map(get_global_mouse_position()),
            )
         # else -> create new point path from current tile
         else:
            current_point_path = main_node.astar.get_point_path(
               main_node.tile_board.local_to_map(global_position),
               main_node.tile_board.local_to_map(get_global_mouse_position()),
            )
         # end of ship moving if statement -----------------------------------
      # end of local path var if statement -----------------------------------
   # end of click while selected if statement --------------------------------
   
   # if user deselects -> deselect ship, update current obj selected in parent node, clear movement overlay
   if event.is_action_pressed("Deselect") and is_selected:
      deselected_manually.emit()
      is_selected = false
      main_node.obj_selected = null
      main_node.tile_overlay.clear()    # clear movement overlay
   # end of user deselects if statement --------------------------------------
# end of movement logic function ---------------------------------------------

# handles sprite movement
func _physics_process(delta):
   # if global path var is empty -> no movement neccessary, exit early
   if current_id_path.is_empty():
      return
   
   # if not moving -> get next point in path, set is_moving
   if is_moving == false:
      target_position = main_node.tile_board.map_to_local(current_id_path.front())
      is_moving = true
   # end of not moving if statement ------------------------------------------
   
   # move global position of ship towards target
   global_position = global_position.move_toward(target_position, 2)
   # rotate the sprite to face the target position
   if global_position.direction_to(target_position) != Vector2(0, 0):
      $Sprite2D.look_at(global_position - global_position.direction_to(target_position))
      $Sprite2D.rotation += deg_to_rad(-90)

   # if global position equals next target point -> remove point from path
   if global_position == target_position:
      current_id_path.pop_front()
      current_point_path = current_point_path.slice(1)
      
      # if path isnt empty -> get new target point
      if !current_id_path.is_empty():
         target_position = main_node.tile_board.map_to_local(current_id_path.front())
      # else -> stop moving
      else:
         is_moving = false
         display_movement()
   # end of global position equals next target point if statement ------------
# end of sprite movement function --------------------------------------------

# handles ship selection, activates when event occurs in ship bounds
func _on_input_event(viewport, event, shape_idx):
   # if user clicks -> handle click
   if event.is_action_pressed("LMB"):
      
      # if ship isnt selected -> select ship, update current obj selected in parent node
      if !is_selected:
         
         # if other ship is selected -> deselect it
         if main_node.obj_selected:
            main_node.tile_overlay.clear    # clear movement overlay
            main_node.obj_selected.is_selected = false
         is_selected = true
         main_node.obj_selected = self
         # change current cell on movement overlay
         UI.update_info_panel()
         display_movement()
      # end of ship not selected if statement --------------------------------
   # end of user click if statement ------------------------------------------
# end of ship selection function --------------------------------------------

func _on_mouse_entered():
   pass


func _on_mouse_exited():
   pass

func display_movement():
   var start_coord : Vector2i = main_node.tile_board.local_to_map(position)
   var tile_queue : Array
   var id_path : Array[Vector2i]
   
   # get all tiles in a square around ship based on movement points, +1 offset
   for i in range(-movement_points, movement_points + 1):
         for j in range(-movement_points, movement_points + 1):
            var tile_coords : Vector2i = Vector2i(start_coord.x + j, start_coord.y + i)
            tile_queue.append(tile_coords)
   
   # fill in tiles
   while tile_queue:
      var current_tile : Vector2i = tile_queue.pop_front()
      id_path = []
      id_path = main_node.astar.get_id_path(start_coord, current_tile)
      id_path.pop_front()        # remove the start coord from path
      
      # if id path size is less than movement points and current tile isnt solid -> apply movement overlay
      if id_path.size() <= movement_points and !main_node.astar.is_point_solid(current_tile):
         main_node.tile_overlay.set_cell(current_tile, 3, Vector2i(0, 0))
   # end of tile queue while loop --------------------------------------------
# end of display movement function -------------------------------------------

func instance_shell():
   # get the mouse position, convert it to grid, then back to global
   var target = main_node.tile_board.local_to_map(get_global_mouse_position())
   print(target == Vector2i(position) or target - RAILGUN_RANGE > Vector2i(0, 0))
   # ensure that shell is fired within range
   if target == Vector2i(position) or target - RAILGUN_RANGE > Vector2i(0, 0):
      return
   target = main_node.tile_board.map_to_local(target)
   # instantiate a new railgun shell
   var shell = main_node.railgun_shell.instantiate()
   # set shell origin for collision, direction, and position, then add to scene
   shell.origin = self
   shell.direction = global_position.direction_to(target)
   shell.position = position
   main_node.add_child(shell)

# refresh ship actions and logic after end of turn
func next_turn():
   # reset movement points
   movement_points = MAX_MOVEMENT
   health_points -= 1
# end of next turn button ----------------------------------------------------
