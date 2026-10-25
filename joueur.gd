extends CharacterBody3D

const SPEED = 5.0
const SPEED_LATERAL = 3.0
const SPEED_SPRINT = 25.0

const JUMP_VELOCITY = 4.5*2
const ROT_SPEED = 2
const BEND_SPEED = 1
const MAX_BEND_ANGLE : float = PI/4

const NOACTION_PERIOD : float = 10.0
signal inactif
signal actif
var pausing = false

var _started : bool = false
var freezed : bool = false
var accroupi : bool = false
var albumopened : bool = false
var albumopening : bool = false
var mouse_captured : bool = false
var look_dir : Vector2
var camera_sens : float = 1.0

const MAXPHOTOS = 24
var photosrestantes = MAXPHOTOS

var objectifs :
	set(ref):
		objectifs = ref
		$Album.objectifs = ref

func start():
	_started = true
	capture_mouse()

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
	%SubViewport.get_camera_3d()
	
# FPS MOUSEMOTION
func _input(event: InputEvent) -> void:
	# on attend que la partie soit démarée
	if not _started: return
	
	# On est freeze tant que l'album est ouvert
	if albumopened : return
	
	if mouse_captured and event is InputEventMouseMotion:
		#rotation_degrees.y -= event.relative.x / 10
		%Tete.rotation_degrees.x -= event.relative.y / 10
		%Tete.rotation_degrees.x = clamp(%Tete.rotation_degrees.x, -70, 70)
		rotation_degrees.y -= event.relative.x / 10
		
		%Camera3D2.rotation_degrees.x -= event.relative.y / 10
		%Camera3D2.rotation_degrees.x = clamp(%Tete.rotation_degrees.x, -70, 70)
		

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

func _on_no_action_timeout() -> void:
	# Il ne s'est rien passé depuis X secondes
	inactif.emit()
	pausing = true
	pass # Replace with function body.

func inaction():
	$TimerNoAction.start(NOACTION_PERIOD)
	if pausing :
		pausing = false
		actif.emit()

func _physics_process(delta: float) -> void:
	# On est freeze tant que l'album est ouvert
	if albumopened : return
	
	# on attend que la partie soit démarée
	if not _started: return
	
	# Add the gravity ?
	if not self.is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		inaction()
		return
		#if velocity != Vector3.ZERO : print(velocity)
	#elif freezed :
		## do nothing
		#pass
	#else :
	
	_handle_joypad_camera_rotation(delta)
	
	
	var running : bool = false
	
	if true:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		#var bend = Input.get_action_strength("back")
		var front = -Input.get_action_strength("front") + Input.get_action_strength("back")
		var lateral = Input.get_action_strength("left") - Input.get_action_strength("right")
		running = Input.is_action_pressed("run") and not is_aiming
		
		var speed = SPEED_SPRINT if running else SPEED
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
				inaction()
				
				# Hide UI and way for frame refresh
				$Control/ViewFinder.visible = false
				$Pellicule.visible = false
				await RenderingServer.frame_post_draw
				# Get screenshot
				var screenshot_img = get_viewport().get_texture().get_image()
				
				var infrared_img = %SubViewport.get_texture().get_image()
				
				
				# Show UI again
				$Control/ViewFinder.visible = true
				$Pellicule.visible = true
				
				photosrestantes -= 1
				for pellicule in $Pellicule/HBoxContainer.get_children():
					if pellicule is TextureRect :
						pellicule.queue_free()
						break
						
				var scores
				var sujet_photo
				var objectif
				var color
				
				scores = get_scores_objectifs(infrared_img)
				
				for i in range(scores.size()):
					
					if scores[i].score >= 100:
					#	print("Cette photo contient un " + scores[i].objectif)
						sujet_photo = scores[i].objectif
					#elif scores[i].score > 0:
					#	print("Cette photo contient un " + scores[i].objectif + " mais il est trop petit ou masqué :(")
				
				if sujet_photo:
					var sujet = get_node("../Objectifs/"+sujet_photo)
					sujet.catched.emit(sujet_photo, sujet, screenshot_img)
				else:
					if not DirAccess.dir_exists_absolute(OS.get_user_data_dir() + "/photos/") :
						DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir() + "/photos/")
					var timestamp : String = Time.get_datetime_string_from_system().replace("-", "").replace(":", "").replace("T", "")
					
					var save_path = OS.get_user_data_dir() + "/photos/" + timestamp + ".png"
					screenshot_img.save_png(save_path)
				
				#var file = FileAccess.open("user://SHOOT", FileAccess.READ)
				#if file != null :
				#	var content = file.get_as_text()
				#	print(content) #FIXME
				#	var sujet = get_node("../Objectifs/"+content)
				#	sujet.catched.emit(content, sujet, screenshot_img)
				#	file.close()
				###
			
			
		if Input.is_action_just_pressed("aim") and not Input.is_action_pressed("run"):
			is_aiming = true
			$Control/ViewFinder.visible = true
			%Tete/Camera3D.fov = 50.0
			inaction()
			
		
		if Input.is_action_just_released("aim"):
			is_aiming = false
			$Control/ViewFinder.visible = false
			%Tete/Camera3D.fov = 75.0
			inaction()
	
	if (velocity.x != 0.0 or velocity.y != 0) and is_on_floor():
		if running :
			$AudioSteps.stop()
			if not $AudioRun.playing :$AudioRun.play()
		else:
			$AudioRun.stop()
			if not $AudioSteps.playing : $AudioSteps.play()
	elif velocity.x == 0.0 and velocity.y == 0 :
		$AudioSteps.stop()
		$AudioRun.stop()
	
	#if velocity != Vector3.ZERO : print (velocity)
	
	if velocity != Vector3.ZERO :
		inaction()
		move_and_slide()

	%Camera3D2.global_transform = %Tete/Camera3D.global_transform

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

func get_photos_prises():
	return MAXPHOTOS - photosrestantes

func _on_animation_finished(anim_name: StringName) -> void:
	albumopening = false
	if anim_name == "showalbum":
		albumopened = true
	elif anim_name == "hidealbum":
		albumopened = false
	pass # Replace with function body.
	
	
func get_scores_objectifs(img: Image) -> Array:
	var thresold = 0.2
	var nb_pixels = 0
	var scores : Array = [
		{"objectif" : "Biche", "color": Color(0.9922, 0.0824, 0.102, 1.0), "score": 0},	
		{"objectif": "Fleur", "color": Color(0.0824, 0.9922, 0.102, 1.0), "score": 0},	
		{"objectif": "Buron", "color": Color(0.0824, 0.102, 0.9922, 1.0), "score": 0}
	] 
	var target_color
	# 2. Parcourir chaque pixel (X et Y)
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			# 3. Récupérer la couleur du pixel actuel
			var pixel_color = img.get_pixel(x, y)
			for i in range(scores.size()):
				target_color = scores[i].color
				# 4. Comparer avec la couleur recherchée
				if pixel_color.r >= target_color.r - thresold and pixel_color.r <= target_color.r + thresold and pixel_color.g >= target_color.g - thresold and pixel_color.g <= target_color.g + thresold and pixel_color.b >= target_color.b - thresold and pixel_color.b <= target_color.b + thresold:
					scores[i].score += 1
	return scores
