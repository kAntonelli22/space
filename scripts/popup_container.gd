extends Node2D

# nodes
@onready var container := $LabelContainer
@onready var label := $LabelContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
   pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
   pass

# create random tween going up in a random direction and a random speed

func create_popup_tween():
   pass

func remove_popup():
   queue_free()
