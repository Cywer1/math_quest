extends Node

@export var game_over_scene: PackedScene
@onready var health_container: HBoxContainer = $HealthContainer
@onready var player_icon: Sprite2D = $PlayerIcon
@onready var marker_2d: Marker2D = $Marker2D

var active_question_points: Array[Node] = []
var is_player_moving:bool = false
const PLAYER_MOVE_SPEED:float = 200

func _ready() -> void:
	PlayerData.health_changed.connect(on_player_health_changed)
	PlayerData.no_health_left.connect(on_player_no_health)
	on_player_health_changed(PlayerData.get_current_health())
	for child in get_children():
		if child.has_signal("point_activated"):
			child.point_activated.connect(_on_question_point_activated)
			active_question_points.append(child)
			print("Connected to question point: ", child.name)

func on_player_health_changed(new_health:int)->void:
	print("MainMap: Health updated to: ",new_health)
	for i in range(health_container.get_child_count()):
		var health_sprite = health_container.get_child(i)
		if health_sprite is Sprite2D:
			health_sprite.visible = (i<new_health)

func on_player_no_health()->void:
	print("MainMap: Player has no health left! game over")
	if game_over_scene:
		get_tree().change_scene_to_packed(game_over_scene)
	else:
		printerr("MainMap: GameOverScene not set!")
		get_tree().quit()

func _on_question_point_activated(point_node: Node,question_scene_to_load:PackedScene):
	if is_player_moving:
		print("Player already is moving.Ignoring Click")
		if point_node is Button:
			point_node.disabled = false
		return
	print("MainMap: Question point activated: ",point_node.name)
	is_player_moving = true
	for qp in active_question_points:
		if qp is Button and qp != point_node:
			qp.disabled = true
	
	
	var tween = get_tree().create_tween()
	tween.tween_property(player_icon, "global_position", point_node.global_position, 
	player_icon.global_position.distance_to(point_node.global_position) / PLAYER_MOVE_SPEED)
	await tween.finished
	print("Mainmap: Player Reached the destination")
	if point_node in active_question_points:
		active_question_points.erase(point_node)
	point_node.queue_free()
	
	if question_scene_to_load:
		get_tree().change_scene_to_packed(question_scene_to_load)
	else:
		printerr("No question scene provided by the point node!")
	
	is_player_moving = false
	for qp in active_question_points:
		if qp is Button:
			qp.disabled = false
	

func set_player_initial_position(pos:Vector2)->void:
	pos = marker_2d.position
	if player_icon:
		player_icon.global_position = pos
