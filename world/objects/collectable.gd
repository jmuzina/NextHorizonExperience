extends Node3D
@export var eggName: String
@export var eggDesc: String
@export var Sprite: Texture2D

func _ready():
	pass
	#$Sprite3D.texture = Sprite

func object_interacted(_modifier: int, player: Node3D) -> void:
	#trigger 'got the thing' ui
	player.get_egg(eggName, eggDesc, Sprite, self)
	
