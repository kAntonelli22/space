extends Node

# singleton script

# global variables

# 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
   pass

func check_collision_with_group(group : Array, coords : Vector2):
   for object in get_tree().get_nodes_in_group("Ships"):
      if object.position == coords:
         return true
      else:
         return false
