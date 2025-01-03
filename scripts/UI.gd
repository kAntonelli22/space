extends CanvasLayer

@onready var main_node := get_parent()

# ui components
@onready var info_panel = $"BottomLeft"
@onready var name_label = $"BottomLeft/VBoxContainer/Label"
@onready var health_bar = $BottomLeft/VBoxContainer/Container/HealthBar
@onready var movement_bar = $BottomLeft/VBoxContainer/Container/MovementBar
@onready var action_bar = $BottomLeft/VBoxContainer/Container/ActionBar

@onready var pause_menu = $"../PauseMenu"
@onready var railgun_button = $"Left Side/Railgun"
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
   main_node.turn_counter += 1
   $BottomRight/TurnCount.text = str("Turn Count: ", main_node.turn_counter)
   Global.next_turn.emit()

# toggles and updates the bottom left info panel with the selected object
func update_info_panel(new_obj, _old_obj):
   name_label.text = new_obj.name
   
   health_bar.max_value = new_obj.MAX_HEALTH
   health_bar.value = new_obj.health_points
   
   movement_bar.max_value = new_obj.MAX_MOVEMENT
   movement_bar.value = new_obj.movement_points
   
   action_bar.max_value = new_obj.MAX_ACTION
   action_bar.value = new_obj.action_points
   
   info_panel.show()
   
func deselect_signal(_obj):
   info_panel.hide()

func connect_signals():
   Global.connect("obj_selected", update_info_panel)
   Global.connect("obj_deselected", deselect_signal)
   Global.connect("attributes_changed", update_info_panel)

# should probably find a way to connect the pressed signal directly
func _on_torpedo_pressed() -> void:
   Global.emit_signal("ui_torpedo")
   
func _on_railgun_pressed() -> void:
   Global.emit_signal("ui_railgun")

func _on_pdc_pressed() -> void:
   Global.emit_signal("ui_pdc")
