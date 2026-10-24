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
	changetopageon()
	pass # Replace with function body.

func open():
	$AudioOpen.play()
	
func close():
	$AudioOpen.play()
	
func pageprev():
	pageon = max(0,pageon-2)
	changetopageon()
	pass
	
func pagenext():
	pageon = min(quests.size(),pageon+2)
	changetopageon()
	pass

func changetopageon():
	$AudioTurn.play()
	change(Cote.GAUCHE,quests[pageon]["img"],quests[pageon]["titre"],quests[pageon]["indice"])
	change(Cote.DROITE,quests[pageon+1]["img"],quests[pageon+1]["titre"],quests[pageon+1]["indice"])
	
func change(cote : Cote, img : Image, titre : String, indice : String):
	var page : Page
	if cote == Cote.GAUCHE :
		page = $PageGauche
	else :
		page = $PageDroite
	page.change(img,titre,indice)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
