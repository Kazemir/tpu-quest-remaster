extends Node2D

@onready var game_over_sound = $GameOverSound
@onready var animation_player = $AnimationPlayer

func _ready():
	game_over_sound.play()
	animation_player.play("launch")

	if Input.is_action_just_pressed("action") or Input.is_action_just_pressed("escape"):
		_go_to_main_menu()


func _on_animation_player_animation_finished(anim_name):
	if game_over_sound.playing:
		await game_over_sound.finished
	_go_to_main_menu()


func _go_to_main_menu():
	get_tree().change_scene_to_file("res://content/levels/main_menu.tscn")
