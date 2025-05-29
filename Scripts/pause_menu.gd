extends Control


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
