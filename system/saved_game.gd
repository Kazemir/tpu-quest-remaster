class_name SavedGame
extends Resource

@export var level_scene_path: String

@export var player_position: Vector2
@export var player_health: int
@export var player_money: int
@export var player_wepon: GameManager.WeaponType

@export var saved_data: Array[SavedData] = []
