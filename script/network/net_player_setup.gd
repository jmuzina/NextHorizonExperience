extends Control

var player_info = {"name": "", "color": Color.SNOW, "id": -1}

signal on_player_start(player_info)

func _on_name_text_submitted(new_text: String) -> void:
	player_info.name = new_text
	print(player_info)
	
func _on_hex_text_submitted(new_text: String) -> void:
	var c = Color.from_string(new_text, Color.SNOW)
	player_info.color = c
	%NetworkPlayer.set_online_color(c)
	print(player_info)


func _on_pain_toggled(toggled_on: bool) -> void:
	#set some sort of global wacky feature
	pass




func _on_start_pressed() -> void:
	on_player_start.emit(player_info)
