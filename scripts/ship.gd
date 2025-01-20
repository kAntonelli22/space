extends CharacterBody2D

# ship logic variables
var faction : int = 0
var is_selected : bool = false
var is_moving : bool = false
var is_firing : bool = false
var ready_to_fire : bool = false
var show_overlay : bool = false

# constant variables
var MAX_HEALTH : int = 10
var MAX_MOVEMENT : int = 4
var MAX_ACTION : int = 2
var RAILGUN_MAX : int = 5
var RAILGUN_MIN : int = 1

# movement variables
var current_position : Vector2i     # main.tile_board.local_to_map(position)
var target_position : Vector2
var current_id_path : Array[Vector2i]
var current_point_path : PackedVector2Array

# assorted variables
var health_points : int = MAX_HEALTH
var movement_points : int = MAX_MOVEMENT
var action_points : int = MAX_ACTION
var damage : int = 4    # average damage that the ship is capable of each turn, for ai 

# node references
@onready var main = get_parent()
@onready var sprite = $Sprite2D
@onready var collider = $CollisionShape2D
@onready var square = $Square
@onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   current_position = main.tile_board.local_to_map(position)
   Global.astar.set_point_solid(current_position)
   
   add_to_group("Ships")
   if faction == 0:
      add_to_group("PlayerShips")
   elif faction == 1:
      add_to_group("EnemyShips")
   elif faction == 2:
      add_to_group("AlliedShips")
   elif faction == 3:
      add_to_group("NeutralShips")
      
   SignalBus.connect("next_turn", next_turn)
   SignalBus.connect("obj_selected", select_signal)
   SignalBus.connect("obj_hit", object_hit)
   SignalBus.connect("shell_destroyed", shell_destroyed)
   SignalBus.connect("ui_railgun", ui_railgun)
# end of ready function ------------------------------------------------------

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
   pass
   
func _physics_process(_delta):
   # if global path var is empty -> no movement neccessary, exit early
   if current_id_path.is_empty(): return
   
   # if not moving -> get next point in path, set is_moving
   if is_moving == false:
      target_position = main.tile_board.map_to_local(current_id_path.front())
      is_moving = true
   move_ship()  # move the ships sprite
# end of sprite movement function --------------------------------------------

# signal called every time an event occurs within bounds of the collision object
func _on_input_event(_viewport, _event, _shape_idx):
   pass

# move ship
func move_ship():
   # move global position of ship towards target
   if line.points[0] == global_position: line.remove_point(0)
   global_position = global_position.move_toward(target_position, 2)
   line.add_point(position, 0)
   # rotate the sprite to face the target position
   if global_position.direction_to(target_position) != Vector2(0, 0):
      sprite.look_at(global_position - global_position.direction_to(target_position))
      sprite.rotation += deg_to_rad(-90)

   # if global position equals next target point -> remove point from path
   if global_position == target_position:
      current_id_path.pop_front()
      current_point_path = current_point_path.slice(1)
      line.remove_point(0)
      print("ship: removing point 0")
      
      # if path isnt empty -> get new target point
      if !current_id_path.is_empty():
         target_position = main.tile_board.map_to_local(current_id_path.front())
      else: # else -> stop moving
         is_moving = false
         current_position = main.tile_board.local_to_map(global_position)
         line.clear_points()
         print("ship: clearing line")
         Global.astar.set_point_solid(current_position)
         if show_overlay: display_movement()
   # end of global position equals next target point if statement ------------
# end of move ship function --------------------------------------------------

func movement_line(points):
   for i in range(0, points.size()):
      line.add_point(main.tile_board.map_to_local(points[i]), i)
      print("ship: added point: ", points[i], " to line")

func display_movement():
   # get all tiles in a square around ship based on movement points
   var tile_queue : Array = Global.get_tiles(current_position, movement_points, movement_points)
   tile_queue = check_pathfinding(Global.astar, tile_queue, 0, movement_points)
   main.tile_overlay.set_cells_terrain_connect(tile_queue, 0, 2)
# end of display movement function -------------------------------------------

