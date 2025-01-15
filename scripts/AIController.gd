extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
   pass

func turn():
   faction_turn(Global.friendly_ships)
   faction_turn(Global.enemy_ships)
   faction_turn(Global.neutral_ships)
   emit_signal("next_turn")

func faction_turn(faction):
   print("faction: ", faction)
   for ship in faction:
      print("\n", ship.name, ": starting turn\n------------------------")
      ship.is_selected
      #while ship.turn: pass      # endlessly loop until the ship is done
