extends "res://scripts/frigate.gd"

func _ready():
   super._ready()    # call ready function of frigate class

func _process(delta):
   super._process(delta)    # call process function of frigate class

func _physics_process(delta):
   super._physics_process(delta)    # call physics function of frigate class

func ai_action():
   # get full move area
   # if ship can target player ships from any tiles
   # # determine which tile it has the highest chance of damage from
   # # set final tile as target position
   # # set target ship
   # else if ship cannot do any damage
   # # determine which tile it can move to that best protects it from enemy ships
   # # set final tile as target position
   # super.move_ship()
   # if target ship is set
   # # fire_railgun(target ship position)
   pass
