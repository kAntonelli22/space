extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
   pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
   pass



func _on_play_button_pressed():
   get_tree().change_scene_to_file("res://scenes/space_game.tscn")

func _on_guide_button_pressed():
   print("Open Guide")

func _on_settings_button_pressed():
   print("Open Settings")

func _on_exit_button_pressed():
   get_tree().quit()