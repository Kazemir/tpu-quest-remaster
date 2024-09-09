extends Node

const LEVELS_DIR = "res://content/levels/"
const SCENE_EXT = ".tscn"

func go_to_level(level_name):
	TransitionManager.transition()
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file(LEVELS_DIR + level_name + SCENE_EXT)
