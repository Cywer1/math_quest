extends Control





func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	PlayerData.reset_health()
	PlayerData.is_first_map_load = true
	get_tree().change_scene_to_file("res://Scenes/main_map.tscn")
