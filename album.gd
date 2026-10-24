extends Node3D

enum Cote {GAUCHE, DROITE}

var pageon = 0
var quests : Array = [
	{"img" : null, "titre": "Champignon", "indice" : "sous les arbres"},
	{"img" : null, "titre": "Caillou", "indice" : "partout"},
	{"img" : null, "titre": "Arbre", "indice" : "dans la forêt"},
	{"img" : null, "titre": "Oiseau", "indice" : "dans les arbres"},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_photos()
	changetopageon()
	pass # Replace with function body.

func open():
	$AudioOpen.play()
	
func close():
	$AudioOpen.play()

func lasteven(n :int):
	if n % 2 == 1:
		return n-1

func pageprev():
	pageon = max(0,pageon-2)
	changetopageon()
	
func pagenext():
	pageon = min(lasteven(quests.size()-1),pageon+2)
	changetopageon()

func changetopageon():
	$AudioTurn.play()
	change(Cote.GAUCHE,quests[pageon]["img"],quests[pageon]["titre"],quests[pageon]["indice"])
	if quests.size() > pageon+1:
		change(Cote.DROITE,quests[pageon+1]["img"],quests[pageon+1]["titre"],quests[pageon+1]["indice"])
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
				quests.append({"img" : photo, "titre": file_name, "indice" : ""})
				print("Loaded " + photos_folder_path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
