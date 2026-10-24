extends Node3D

const MARGEPOS = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Repositionnement aléatoire du joueur dans l'Area3D
	#var asize = $Area3D/MeshInstance3D.mesh.size
	var randposx = randi_range(100/2+MARGEPOS, 100/2-MARGEPOS)
	var randposy = randi_range(-100/2+MARGEPOS, 100/2-MARGEPOS)
	$Joueur.position = $Area3D/MeshInstance3D.position + Vector3(randposx, 0, randposy)
	$Joueur.rotation = Vector3(0,randf_range(0,PI),0)
	
	#FIXME : il faut maintenant gérer les collisions avec le décor
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
