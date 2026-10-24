extends Node3D

enum Cote {GAUCHE, DROITE}

var pageon = 0
var objectifs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_photos()
	pass # Replace with function body.

var opening = false
var opened = true

func open():
	if opened == false :
		$AnimationPlayer.play("open")
		opening = true
	$AudioOpen.play()
	
func close():
	if opened == true :
		$AnimationPlayer.play("close")
	$AudioOpen.play()

func lasteven(n :int):
	if n % 2 == 1:
		return n-1

func pageprev():
	var newpageon = max(0,pageon-2)
	if newpageon != pageon :
		pageon = newpageon
		closeandopen()
	
func pagenext():
	var newpageon = min(lasteven(objectifs.size()-1),pageon+2)
	if newpageon != pageon :
		pageon = newpageon
		closeandopen()

func closeandopen():
	$AnimationPlayer.play("close")
	opening = true
	
func changetopageon():
	change(Cote.GAUCHE,objectifs[pageon]["img"],objectifs[pageon]["titre"],objectifs[pageon]["indice"])
	if objectifs.size() > pageon+1:
		change(Cote.DROITE,objectifs[pageon+1]["img"],objectifs[pageon+1]["titre"],objectifs[pageon+1]["indice"])
	else :
		change(Cote.DROITE,null,"","")
	
func change(cote : Cote, img : Image, titre : String, indice : String):
	var page : Page
	if cote == Cote.GAUCHE :
		page = $PageGauche
	else :
		page = $PageDroite
	page.change(img,titre,indice)

func load_photos():
	var photos_folder_path = OS.get_user_data_dir() + "/photos/"
	var photo : Image
	var dir = DirAccess.open(photos_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				photo = Image.load_from_file(photos_folder_path + file_name)
				objectifs.append({"img" : photo, "titre": file_name, "indice" : ""})
				print("Loaded " + photos_folder_path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open":
		opening = false
		opened = true
	elif anim_name == "close":
		opening = true
		opened = false
		# On en profite pour changer les pages
		$AudioTurn.play()
		changetopageon()
		$AnimationPlayer.play("open")
