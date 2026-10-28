extends StaticBody3D

@export var vivacity : float = 5.0
var direction : Vector3
var animation : AnimationPlayer
var timer : Timer

signal catched(nom : String, node : Node3D, photo : Image)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func _physics_process(delta: float) -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout():
	pass
