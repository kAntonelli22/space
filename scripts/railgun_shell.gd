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
   print("percent: ", percent, "roll: ", roll)
   if roll <= percent / 2:
      damage *= 2
      print("critical hit")
   elif roll > percent:
      miss = true
      damage = 0
      print("miss")
   else: # dont change sprite if shell misses
      print("hit")

# called on collision with objects or ships
func _on_body_entered(body):
   if body != origin:
      Global.obj_hit.emit(body, self, damage, origin)
      if !miss:
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
