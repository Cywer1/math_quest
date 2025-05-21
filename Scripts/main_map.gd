extends Node

@export var game_over_scene: PackedScene
@export var question_scene_default_resource : PackedScene
@export var cutscene_scene_resource : PackedScene
@export var final_win_scene: PackedScene


@onready var health_container: HBoxContainer = $MapContent/HealthContainer
@onready var player_icon: Sprite2D = $MapContent/PlayerIcon
@onready var marker_2d: Marker2D = $MapContent/Marker2D
@onready var map_content_root: Node2D = $MapContent

var all_question_points_initial_nodes: Array[Node] = []
var active_question_points: Array[Node] = []
var is_player_moving:bool = false
const PLAYER_MOVE_SPEED:float = 200

var current_sub_scene:Node = null

var pending_question_scene_resource: PackedScene


func _ready() -> void:
	PlayerData.health_changed.connect(on_player_health_changed)
	PlayerData.no_health_left.connect(on_player_no_health)
	on_player_health_changed(PlayerData.get_current_health())
	set_player_initial_position(marker_2d.global_position)
	for child in map_content_root.get_children():
		if child.has_signal("point_activated"):
			child.point_activated.connect(_on_question_point_activated)
			all_question_points_initial_nodes.append(child)
			active_question_points.append(child)
			print("Connected to question point: ", child.name)
	
	if PlayerData.is_first_map_load:
		set_player_initial_position(marker_2d.global_position)
		PlayerData.is_first_map_load = false
	

func set_player_initial_position(pos:Vector2)->void:
	if player_icon:
		player_icon.global_position = pos

func on_player_health_changed(new_health:int)->void:
	print("MainMap: Health updated to: ",new_health)
	for i in range(health_container.get_child_count()):
		var health_sprite = health_container.get_child(i)
		if health_sprite is Sprite2D:
			health_sprite.visible = (i<new_health)

func on_player_no_health()->void:
	print("MainMap: Player has no health left! game over")
	if current_sub_scene:
		current_sub_scene.queue_free()
		current_sub_scene = null
	if game_over_scene:
		get_tree().change_scene_to_packed(game_over_scene)
	else:
		printerr("MainMap: GameOverScene not set!")
		get_tree().quit()

func _on_question_point_activated(point_node: Node,question_scene_to_load:PackedScene):
	if is_player_moving or current_sub_scene != null: # Also don't interact if a sub-scene is up
		print("MainMap: Action blocked (moving or sub-scene active).")
		if point_node is Button:
			point_node.disabled = false # Re-enable if it auto-disabled
		return
	
	print("MainMap: Question point activated: ", point_node.name)
	is_player_moving = true
	pending_question_scene_resource = question_scene_to_load # Store which question scene to load
	# Disable other question points
	_set_question_points_interactive(false, point_node)
	
	var target_position: Vector2
	if point_node is Node2D:
		target_position = point_node.global_position
	elif point_node is Control: # Buttons are Controls
		target_position = point_node.get_global_rect().get_center() # Or .global_position if it's enough
	else:
		printerr("MainMap: point_node type not handled for position.")
		_cleanup_after_failed_interaction(point_node)
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(player_icon, "global_position", target_position,
		player_icon.global_position.distance_to(target_position) / PLAYER_MOVE_SPEED)
	
	await tween.finished # Wait for movement
	print("MainMap: Player reached the destination.")
	
	# Destroy the question point (THIS WILL NOW PERSIST)
	if point_node in active_question_points:
		active_question_points.erase(point_node)
	point_node.queue_free()
	
	is_player_moving = false
	
	# Now show the question scene
	_show_question_scene(pending_question_scene_resource)

func _show_question_scene(scene_resource: PackedScene) -> void:
	if current_sub_scene: # Should not happen if logic is correct, but as a safeguard
		current_sub_scene.queue_free()
	
	if scene_resource:
		current_sub_scene = scene_resource.instantiate()
		# Connect signals from the question scene
		current_sub_scene.question_answered_win.connect(_on_question_answered_win)
		current_sub_scene.question_answered_lose.connect(_on_question_answered_lose)
		
		add_child(current_sub_scene) # Or add to sub_scene_container
		_set_main_map_interactive(false) # Disable main map interactions
		print("MainMap: Question scene shown.")
	else:
		printerr("MainMap: No question scene resource to show!")
		_set_question_points_interactive(true) # Re-enable points if we failed to show scene

func _on_question_answered_win() -> void:
	print("MainMap: Received question_answered_win.")
	_remove_current_sub_scene()
	_show_cutscene()

