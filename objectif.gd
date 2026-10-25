extends StaticBody3D

@export var speed : float = 0.0
@export var vivacity : float = 5.0
var direction : Vector3

signal catched(nom : String, node : Node3D, photo : Image)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if speed > 0.0 :
		newdirection()
		$Timer.start(vivacity)

func newdirection():
	direction = Vector3.FORWARD.rotated(Vector3.UP,randf_range(-PI,PI))

func _physics_process(delta: float) -> void:
	if speed > 0.0 :
		var collisions = move_and_collide(direction*speed*delta)
		if collisions != null and collisions.get_collision_count() > 0 :
			newdirection()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	newdirection()
	$Timer.start(vivacity)
