@tool
class_name Weapon
extends Area2D

enum Type { Sword, SwordLight }
var damage = 10

@export var type = Type.Sword

@onready var sprite = $Sprite

func _ready():
	match type:
		Type.Sword:
			damage = 10
			sprite.texture = preload("res://content/graphics/items/sword.png")
		Type.SwordLight:
			damage = 100
			sprite.texture = preload("res://content/graphics/items/sword_light.png")

func _on_body_entered(_body):
	match type:
		Type.Sword:
			GameManager.addWeapon(GameManager.WeaponType.Sword)
		Type.SwordLight:
			GameManager.addWeapon(GameManager.WeaponType.SwordLight)
	queue_free()

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(data: SavedData):
	global_position = data.position
	if data is SavedWeaponData:
		type = data.type
	
func on_save_game(saved_data: Array[SavedData]):
	var data = SavedWeaponData.new()
	data.scene_path = scene_file_path
	data.position = global_position
	data.type = type
	saved_data.append(data)
