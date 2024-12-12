extends Control

# nodes
@onready var player_rack : Node = $ColorRect/MarginContainer/VBoxContainer/FleetContainer/PlayerFleet

# variables
var player_fleet : Array = []
var player_fleet_size : int = 0
@onready var player_rack_buttons : Array = player_rack.get_children()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
   if player_fleet_size != player_fleet.size():
      player_fleet_size = player_fleet.size()
      update_rack(player_fleet, player_rack_buttons)

func update_rack(fleet : Array, buttons : Array):
   for i in fleet.size():
      if fleet[i] == "frigate":
         buttons[i].icon = Global.ship_sprites["frigate"]
      elif fleet[i] == "destroyer":
         buttons[i].icon = Global.ship_sprites["destroyer"]
      elif fleet[i] == "cruiser":
         buttons[i].icon = Global.ship_sprites["cruiser"]
      elif fleet[i] == "battlecruiser":
         buttons[i].icon = Global.ship_sprites["battlecruiser"]
      elif fleet[i] == "battleship":
         buttons[i].icon = Global.ship_sprites["battleship"]
   for i in range(fleet.size(), buttons.size()):
      buttons[i].icon = null

# player bottom rack
func _on_frigate_button_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_frigate_button_2_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_frigate_button_3_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_frigate_button_4_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_frigate_button_5_pressed() -> void:
   player_fleet.push_back("frigate")

# player top rack
func _on_player_slot_1_pressed() -> void:
   if player_rack_buttons[0].icon != null:
      player_fleet.remove_at(0)
func _on_player_slot_2_pressed() -> void:
   if player_rack_buttons[1].icon != null:
      player_fleet.remove_at(1)
func _on_player_slot_3_pressed() -> void:
   if player_rack_buttons[2].icon != null:
      player_fleet.remove_at(2)
func _on_player_slot_4_pressed() -> void:
   if player_rack_buttons[3].icon != null:
      player_fleet.remove_at(3)
func _on_player_slot_5_pressed() -> void:
   if player_rack_buttons[4].icon != null:
      player_fleet.remove_at(4)

func _on_back_button_pressed() -> void:
   get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_start_button_pressed() -> void:
   Global.player_fleet = player_fleet
   get_tree().change_scene_to_file("res://scenes/space_game.tscn")
