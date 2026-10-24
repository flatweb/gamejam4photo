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
		$Image3D.hide()
		var imgpng = ResourceLoader.load("res://icon.svg")
		#$Image3D.mesh.material.set_texture(BaseMaterial3D.TextureParam.TEXTURE_ALBEDO,img)  ##FIXME
		#print (xx)
	if img != null:
		$Sprite3D.texture = img
		$Sprite3D.show() 
	$LabelTitre.text = titre
	$LabelIndice.text = indice
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
