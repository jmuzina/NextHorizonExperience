extends Node3D

var id: int = 0
var transparency = 0.6

func update_transform(id, position):
	pass

func hide_local():
	visible = false

func set_color(new_color: Color):
	new_color.a = transparency
	$NetPlayer_Mesh.get_active_material(0).albedo_color = new_color

func set_overhead_name(name: String):
	$Name.text = name
