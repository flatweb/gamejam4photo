extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROT_SPEED = 2
const BEND_SPEED = 1
const MAX_BEND_ANGLE : float = PI/4

var freezed : bool = false
var albumopened : bool = false
var albumopening : bool = false

func _physics_process(delta: float) -> void:
	
	# On est freeze tant que l'album est ouvert
	if albumopened : return
	
	# Add the gravity ?
	#if not self.is_on_floor():
		#velocity += get_gravity() * delta
		##if velocity != Vector3.ZERO : print(velocity)
	#elif freezed :
		## do nothing
		#pass
	#else :
	if true:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		#var bend = Input.get_action_strength("back")
		var front = -Input.get_action_strength("front") + Input.get_action_strength("back")
		var turn = Input.get_action_strength("left") - Input.get_action_strength("right")
		if turn != 0 :
			rotate_y(delta*turn*ROT_SPEED)
			
		var direction : Vector3
		direction = Vector3(sin(rotation.y),0,cos(rotation.y))
		velocity = direction.normalized()*front*SPEED

		#if bend > 0:
			#var bendangle = min(delta*BEND_SPEED,MAX_BEND_ANGLE)
			## on se benche en arrière, donc on va vers le négatif
			#rotation.x = max(rotation.x-bendangle,-MAX_BEND_ANGLE)
		#elif rotation.x < 0 :
			#var bendangle = min(delta*BEND_SPEED,MAX_BEND_ANGLE)
			## on revient droit, donc on va vers zéro
			#rotation.x = min(rotation.x+bendangle,0)
			
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	move_and_slide()

func _process(delta : float):
	# Pas d'action autorisée sur l'album est en train de bouger
	if albumopening : return
	if Input.is_action_just_pressed("album") and not albumopened :
		albumopening = true
		$AnimationPlayer.play("open")
	elif Input.is_action_just_pressed("album") and albumopened :
		albumopening = true
		$AnimationPlayer.play("close")


func _on_animation_finished(anim_name: StringName) -> void:
	albumopening = false
	if anim_name == "open":
		albumopened = true
	elif anim_name == "close":
		albumopened = false
	pass # Replace with function body.
