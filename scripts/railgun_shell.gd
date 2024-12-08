extends Area2D

# variables
var origin
var direction : Vector2
var speed : int = 400
var hit_target : bool = false

@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
   self.rotation += direction.angle()

# called on collision with objects or ships
func _on_body_entered(body):
   if body == origin:
      return
   hit_target = true
   position = body.position
   $Sprite2D.texture = preload("res://assets/railgun_debris.png")
   $DestroyTimer.start()

# handles movement of shell
func _physics_process(delta):
   if !hit_target:
      position += direction * speed * delta
   else:
      # slow down movement and fade away
      position += direction * (speed / 10) * delta
      sprite.modulate.a -= 0.05

func _on_visible_on_screen_notifier_2d_screen_exited():
   self.queue_free()

func _on_destroy_timer_timeout():
   self.queue_free()
