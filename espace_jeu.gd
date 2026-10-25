extends Node3D

const MARGEPOS = 10


var objectifs : Array = [
	{"img" : null, "titre": "Champignon", "indice" : "sous les arbres"},
	{"img" : null, "titre": "Caillou", "indice" : "partout"},
	{"img" : null, "titre": "Arbre", "indice" : "dans la forêt"},
	{"img" : null, "titre": "Oiseau", "indice" : "dans les arbres"},
]

var matched : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Repositionnement aléatoire du joueur dans l'Area3D
	#var asize = $Area3D/MeshInstance3D.mesh.size
	var randposx = randi_range(100/2+MARGEPOS, 100/2-MARGEPOS)
	var randposy = randi_range(-100/2+MARGEPOS, 100/2-MARGEPOS)
	$Joueur.position = Vector3(randposx, 0.5, randposy)
	$Joueur.rotation = Vector3(0,randf_range(0,PI),0)
	
	#FIXME : il faut maintenant gérer les collisions avec le décor
	
	#Lister les objectifs
	loadobjectifs(self)
	print(objectifs)
	
	$Joueur.objectifs = objectifs # Passage par référence, donc en cohérence
	
	var file = FileAccess.open("user://UNLOADMAP", FileAccess.READ)
	if file != null :
		$MAP/BIOME/FORET_EST.visible = false
		$MAP/BIOME/FORET_OUEST.visible = false
		unloadpins(self)
	pass

# Méthode spécifique pour alléger le modèle au run (perf PC Thierry)
func unloadpins(node : Node):
	for child in node.get_children():
		if child.name == "SAPIN" or child.name == "PIN":
			child.queue_free()
		elif child.get_child_count() > 0 :
			unloadpins(child)
		

func loadobjectifs(node : Node):
	if node.is_in_group("objectif"):
		var ind : int = 0
		for obj in objectifs :
			if obj["titre"] == node.name :
				objectifs[ind]["get"] = false
			ind += 1
		node.catched.connect(photo.bind())
		return
	if node.get_child_count() > 0 :
		for child in node.get_children():
			loadobjectifs(child)
	else:
		return

func photo(type : String, node : Node3D, img : Image):
	print ("Get ", type)
	print (node)
	for i in range(0,objectifs.size()-1):
		if type == objectifs[i]["titre"]:
			objectifs[i]["img"] = img

func check_end():
	#TODO
	for obj in objectifs:
		if obj.has_key("get") and obj["get"] == false :
			return
	# Si on est là, c'est que tous les objectifs sont get
	# TODO : le jeu est fini

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
