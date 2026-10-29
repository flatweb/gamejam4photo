extends CharacterBody3D

@export var speed : float = 0.0
@export var vivacity : float = 5.0
var direction : Vector3
var animation : AnimationPlayer
var timer : Timer

signal catched(nom : String, node : Node3D, photo : Image)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if speed > 0.0 :
		newdirection()
		timer = Timer.new()
		timer.timeout.connect(_on_timer_timeout.bind())
		add_child(timer)
		timer.start(vivacity)
		
	# Cherche un AnimationPlayer
	animation = find_animation_player(self)
	if animation != null and animation.has_animation("ArmatureAction"):
		animation.play("ArmatureAction")
	
# Cherche le premier Node AnimationPlayer
func find_animation_player(node) -> AnimationPlayer:
	if node is AnimationPlayer :
		return node
	for child in node.get_children():
		var anim = find_animation_player(child)
		if anim != null :
			return anim
	return null
	
func newdirection():
	var orientation = randf_range(-PI,PI)
	direction = Vector3.FORWARD.rotated(Vector3.UP,orientation)
	rotation = Vector3(0,orientation,0)
	direction += Vector3.UP*0.05
	#print(rotation)


func _physics_process(delta: float) -> void:	
	velocity = direction * speed
	# Add the gravity ?
	if not self.is_on_floor():
		velocity += get_gravity()
		
	if speed > 0.0 :
		var obstacle : bool = false
		move_and_slide()
		#var collisions = move_and_collide(velocity*delta)
		#if collisions != null and collisions.get_collision_count() > 0 :
			#for i in range(0,collisions.get_collision_count()):
				#var collider  = collisions.get_collider()
				#if collider is StaticBody3D:
					#var body = collider as StaticBody3D
					#if not body.is_in_group("floor"):
						#print(body)
						#print(body.get_parent().get_groups())
						#obstacle = true
						#break
			#if obstacle:
				##newdirection()
				#pass
	
	if position.y < -20 :
		pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	newdirection()
	timer.start(vivacity)
