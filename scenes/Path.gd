extends Node2D

# get ship groups
@onready var player_ships := get_tree().get_nodes_in_group("PlayerShips")
@onready var friendly_ships := get_tree().get_nodes_in_group("FriendlyShips")
@onready var neutral_ships := get_tree().get_nodes_in_group("NeutralShips")
@onready var enemy_ships := get_tree().get_nodes_in_group("EnemyShips")


func _process(delta):
   # update ship groups
   player_ships = get_tree().get_nodes_in_group("PlayerShips")
   friendly_ships = get_tree().get_nodes_in_group("FriendlyShips")
   neutral_ships = get_tree().get_nodes_in_group("NeutralShips")
   enemy_ships = get_tree().get_nodes_in_group("EnemyShips")
   # redraw path
   queue_redraw()
   
func _draw():
   
   draw_paths(player_ships, Color.BLUE)
   draw_paths(friendly_ships, Color.GREEN)
   draw_paths(neutral_ships, Color.GRAY)
   draw_paths(enemy_ships, Color.RED)
# end of draw function ------------------------------------------------------

func draw_paths(group : Array, color: Color):
   # loop through friendly ships and draw paths
   for ship in group:
      
      # if points are more than 2 -> draw path
      if !ship.current_point_path.size() < 2:
         var point_path : PackedVector2Array = ship.current_point_path
         point_path.slice(1).insert(0, ship.position)
         draw_polyline(point_path, color)
# end of draw paths function -------------------------------------------------
