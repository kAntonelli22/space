extends Area2D

# variables
var origin
var direction : Vector2
var speed : int = 400
var hit_target : bool = false
var miss : bool = false
var percent : float

var damage : int = 1

@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
   self.rotation += direction.angle()
   
   # roll damage with chance of crit if roll is half of percent
   var roll = randi_range(0, 100)
   if roll <= percent / 2:
      damage *= 2
   elif roll > percent:
      miss = true
      damage = 0

# called on collision with objects or ships
func _on_body_entered(body):
   if body != origin:
      Global.obj_hit.emit(body, self, damage, origin)
      hit_target = true
      if !miss:
         position = body.position
         $Sprite2D.texture = preload("res://assets/railgun_debris.png")
         $DestroyTimer.start()

# handles movement of shell
func _physics_process(delta):
   if !hit_target or miss:
      position += direction * speed * delta
   elif hit_target and !miss:
      # slow down movement and fade away
      position += direction * (speed / 10.0) * delta
      sprite.modulate.a -= 0.05

func _on_visible_on_screen_notifier_2d_screen_exited():
   Global.shell_destroyed.emit(self, origin)
   self.queue_free()

func _on_destroy_timer_timeout():
   Global.shell_destroyed.emit(self, origin)
   self.queue_free()
