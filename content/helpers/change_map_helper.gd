@tool
extends Area2D

const LEVELS_DIR: String = "res://content/levels/"
const SCENE_EXT: String = ".tscn"

@onready var enter_label: Label = $EnterLabel
@export var level_name: String

func _ready():
	if Engine.is_editor_hint():
		enter_label.visible = true
		enter_label.text = level_name
	else:
		enter_label.visible = false
		enter_label.text = "gameHelp_enter"

func _on_body_entered(_body):
	enter_label.visible = true

func _on_body_exited(_body):
	enter_label.visible = false

func _process(_delta):
	if Engine.is_editor_hint() or GameManager.is_game_paused:
		return
	if Input.is_action_just_pressed("action") and enter_label.visible:
		NavigationManager.go_to_level(level_name)
