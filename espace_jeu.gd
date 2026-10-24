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
	
	$Joueur.objectifs = objectifs # Passage par référence, donc en cohérence


func loadobjectifs(node : Node3D):
	for child in get_children():
		if child.is_in_group("objectif"):
			child.catched.connect(photo.bind())
		elif child.get_child_count() > 0 :
			loadobjectifs(child)
		else:
			return
	
func photo(type : String, node : Node3D, img : Image):
	print ("Get ", type)
	print (node)
	for i in range(0,objectifs.size()-1):
		if type == objectifs[i]["titre"]:
			objectifs[i]["img"] = img
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
