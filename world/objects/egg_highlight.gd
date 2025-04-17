extends Sprite3D

@export var follow: Node3D


func _process(delta: float) -> void:
	transform = follow.transform
