extends CanvasLayer

@onready var health_value = %HealthValue
@onready var coins_value = %CoinsValue
@onready var weapon_icon = %WeaponIcon

func _on_ready():
	GameManager.health_changed.connect(update_health)
	GameManager.money_changed.connect(update_money)
	GameManager.weapon_chaned.connect(update_weapon)
	updateHud()

func update_health(val: int):
	health_value.text = "%03d" % val

func update_money(val: int):
	coins_value.text = "%03d" % val

func update_weapon(weapon: int):
	match weapon:
		GameManager.WeaponType.None:
			weapon_icon.visible = false
		GameManager.WeaponType.Sword:
			weapon_icon.visible = true
			weapon_icon.texture = load("res://content/graphics/items/sword.png")
		GameManager.WeaponType.SwordLight:
			weapon_icon.visible = true
			weapon_icon.texture = load("res://content/graphics/items/sword_light.png")


func updateHud():
	update_health(GameManager.player_health)
	update_money(GameManager.player_money)
	update_weapon(GameManager.player_weapon)
	
