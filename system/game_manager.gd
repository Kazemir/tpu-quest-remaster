extends Node

@onready var main_menu = preload("res://content/levels/main_menu.tscn") as PackedScene

func _process(delta: float) -> void:
	# handle inputs
	if Input.is_action_just_pressed("escape"):
		# TODO show compact menu
		#get_tree().change_scene_to_packed(main_menu)
		get_tree().quit()
	if Input.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()
