extends Node

const LEVELS_DIR: String = "res://content/levels/"
const SCENE_EXT: String = ".tscn"

var _pending_bundle: Dictionary = {}

func get_pending_bundle() -> Dictionary:
	var dict: Dictionary = _pending_bundle
	_pending_bundle = {}
	return dict

func go_to_level(level_name: String, bundle: Dictionary = {}) -> void:
	await Target.new(level_name).go(get_tree(), bundle)

var MainMenu: Target = Target.new("main_menu")
var HomeLevel: Target = Target.new("home_level")
var FungusLevel: Target = Target.new("fungus_level")
var LavLevel: Target = Target.new("lav_level")
var TowerLevel: Target = Target.new("tower_level")

class Target:

	var path: String

	func _init(name: String) -> void:
		self.path = LEVELS_DIR + name + SCENE_EXT

	func go(tree: SceneTree, bundle: Dictionary = {}, with_transition: bool = true) -> void:
		if with_transition:
			TransitionManager.transition()
			await TransitionManager.on_transition_finished
		NavigationManager._pending_bundle = bundle
		tree.change_scene_to_file(path)
