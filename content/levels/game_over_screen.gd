extends Node2D

@onready var game_over_sound = $GameOverSound
@onready var animation_player = $AnimationPlayer

func _ready():
	game_over_sound.play()
	animation_player.play("launch")

func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://content/levels/main_menu.tscn")
