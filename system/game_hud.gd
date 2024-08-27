extends CanvasLayer

@onready var health_value = %HealthValue
@onready var coins_value = %CoinsValue
@onready var weapon_icon = %WeaponIcon

func _process(delta):
	health_value.text = str(GameManager.player_health)
	coins_value.text = str(GameManager.player_money)
	
	match GameManager.player_weapon:
		GameManager.WeaponType.None:
			weapon_icon.visible = false
		GameManager.WeaponType.Sword:
			weapon_icon.visible = true
			weapon_icon.texture = load("res://content/graphics/items/sword.png")
		GameManager.WeaponType.SwordLight:
			weapon_icon.visible = true
			weapon_icon.texture = load("res://content/graphics/items/sword_light.png")
