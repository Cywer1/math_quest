extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func play_char_animation(animation_name:String)->void:
	animated_sprite_2d.play(animation_name)
	return
