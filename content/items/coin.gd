@tool
class_name Coin
extends Area2D

enum Type { Coin, Gold, GoldenBar }

@export var type = Type.Coin

@onready var sprite = $Sprite

var amount = 1

func _ready():
	match type:
		Type.Coin:
			amount = 1
			sprite.texture = preload("res://content/graphics/items/coin.png")
		Type.Gold:
			amount = 5
			sprite.texture = preload("res://content/graphics/items/gold.png")
		Type.GoldenBar:
			amount = 25
			sprite.texture = preload("res://content/graphics/items/gold_bar.png")

func _on_body_entered(_body):
	GameManager.addMoney(amount)
	queue_free()

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(data: SavedData):
	global_position = data.position
	if data is SavedCoinData:
		type = data.type

func on_save_game(saved_data: Array[SavedData]):
	var data = SavedCoinData.new()
	data.scene_path = scene_file_path
	data.position = global_position
	data.type = type
	saved_data.append(data)
