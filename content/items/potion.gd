@tool
class_name Potion
extends Area2D

enum Type { PotionSmall, Potion, Heart }
var amount = 25

@export var type = Type.PotionSmall

@onready var sprite = $Sprite

func _ready():
	match type:
		Type.PotionSmall:
			amount = 25
			sprite.texture = preload("res://content/graphics/items/potion_red_small.png")
		Type.Potion:
			amount = 50
			sprite.texture = preload("res://content/graphics/items/potion_red.png")
		Type.Heart:
			amount = 100
			sprite.texture = preload("res://content/graphics/items/heart.png")

func _on_body_entered(_body):
	if GameManager.isHealthMaxed():
		return
	GameManager.addHealth(amount)
	queue_free()

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(data: SavedData):
	global_position = data.position
	if data is SavedPotionData:
		type = data.type

func on_save_game(saved_data: Array[SavedData]):
	var data = SavedPotionData.new()
	data.scene_path = scene_file_path
	data.position = global_position
	data.type = type
	saved_data.append(data)
