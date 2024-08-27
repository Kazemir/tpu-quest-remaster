@tool
extends Area2D

const LEVELS_DIR = "res://content/levels/"
const SCENE_EXT = ".tscn"

@onready var enter_label = $EnterLabel
@export var level_name: String

func _ready():
	if Engine.is_editor_hint():
		enter_label.visible = true
		enter_label.text = level_name
	else:
		enter_label.visible = false

func _on_body_entered(body):
	enter_label.visible = true

func _on_body_exited(body):
	enter_label.visible = false

func _process(delta):
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed("action") and enter_label.visible:
		get_tree().change_scene_to_file(LEVELS_DIR + level_name + SCENE_EXT)
