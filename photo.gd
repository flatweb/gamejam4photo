@tool
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fit()
	pass # Replace with function body.

func fit():
	$SpriteImg.pixel_size = $MeshInstance3D.mesh.size.x*0.8/$SpriteImg.texture.get_width()
	$SpriteImg.scale = Vector3(1,1,1)

func change(img : Image, titre : String):
	if img == null: return
	$SpriteImg.texture = ImageTexture.create_from_image(img)
	fit()
	$SpriteImg.show()
	if titre.ends_with(".png"):
		$SpriteCheck.hide()
	else:
		$SpriteCheck.show()
	$LabelTitre.text = titre

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
