extends Node2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func play_char_animation(animation_name:String)->void:
	if animationPlayer.has_animation(animation_name):
		animationPlayer.play(animation_name)
		print("Character playing animation - ", animation_name)
	else:
		printerr("Character: Animation not found - ",animation_name)
