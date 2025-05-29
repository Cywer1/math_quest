extends Control

signal question_answered_win
signal question_answered_lose
const CORRECT_ANSWER = preload("res://correct_answer.tres")
const FALSE_ANSWER = preload("res://false_answer.tres")
const NORMAL_THEME = preload("res://normal_theme.tres")
const PAUSE_MENU = preload("res://Scenes/pause_menu.tscn")

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
	for button in [answer_button,answer_button_2,answer_button_3,answer_button_4] : 
		button.theme = NORMAL_THEME
		button.add_theme_color_override("font_color",Color.BLACK)




func disable_buttons():
	answer_button.disabled = true
	answer_button_2.disabled = true
	answer_button_3.disabled = true
	answer_button_4.disabled = true

func _on_answer_button_pressed() -> void:
	if answer_button.text == Question_data["correctAnswer"]:
		answer_button.theme = CORRECT_ANSWER
		handle_win()
	else : 
		answer_button.theme = FALSE_ANSWER
		highlight_the_correct_answer()
		handle_lose()


func _on_answer_button_2_pressed() -> void:
	if answer_button_2.text == Question_data["correctAnswer"]:
		answer_button_2.theme = CORRECT_ANSWER
		handle_win()
	else : 
		answer_button_2.theme = FALSE_ANSWER
		highlight_the_correct_answer()
		handle_lose()


func _on_answer_button_3_pressed() -> void:
	if answer_button_3.text == Question_data["correctAnswer"]:
		answer_button_3.theme = CORRECT_ANSWER
		handle_win()
	else : 
		answer_button_3.theme = FALSE_ANSWER
		highlight_the_correct_answer()
		handle_lose()


func _on_answer_button_4_pressed() -> void:
	if answer_button_4.text == Question_data["correctAnswer"]:
		answer_button_4.theme = CORRECT_ANSWER
		handle_win()
	else : 
		answer_button_4.theme = FALSE_ANSWER
		highlight_the_correct_answer()
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
		PlayerData.next_character_animation = "heart_lose"
	
	await after_answer_timer.timeout # Timer still useful for local feedback
	emit_signal("question_answered_lose")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
			print("Question_scene: I am being freed now!")

func highlight_the_correct_answer()->void:
	for buttony in [answer_button,answer_button_2,answer_button_3,answer_button_4]:
		if buttony.text == Question_data["correctAnswer"]:
			buttony.theme = CORRECT_ANSWER


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pmenu = PAUSE_MENU.instantiate()
		add_child(pmenu)
		get_tree().paused = true
