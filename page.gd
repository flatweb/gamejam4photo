extends Node3D
class_name Page

@export var img : Texture
@export var titre : String
@export var indice : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change(img : Image, titre : String, indice : String):
	if img == null:
		$Sprite3D.hide()
	if img != null:
		pass # TODO remplacer l'image par la photo
		$Sprite3D.show()
	$LabelTitre.text = titre
	$LabelIndice.text = indice
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
