extends Node2D

@export var character_scene_resource : PackedScene
@export var main_scene_resource : PackedScene

var character_instance: Node

func _ready() -> void:
	if not character_scene_resource:
		printerr("Cutscene: Character Scene Resource not set!")
		await get_tree().create_timer(0.1).timeout
		proceed_to_main_map()
		return
	if not main_scene_resource:
		printerr("Cutscene: Main map scene resource not set!")
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
		if animation_to_play == "":
			print("Cutscene: No specific animation requested from PlayerData. Defaulting to 0.1s delay.")
		else:
			printerr("CutsceneScene: Character instance, play_char_animation method, or AnimationPlayer missing.")
		await get_tree().create_timer(0.1).timeout
	if animation_to_play == "game_lose" or PlayerData.get_current_health() <= 0:
		print("CutsceneScene: Game Over. Quitting application.")
		get_tree().quit()
	else:
		proceed_to_main_map()


func proceed_to_main_map()->void:
	if main_scene_resource :
		print("Cutscene: Proceeding to main map")
		get_tree().change_scene_to_packed(main_scene_resource)
	else:
		printerr("Cutscene: Cannot proceed to main map! Resource not set!")
