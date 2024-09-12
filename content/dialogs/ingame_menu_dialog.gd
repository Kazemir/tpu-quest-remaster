extends Control

@onready var continue_game_label = $PanelContainer/VBoxContainer/PanelContainer2/TopMenuContainer/CenterContainer/ContinueGameLabel
@onready var settings_label = $PanelContainer/VBoxContainer/PanelContainer2/TopMenuContainer/CenterContainer2/SettingsLabel
@onready var back_to_main_menu_label = $PanelContainer/VBoxContainer/PanelContainer2/TopMenuContainer/CenterContainer3/BackToMainMenuLabel
@onready var top_menu_labels: Array[Label] = [continue_game_label, settings_label, back_to_main_menu_label]

@onready var sound_value = $PanelContainer/VBoxContainer/PanelContainer2/SettingsContainer/GridContainer/SoundValue
@onready var music_value = $PanelContainer/VBoxContainer/PanelContainer2/SettingsContainer/GridContainer/MusicValue
@onready var settings_menu_labels: Array[Label] = [sound_value, music_value]

var current_menu_element: int = 0
@onready var current_menu_labels: Array[Label] = top_menu_labels

@onready var top_menu_container = $PanelContainer/VBoxContainer/PanelContainer2/TopMenuContainer
@onready var settings_container = $PanelContainer/VBoxContainer/PanelContainer2/SettingsContainer

func _on_ready():
	settings_container.visible = false
	updateMenu()
	updateValues()

func _process(_delta):
	var newCurrentMenuElement = current_menu_element
	if Input.is_action_just_pressed("move_up"):
		newCurrentMenuElement -= 1
	elif Input.is_action_just_pressed("move_down"):
		newCurrentMenuElement += 1
	elif Input.is_action_just_pressed("action"):
		handleAction()
		return
	elif Input.is_action_just_pressed("escape"):
		if is_in_settings_menu():
			go_to_top_menu()
		else:
			DialogManager.hide_dialog()
		return
	else:
		if is_in_settings_menu():
			handle_settings_actions()
		return
		
	if newCurrentMenuElement < 0:
		newCurrentMenuElement = current_menu_labels.size() - 1
	elif newCurrentMenuElement >= current_menu_labels.size():
		newCurrentMenuElement = 0
		
	if newCurrentMenuElement != current_menu_element:
		current_menu_element = newCurrentMenuElement
		updateMenu()

func updateMenu():
	var red = Color(1.0, 0.0, 0.0, 1.0)
	var black = Color(0.0, 0.0, 0.0, 1.0)
	for i in current_menu_labels.size():
		current_menu_labels[i].set(
			"theme_override_colors/font_color", 
			red if current_menu_element == i else black
		)

func updateValues():
	sound_value.text = _buildRangeString(GameManager.setting_sound)
	music_value.text = _buildRangeString(GameManager.setting_music)

func handleAction():
	match current_menu_labels[current_menu_element]:
		continue_game_label:
			DialogManager.hide_dialog()
		settings_label:
			go_to_settings()
		back_to_main_menu_label:
			GameSaver.save_game()
			get_tree().change_scene_to_file("res://content/levels/main_menu.tscn")
			DialogManager.hide_dialog()

func handle_settings_actions():
	if Input.is_action_just_pressed("move_left"):
		if current_menu_element == 0:
			GameManager.setting_sound -= 1
			if GameManager.setting_sound < 0:
				GameManager.setting_sound = 0
			GameManager.applySoundSettings()
			updateValues()
		elif current_menu_element == 1:
			GameManager.setting_music -= 1
			if GameManager.setting_music < 0:
				GameManager.setting_music = 0
			GameManager.applySoundSettings()
			updateValues()
		GameManager.saveSettings()
	elif Input.is_action_just_pressed("move_right"):
		if current_menu_element == 0:
			GameManager.setting_sound += 1
			if GameManager.setting_sound > 10:
				GameManager.setting_sound = 10
			GameManager.applySoundSettings()
			updateValues()
		elif current_menu_element == 1:
			GameManager.setting_music += 1
			if GameManager.setting_music > 10:
				GameManager.setting_music = 10
			GameManager.applySoundSettings()
			updateValues()
		GameManager.saveSettings()

func go_to_settings():
	top_menu_container.visible = false
	settings_container.visible = true
	current_menu_element = 0
	current_menu_labels = settings_menu_labels
	updateMenu()
	
func go_to_top_menu():
	top_menu_container.visible = true
	settings_container.visible = false
	current_menu_element = 1
	current_menu_labels = top_menu_labels
	updateMenu()
	
func is_in_settings_menu() -> bool:
	return settings_container.visible

func _buildRangeString(val: int) -> String:
	var text = ""
	for i in range(val):
		text += "/"
	for i in range(val, 10):
		text += "-"
	return text
