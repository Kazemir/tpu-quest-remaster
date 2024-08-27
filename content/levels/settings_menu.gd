extends Control

@onready var sound_label = $MarginContainer/GridContainer/MarginContainer/GridContainer/SoundLabel
@onready var music_label = $MarginContainer/GridContainer/MarginContainer/GridContainer/MusicLabel
@onready var langue_label = $MarginContainer/GridContainer/MarginContainer/GridContainer/LangueLabel

@onready var sound_value = $MarginContainer/GridContainer/MarginContainer/GridContainer/SoundValue
@onready var music_value = $MarginContainer/GridContainer/MarginContainer/GridContainer/MusicValue
@onready var langue_value = $MarginContainer/GridContainer/MarginContainer/GridContainer/LangueValue

@onready var menu_values: Array[Label] = [sound_value, music_value, langue_value]

var currentMenuElement = 0

var ordered_languages = ["ru", "en", "de", "pt", "gag"];
var sorted_locales = []

func _ready():
	var loaded_locales = TranslationServer.get_loaded_locales()
	for lang in ordered_languages:
		if lang in loaded_locales:
			sorted_locales.append(lang)
	for lang in loaded_locales:
		if lang not in sorted_locales:
			sorted_locales.append(lang)

	updateMenu()
	updateValues()

func _process(delta):
	var newCurrentMenuElement = currentMenuElement
	if Input.is_action_just_pressed("move_up"):
		newCurrentMenuElement -= 1
	elif Input.is_action_just_pressed("move_down"):
		newCurrentMenuElement += 1
	elif Input.is_action_just_pressed("move_left"):
		if currentMenuElement == 0:
			GameManager.setting_sound -= 1
			if GameManager.setting_sound < 0:
				GameManager.setting_sound = 0
			GameManager.applySoundSettings()
			updateValues()
		elif currentMenuElement == 1:
			GameManager.setting_music -= 1
			if GameManager.setting_music < 0:
				GameManager.setting_music = 0
			GameManager.applySoundSettings()
			updateValues()
		elif currentMenuElement == 2:
			var index = sorted_locales.find(TranslationServer.get_locale())
			if index == -1:
				push_error("sorted_locales is corrupted!")
			var prevIndex = -1
			if index - 1 < 0:
				prevIndex = sorted_locales.size() - 1
			else:
				prevIndex = index - 1
			TranslationServer.set_locale(sorted_locales[prevIndex])
		GameManager.saveSettings()
	elif Input.is_action_just_pressed("move_right"):
		if currentMenuElement == 0:
			GameManager.setting_sound += 1
			if GameManager.setting_sound > 10:
				GameManager.setting_sound = 10
			GameManager.applySoundSettings()
			updateValues()
		elif currentMenuElement == 1:
			GameManager.setting_music += 1
			if GameManager.setting_music > 10:
				GameManager.setting_music = 10
			GameManager.applySoundSettings()
			updateValues()
		elif currentMenuElement == 2:
			var index = sorted_locales.find(TranslationServer.get_locale())
			if index == -1:
				push_error("sorted_locales is corrupted!")
			var prevIndex = -1
			if index + 1 > sorted_locales.size() - 1:
				prevIndex = 0
			else:
				prevIndex = index + 1
			TranslationServer.set_locale(sorted_locales[prevIndex])
		GameManager.saveSettings()
	
	if newCurrentMenuElement < 0:
		newCurrentMenuElement = menu_values.size() - 1
	elif newCurrentMenuElement >= menu_values.size():
		newCurrentMenuElement = 0
		
	if newCurrentMenuElement != currentMenuElement:
		currentMenuElement = newCurrentMenuElement
		updateMenu()

func updateValues():
	sound_value.text = _buildRangeString(GameManager.setting_sound)
	music_value.text = _buildRangeString(GameManager.setting_music)

func updateMenu():
	var red = Color(1.0, 0.0, 0.0, 1.0)
	var black = Color(0.0, 0.0, 0.0, 1.0)
	for i in menu_values.size():
		menu_values[i].set(
			"theme_override_colors/font_color", 
			red if currentMenuElement == i else black
		)

func _buildRangeString(val: int) -> String:
	var text = ""
	for i in range(val):
		text += "/"
	for i in range(val, 10):
		text += "-"
	return text