func display_attack(min_range : int, max_range : int):
   # get all tiles in a square around ship based on weapon max range
   var tile_queue : Array = Global.get_tiles(current_position, max_range, max_range)
   tile_queue = check_pathfinding(Global.astar_clear, tile_queue, min_range, max_range)
   main.tile_overlay.set_cells_terrain_connect(tile_queue, 0, 3)
# end of display movement function -------------------------------------------

func check_pathfinding(astar_grid, tiles, min_range, max_range):
   var id_path : Array[Vector2i] # contains the pathfinding point array
   var queue : Array             # contains the final tiles the overlay is to be added to
   
   while tiles:
      var current_tile : Vector2i = tiles.pop_front()
      if !Global.map_rect.has_point(current_tile): continue
      id_path = []
      id_path = astar_grid.get_id_path(current_position, current_tile)
      id_path.pop_front()        # remove the start coord from path
      
      # if id path size is less than movement points and current tile isnt solid -> apply movement overlay
      if id_path.size() <= max_range and id_path.size() > min_range and !astar_grid.is_point_solid(current_tile):
         queue.append(current_tile)
   # end of tile queue while loop --------------------------------------------
   return queue
# end of check_pathfinding function ---------------------------------------------

func calc_accuracy(tile, target, create_popups) -> int:
   var accuracy : int = 100
   var distance = tile.distance_to(target)
   var id_path = []
   id_path = Global.astar_clear.get_id_path(tile, target)
   id_path.pop_front()        # remove the start coord from path
         
   for point in id_path:
      var tile_data = main.tile_board.get_cell_tile_data(point).get_custom_data("Type")
      if tile_data == "asteroid":
         accuracy = 0
         if create_popups: Global.tile_popup("-100%", point, Color.RED)
      elif tile_data == "asteroid_bunch":
         accuracy -= 20
         if create_popups: Global.tile_popup("-20%", point, Color.RED)
      elif Global.check_collision_with_group("Ships", point):
         accuracy -= 10
         if create_popups: Global.tile_popup("-10%", point, Color.RED)
   accuracy -= (distance * 10)
   if distance > RAILGUN_MAX or accuracy < 0: accuracy = 0
   return accuracy
   
# fires a single railgun shell at the target tile
func fire_railgun(target : Vector2i):
   var accuracy = calc_accuracy(current_position, target, false)
   is_firing = true
   action_points -= 1
   SignalBus.attributes_changed.emit(self, null)
   Global.instance_shell(target, self, accuracy)

# refresh ship actions and logic after end of turn
func next_turn():
   print("ship: starting next turn")
   # reset logic booleans
   is_selected = false
   is_moving = false
   is_firing = false
   ready_to_fire = false
   show_overlay = false
   # reset movement and action points
   movement_points = MAX_MOVEMENT
   action_points = MAX_ACTION
   SignalBus.attributes_changed.emit(self, null)
   #if is_selected:
      #display_movement()
# end of next turn button ----------------------------------------------------

# deselect ship if other ship emits select signal
func select_signal(_obj_selected, obj_deselected):
   if is_selected and obj_deselected == self:
      main.tile_overlay.clear()
      is_selected = false
      is_moving = false
      is_firing = false
      ready_to_fire = false
      show_overlay = false
   
# check if ship has been hit by a projectile
func object_hit(obj : Object, _weapon : Object, damage_dealt : int, _origin : Object):
   if obj != self: return
   health_points -= damage_dealt
   if health_points <= 0: ship_destroyed()
   if damage_dealt == 0: Global.popup("Miss!", position, Color.GRAY)
   else: Global.popup(str(damage_dealt), position, Color.RED)

# enable user control logic
func shell_destroyed(_weapon, _origin):
   is_firing = false

# # ui buttons
# handle railgun ui button being pressed
func ui_railgun():
   print("ship: ui signal received")
   if is_selected and !ready_to_fire:
      ready_to_fire = true
      main.tile_overlay.clear()
      display_attack(RAILGUN_MIN, RAILGUN_MAX)
   elif is_selected and ready_to_fire:
      ready_to_fire = false
      main.tile_overlay.clear()
      if movement_points > 0:
         display_movement()
      
# ship destroyed function
func ship_destroyed():
   SignalBus.emit_signal("ship_destroyed", self)
   Global.astar.set_point_solid(current_position, 0)     # clear current position from astar
   queue_free()
