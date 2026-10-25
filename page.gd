extends Node3D
class_name Page

@export var img : Texture
@export var titre : String
@export var indice : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change(numpage : int, maxpage : int, img : Image, titre : String, indice : String):
	$Sprite3D.hide()
	if img == null:
		var imgpng = ResourceLoader.load("res://icon.svg")
		#$Image3D.mesh.material.set_texture(BaseMaterial3D.TextureParam.TEXTURE_ALBEDO,img)  ##FIXME
		#print (xx)
		$LabelIndice.show()
	if img != null:
		$Sprite3D.texture = ImageTexture.create_from_image(img)
		$Sprite3D.show()
		$LabelIndice.hide()
		if titre.ends_with(".png"):
			$Sprite3D/SpriteCheck.hide()
		else:
			$Sprite3D/SpriteCheck.show()
	$LabelTitre.text = titre
	$LabelIndice.text = indice
	if numpage <= maxpage:
		$LabelNumPage.text = str(numpage," / ",maxpage)
		$LabelNumPage.show()
	else:
		$LabelNumPage.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
