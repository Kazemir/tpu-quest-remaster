extends Node

@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var game_music: AudioStreamPlayer = $GameMusic
@onready var win_music: AudioStreamPlayer = $WinMusic

@onready var coin_sound: AudioStreamPlayer = $CoinSound
@onready var potion_sound: AudioStreamPlayer = $PotionSound
@onready var weapon_sound: AudioStreamPlayer = $WeaponSound

@onready var coin_queue_processor: Timer = $CoinQueueProcessor

var ingame_menu_dialog: PackedScene = preload("res://content/dialogs/ingame_menu_dialog.tscn") as PackedScene

var is_in_dev_mode: bool = true

var is_game_paused: bool = false

var is_in_main_menu: bool = false
var is_in_dialog_menu: bool = false
var is_in_game: bool = false

var setting_sound: int = 6
var setting_music: int = 9

const MAX_HEALTH: int = 100
enum WeaponType {None, Sword, SwordLight}
var player_health: int = MAX_HEALTH
var player_money: int = 0
var player_money_queue: int = 0
var player_weapon: WeaponType = WeaponType.None

signal health_changed
signal money_changed
signal weapon_chaned

func _ready():
	_loadSettings()
	menu_music.play()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if is_in_game and not is_in_dialog_menu:
			DialogManager.show_dialog(ingame_menu_dialog.instantiate())
	if is_in_dev_mode and Input.is_action_pressed("restart_level"):
		if is_in_game and not is_in_dialog_menu:
			get_tree().reload_current_scene()

func go_to_game():
	is_in_main_menu = false
	is_in_game = true
	menu_music.stop()
	if not game_music.playing:
		game_music.play()

func go_to_main_menu():
	is_in_main_menu = true
	is_in_game = false
	game_music.stop()
	if not menu_music.playing:
		menu_music.play()

func resetPlayer():
	player_health = MAX_HEALTH
	player_money = 0
	player_money_queue = 0
	player_weapon = WeaponType.None

	health_changed.emit(player_health)
	money_changed.emit(player_money)
	weapon_chaned.emit(player_weapon)

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
	health_changed.emit(player_health)

func recieveDamage(val: int):
	player_health -= val
	if player_health <= 0:
		is_in_game = false
		game_music.stop()
		get_tree().change_scene_to_file("res://content/levels/game_over_screen.tscn")
	else:
		health_changed.emit(player_health)

func addWeapon(type: WeaponType):
	player_weapon = type
	weapon_sound.play()
	weapon_chaned.emit(type)

func getMoney() -> int:
	return player_money

func addMoney(val: int):
	player_money_queue += val

func spendMoney(val: int):
	_setMoney(getMoney() - val)

func _setMoney(val: int):
	player_money = val
	money_changed.emit(val)

func _on_coin_queue_processor_timeout():
	if player_money_queue == 0:
		return
	_setMoney(player_money + 1)
	if coin_sound.playing:
		coin_sound.stop()
	coin_sound.play()
	player_money_queue -= 1

func triggerGameWin():
	is_in_game = false
	game_music.stop()
	win_music.play()
	get_tree().change_scene_to_file("res://content/levels/win_screen.tscn")

func get_game_score() -> int:
	var money = player_money + player_money_queue
	return money * 5 + player_health
