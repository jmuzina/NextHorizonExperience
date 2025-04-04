extends LineEdit

func _on_focus_entered() -> void:
	placeholder_text = "Override IP address"


func _on_focus_exited() -> void:
	placeholder_text = ""
