extends CollisionObject3D

signal OnInteracted(player: Node3D)

var Player: Node3D = null

@export var Outlines: Array[Node3D]

func use_object(modifier_interact: int = 0) -> void:
	OnInteracted.emit(Player)
	if get_parent().has_method("object_interacted"):
		get_parent().object_interacted(modifier_interact, Player)
	for ch in get_parent().get_children():
		if ch.has_method("object_interacted"):
			ch.object_interacted(modifier_interact, Player)

func player_lookat(player: Node3D) -> void:
	Player = player
	for o in Outlines:
		o.visible = true
	for ch in get_parent().get_children():
		if ch.has_method("player_mouseover"):
			ch.player_mouseover(player)

func player_stop_look(player: Node3D) -> void:
	Player = null
	for o in Outlines:
		o.visible = false
	for ch in get_parent().get_children():
		if ch.has_method("player_mouseover_end"):
			ch.player_mouseover_end(player)
