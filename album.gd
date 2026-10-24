extends Node3D

enum Cote {GAUCHE, DROITE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change(cote : Cote, img : Image, titre : String, indice : String):
	var page : Page
	if cote == Cote.GAUCHE :
		page = $PageGauche
	else :
		page = $PageDroite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
