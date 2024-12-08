extends CanvasLayer

signal game_paused
signal turn_over

@onready var main_node := get_parent()

# ui components
@onready var info_panel = $"BottomLeft"
@onready var name_label = $"BottomLeft/VBoxContainer/Label"
@onready var health_bar = $"BottomLeft/VBoxContainer/HealthBar"
@onready var movement_bar = $"BottomLeft/VBoxContainer/MovementBar"

@onready var pause_menu = $"../PauseMenu"

# Called when the node enters the scene tree for the first time.
func _ready():
   pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
   pass


func _on_pause_button_pressed():
   pause_menu.show()
   get_tree().paused = true

func _on_turn_button_pressed():
   get_parent().turn_counter += 1
   $BottomRight/TurnCount.text = str("Turn Count: ", get_parent().turn_counter)
   emit_signal("turn_over")

# toggles and updates the bottom left info panel with the selected object
func update_info_panel():
   main_node.obj_selected
   name_label.text = main_node.obj_selected.name
   
   health_bar.max_value = main_node.obj_selected.MAX_HEALTH
   health_bar.value = main_node.obj_selected.health_points
   
   movement_bar.max_value = main_node.obj_selected.MAX_MOVEMENT
   movement_bar.value = main_node.obj_selected.movement_points
   
   info_panel.visible = true
