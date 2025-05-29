extends Control

@onready var won_label: Label = $WonLabel

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const END_GAME_MENU = preload("res://Scenes/end_game_menu.tscn")
func _ready() -> void:
	animated_sprite_2d.play("final_victory")
	if won_label.visible : 
		won_label.hide()

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.queue_free()
	var endmenu = END_GAME_MENU.instantiate()
	add_child(endmenu)
	if won_label.visible == false : 
		won_label.show()
	
