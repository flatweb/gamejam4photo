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
		%Album.objectifs = ref

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

@export var camera_FOV = 55

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
	$Control/ViewFinder.hide()
	%Photo.hide()
	
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

func in_action():
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
		in_action()
		return
		#if velocity != Vector3.ZERO : print(velocity)
	
	_handle_joypad_camera_rotation(delta)
	
	var running : bool = false
	
	if not freezed:
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
		
		# Prise de vue
		if Input.is_action_just_pressed("shoot") and is_aiming :
			if photosrestantes > 0 :
				shootphoto()
		
		# Visée
		if Input.is_action_just_pressed("aim") and not Input.is_action_pressed("run"):
			is_aiming = true
			$AudioAim.play()
			$Control/ViewFinder.visible = true
			%Tete/Camera3D.fov = 50.0
		
	if is_aiming: in_action()
	
	# Fin de visée, relachement ud bouton
	if Input.is_action_just_released("aim"):
		is_aiming = false
		$Control/ViewFinder.visible = false
		%Tete/Camera3D.fov = 75.0
		in_action()
	
	if not freezed:
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
	
		if velocity != Vector3.ZERO :
			in_action()
			move_and_slide()

	%Camera3D2.global_transform = %Tete/Camera3D.global_transform

func shootphoto():
		in_action()
		$AudioShoot.play()
		
		# Hide UI and way for frame refresh
		$Control/ViewFinder.visible = false
		$Pellicule.visible = false
		await RenderingServer.frame_post_draw
		
		# Get screenshot FIXME pour avoir un zoom de la vue
		var screenshot_img = get_viewport().get_texture().get_image()
		
		# Controle de l'objectif visé
		var sujet_photo
		var resultat : Check
		if Global.has_option("INFRARED") :
			sujet_photo = check_objectif_by_infrared()
			if sujet_photo == null : resultat = Check.RATE
			else: resultat = Check.OK
		else:
			var resultphoto = check_objectif_by_raycast()
			sujet_photo = resultphoto["body"]
			resultat = resultphoto["result"]
			
		# Show UI again
		$Control/ViewFinder.visible = true
		$Pellicule.visible = true
		
		photosrestantes -= 1
		for pellicule in $Pellicule/HBoxContainer.get_children():
			if pellicule is TextureRect :
				pellicule.queue_free()
				break
		
		if resultat == Check.OK:
			# On a bien pris un sujet en photo
			Global.showstamp("OK")
			var sujet = find_objectif_in_tree(sujet_photo)
			showphoto(screenshot_img,sujet_photo)
			sujet.catched.emit(sujet_photo, sujet, screenshot_img)
		elif resultat == Check.TROPLOIN :
			Global.showstamp("TropLoin")
		elif resultat == Check.CACHE :
			Global.showstamp("Rate")
		else:
			if not DirAccess.dir_exists_absolute("user://photos/") :
				DirAccess.make_dir_recursive_absolute("user://photos/")
			var timestamp : String = Time.get_datetime_string_from_system().replace("-", "").replace(":", "").replace("T", "")
			
			var save_path = "user://photos/" + timestamp + ".png"
			screenshot_img.save_png(save_path)
			sujet_photo = timestamp
			showphoto(screenshot_img,sujet_photo)
		
func find_objectif_in_tree(sujet : String, node : Node3D = null):
	if node == null : node = get_node("../Objectifs/")
	if node.name == sujet : return node
	for child in node.get_children():
		if not child is Node3D : continue
		var found = find_objectif_in_tree(sujet,child)
		if found != null : return found
	return null

func showphoto(img,nom):
	$Control/ViewFinder.hide()
	%Photo.show()
	%Photo.change(img,nom)
	$TimerPhoto.start()
	freezed = true

func _on_timer_photo_timeout() -> void:
	%Photo.hide()
	# Visée
	if Input.is_action_pressed("aim"):
		# On a toujours le doigt appuyé sur le clic du viseur
		$Control/ViewFinder.show()
	
	freezed = false
	
	
func _process(delta : float):
	# Pas d'action autorisée sur l'album est en train de bouger
	if albumopening : return
	if freezed: return
	
	if Input.is_action_just_pressed("esc"):
		toggle_cursor_mode()
		# FIXME : on garde ça ici ?
	
	if Input.is_action_just_pressed("album") and not albumopened :
		albumopening = true
		%Album.load_photos()
		%Album.show()
		$AnimationPlayer.play("showalbum")
		%Album.showup()
	elif Input.is_action_just_pressed("album") and albumopened :
		albumopening = true
		$AnimationPlayer.play("hidealbum")
		%Album.hidedown()
		
	if albumopened:
		if Input.is_action_just_pressed("right"):
			%Album.pagenext()
		elif Input.is_action_just_pressed("left"):
			%Album.pageprev()

