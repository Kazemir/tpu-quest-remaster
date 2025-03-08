extends Node2D

var is_pending_game_loading: bool = false
var is_pending_level_loading: bool = false
var pending_save_game: SavedGame = null

var levels_saved_data: Dictionary[String, Array] = {}

func _ready() -> void:
	get_tree().tree_changed.connect(_on_tree_changed)

func new_game() -> void:
	levels_saved_data = {}

func is_game_saved() -> bool:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	return saved_game != null

func is_level_saved() -> bool:
	return levels_saved_data.has(get_tree().current_scene.get_scene_file_path())

func save_game() -> void:
	var saved_game: SavedGame = SavedGame.new()

	saved_game.current_level_scene_path = get_tree().current_scene.get_scene_file_path()

	var player: Node2D = get_tree().get_first_node_in_group(&"Player")

	saved_game.player_position = player.global_position
	saved_game.player_health = GameManager.player_health
	saved_game.player_money = GameManager.player_money
	saved_game.player_wepon = GameManager.player_weapon

	save_level()
	saved_game.levels_saved_data = levels_saved_data

	ResourceSaver.save(saved_game, "user://savegame.tres")

func save_level() -> void:
	var saved_data: Array[SavedData] = []
	get_tree().call_group(&"Saveable", &"on_save_game", saved_data)
	levels_saved_data[get_tree().current_scene.get_scene_file_path()] = saved_data

func load_game() -> void:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	if saved_game == null:
		return

	get_tree().change_scene_to_file(saved_game.current_level_scene_path)

	GameManager.player_health = saved_game.player_health
	GameManager.player_money = saved_game.player_money
	GameManager.player_weapon = saved_game.player_wepon

	levels_saved_data = saved_game.levels_saved_data
	pending_save_game = saved_game
	is_pending_game_loading = true

func shedule_level_loading() -> void:
	is_pending_level_loading = true

func load_level() -> void:
	if not is_level_saved():
		return

	get_tree().call_group(&"Saveable", &"on_before_load_game")

	for tileMap: TileMapLayer in get_tree().get_nodes_in_group(&"SaveableTileMap"):
		tileMap.clear()

	for item: SavedData in levels_saved_data[get_tree().current_scene.get_scene_file_path()]:
		var scene: PackedScene = load(item.scene_path) as PackedScene
		var restored_node: Node = scene.instantiate()

		if restored_node.has_method(&"on_load_game"):
			restored_node.on_load_game(item)

		get_tree().current_scene.add_child(restored_node)

func _on_tree_changed() -> void:
	if is_pending_game_loading:
		if pending_save_game == null:
			return
		if pending_save_game.current_level_scene_path != get_tree().current_scene.get_scene_file_path():
			return
		is_pending_game_loading = false

		var player: Node2D = get_tree().get_first_node_in_group(&"Player")
		player.global_position = pending_save_game.player_position
		pending_save_game = null

		load_level()
	if is_pending_level_loading:
		is_pending_level_loading = false
		load_level()
