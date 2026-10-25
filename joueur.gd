extends CharacterBody3D

const SPEED = 5.0
const SPEED_LATERAL = 3.0
const SPEED_SPRINT = 25.0

const JUMP_VELOCITY = 4.5*2
const ROT_SPEED = 2
const BEND_SPEED = 1
const MAX_BEND_ANGLE : float = PI/4

var freezed : bool = false
var accroupi : bool = false
var albumopened : bool = false
var albumopening : bool = false
var mouse_captured : bool = true
var look_dir : Vector2
var camera_sens : float = 1.0

const MAXPHOTOS = 24
var photosrestantes = MAXPHOTOS

var objectifs :
	set(ref):
		objectifs = ref
		$Album.objectifs = ref

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

@onready var fps_camera: Camera3D = %Camera3D
#@onready var interaction_ray: RayCast3D = %InteractionRay

@export var camera_FOV = 55
@export var interaction_ray_length = 3.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#fps_camera.fov = camera_FOV
	for i in range(0,MAXPHOTOS):
		var textrect : TextureRect
		textrect = TextureRect.new()
		var res = load("res://ASSETS/SPRITES/pellicule.png")
		textrect.set_texture(res)
		textrect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		$Pellicule/HBoxContainer.add_child(textrect)
	
# FPS MOUSEMOTION
func _input(event: InputEvent) -> void:
			
	# On est freeze tant que l'album est ouvert
	if albumopened : return
	
	if mouse_captured and event is InputEventMouseMotion:
		#rotation_degrees.y -= event.relative.x / 10
		%Tete.rotation_degrees.x -= event.relative.y / 10
		%Tete.rotation_degrees.x = clamp(%Tete.rotation_degrees.x, -70, 70)
		rotation_degrees.y -= event.relative.x / 10
		

# INTERACTION RAY
#func interaction():
	#var hit = interaction_ray.get_collider()
	#if cursor_locked and interaction_ray.is_colliding():
		#if hit and hit.has_method("interact"):
			#hit.interact()

# MOUSEMODE TOGGLE
func toggle_cursor_mode():
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = !mouse_captured

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	
	# On est freeze tant que l'album est ouvert
	if albumopened : return
	
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		rotation.y -= look_dir.x * camera_sens * sens_mod
		%Tete.rotation.x = clamp(%Tete.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
		%Tete.rotation_degrees.x = clamp(%Tete.rotation_degrees.x, -70, 70)
		%Tete.rotation_degrees.y = clamp(%Tete.rotation_degrees.y, -70, 70)
		look_dir = Vector2.ZERO
	#else:
		#look_dir = Vector2(sign(%Tete.rotation_degrees.y),sign(%Tete.rotation_degrees.x))*delta
		#if sign(%Tete.rotation.x - look_dir.y * camera_sens * sens_mod) != sign(%Tete.rotation.x):
			#%Tete.rotation.x = 0.0
		#else:
			#%Tete.rotation.x = clamp(%Tete.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
		#look_dir = Vector2.ZERO


var is_aiming : bool = false


func _physics_process(delta: float) -> void:
	# On est freeze tant que l'album est ouvert
	if albumopened : return
	
	# Add the gravity ?
	if not self.is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
		#if velocity != Vector3.ZERO : print(velocity)
	#elif freezed :
		## do nothing
		#pass
	#else :
	
	_handle_joypad_camera_rotation(delta)
	
	if true:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		#var bend = Input.get_action_strength("back")
		var front = -Input.get_action_strength("front") + Input.get_action_strength("back")
		var lateral = Input.get_action_strength("left") - Input.get_action_strength("right")
		var sprint = Input.is_action_pressed("run") and not is_aiming
		
		var speed = SPEED_SPRINT if sprint else SPEED
		var direction : Vector3
		direction = Vector3(sin(rotation.y),0,cos(rotation.y))
		velocity = direction.normalized()*front*speed
		velocity +=  Vector3(-cos(rotation.y),0,sin(rotation.y)).normalized()*lateral*SPEED_LATERAL
		
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_pressed("accroupi"):
			if not accroupi and is_on_floor():
				$Corps.scale.y /= 3.0
				accroupi = true
		else:
			$Corps.scale.y = 1
			accroupi = false
		
		if Input.is_action_just_pressed("shoot") and is_aiming:
			# Si plus de pellicule, interdire
			if photosrestantes > 0 :
				# Hide UI and way for frame refresh
				$Control/ViewFinder.visible = false
				$Pellicule.visible = false
				await RenderingServer.frame_post_draw
				# Get screenshot
				var screenshot_img = get_viewport().get_texture().get_image()
				# Show UI again
				$Control/ViewFinder.visible = true
				$Pellicule.visible = true
				
				# Dimensions of the crop_zone match our camera TextureRect's size
				var crop_zone:Rect2 = Rect2(Vector2.ZERO, Vector2.ONE * 512)
				
				var cropped_img:Image = Image.create_empty(crop_zone.size.x, crop_zone.size.y, false, screenshot_img.get_format())
				cropped_img.blit_rect(screenshot_img, crop_zone, screenshot_img.get_size() / 2)
				
				if not DirAccess.dir_exists_absolute(OS.get_user_data_dir() + "/photos/") :
					DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir() + "/photos/")
				
				var save_path = OS.get_user_data_dir() + "/photos/" + Time.get_datetime_string_from_system().replace("-", "").replace(":", "").replace("T", "") + ".png"
				screenshot_img.save_png(save_path)
				print(save_path)
				
				photosrestantes -= 1
				for pellicule in $Pellicule/HBoxContainer.get_children():
					if pellicule is TextureRect :
						pellicule.queue_free()
						break
				
				#$Photo.scale = Vector3.ONE / 10
				#var photo_texture = ImageTexture.create_from_image(cropped_img)
				#$Photo.texture = photo_texture # Sprite will show our viewport capture!
			
		if Input.is_action_just_pressed("aim") and not Input.is_action_pressed("run"):
			is_aiming = true
			$Control/ViewFinder.visible = true
			%Tete/Camera3D.fov = 50.0
			
		
		if Input.is_action_just_released("aim"):
			is_aiming = false
			$Control/ViewFinder.visible = false
			%Tete/Camera3D.fov = 75.0
	#if velocity != Vector3.ZERO : print (velocity)
	move_and_slide()

func _process(delta : float):
	# Pas d'action autorisée sur l'album est en train de bouger
	if albumopening : return
	
	if Input.is_action_just_pressed("esc"):
		toggle_cursor_mode()
	
	if Input.is_action_just_pressed("album") and not albumopened :
		albumopening = true
		$Album.load_photos()
		$AnimationPlayer.play("showalbum")
		$Album.showup()
	elif Input.is_action_just_pressed("album") and albumopened :
		albumopening = true
		$AnimationPlayer.play("hidealbum")
		$Album.hidedown()
		
	if albumopened:
		if Input.is_action_just_pressed("right"):
			$Album.pagenext()
			pass
		elif Input.is_action_just_pressed("left"):
			$Album.pageprev()
			pass


func _on_animation_finished(anim_name: StringName) -> void:
	albumopening = false
	if anim_name == "showalbum":
		albumopened = true
	elif anim_name == "hidealbum":
		albumopened = false
	pass # Replace with function body.
