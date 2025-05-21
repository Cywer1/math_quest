extends Node

const MAX_HEALTH = 3
var current_health = MAX_HEALTH
signal health_changed(new_health)
signal no_health_left

var next_character_animation: String = ""

func _ready() :
	reset_health()

func decrease_health():
	if current_health > 0:
		current_health -= 1
		emit_signal("health_changed",current_health)
		print("Can azaldı.Kalan can: "+str(current_health))
	if current_health <= 0 and not no_health_left.is_connected(_on_no_health_emit_once):
		emit_signal("no_health_left")
		print("Can bitti!")
	
func _on_no_health_emit_once():
	pass
	
func reset_health():
	current_health = MAX_HEALTH
	if no_health_left.is_connected(_on_no_health_emit_once):
		no_health_left.disconnect(_on_no_health_emit_once)
	emit_signal("health_changed",current_health)

func get_current_health():
	return current_health
