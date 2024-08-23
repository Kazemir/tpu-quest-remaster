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

func _process(delta):
	pass

func _on_body_entered(body):
	pass
