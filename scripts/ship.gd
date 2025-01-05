extends CharacterBody2D

# ship logic variables
var faction : int = 0
var is_selected : bool = false
var is_moving : bool = false
var is_firing : bool = false
var ready_to_fire : bool = false

# constant variables
var MAX_HEALTH : int = 10
var MAX_MOVEMENT : int = 4
var MAX_ACTION : int = 2
var RAILGUN_RANGE : int = 5

# movement variables
var current_position : Vector2i     # main.tile_board.local_to_map(position)
var target_position : Vector2
var current_id_path : Array[Vector2i]
var current_point_path : PackedVector2Array

# assorted variables
var health_points : int = MAX_HEALTH
var movement_points : int = MAX_MOVEMENT
var action_points : int = MAX_ACTION

# node references
@onready var main = get_parent()
@onready var sprite = $Sprite2D
@onready var collider = $CollisionShape2D
@onready var square = $Square

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
      
   Global.connect("next_turn", next_turn)
   Global.connect("obj_selected", select_signal)
   Global.connect("obj_hit", object_hit)
   Global.connect("shell_destroyed", shell_destroyed)
   Global.connect("ui_railgun", ui_railgun)
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

func display_movement():
   var tile_queue : Array
   # get all tiles in a square around ship based on movement points, +1 offset
   for i in range(-movement_points, movement_points + 1):
         for j in range(-movement_points, movement_points + 1):
            var tile_coords : Vector2i = Vector2i(current_position.x + i, current_position.y + j)
            tile_queue.append(tile_coords)
   # end of for loop ---------------------------------------------------------
   tile_queue = check_pathfinding(tile_queue, 0, movement_points)
   main.tile_overlay.set_cells_terrain_connect(tile_queue, 0, 2)
# end of display movement function -------------------------------------------

func display_attack(min_range : int, max_range : int):
   var tile_queue : Array
   
   # get all tiles in a square around ship based on movement points, +1 offset
   for i in range(-max_range, max_range + 1):
         for j in range(-max_range, max_range + 1):
            var tile_coords : Vector2i = Vector2i(current_position.x + i, current_position.y + j)
            if Global.check_cardinal(tile_coords, current_position):
               tile_queue.append(tile_coords)
   # end of for loop ---------------------------------------------------------
   tile_queue = check_pathfinding(tile_queue, min_range, max_range)
   main.tile_overlay.set_cells_terrain_connect(tile_queue, 0, 3)
# end of display movement function -------------------------------------------

func check_pathfinding(tiles, min_range, max_range):
   var id_path : Array[Vector2i] # contains the pathfinding point array
   var queue : Array             # contains the final tiles the overlay is to be added to
   
   while tiles:
      var current_tile : Vector2i = tiles.pop_front()
      if !Global.map_rect.has_point(current_tile): continue
      id_path = []
      id_path = Global.astar.get_id_path(current_position, current_tile)
      id_path.pop_front()        # remove the start coord from path
      
      # if id path size is less than movement points and current tile isnt solid -> apply movement overlay
      if id_path.size() <= movement_points and !Global.astar.is_point_solid(current_tile):
         queue.append(current_tile)
   # end of tile queue while loop --------------------------------------------
   return queue
# end of check_pathfinding function ---------------------------------------------

# move ship
func move_ship():
   # move global position of ship towards target
   global_position = global_position.move_toward(target_position, 2)
   # rotate the sprite to face the target position
   if global_position.direction_to(target_position) != Vector2(0, 0):
      sprite.look_at(global_position - global_position.direction_to(target_position))
      sprite.rotation += deg_to_rad(-90)

   # if global position equals next target point -> remove point from path
   if global_position == target_position:
      current_id_path.pop_front()
      current_point_path = current_point_path.slice(1)
      
      # if path isnt empty -> get new target point
      if !current_id_path.is_empty():
         target_position = main.tile_board.map_to_local(current_id_path.front())
      else: # else -> stop moving
         is_moving = false
         current_position = main.tile_board.local_to_map(global_position)
         Global.astar.set_point_solid(current_position)
         display_movement()
   # end of global position equals next target point if statement ------------
# end of move ship function --------------------------------------------------

# fire railgun
func fire_railgun(target):
   var distance = current_position.distance_to(target)
   if Global.check_cardinal(target, current_position) and distance < RAILGUN_RANGE:
      var hit_chance = 100 - (distance * 10)
      is_firing = true
      action_points -= 1
      Global.attributes_changed.emit(self, null)
      Global.instance_shell(target, self, hit_chance)

# refresh ship actions and logic after end of turn
func next_turn():
   # reset movement and action points
   movement_points = MAX_MOVEMENT
   action_points = MAX_ACTION
   Global.attributes_changed.emit(self, null)
   if is_selected:
      display_movement()
# end of next turn button ----------------------------------------------------

# deselect ship if other ship emits select signal
func select_signal(_obj_selected : Object, obj_deselected):
   if is_selected and obj_deselected == self:
      main.tile_overlay.clear()
      is_selected = false
   
# check if ship has been hit by a projectile
func object_hit(obj : Object, _weapon : Object, damage : int, _origin : Object):
   if obj != self: return
   health_points -= damage
   if health_points <= 0: queue_free()
   if damage == 0: Global.popup("Miss!", position, Color.GRAY)
   else: Global.popup(str(damage), position, Color.RED)

# enable user control logic
func shell_destroyed(_weapon : Object, _origin : Object):
   is_firing = false

# # ui buttons
# handle railgun ui button being pressed
func ui_railgun():
   if is_selected and !ready_to_fire:
      ready_to_fire = true
      main.tile_overlay.clear()
      display_attack(0, RAILGUN_RANGE)
   elif is_selected and ready_to_fire:
      ready_to_fire = false
      main.tile_overlay.clear()
      if movement_points > 0:
         display_movement()
      
