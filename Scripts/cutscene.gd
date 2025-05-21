extends Node2D

signal cutscene_finished
signal cutscene_quit_game

@export var character_scene_resource : PackedScene

var character_instance: Node

func _ready() -> void:
	if not character_scene_resource:
		printerr("Cutscene: Character Scene Resource not set!")
		await get_tree().create_timer(0.1).timeout
		emit_signal("cutscene_finished")
		return
	character_instance = character_scene_resource.instantiate()
	add_child(character_instance)
	var animation_to_play = PlayerData.next_character_animation
	PlayerData.next_character_animation = ""
	
	
	if character_instance and character_instance.has_method("play_char_animation") and animation_to_play!="":
		character_instance.play_char_animation(animation_to_play)
		var char_anim_player = character_instance.get_node_or_null("AnimationPlayer")
		if char_anim_player:
			print("Cutscene: waiting for animation '",animation_to_play,"' to finish")
			await char_anim_player.animation_finished
			print("Cutscene: Animation finished")
		else:
			printerr("Cutscene: AnimationPlayer resource has not been found")
			await get_tree().create_timer(1.5).timeout
	else:
		await get_tree().create_timer(0.1).timeout
	# Decide what to do after animation
	if animation_to_play == "game_lose" or PlayerData.get_current_health() <= 0:
		print("CutsceneScene: Game Over condition met.")
		emit_signal("cutscene_quit_game") # Signal MainMap to quit
	else: # "victory" or "hearth_lose"
		print("CutsceneScene: Proceeding from cutscene.")
		emit_signal("cutscene_finished")
	
