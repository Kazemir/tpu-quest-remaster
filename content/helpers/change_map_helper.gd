@tool
extends Area2D

const LEVELS_DIR: String = "res://content/levels/"
const SCENE_EXT: String = ".tscn"

@onready var enter_label: Label = $EnterLabel
@export var level_name: String
@export var move_palyer: bool
@export var player_x: float
@export var player_y: float

func _ready() -> void:
	if Engine.is_editor_hint():
		enter_label.visible = true
		enter_label.text = level_name
	else:
		enter_label.visible = false
		enter_label.text = "gameHelp_enter"

func _on_body_entered(_body: Node2D) -> void:
	enter_label.visible = true

func _on_body_exited(_body: Node2D) -> void:
	enter_label.visible = false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or GameManager.is_game_paused:
		return
	if Input.is_action_just_pressed("action") and enter_label.visible:
		var bundle: Dictionary = {}
		if move_palyer:
			bundle["player_x"] = player_x
			bundle["player_y"] = player_y
		NavigationManager.go_to_level(level_name, bundle)
