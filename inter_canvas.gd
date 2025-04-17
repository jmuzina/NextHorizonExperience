extends Sprite3D

@export var Sprites: Array[Texture2D]


var done: bool = false
func object_interacted(_t, _f):
	if !done:
		texture = Sprites.pick_random()
		
