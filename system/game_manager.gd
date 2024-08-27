extends Node

@onready var menu_music = $MenuMusic
@onready var game_music = $GameMusic
@onready var win_music = $WinMusic

@onready var coin_sound = $CoinSound
@onready var potion_sound = $PotionSound
@onready var weapon_sound = $WeaponSound

@onready var coin_queue_processor = $CoinQueueProcessor

var is_in_dev_mode = true

var is_in_main_menu = false
var is_in_dialog_menu = false
var is_in_game = false

var setting_sound = 6
var setting_music = 9

const MAX_HEALTH = 100
enum WeaponType { None, Sword, SwordLight }
var player_health: int = 100
var player_money: int = 0
var player_money_queue: int = 0
var player_weapon: WeaponType = WeaponType.None

signal money_changed

func _ready():
	_loadSettings()
	menu_music.play()
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if not is_in_main_menu:
			get_tree().change_scene_to_file("res://content/levels/main_menu.tscn")
		elif is_in_game and not is_in_dialog_menu:
			pass # TODO show compact menu
	if is_in_dev_mode and Input.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()

func resetPlayer():
	player_health = MAX_HEALTH
	player_money = 0
	player_money_queue = 0
	player_weapon = WeaponType.None

func saveSettings():
	var config = ConfigFile.new()

	config.set_value("settings", "sound", setting_sound)
	config.set_value("settings", "music", setting_music)
	config.set_value("settings", "language", TranslationServer.get_locale())

	config.save("user://config.cfg")

func applySoundSettings():
	_set_music_volume("SFX", setting_sound)
	_set_music_volume("Music", setting_music)

func _set_music_volume(busName: String, volumeLevel: int):
	var busId = AudioServer.get_bus_index(busName)
	if volumeLevel == 0:
		AudioServer.set_bus_mute(busId, true)
	else:
		AudioServer.set_bus_mute(busId, false)
		var volumeDb = 20 * _log10(volumeLevel / 10.0)
		AudioServer.set_bus_volume_db(busId, volumeDb)

func _log10(x: float) -> float:
	return log(x) / log(10)

func _loadSettings():
	var config = ConfigFile.new()
	config.load("user://config.cfg")
	
	setting_sound = config.get_value("settings", "sound", setting_sound)
	setting_music = config.get_value("settings", "music", setting_music)
	applySoundSettings()
	
	var language = config.get_value("settings", "language", "ru")
	TranslationServer.set_locale(language)

func isHealthMaxed() -> bool:
	return player_health == MAX_HEALTH

func addHealth(val: int):
	player_health += val
	if player_health > MAX_HEALTH:
		player_health = MAX_HEALTH
	potion_sound.play()
	
func addWeapon(type: WeaponType):
	player_weapon = type
	weapon_sound.play()

func addMoney(val: int):
	player_money_queue += val

func _setMoney(val: int):
	player_money = val
	money_changed.emit(val)

func _on_coin_queue_processor_timeout():
	if player_money_queue == 0:
		return
	_setMoney(player_money + 1)
	coin_sound.play()
	player_money_queue -= 1
