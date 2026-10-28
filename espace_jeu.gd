@tool
extends Node3D

const MARGEPOS = 10

signal fini ()

var objectifs : Array = [
	{"img" : null, "titre": "Champignon", "indice" : "sous les arbres"},
	{"img" : null, "titre": "Oiseau", "indice" : "dans les arbres"},
	{"img" : null, "titre": "Biche", "indice" : "elle court vite !"},
	{"img" : null, "titre": "Caillou", "indice" : "partout"},
	{"img" : null, "titre": "Buron", "indice" : "sur la montagne"},
	{"img" : null, "titre": "Fleur", "indice" : "dans la forêt"},
]

var matched : Array

var started : bool = false : 
	set(value):
		started = value
		if value :
			$Joueur.start()

func _init() -> void :
	if Engine.is_editor_hint():
		# CONTOURNEMENT D'UN PROBLEME DE PERF SPECIFIQUE SUR PC
		var file = FileAccess.open("user://UNLOADMAP", FileAccess.READ)
		if file == null :
			# On n'est pas en mode optimisé (pb perf Thierry), donc on peut charger la MAP2
			print ("Loading MAP2")
			var maptscn : PackedScene = load("res://ASSETS/SCENES/map_2.tscn")
			var scene = maptscn.instantiate()
			add_child(scene)
			return
		else:
			print ("Loading MAP2 light !")
			var maptscn : PackedScene = load("res://ASSETS/SCENES/map_2_light.tscn")
			var scene = maptscn.instantiate()
			add_child(scene)
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var maptscn : PackedScene = load("res://ASSETS/SCENES/map_2.tscn")
	var scene = maptscn.instantiate()
	add_child(scene)
	
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
	
	# CONTOURNEMENT D'UN PROBLEME DE PERF SPECIFIQUE SUR PC
	var file = FileAccess.open("user://UNLOADMAP", FileAccess.READ)
	if file != null :
		if has_node("MAP"):
			$MAP/BIOME/FORET_EST.visible = false
			$MAP/BIOME/FORET_OUEST.visible = false
		if has_node("MAP2"):
			$MAP2/BIOME/FORET_EST.visible = false
			$MAP2/BIOME/FORET_OUEST.visible = false
		unloadpins(self.get_node("MAP2"))
	pass

# Méthode spécifique pour alléger le modèle au run (perf PC Thierry)
func unloadpins(node : Node):
	for child in node.get_children():
		if child.name == "SAPIN" :
			child.free()
		elif child.name == "PIN":
			child.free()
		elif child.name.begins_with("ROCHE"):
			child.free()
		elif child.name.begins_with("ARBRE"):
			child.free()
		elif child.name.begins_with("CHAMP"):
			child.free()
		elif child.name.begins_with("HERBE"):
			child.free()
		elif child.name.begins_with("ARBRE"):
			child.free()
		elif child.name.begins_with("Cube"):
			child.free()
		elif child.name.begins_with("Plane"):
			child.free()
		elif child.get_child_count() > 0 :
			unloadpins(child)
		else:
			print (child.name)
			pass
	pass

func loadobjectifs(node : Node):
	if node.is_in_group("objectif"):
		var ind : int = 0
		for obj in objectifs :
			if obj["titre"] == node.name :
				objectifs[ind]["get"] = false
			ind += 1
		print("Dinde")
		node.catched.connect(photographie.bind())
		return
	if node.get_child_count() > 0 :
		for child in node.get_children():
			loadobjectifs(child)
	else:
		return

func silence():
	$AudioForetEst.stop()
	$AudioForetOuest.stop()
	$AudioPlaine.stop()
	
func start():
	started = true
	$AudioForetEst.play()
	$AudioForetOuest.play()
	$AudioPlaine.play()

func photographie(type : String, node : Node3D, img : Image):
	print ("Get ", type)
	print (node)
	for i in range(0,objectifs.size()):
		if type == objectifs[i]["titre"]:
			objectifs[i]["img"] = img
			objectifs[i]["get"] = true
	check_end()

func get_nb_objectifs_atteints():
	var accum = 0
	for obj in objectifs:
		if  obj.has("get") and obj["get"]:
			accum +=1
	return accum

func check_end():
	if check_objectifs_atteints() :
		fini.emit()
		$Joueur/TimerNoAction.stop()
	if check_pellicule_vide():
		fini.emit()
		$Joueur/TimerNoAction.stop()

func check_pellicule_vide():
	return $Joueur.photosrestantes <= 0
	
func check_objectifs_atteints():
	var nbatteints = 0
	for obj : Dictionary in objectifs:
		if obj.has("get") and not obj["get"] :
			nbatteints += 1
	if nbatteints == objectifs.size(): return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
