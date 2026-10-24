extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROT_SPEED = 2
const BEND_SPEED = 1
const MAX_BEND_ANGLE : float = PI/4

var freezed : bool = false


func _physics_process(delta: float) -> void:
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
			
		if Input.is_action_just_pressed("shoot"):
			# Calling get_data() on the result gives us an Image we can call flip_y() on.
			var screenshot_img = get_viewport().get_texture().get_image()
			#img.flip_y()
			
			# Dimensions of the crop_zone match our camera TextureRect's size
			var crop_zone:Rect2 = Rect2(Vector2.ZERO, Vector2.ONE * 512)
			
			var cropped_img:Image = Image.create_empty(crop_zone.size.x, crop_zone.size.y, false, screenshot_img.get_format())
			cropped_img.blit_rect(screenshot_img, crop_zone, screenshot_img.get_size() / 2)
			
			var save_path = OS.get_user_data_dir() + "/photos/pic_" + Time.get_datetime_string_from_system().replace("-", "_") + ".png"
			screenshot_img.save_png(save_path)
			print(save_path)
			
			
			#$Photo.scale = Vector3.ONE / 10
			#var photo_texture = ImageTexture.create_from_image(cropped_img)
			#$Photo.texture = photo_texture # Sprite will show our viewport capture!
			

	move_and_slide()
