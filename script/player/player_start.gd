extends Node3D

@export var create_on_ready = false
@export var player_class: PackedScene

func _ready() -> void:
	await %editor_only.is_node_ready()
	%editor_only.queue_free()

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	if create_on_ready:
		create_player()

func create_player(name: String ="") -> Node3D:
	var p = player_class.instantiate()
	get_parent().add_child(p)
	if !name.is_empty(): p.name = name
	p.transform = transform
	queue_free()
	return p