func _on_question_answered_lose() -> void:
	print("MainMap: Received question_answered_lose.")
	_remove_current_sub_scene()
	# Check for game over condition immediately after health decrease
	if PlayerData.get_current_health() <= 0:
		on_player_no_health() # This will handle game over transition
	else:
		_show_cutscene() # Proceed to cutscene for health loss animation

func _show_cutscene() -> void:
	if not cutscene_scene_resource:
		printerr("MainMap: Cutscene resource not set!")
		_return_to_map_interaction() # Fallback: just return to map
		return
	
	current_sub_scene = cutscene_scene_resource.instantiate()
	current_sub_scene.cutscene_finished.connect(_on_cutscene_finished)
	current_sub_scene.cutscene_quit_game.connect(_on_cutscene_quit_game)

	add_child(current_sub_scene) # Or add to sub_scene_container
	_set_main_map_interactive(false) # Ensure map is still non-interactive
	print("MainMap: Cutscene shown.")

func _on_cutscene_finished() -> void:
	print("MainMap: Received cutscene_finished.")
	_remove_current_sub_scene()
	if active_question_points.is_empty() and PlayerData.get_current_health() >0: 
		_go_to_final_win_scene()
	else:
		_return_to_map_interaction()

func _go_to_final_win_scene()->void:
	print("MainMap: All questions answered! Proceeding to final win scene.")
	if final_win_scene:
		if current_sub_scene:
			_remove_current_sub_scene()
		get_tree().change_scene_to_packed(final_win_scene) 
	else:
		printerr("MainMap: Final Win Scene not set!")
		_return_to_map_interaction() 
	

func _on_cutscene_quit_game() -> void:
	print("MainMap: Received cutscene_quit_game.")
	_remove_current_sub_scene() # Clean up cutscene
	get_tree().quit()           # Quit game

func _remove_current_sub_scene() -> void:
	if is_instance_valid(current_sub_scene): # Check if the node is still valid
		print("MainMap: Attempting to remove sub-scene:", current_sub_scene.name)
		
		if current_sub_scene.has_signal("question_answered_win") and \
		   current_sub_scene.question_answered_win.is_connected(_on_question_answered_win):
			current_sub_scene.question_answered_win.disconnect(_on_question_answered_win)
		
		if current_sub_scene.has_signal("question_answered_lose") and \
		   current_sub_scene.question_answered_lose.is_connected(_on_question_answered_lose):
			current_sub_scene.question_answered_lose.disconnect(_on_question_answered_lose)
		
		if current_sub_scene.has_signal("cutscene_finished") and \
		   current_sub_scene.cutscene_finished.is_connected(_on_cutscene_finished):
			current_sub_scene.cutscene_finished.disconnect(_on_cutscene_finished)
			
		if current_sub_scene.has_signal("cutscene_quit_game") and \
		   current_sub_scene.cutscene_quit_game.is_connected(_on_cutscene_quit_game):
			current_sub_scene.cutscene_quit_game.disconnect(_on_cutscene_quit_game)
			
		current_sub_scene.queue_free()
		current_sub_scene = null # Set to null immediately
		print("MainMap: Sub-scene removed and set to null.")
	else:
		print("MainMap: _remove_current_sub_scene called but current_sub_scene is already invalid or null.")
		if current_sub_scene != null: # If it's not null but invalid, set to null
			current_sub_scene = null

func _return_to_map_interaction() -> void: # Optionally reset player position
	_set_main_map_interactive(true)
	print("MainMap: Returned to map interaction.")

func _set_main_map_interactive(is_interactive: bool) -> void:
	if map_content_root:
		map_content_root.visible = is_interactive
	else:
		printerr("MainMap: 'map_content_root' not assigned. Cannot hide/show map content.")
	
	# Existing logic for question points
	_set_question_points_interactive(is_interactive)
	
	if is_interactive:
		print("MainMap: Interactions and visibility ENABLED.")
	else:
		print("MainMap: Interactions and visibility DISABLED.")

func _set_question_points_interactive(is_interactive: bool, exclude_node: Node = null) -> void:
	for qp_node in active_question_points: # Iterate over a copy if modifying list
		if qp_node == exclude_node:
			continue
		if qp_node is Button:
			qp_node.disabled = not is_interactive
		elif qp_node is Control: # General control nodes
			qp_node.mouse_filter = Control.MOUSE_FILTER_STOP if not is_interactive else Control.MOUSE_FILTER_PASS
		

func _cleanup_after_failed_interaction(point_node: Node):
	is_player_moving = false
	if point_node is Button:
		point_node.disabled = false
	_set_question_points_interactive(true)
