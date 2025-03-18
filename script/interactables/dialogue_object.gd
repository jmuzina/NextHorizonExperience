extends Node3D

@export var Tex: Texture2D
@export var RootPassages: Resource

func _ready()-> void:
	$GFloatingText.set_passage_root(RootPassages)
	$Sprite3D.texture = Tex
