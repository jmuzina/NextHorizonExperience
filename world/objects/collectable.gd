extends Node3D
@export var eggName: String
@export var eggDesc: String
@export var Sprite: Texture2D
@export var disabled: bool = false

func _ready():
	pass
	await $egg_sprite.is_node_ready()
	$egg_sprite.texture = Sprite
	$AnimationPlayer.play("egg_bob")

func object_interacted(_modifier: int, player: Node3D) -> void:
	if disabled: return
	#trigger 'got the thing' ui
	player.get_egg(eggName, eggDesc, Sprite, self)
	
