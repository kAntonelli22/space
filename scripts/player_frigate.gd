extends "res://scripts/ship.gd"

func _ready():
   super._ready()    # call ready function of ship class
   square.modulate = Color.BLUE
# end of ready function ------------------------------------------------------

func _process(delta):
   super._process(delta)    # call ready function of ship class

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
   if event.is_action_pressed("RMB") and ![is_selected, over_object, ready_to_fire].has(false) and action_points > 0:
      fire_railgun(tile)
      
   # if user clicks while ship selected -> move
   if event.is_action_pressed("RMB") and ![is_selected, !over_object, !ready_to_fire].has(false):
      print("player: moving")
      Global.astar.set_point_solid(current_position, 0)     # clear current position from astar
      var id_path = Global.astar.get_id_path(current_position, tile).slice(1)
         
      # if local path var isnt empty -> set global path var and point path var
      if !id_path.is_empty() and id_path.size() <= movement_points:
         main.tile_overlay.clear()    # clear movement overlay
         movement_points -= id_path.size()
         SignalBus.attributes_changed.emit(self, null)
         current_id_path = id_path
         current_point_path = Global.astar.get_point_path(current_position, tile)
      else: print("player: outside movement area")
         # end of ship moving if statement -----------------------------------
      # end of local path var if statement -----------------------------------
   # end of click while selected if statement --------------------------------
   
   # if user deselects -> deselect ship, update current obj selected in parent node, clear movement overlay
   if event.is_action_pressed("Deselect") and is_selected:
      SignalBus.obj_deselected.emit(self)
      Global.current_selected = null
      is_selected = false
      main.tile_overlay.clear()    # clear movement overlay
   # end of user deselects if statement --------------------------------------
# end of movement logic function ---------------------------------------------

# handles sprite movement
func _physics_process(delta):
   super._physics_process(delta)
# end of sprite movement function --------------------------------------------

# handles ship selection, activates when event occurs in ship bounds
func _on_input_event(_viewport, event, _shape_idx):
   if event.is_action_pressed("LMB"):
      # if ship isnt selected -> select ship
      if !is_selected:
         SignalBus.obj_selected.emit(self, Global.current_selected)
         Global.current_selected = self
         display_movement()
         is_selected = true
# end of ship selection function --------------------------------------------