func get_photos_prises():
	return MAXPHOTOS - photosrestantes

func _on_animation_finished(anim_name: StringName) -> void:
	albumopening = false
	if anim_name == "showalbum":
		albumopened = true
	elif anim_name == "hidealbum":
		albumopened = false
		%Album.hide()
	pass # Replace with function body.

##################################################################
## Algorithme de recherche d'objectif par envoi de rayon (raycast)
##################################################################

enum Check {OK, RATE, CACHE, TROPLOIN}

func check_objectif_by_raycast() -> Dictionary:
	var scanresult : Dictionary
	var result = {"result" : Check.RATE, "body" : null}
	# Cherche un body dans le cadre en utilisant le raycast
	scanresult = scan_by_raycast()
	if scanresult["result"] == Check.RATE :
		# Il n'y a rien sur la photo, ou bien c'est trop petit !
		return scanresult
	
	var body : PhysicsBody3D = scanresult["body"]
	if body.get("ObjectifName") != null and body.get("ObjectifName") != "":
		result["body"] = body.get("ObjectifName")
	else:
		result["body"] = body.name
	
	if scanresult["result"] == Check.TROPLOIN:
		return scanresult
	
	# Vérifie si il y a un obstacle devant le body
	if check_obstacles_in_photo(body):
		# Il y a un obstacle
		result["result"] = Check.CACHE
		return result
	
	result["result"] = Check.OK 
	return result

## Pourcentage minimum pour considérer que le sujet est bien pris
## dans la zone centrale (container ZoneCentre)
const COVERAGEMIN = 0.02  #TODO : à tuner

func scan_by_raycast() -> Dictionary:
	var cam : Camera3D = %Camera3D
	const RAY_LENGTH = 1000 # TODO
	var scans = 0
	var hits : Dictionary
	var bodies : Dictionary
	var space_state = get_world_3d().direct_space_state
	for x in range(%ZoneCentre.position.x,%ZoneCentre.position.x + %ZoneCentre.size.x,20):
		for y in range(%ZoneCentre.position.y,%ZoneCentre.position.y + %ZoneCentre.size.y,20):
			scans += 1
			# position au centre de l'image
			var pos = Vector2(x,y)
			var origin = cam.project_ray_origin(pos)
			var end = origin + cam.project_ray_normal(pos) * RAY_LENGTH
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			query.collide_with_areas = true
			var result = space_state.intersect_ray(query)
			if not result.is_empty():
				var cc = result["collider"]
				if cc.name.begins_with("@StaticBody3D"):
					continue
				#print (origin, "->",end,"=",cc.name)
				var groups : Array = cc.get_groups()
				if groups.size() >0 and groups.has("objectif"):
					if not hits.has(cc.name):
						hits[cc.name] = 0
						bodies[cc.name] = cc
					hits[cc.name] += 1
	#print (hits)
	if hits.size() == 0:
		# On n'a rien touché du tout
		return {"result" : Check.RATE, "body" : null}
	
	# Recherche maintenant le maximum
	var maxpcthit : float = 0.0
	var objhit = null
	for k in hits.keys() :
		if float(hits[k])/scans > maxpcthit:
			objhit = bodies[k]
			maxpcthit = float(hits[k])/scans
	#print (objhit," gets ",maxpcthit)
	if maxpcthit >= COVERAGEMIN : #FIXME pour être plus précis
		return {"result" : Check.OK, "body" : objhit}
	else:
		return {"result" : Check.TROPLOIN, "body" : objhit}
	
	
## Vérifie si il y a des obstacles devant la photo
func check_obstacles_in_photo(body : PhysicsBody3D) -> bool:
	for child in body.get_children():
		if child is CollisionShape3D:
			var shape = child.shape
			var obstacle : Node3D = null
			# Do something with shape_res or child
			if shape is BoxShape3D :
				obstacle = check_obstacle_to_boxshape(body,child, shape)
			elif shape is CylinderShape3D:
				obstacle = check_obstacle_to_cylindershape(body,child, shape)
			if obstacle != null :
				# Il y a un obstacle devant le sujet sur la photo
				return true
	# On a tout parcouru, il n'y a donc pas d'obstacle
	return false

const ECHANTILLONNAGE = 20

