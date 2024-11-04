extends Node2D

var is_pending_loading: bool = false

func _ready():
	get_tree().tree_changed.connect(_on_tree_changed)

func is_game_saved() -> bool:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	return saved_game != null

func save_game():
	var saved_game := SavedGame.new()

	saved_game.level_scene_path = get_tree().current_scene.get_scene_file_path()

	var player = get_tree().get_first_node_in_group("Player")

	saved_game.player_position = player.global_position
	saved_game.player_health = GameManager.player_health
	saved_game.player_money = GameManager.player_money
	saved_game.player_wepon = GameManager.player_weapon

	var saved_data: Array[SavedData] = []
	get_tree().call_group("Saveable", "on_save_game", saved_data)
	saved_game.saved_data = saved_data

	ResourceSaver.save(saved_game, "user://savegame.tres")

func load_game():
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	if saved_game == null:
		return

	get_tree().change_scene_to_file(saved_game.level_scene_path)
	is_pending_loading = true

func _on_tree_changed():
	if is_pending_loading:
		var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
		if saved_game == null:
			return
		if saved_game.level_scene_path != get_tree().current_scene.get_scene_file_path():
			return

		is_pending_loading = false

		get_tree().call_group("Saveable", "on_before_load_game")

		var player: Node2D = get_tree().get_first_node_in_group("Player")
		player.global_position = saved_game.player_position

		GameManager.player_health = saved_game.player_health
		GameManager.player_money = saved_game.player_money
		GameManager.player_weapon = saved_game.player_wepon

		for item in saved_game.saved_data:
			var scene := load(item.scene_path) as PackedScene
			var restored_node = scene.instantiate()

			if restored_node.has_method("on_load_game"):
				restored_node.on_load_game(item)

			get_tree().current_scene.add_child(restored_node)
