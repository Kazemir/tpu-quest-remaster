extends Node2D

var is_pending_loading: bool = false

func _ready() -> void:
	get_tree().tree_changed.connect(_on_tree_changed)

func is_game_saved() -> bool:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	return saved_game != null

func save_game() -> void:
	var saved_game: SavedGame = SavedGame.new()

	saved_game.level_scene_path = get_tree().current_scene.get_scene_file_path()

	var player: Node2D = get_tree().get_first_node_in_group(&"Player")

	saved_game.player_position = player.global_position
	saved_game.player_health = GameManager.player_health
	saved_game.player_money = GameManager.player_money
	saved_game.player_wepon = GameManager.player_weapon

	saved_game.saved_data = _save_level()

	ResourceSaver.save(saved_game, "user://savegame.tres")

func _save_level() -> Array[SavedData]:
	var saved_data: Array[SavedData] = []
	get_tree().call_group(&"Saveable", &"on_save_game", saved_data)
	return saved_data

func load_game() -> void:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	if saved_game == null:
		return

	get_tree().change_scene_to_file(saved_game.level_scene_path)

	GameManager.player_health = saved_game.player_health
	GameManager.player_money = saved_game.player_money
	GameManager.player_weapon = saved_game.player_wepon

	is_pending_loading = true

func load_level() -> void:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	if saved_game == null:
		return
	if saved_game.level_scene_path != get_tree().current_scene.get_scene_file_path():
		return

	get_tree().call_group(&"Saveable", &"on_before_load_game")

	for tileMap: TileMapLayer in get_tree().get_nodes_in_group(&"SaveableTileMap"):
		tileMap.clear()

	var player: Node2D = get_tree().get_first_node_in_group(&"Player")
	player.global_position = saved_game.player_position

	for item: SavedData in saved_game.saved_data:
		var scene: PackedScene = load(item.scene_path) as PackedScene
		var restored_node: Node = scene.instantiate()

		if restored_node.has_method(&"on_load_game"):
			restored_node.on_load_game(item)

		get_tree().current_scene.add_child(restored_node)

func _on_tree_changed() -> void:
	if is_pending_loading:
		is_pending_loading = false
		load_level()
