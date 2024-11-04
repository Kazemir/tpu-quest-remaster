extends Node

const LEVELS_DIR: String = "res://content/levels/"
const SCENE_EXT: String = ".tscn"

func go_to_level(level_name: String):
	TransitionManager.transition()
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file(LEVELS_DIR + level_name + SCENE_EXT)
