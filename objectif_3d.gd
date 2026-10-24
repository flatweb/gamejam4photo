extends Node3D
class_name Objectif3D

signal catched

@export var type : String
@export var speed : float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func catch() -> void:
	catched.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
