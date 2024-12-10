extends CanvasLayer

@onready var main_node := get_parent()

# ui components
@onready var info_panel = $"BottomLeft"
@onready var name_label = $"BottomLeft/VBoxContainer/Label"
@onready var health_bar = $BottomLeft/VBoxContainer/Container/HealthBar
@onready var movement_bar = $BottomLeft/VBoxContainer/Container/MovementBar
@onready var action_bar = $BottomLeft/VBoxContainer/Container/ActionBar

@onready var pause_menu = $"../PauseMenu"

# Called when the node enters the scene tree for the first time.
func _ready():
   pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
   pass


func _on_pause_button_pressed():
   pause_menu.show()
   get_tree().paused = true

func _on_turn_button_pressed():
   get_parent().turn_counter += 1
   $BottomRight/TurnCount.text = str("Turn Count: ", get_parent().turn_counter)
   Global.next_turn.emit()

# toggles and updates the bottom left info panel with the selected object
func update_info_panel(obj):
   name_label.text = obj.name
   
   health_bar.max_value = obj.MAX_HEALTH
   health_bar.value = obj.health_points
   
   movement_bar.max_value = obj.MAX_MOVEMENT
   movement_bar.value = obj.movement_points
   
   action_bar.max_value = obj.MAX_ACTION
   action_bar.value = obj.action_points
   
   info_panel.show()
   
func select_signal(new_obj, _old_obj):
   update_info_panel(new_obj)
   
func deselect_signal(_obj):
   info_panel.hide()

func connect_signals():
   Global.connect("obj_selected", select_signal)
   Global.connect("obj_deselected", deselect_signal)
