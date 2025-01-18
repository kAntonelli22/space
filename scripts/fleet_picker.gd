extends Control

# nodes
@onready var player_rack : Node = $ColorRect/MarginContainer/VBoxContainer/FleetContainer/PlayerFleet
@onready var enemy_rack: Node = $ColorRect/MarginContainer/VBoxContainer/FleetContainer/EnemyFleet

# player variables
var player_fleet : Array = []
var enemy_fleet : Array = []
var player_fleet_size : int = 0
var enemy_fleet_size : int = 0
@onready var player_rack_buttons : Array = player_rack.get_children()
@onready var enemy_rack_buttons : Array = enemy_rack.get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
   if player_fleet_size != player_fleet.size():
      player_fleet_size = player_fleet.size()
      update_rack(player_fleet, player_rack_buttons)
   if enemy_fleet_size != enemy_fleet.size():
      enemy_fleet_size = enemy_fleet.size()
      update_rack(enemy_fleet, enemy_rack_buttons)

func update_rack(fleet : Array, buttons : Array):
   for i in fleet.size():
      buttons[i].icon = Global.ship_sprites[fleet[i]]
   for i in range(fleet.size(), buttons.size()):
      buttons[i].icon = null
      
func add_to_fleet(ship):
   pass

func remove_from_fleet(buttons, fleet, index):
   if buttons[index].icon != null:
      fleet.remove_at(index)

# player bottom rack
func _on_player_frigate_button_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_player_frigate_button_2_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_player_frigate_button_3_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_player_frigate_button_4_pressed() -> void:
   player_fleet.push_back("frigate")
func _on_player_frigate_button_5_pressed() -> void:
   player_fleet.push_back("frigate")

# enemy bottom rack
func _on_enemy_frigate_button_pressed() -> void:
   enemy_fleet.push_back("frigate")
func _on_enemy_frigate_button_2_pressed() -> void:
   enemy_fleet.push_back("frigate")
func _on_enemy_frigate_button_3_pressed() -> void:
   enemy_fleet.push_back("frigate")
func _on_enemy_frigate_button_4_pressed() -> void:
   enemy_fleet.push_back("frigate")
func _on_enemy_frigate_button_5_pressed() -> void:
   enemy_fleet.push_back("frigate")

# player top rack
func _on_player_slot_1_pressed() -> void:
   remove_from_fleet(player_rack_buttons, player_fleet, 0)
func _on_player_slot_2_pressed() -> void:
   remove_from_fleet(player_rack_buttons, player_fleet, 1)
func _on_player_slot_3_pressed() -> void:
   remove_from_fleet(player_rack_buttons, player_fleet, 2)
func _on_player_slot_4_pressed() -> void:
   remove_from_fleet(player_rack_buttons, player_fleet, 3)
func _on_player_slot_5_pressed() -> void:
   remove_from_fleet(player_rack_buttons, player_fleet, 4)

# enemy top rack
func _on_enemy_slot_1_pressed() -> void:
   remove_from_fleet(enemy_rack_buttons, enemy_fleet, 0)
func _on_enemy_slot_2_pressed() -> void:
   remove_from_fleet(enemy_rack_buttons, enemy_fleet, 1)
func _on_enemy_slot_3_pressed() -> void:
   remove_from_fleet(enemy_rack_buttons, enemy_fleet, 2)
func _on_enemy_slot_4_pressed() -> void:
   remove_from_fleet(enemy_rack_buttons, enemy_fleet, 3)
func _on_enemy_slot_5_pressed() -> void:
   remove_from_fleet(enemy_rack_buttons, enemy_fleet, 4)

func _on_back_button_pressed() -> void:
   get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_start_button_pressed() -> void:
   Global.player_fleet = player_fleet
   Global.enemy_fleet = enemy_fleet
   get_tree().change_scene_to_file("res://scenes/battle.tscn")
