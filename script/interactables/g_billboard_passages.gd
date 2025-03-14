extends Resource

@export var Passages: Array[String]
@export var branch_end: bool = false
@export var Options: Array[Resource] = []
@export var SelectionText: String = ""


func set_passages(psg: Array[String]):
	Passages = psg
