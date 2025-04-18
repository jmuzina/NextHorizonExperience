extends Node3D

@export var NodesToEnable: Array[Node3D]
@export var NodesToDisable: Array[Node3D]

func text_end():
	for node in NodesToEnable:
		if node.has_method("enable"):
			node.enable()
		
	for node in NodesToDisable:
		if node.has_method("disable"):
			node.disable()
		
