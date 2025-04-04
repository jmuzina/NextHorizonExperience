extends Sprite3D


func _process(delta: float) -> void:
	texture.set_width($Name.font_size * $Name.text.length() * $Name.pixel_size)
