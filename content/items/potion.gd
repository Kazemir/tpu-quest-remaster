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


func _process(delta):
	pass


func _on_body_entered(body):
	pass