## Controle de la présente d'un obstacle entre le sujet et l'appareil
## quand le sujet a une forme de cube (type BoxShape3D)
func check_obstacle_to_boxshape(body : PhysicsBody3D, collisionshape : CollisionShape3D, boxshape : BoxShape3D) -> Node3D:
	for nx in range(-ECHANTILLONNAGE/2,ECHANTILLONNAGE/2+1):
		var x = boxshape.size.x * (float(nx)/ECHANTILLONNAGE)
		for nz in range(-ECHANTILLONNAGE/2,ECHANTILLONNAGE/2+1):
			var z = boxshape.size.z * (float(nz)/ECHANTILLONNAGE)
			for ny in range(-ECHANTILLONNAGE/2,ECHANTILLONNAGE/2+1):
				var y = boxshape.size.y * (float(ny)/ECHANTILLONNAGE)
				# position au centre de l'image
				var end : Vector3 = collisionshape.global_position + Vector3(x,y,z)
				var cast = cast_ray_to_obstacle(body,end)
				if cast == null:
					continue
				return cast # FIXME
	# On n'a rien trouvé, donc il n'y a pas d'obstacle
	return null

## Controle de la présente d'un obstacle entre le sujet et l'appareil
## quand le sujet a une forme de cylidre (type CylinderShape3D)
func check_obstacle_to_cylindershape(body : PhysicsBody3D, collisionshape : CollisionShape3D, cylshape : CylinderShape3D) -> Node3D:
	for nangle in range(-ECHANTILLONNAGE/2,ECHANTILLONNAGE/2+1):
		var angle : float = PI * (float(nangle)/ECHANTILLONNAGE)
		for ny in range(-ECHANTILLONNAGE/2,ECHANTILLONNAGE/2+1):
			var y = cylshape.height * (float(ny)/ECHANTILLONNAGE)
			var radius = cylshape.radius
			# Dans un premier temps, on considère que le cylindre est vertical : TODO
			var end : Vector3 = collisionshape.global_position + Vector3(radius*cos(angle),y,radius*sin(angle))
			var cast = cast_ray_to_obstacle(body,end)
			if cast == null:
				continue
			return cast # FIXME
	# On n'a rien trouvé, donc il n'y a pas d'obstacle
	return null
	
	
# Envoie un ray cast de la caméra vers la cible "end"
# Retourne null si on touche soi-même ou la map (sol)
# Retourne null si on touche un objet plus loin que body
# Retourne le parent de l'objet touché 
func cast_ray_to_obstacle(body : PhysicsBody3D, end : Vector3):
	var cam = %Camera3D
	var space_state = get_world_3d().direct_space_state
	var distbody = body.global_position.distance_to(cam.global_position)
	var origin : Vector3 = cam.global_position #cam.project_ray_origin(pos)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		var cc = result["collider"]
		# Si c'est la map du sol, on ignore
		# Si c'est l'objet lui-même, on ignore
		if cc == body :
			return null
		# FIXME : si c'est le sol, il faudrait quand même vérifier qu'on ne masque pas
		if cc.name.begins_with("@StaticBody3D"):
			return null #
		var distance = origin.distance_to(result["position"])
		#print ("dist : ",result["position"],"  --  ",distance, " versus ",distbody)
		# Reste à savoir si l'objet est au loin, ou devant...
		if (distance < distbody):
			print("Un objet ",result["collider"].get_parent().name," masque le sujet ",body.name,"  à  ",distance, " versus ",distbody)
			return result["collider"]
	return null

##################################################################
## Algorithme de recherche d'objectif par la recherche de couleur
##################################################################

func check_objectif_by_infrared() :
		var scores
		var sujet_photo
		var objectif
		var color
		
		var infrared_img = %SubViewport.get_texture().get_image()
		var save_path_infrared = OS.get_user_data_dir() + "/photos/infrared.png"
		infrared_img.save_png(save_path_infrared)
		
		scores = get_scores_objectifs(infrared_img)
		
		for i in range(scores.size()):
			
			if scores[i].score >= 100:
				print("Cette photo contient un " + scores[i].objectif)
				sujet_photo = scores[i].objectif
			#elif scores[i].score > 0:
			#	print("Cette photo contient un " + scores[i].objectif + " mais il est trop petit ou masqué :(")
		

func get_scores_objectifs(img: Image) -> Array:
	var thresold = 0.2
	var nb_pixels = 0
	var scores : Array = [
		{"objectif": "Biche", "color": Color(0.9922, 0.0824, 0.102, 1.0), "score": 0},	
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
