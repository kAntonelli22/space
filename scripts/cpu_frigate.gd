extends "res://scripts/ship.gd"

func _ready():
   super._ready()    # call ready function of frigate class
   square.modulate = Color.RED

func _process(delta):
   super._process(delta)    # call process function of frigate class

func _physics_process(delta):
   super._physics_process(delta)    # call physics function of frigate class

func ai_move():
   # var can_attack : bool = false
   # var tiles : array = full move area
   # var potential : int = 0
   # var current_tile : Vector2i = current_position
   # var current_potential
   # for each tile in tiles
   # # if ship in player_ships can be hit:
   # # # potential = calculation of highest damage and hit percentage
   # # # if potential > current_potential:
   # # # # current_tile = tile
   # # # # current_potential = potential
   # # # # can_attack = true
   # if current_tile = current_position: 
   # # return
   # else: 
   # # move_ship()
   # if can_attack and action_points > 0:
   # # ai_attack()
   pass

func ai_attack():
   # var valid_targets = all targets in range
   # var target
   # for target in targets:
   # # logic to determine which target is best
   # fire__railgun(target)
   # if movement_points > 0:
   # # ai_move()
   # else if action_points > 0:
   # # ai_attack()
   pass
