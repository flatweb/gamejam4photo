extends StaticBody3D

@export var speed : float = 0.0
var direction : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if speed > 0:
		newdirection()

func newdirection():
	direction = Vector3.FORWARD.rotated(Vector3.UP,randf_range(-PI,PI))
	
func _physics_process(delta: float) -> void:
	if speed > 0.0 :
		var collision = move_and_collide(direction*speed*delta)
		if collision.get_collision_count() > 0 :
			newdirection()
			
	if position.y < 1.0 :
		# on chute
		#FIXME
		pass
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
