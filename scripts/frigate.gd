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

func _ready():
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

func _process(_delta):
    if health_points == 0:    # ship has been destroyed by a normal hit
        self.queue_free()
    elif health_points < 0:   # ship has been destroyed by a critical hit
        self.queue_free()

# handles movement logic, activates when any event activates
func _input(event):
   if is_moving or is_firing: return   # do not allow inputs if ship is currently moving or firing
   
   var mouse_position : Vector2 = get_global_mouse_position()
   var tile : Vector2i = main.tile_board.local_to_map(mouse_position)
   
   if !Global.map_rect.has_point(tile): return  # if mouse is not in map bounds -> exit early
   
   current_position = main.tile_board.local_to_map(global_position)
   # if tile is solid -> over object is true, else -> false
   var over_object : bool = true if Global.astar.is_point_solid(tile) else false
   
   # fire railgun shell
   if event.is_action_pressed("RMB") and is_selected and over_object and action_points > 0:
      var hit_chance = 100 - (current_position.distance_to(tile) * 10)
      is_firing = true
      action_points -= 1
      Global.attributes_changed.emit(self, null)
      Global.instance_shell(tile, self, hit_chance)
      
   # if user clicks while ship selected -> move
   if event.is_action_pressed("RMB") and is_selected and !over_object:
      Global.astar.set_point_solid(current_position, 0)     # clear current position from astar
      var id_path = Global.astar.get_id_path(current_position, tile).slice(1)
         
      # if local path var isnt empty -> set global path var and point path var
      if !id_path.is_empty() and id_path.size() <= movement_points:
         main.tile_overlay.clear()    # clear movement overlay
         movement_points -= id_path.size()
         Global.attributes_changed.emit(self, null)
         current_id_path = id_path
         current_point_path = Global.astar.get_point_path(current_position, tile)
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
   if current_id_path.is_empty(): return
   
   # if not moving -> get next point in path, set is_moving
   if is_moving == false:
      target_position = main.tile_board.map_to_local(current_id_path.front())
      is_moving = true
   Global.move_ship(self)  # move the ships sprite
# end of sprite movement function --------------------------------------------

# handles ship selection, activates when event occurs in ship bounds
func _on_input_event(_viewport, event, _shape_idx):
   if event.is_action_pressed("LMB"):
      # if ship isnt selected -> select ship
      if !is_selected:
         Global.obj_selected.emit(self, Global.current_selected)
         Global.current_selected = self
         Global.display_movement(current_position, movement_points, 0)
         is_selected = true
# end of ship selection function --------------------------------------------

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
      
func object_hit(obj : Object, weapon : Object, damage : int, _origin : Object):
   if obj == self: health_points -= damage
   
func shell_destroyed(_weapon : Object, _origin : Object):
   is_firing = false
