extends Camera2D

@onready var background := $"../Background"
@onready var top_left : Vector2 = Vector2.ZERO
@onready var bottom_right : Vector2 = background.size

func _ready():
   position = Vector2(bottom_right / 2)       # set camera position to middle of map
   #pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
   var moveby : Vector2
   # if user presses keys -> move in the direction pressed     
   if Input.is_action_pressed("CameraRight"):
      moveby.x += lerp(7.5, 2.5, (zoom.x - 1) / 4)
   if Input.is_action_pressed("CameraLeft"):
      moveby.x -= lerp(7.5, 2.5, (zoom.x - 1) / 4)
   if Input.is_action_pressed("CameraDown"):
      moveby.y += lerp(7.5, 2.5, (zoom.y - 1) / 4)
   if Input.is_action_pressed("CameraUp"):
      moveby.y -= lerp(7.5, 2.5, (zoom.y - 1) / 4)
   # if user zooms -> zoom in or out and clamp value
   if Input.is_action_just_released("ZoomUp"):
      zoom += Vector2(0.25, 0.25)
      zoom = zoom.clamp(Vector2(1, 1), Vector2(5, 5))
   if Input.is_action_just_released("ZoomDown"):
      zoom -= Vector2(0.25, 0.25)
      zoom = zoom.clamp(Vector2(1, 1), Vector2(5, 5))
   
   # update camera position and clamp it to map bounds
   position += moveby
   position = position.clamp(top_left + Vector2(96, 96), bottom_right - Vector2(96, 96))
# end of process function ----------------------------------------------------
