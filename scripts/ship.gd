extends CharacterBody2D

# ship logic variables
var faction : int = 0
var is_selected : bool = false
var is_moving : bool = false
var is_firing : bool = false

# constant variables
var MAX_HEALTH : int = 10
var MAX_MOVEMENT : int = 4
var MAX_ACTION : int = 2
var RAILGUN_RANGE : Vector2i = Vector2i(5, 5)

# movement variables
var current_position : Vector2i
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
# end of ready function ------------------------------------------------------

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
   pass

func display_movement():
   var tile_queue : Array
   var id_path : Array[Vector2i]
   # get all tiles in a square around ship based on movement points, +1 offset
   for i in range(-movement_points, movement_points + 1):
         for j in range(-movement_points, movement_points + 1):
            var tile_coords : Vector2i = Vector2i(current_position.x + j, current_position.y + i)
            tile_queue.append(tile_coords)
   # end of for loop ---------------------------------------------------------
   # fill in tiles
   while tile_queue:
      var current_tile : Vector2i = tile_queue.pop_front()
      id_path = []
      id_path = Global.astar.get_id_path(current_position, current_tile)
      id_path.pop_front()        # remove the start coord from path
      
      # if id path size is less than movement points and current tile isnt solid -> apply movement overlay
      if id_path.size() <= movement_points and !Global.astar.is_point_solid(current_tile):
         main.tile_overlay.set_cell(current_tile, 3, Vector2i(0, 0))
   # end of tile queue while loop --------------------------------------------
# end of display movement function -------------------------------------------

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
         Global.display_movement(main.tile_board.local_to_map(position), movement_points, 0)
   # end of global position equals next target point if statement ------------
# end of move ship function --------------------------------------------------

# refresh ship actions and logic after end of turn
func next_turn():
   # reset movement and action points
   movement_points = MAX_MOVEMENT
   action_points = MAX_ACTION
   Global.attributes_changed.emit(self, null)
   if is_selected:
      Global.display_movement(main.tile_board.local_to_map(position), movement_points, 0)
# end of next turn button ----------------------------------------------------

# deselect ship if other ship emits select signal
func select_signal(_obj_selected : Object, obj_deselected):
   if is_selected and obj_deselected == self:
      main.tile_overlay.clear()
      is_selected = false
      
func object_hit(obj : Object, _weapon : Object, damage : int, _origin : Object):
   if obj == self: health_points -= damage
   if health_points <= 0: queue_free()
   
func shell_destroyed(_weapon : Object, _origin : Object):
   is_firing = false
