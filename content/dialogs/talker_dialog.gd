class_name TalkerDialog
extends Control

@onready var caption_label: Label = $PanelContainer/VBoxContainer/PanelContainer/CenterContainer/CaptionLabel
@onready var message_label: Label = $PanelContainer/VBoxContainer/PanelContainer2/CenterContainer2/MessageLabel
@onready var questions_container: BoxContainer = $PanelContainer/VBoxContainer/PanelContainer3/QuestionsContainer

@export var talk_data: TalkData

var current_question_element: int = 0
var questions: Array[Label] = []

func _on_ready():
	if talk_data == null:
		return
	caption_label.text = talk_data.name
	message_label.text = talk_data.greeting

	for child in questions_container.get_children():
		questions_container.remove_child(child)

	for question in talk_data.questions:
		var question_label = Label.new()
		questions_container.add_child(question_label)
		questions.append(question_label)

	update()

func _process(_delta):
	if talk_data == null:
		return

	var new_current_question_element = current_question_element
	if Input.is_action_just_pressed("move_up"):
		new_current_question_element -= 1
	elif Input.is_action_just_pressed("move_down"):
		new_current_question_element += 1
	elif Input.is_action_just_pressed("action"):
		message_label.text = TranslationServer.translate(talk_data.answers[current_question_element])
		return
	elif Input.is_action_just_pressed("escape"):
		DialogManager.hide_dialog()
		return
	else:
		return

	if new_current_question_element < 0:
		new_current_question_element = talk_data.questions.size() - 1
	elif new_current_question_element >= talk_data.questions.size():
		new_current_question_element = 0

	if new_current_question_element != current_question_element:
		current_question_element = new_current_question_element
		update()

func update():
	for i in questions.size():
		var prefix = ">  " if current_question_element == i else "   "
		var question_label = questions[i]
		question_label.text = prefix + TranslationServer.translate(talk_data.questions[i])
