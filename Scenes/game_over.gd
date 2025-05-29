extends Control

var endmenu = load("res://Scenes/end_game_menu.tscn")

func _ready() -> void:
	var ending = endmenu.instantiate()
	add_child(ending)
