extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("launch")

func _on_animation_player_animation_finished(_anim_name):
	get_tree().change_scene_to_file("res://content/levels/main_menu.tscn")
