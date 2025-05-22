extends Button 

signal point_activated(point_node: Node2D, question_data_for_this_point: Dictionary)


@export var question_scene_resource: PackedScene
@export var specific_question_data: Dictionary = {
	"question": "Default - Configure Me in Inspector!",
	"answers": ["A", "B", "C", "D"],
	"correctAnswer": "A"
}

func _ready():
	
	if not question_scene_resource:
		printerr("QuestionPoint: ", name, " is missing 'question_scene_resource'!")
		set_process_mode(Node.PROCESS_MODE_DISABLED) 
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	emit_signal("point_activated", self, specific_question_data)
	self.disabled = true
