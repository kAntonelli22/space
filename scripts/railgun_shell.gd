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
   Global.obj_hit.emit(body, self, origin)
   
   # roll damage with 25% chance of crit or miss and 50% chance of hit
   var roll = randi_range(0, 3)
   if roll == 3 and "health_points" in body:
      body.health_points -= 2
   elif roll != 0 and "health_points" in body:
      body.health_points -= 1

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
      position += direction * (speed / 10.0) * delta
      sprite.modulate.a -= 0.05

func _on_visible_on_screen_notifier_2d_screen_exited():
   Global.shell_destroyed.emit(self, origin)
   self.queue_free()

func _on_destroy_timer_timeout():
   Global.shell_destroyed.emit(self, origin)
   self.queue_free()
