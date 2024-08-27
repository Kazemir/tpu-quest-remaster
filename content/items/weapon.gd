@tool
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
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	match type:
		Type.Sword:
			GameManager.addWeapon(GameManager.WeaponType.Sword)
		Type.SwordLight:
			GameManager.addWeapon(GameManager.WeaponType.SwordLight)
	queue_free()
