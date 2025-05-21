extends Control

signal question_answered_win
signal question_answered_lose

var Question_data = {"question":"What is 2 + 2 ?","answers":["1","3","4","5"],"correctAnswer":"4"}
@onready var answer_button_2: Button = $Answer_Button2
@onready var answer_button_3: Button = $Answer_Button3
@onready var answer_button_4: Button = $Answer_Button4
@onready var answer_button: Button = $Answer_Button
@onready var question_label: Label = $Question_Label
@onready var after_answer_timer: Timer = $After_Answer_Timer

func _ready() -> void:
	question_label.text = Question_data["question"]
	answer_button.text = Question_data["answers"][0]
	answer_button_2.text = Question_data["answers"][1]
	answer_button_3.text = Question_data["answers"][2]
	answer_button_4.text = Question_data["answers"][3]




func disable_buttons():
	answer_button.disabled = true
	answer_button_2.disabled = true
	answer_button_3.disabled = true
	answer_button_4.disabled = true

func _on_answer_button_pressed() -> void:
	if answer_button.text == Question_data["correctAnswer"]:
		handle_win()
	else : 
		handle_lose()


func _on_answer_button_2_pressed() -> void:
	if answer_button_2.text == Question_data["correctAnswer"]:
		handle_win()
	else : 
		handle_lose()


func _on_answer_button_3_pressed() -> void:
	if answer_button_3.text == Question_data["correctAnswer"]:
		handle_win()
	else : 
		handle_lose()


func _on_answer_button_4_pressed() -> void:
	if answer_button_4.text == Question_data["correctAnswer"]:
		handle_win()
	else : 
		handle_lose()

func handle_win(): # Make async to use await
	print("QuestionScene: You won")
	disable_buttons()
	after_answer_timer.start()
	await after_answer_timer.timeout # Timer still useful for local feedback
	PlayerData.next_character_animation = "victory"
	emit_signal("question_answered_win")

func handle_lose(): # Make async to use await
	print("QuestionScene: You Lost")
	disable_buttons()
	after_answer_timer.start()
	PlayerData.decrease_health() # This should happen BEFORE setting animation
	
	if PlayerData.get_current_health() <= 0:
		PlayerData.next_character_animation = "game_lose"
	else:
		PlayerData.next_character_animation = "hearth_lose"
	
	await after_answer_timer.timeout # Timer still useful for local feedback
	emit_signal("question_answered_lose")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
			print("Question_scene: I am being freed now!")
