extends "res://scripts/ship.gd"

func _ready():
   super._ready()    # call ready function of frigate class
   square.modulate = Color.RED

func _process(delta):
   super._process(delta)    # call process function of frigate class

func _physics_process(delta):
   super._physics_process(delta)    # call physics function of frigate class

func next_turn():
   print("\ncpu: ", name, ", starting turn")
   ai_move()
   ai_attack()
   print("cpu: ", name, ", ending turn\n--------------------")
   super.next_turn()

func ai_move():
   var can_attack : bool = false
   var tiles : Array = Global.get_tiles(current_position, movement_points, movement_points)
   tiles = check_pathfinding(tiles, 0, movement_points)
   var current_tile : Vector2i = current_position
   var current_potential : int = 0
   for tile in tiles:
      print("cpu: checking tile ", tile, " for potential moves")
      var potential : int = 0
      var all_tiles : Array = Global.get_tiles(tile, RAILGUN_MAX, RAILGUN_MAX)
      var reachable_tiles : Array # tiles that can be reached by railguns from tile
      for possible_tile in all_tiles:
         if Global.check_cardinal(possible_tile, tile):
            reachable_tiles.append(possible_tile)
      for ship in Global.player_ships:
         if reachable_tiles.has(ship.current_position):
            var accuracy = calc_accuracy(current_position, ship.current_position)
            print(accuracy, ship.health_points, ship.damage)
            potential += accuracy - ship.health_points - ship.damage
            print("cpu: current potential of ", tile, ": ", potential)
            # add to potential score based off of accuracy, damage, and health of the target
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
         print("cpu: subtracting ", id_path.size(), " from ", movement_points)
         movement_points -= id_path.size()
         Global.attributes_changed.emit(self, null)
         current_id_path = id_path
         current_point_path = Global.astar.get_point_path(current_position, current_tile)
   if can_attack and action_points > 0:
     ai_attack()
   pass

func ai_attack():
   print("cpu: entering attack function")
   var final_target
   var current_potential : int = 0
   
   var possible_targets = Global.player_ships
   var valid_targets : Array = []
   for target in possible_targets:
      if Global.check_cardinal(target.current_position, current_position):
         valid_targets.append(target)
            
   for target in valid_targets:
      var potential : int = calc_accuracy(current_position, target.current_position)
      potential -= target.health_points + target.damage
      if target.health_points <= damage:
         print("cpu: potential to destroy enemy ship")
         potential += 25
      if potential > current_potential:
         print("cpu: new target determined: ", target, " at ", target.current_position)
         current_potential = potential
         final_target = target
   
   if final_target:
      print("cpu: firing railgun at ", final_target.current_position)
      fire_railgun(final_target.current_position)
   elif movement_points == 0:
      print("cpu: cannot hit any targets")
      action_points = 0
      return
      
   print("cpu: movement points: ", movement_points, " action points: ", action_points)
   if movement_points > 0:
      print("cpu: checking moves")
      ai_move()
   elif action_points > 0:
      print("cpu: attacking again")
      ai_attack()
