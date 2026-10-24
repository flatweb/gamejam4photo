extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROT_SPEED = 2
const BEND_SPEED = 1
const MAX_BEND_ANGLE : float = PI/4

var freezed : bool = false
var albumopened : bool = false
var albumopening : bool = false
var mouse_captured : bool = false

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false



@onready var fps_camera: Camera3D = %Camera3D
@onready var interaction_ray: RayCast3D = %InteractionRay

@export var camera_FOV = 55
@export var interaction_ray_length = 3.0

var cursor_locked = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#fps_camera.fov = camera_FOV
	
# FPS MOUSEMOTION
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		var mouseevent = event as InputEventMouseButton
		if mouseevent.pressed and not cursor_locked :
			# Passage en mode
			toggle_cursor_mode()
		elif mouseevent.pressed == false and cursor_locked :
			$Tete.rotation_degrees.x = 0.0
			$Tete.rotation_degrees.y = 0.0
			toggle_cursor_mode()
			
	if cursor_locked and event is InputEventMouseMotion:
		#rotation_degrees.y -= event.relative.x / 10
		$Tete.rotation_degrees.x -= event.relative.y / 10
		$Tete.rotation_degrees.x = clamp($Tete.rotation_degrees.x, -70, 70)
		$Tete.rotation_degrees.y -= event.relative.x / 10
		$Tete.rotation_degrees.y = clamp($Tete.rotation_degrees.y, -70, 70)
		

# INTERACTION RAY
#func interaction():
	#var hit = interaction_ray.get_collider()
	#if cursor_locked and interaction_ray.is_colliding():
		#if hit and hit.has_method("interact"):
			#hit.interact()

# MOUSEMODE TOGGLE
func toggle_cursor_mode():
	if cursor_locked:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cursor_locked = !cursor_locked


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
	
	if Input.is_action_just_pressed("esc"):
		toggle_cursor_mode()
	
	if Input.is_action_just_pressed("album") and not albumopened :
		albumopening = true
		$AnimationPlayer.play("open")
	elif Input.is_action_just_pressed("album") and albumopened :
		albumopening = true
		$AnimationPlayer.play("close")
		
	if albumopened:
		if Input.is_action_just_pressed("right"):
			$Album.pagenext()
			pass
		elif Input.is_action_just_pressed("left"):
			$Album.pageprev()
			pass


func _on_animation_finished(anim_name: StringName) -> void:
	albumopening = false
	if anim_name == "open":
		albumopened = true
	elif anim_name == "close":
		albumopened = false
	pass # Replace with function body.
