extends CharacterBody2D

# ship logic variables
var faction : int = 0
var is_selected : bool = false
var is_moving : bool = false
var is_firing : bool = false
var over_object : bool = false

# constant variables
var MAX_HEALTH : int = 10
var MAX_MOVEMENT : int = 4
var MAX_ACTION : int = 2
var RAILGUN_RANGE : Vector2i = Vector2i(5, 5)

# movement variables
var target_position : Vector2
var current_id_path : Array[Vector2i]
var current_point_path : PackedVector2Array

# assorted variables
var health_points : int = MAX_HEALTH
var movement_points : int = MAX_MOVEMENT
var action_points : int = MAX_ACTION

# node references
@onready var main = get_parent()
@onready var ship_sprite = $Sprite2D
@onready var collider = $CollisionShape2D

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
      
   Global.connect("next_turn", next_turn)
   Global.connect("obj_selected", select_signal)
   Global.connect("obj_hit", object_hit)
   Global.connect("shell_destroyed", shell_destroyed)
# end of ready function ------------------------------------------------------

func _process(delta):
    if health_points == 0:
        print(self.name, " has been destroyed")
        get_tree().queue_free()
    elif health_points < 0:
        print(self.name, " has exploded")
        get_tree().queue_free()

# handles movement logic, activates when any event activates
func _input(event):
   # do not allow inputs if ship is currently moving or firing
   if is_moving or is_firing:
      return
   
   var mouse_position = get_global_mouse_position()
   var tile = main.tile_board.local_to_map(mouse_position)
   var snapped_mouse = main.tile_board.map_to_local(tile)
   over_object = true
   
   # check if mouse_position collides with any ships or asteroids
   over_object = Global.check_collision_with_group("Ships", snapped_mouse)
   if Global.astar.is_point_solid(tile):
      over_object = true
   # fire railgun shell
   if event.is_action_pressed("RMB") and is_selected and over_object and action_points > 0:
      is_firing = true
      action_points -= 1
      Global.attributes_changed.emit(self, null)
      instance_shell()
   # if user clicks while ship selected -> move
   if event.is_action_pressed("RMB") and is_selected and !over_object:
      var id_path = Global.astar.get_id_path(main.tile_board.local_to_map(global_position), tile).slice(1)
         
      # if local path var isnt empty -> set global path var and point path var
      if !id_path.is_empty() and id_path.size() <= movement_points:
         main.tile_overlay.clear()    # clear movement overlay
         movement_points -= id_path.size()
         Global.attributes_changed.emit(self, null)
         current_id_path = id_path
         current_point_path = Global.astar.get_point_path(main.tile_board.local_to_map(global_position), tile)
         # end of ship moving if statement -----------------------------------
      # end of local path var if statement -----------------------------------
   # end of click while selected if statement --------------------------------
   
   # if user deselects -> deselect ship, update current obj selected in parent node, clear movement overlay
   if event.is_action_pressed("Deselect") and is_selected:
      Global.obj_deselected.emit(self)
      Global.current_selected = null
      is_selected = false
      main.tile_overlay.clear()    # clear movement overlay
   # end of user deselects if statement --------------------------------------
# end of movement logic function ---------------------------------------------

# handles sprite movement
func _physics_process(_delta):
   # if global path var is empty -> no movement neccessary, exit early
   if current_id_path.is_empty():
      return
   
   # if not moving -> get next point in path, set is_moving
   if is_moving == false:
      target_position = main.tile_board.map_to_local(current_id_path.front())
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
         target_position = main.tile_board.map_to_local(current_id_path.front())
      # else -> stop moving
      else:
         is_moving = false
         display_movement()
   # end of global position equals next target point if statement ------------
# end of sprite movement function --------------------------------------------

# handles ship selection, activates when event occurs in ship bounds
func _on_input_event(_viewport, event, _shape_idx):
   # if user clicks -> handle click
   if event.is_action_pressed("LMB"):
      # if ship isnt selected -> select ship, update current obj selected in parent node
      if !is_selected:
         # emit selected signal
         Global.obj_selected.emit(self, Global.current_selected)
         Global.current_selected = self
         is_selected = true
         # change current cell on movement overlay
         display_movement()
      # end of ship not selected if statement --------------------------------
   # end of user click if statement ------------------------------------------
# end of ship selection function --------------------------------------------

# deselect ship if other ship emits select signal
func select_signal(_obj_selected : Object, obj_deselected):
   if is_selected and obj_deselected == self:
      main.tile_overlay.clear()
      is_selected = false

func display_movement():
   var start_coord : Vector2i = main.tile_board.local_to_map(position)
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
      id_path = Global.astar.get_id_path(start_coord, current_tile)
      id_path.pop_front()        # remove the start coord from path
      
      # if id path size is less than movement points and current tile isnt solid -> apply movement overlay
      if id_path.size() <= movement_points and !Global.astar.is_point_solid(current_tile):
         main.tile_overlay.set_cell(current_tile, 3, Vector2i(0, 0))
   # end of tile queue while loop --------------------------------------------
# end of display movement function -------------------------------------------

func object_hit(_object_hit : Object, _weapon : Object, _origin : Object):
   pass
   
func shell_destroyed(_weapon : Object, _origin : Object):
   is_firing = false

func instance_shell():
   # get the mouse position, convert it to grid, then back to global
   var target = main.tile_board.local_to_map(get_global_mouse_position())
   # ensure that shell is fired within range
   if target == Vector2i(position) or target - RAILGUN_RANGE < Vector2i(0, 0):
      return
   target = main.tile_board.map_to_local(target)
   # instantiate a new railgun shell and set its variables, then add it to the scene
   var shell = Global.railgun_shell.instantiate()
   shell.origin = self
   shell.direction = global_position.direction_to(target)
   shell.position = position
   main.add_child(shell)

# refresh ship actions and logic after end of turn
func next_turn():
   # reset movement and action points
   movement_points = MAX_MOVEMENT
   action_points = MAX_ACTION
   Global.attributes_changed.emit(self, null)
   if is_selected:
      display_movement()
# end of next turn button ----------------------------------------------------
