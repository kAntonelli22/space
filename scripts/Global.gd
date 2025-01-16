extends Node # singleton global script

var ship_scene = preload("res://scenes/ship.tscn")
# ship scripts for instancing - "ship_name": [player_ship, ai_ship]
var ships = {
   "frigate": [preload("res://scripts/player_frigate.gd"), preload("res://scripts/cpu_frigate.gd")],
   "destroyer": [preload("res://scripts/player_frigate.gd"), preload("res://scripts/cpu_frigate.gd")],
   "cruiser": [preload("res://scripts/player_frigate.gd"), preload("res://scripts/cpu_frigate.gd")],
   "battlecruiser": [preload("res://scripts/player_frigate.gd"), preload("res://scripts/cpu_frigate.gd")],
   "battleship": [preload("res://scripts/player_frigate.gd"), preload("res://scripts/cpu_frigate.gd")],
}
var ship_sprites = {
   "frigate": preload("res://assets/frigate.png"),
   "destroyer": preload("res://assets/frigate.png"),
   "cruiser": preload("res://assets/frigate.png"),
   "battlecruiser": preload("res://assets/frigate.png"),
   "battleship": preload("res://assets/frigate.png"),
}
var railgun_shell := preload("res://scenes/railgun_shell.tscn")
var text_popup := preload("res://scenes/popup_container.tscn")

# global variables
var main : Node2D
var map_size : Vector2i
var map_rect : Rect2i
var tile_size : Vector2i

var astar : AStarGrid2D = AStarGrid2D.new()
var current_selected : Object

# custom battle variables
var player_fleet : Array
var enemy_fleet : Array

# get ship groups
@onready var player_ships = get_tree().get_nodes_in_group("PlayerShips")
@onready var friendly_ships = get_tree().get_nodes_in_group("FriendlyShips")
@onready var neutral_ships = get_tree().get_nodes_in_group("NeutralShips")
@onready var enemy_ships = get_tree().get_nodes_in_group("EnemyShips")

@onready var faction_groups : Array = [player_ships, enemy_ships]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
   player_ships = get_tree().get_nodes_in_group("PlayerShips")
   friendly_ships = get_tree().get_nodes_in_group("FriendlyShips")
   neutral_ships = get_tree().get_nodes_in_group("NeutralShips")
   enemy_ships = get_tree().get_nodes_in_group("EnemyShips")
   faction_groups = [player_ships, enemy_ships]
   
   # redraw path
   if main: main.queue_redraw()
   
func draw_paths(map, group : Array, color: Color):
   # loop through friendly ships and draw paths
   for ship in group:
      
      # if points are more than 2 -> draw path
      if !ship.current_point_path.size() < 2:
         var point_path : PackedVector2Array = ship.current_point_path
         point_path.slice(1).insert(0, ship.position)
         map.draw_polyline(point_path, color, 3)
# end of draw paths function -------------------------------------------------

func update_pathfinding(map):
   main = map
   map_size = map.tile_board.get_used_rect().end - map.tile_board.get_used_rect().position
   map_rect = Rect2i(Vector2.ZERO, map_size)
   tile_size = map.tile_board.tile_set.tile_size

   # set astar to integer map, set cell size, offset, movement style
   astar.region = map_rect
   astar.cell_size = tile_size
   astar.offset = tile_size / 2
   astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
   astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
   astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
   # update the astar grid to apply changes to settings
   astar.update()
   # loop through tilemap and set astar grid solid on asteriod tiles
   for i in map_size.x:
      for j in map_size.y:
         var coords = Vector2i(i, j)
         var tile_data = map.tile_board.get_cell_tile_data(coords)
         
         # if tile at coords is not an empty space, set solid
         if tile_data and tile_data.get_custom_data("Type") != "space":
            astar.set_point_solid(coords)
   # end of astar for loop ---------------------------------------------------
# end of update pathfinding function -----------------------------------------

func check_collision_with_group(group : String, coords : Vector2):
   for object in get_tree().get_nodes_in_group(group):
      if object.position == coords:
         return true
   return false
# end of check collision with group function ---------------------------------

# gets the tiles in in a square from the given position
func get_tiles(position : Vector2i, width : int, height : int) -> Array:
   var array : Array
   for i in range(-width, width + 1):
      for j in range(-height, height + 1):
         array.append(Vector2i(position.x + i, position.y + j))
   return array
# end of get tiles function --------------------------------------------------

func check_cardinal(target : Vector2i, origin : Vector2i) -> bool:
   var difference = target - origin
   if difference.x == 0 or difference.y == 0: return true
   elif abs(difference.x) == abs(difference.y): return true
   else: return false
# end of check cardinal direction function -----------------------------------

# takes a fleet array and deploys it to the given coordinates
func deploy_fleet(fleet : Array, faction : int, coords : Vector2):
   var alternator : bool = true
   instance_ship(main, fleet[0], faction, coords)
   for i in range(1, fleet.size()):
      if alternator:
         alternator = false
         instance_ship(main, fleet[i], faction, coords + Vector2(i + 1, 0))
      else:
         alternator = true
         instance_ship(main, fleet[i], faction, coords + Vector2(-i, 0))
# end of deploy fleet function -----------------------------------------------

# creates a new instance of a ship, sets its position, names it, sets its faction, and adds it to the scene
func instance_ship(map, ship_type : String, faction : int, ship_position : Vector2i):
   var ship = ship_scene.instantiate()
   ship.set_script(ships[ship_type][faction])
   print("ship ", ship_type + str(faction_groups[faction].size()), " added")
   ship.name = ship_type + str(faction_groups[faction].size())
   ship.position = map.tile_board.map_to_local(ship_position)
   ship.faction = faction
   map.add_child(ship)
   ship.sprite.rotation += deg_to_rad(180 * faction)
   
   player_ships = get_tree().get_nodes_in_group("PlayerShips")
   friendly_ships = get_tree().get_nodes_in_group("FriendlyShips")
   neutral_ships = get_tree().get_nodes_in_group("NeutralShips")
   enemy_ships = get_tree().get_nodes_in_group("EnemyShips")
   faction_groups = [player_ships, enemy_ships]
# end of instance ship function ----------------------------------------------

func instance_shell(target, ship, percent):
   # ensure that shell is fired within range
   if target == Vector2i(ship.position):
      return
   target = main.tile_board.map_to_local(target)
   # instantiate a new railgun shell and set its variables, then add it to the scene
   var shell = Global.railgun_shell.instantiate()
   shell.origin = ship
   shell.direction = ship.global_position.direction_to(target)
   shell.position = ship.position
   shell.percent = percent
   main.add_child(shell)

# display text
func popup(text, position, color):
   print("popup function activated")
   var popup_instance = text_popup.instantiate()
   main.add_child(popup_instance)
   popup_instance.label.text = text
   popup_instance.position = position
   popup_instance.label.add_theme_color_override("font_color", color)

func turn():
   await faction_turn(Global.friendly_ships)
   await faction_turn(Global.enemy_ships)
   await faction_turn(Global.neutral_ships)
   SignalBus.emit_signal("next_turn")

func faction_turn(faction):
   print("Global: faction starting turn\n------------------------")
   for ship in faction:
      print("\n", ship.name, ": starting turn\n------------------------")
      current_selected = ship
      ship.is_selected = true
      await SignalBus.turn_complete
      print(ship.name, ": ending turn\n------------------------")
   print("Global: faction ending turn\n------------------------")

# called by map node after all new instances that access signals have been added
func connect_signals():
   pass
