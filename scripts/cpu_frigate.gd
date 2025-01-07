extends "res://scripts/ship.gd"

func _ready():
   super._ready()    # call ready function of frigate class
   square.modulate = Color.RED

func _process(delta):
   super._process(delta)    # call process function of frigate class

func _physics_process(delta):
   super._physics_process(delta)    # call physics function of frigate class

func next_turn():
   print("cpu: ", name, ", starting turn")
   ai_move()
   ai_attack()
   print("cpu: ", name, ", ending turn")
   super.next_turn()

func ai_move():
   print("cpu: checking for moves")
   var can_attack : bool = false
   var tiles : Array = Global.get_tiles(current_position, movement_points, movement_points)
   tiles = check_pathfinding(tiles, movement_points, movement_points)
   var potential : int = 0
   var current_tile : Vector2i = current_position
   var current_potential : int = 0
   for tile in tiles:
      print("cpu: checking tile ", tile, " for potential moves")
      # find which player ships can be hit from the tile
      # calculate the accuracy of each and add the two largest to current_potential
      if potential > current_potential:
         print("cpu: tile ", tile, " has beat tile ", current_tile, " with a potential of ", potential, " to ", current_potential)
         current_tile = tile
         current_potential = potential
         can_attack = true
   if current_tile == current_position:
      print("cpu: best move is no move")
      return
   else:
      print("cpu: moving to tile ", current_tile)
      Global.astar.set_point_solid(current_position, 0)     # clear current position from astar
      var id_path = Global.astar.get_id_path(current_position, current_tile).slice(1)
         
      # if local path var isnt empty -> set global path var and point path var
      if !id_path.is_empty() and id_path.size() <= movement_points:
         movement_points -= id_path.size()
         Global.attributes_changed.emit(self, null)
         current_id_path = id_path
         current_point_path = Global.astar.get_point_path(current_position, current_tile)
   if can_attack and action_points > 0:
     ai_attack()
   pass

func ai_attack():
   print("cpu: attacking")
   action_points -= 1
   var valid_targets = [Vector2i(0, 0), Vector2i(1, 1)]# = all ships in range
   var final_target
   var potential : int = 0
   var current_potential : int = 0
   for target in valid_targets:
      # calculate accuracy of attacking the target
      # calculate effect of damage on target
      # use both to determine attack potential
      pass
   #fire_railgun(final_target)
   if movement_points > 0:
      print("cpu: checking moves")
      ai_move()
   elif action_points > 0:
      print("cpu: attacking again")
      ai_attack()
