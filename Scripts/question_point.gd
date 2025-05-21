extends Button 

signal point_activated(point_node: Node2D, question_scene_to_load: PackedScene)


@export var question_scene_resource: PackedScene

func _ready():
	
	if not question_scene_resource:
		printerr("QuestionPoint: ", name, " is missing 'question_scene_resource'!")
		set_process_mode(Node.PROCESS_MODE_DISABLED) 
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# When pressed, emit the signal with itself and the scene it wants to load.
	# The main map will listen for this.
	if question_scene_resource:
		emit_signal("point_activated", self, question_scene_resource)
		# Optionally disable the button immediately to prevent double clicks
		# The main map will queue_free it later.
		self.disabled = true
