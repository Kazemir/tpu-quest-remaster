extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
	var bundle = NavigationManager.get_pending_bundle()
	var player_x = bundle.get("player_x")
	var player_y = bundle.get("player_y")
	if player_x != null and player_y != null:
		player.global_position = Vector2(player_x, player_y)
