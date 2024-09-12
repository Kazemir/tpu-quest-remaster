extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("launch")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action") or Input.is_action_just_pressed("escape"):
		_go_to_main_menu()

func _on_animation_player_animation_finished(_anim_name):
	_go_to_main_menu()

func _go_to_main_menu():
	get_tree().change_scene_to_file("res://content/levels/main_menu.tscn")
