extends Node3D

var transparency = 0.6

@export var speed = 0.5

func set_online_color(color: Color):
	if color.a == 1: 
		color.a = transparency
	$NetPlayer_Mesh.get_active_material(0).albedo_color = color

func set_online_name(name: String):
	pass

func _process(delta: float) -> void:
	rotate(Vector3.UP, speed * delta)
