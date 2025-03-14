extends CollisionObject3D

signal OnInteracted

@export var Outlines: Array[Node3D]

func use_object() -> void:
	OnInteracted.emit()
	for ch in get_parent().get_children():
		if ch.has_method("object_interacted"):
			ch.object_interacted()

func player_lookat() -> void:
	for o in Outlines:
		o.visible = true

func player_stop_look() -> void:
	for o in Outlines:
		o.visible = false
