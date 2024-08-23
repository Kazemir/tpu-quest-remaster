extends Node2D

@onready var canvas_layer = $CanvasLayer
@onready var main_menu_container = $CanvasLayer/MainMenuContainer

@onready var new_game_label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer/NewGameLabel
@onready var continue_label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer2/ContinueLabel
@onready var settings_label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer3/SettingsLabel
@onready var high_scores_label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer4/HighScoresLabel
@onready var authors_label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer5/AuthorsLabel
@onready var exit_label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer6/ExitLabel

@onready var menu_labels: Array[Label] = [new_game_label, continue_label, settings_label, high_scores_label, authors_label, exit_label]

@onready var start_level = preload("res://content/levels/home_level.tscn") as PackedScene
@onready var authors_menu = preload("res://content/levels/authors_menu.tscn") as PackedScene
@onready var high_score_menu = preload("res://content/levels/high_score_menu.tscn") as PackedScene
@onready var settings_menu = preload("res://content/levels/settings_menu.tscn") as PackedScene

var currentMenuElement = 0

var currentChildMenu = null

func _ready():
	TranslationServer.set_locale("ru")
	updateMenu()

func _process(delta):
	var newCurrentMenuElement = currentMenuElement
	if Input.is_action_just_pressed("escape"):
		if currentChildMenu != null:
			canvas_layer.remove_child(currentChildMenu)
			currentChildMenu = null
			main_menu_container.visible = true
		else:
			get_tree().quit()
	if Input.is_action_just_pressed("move_up") and currentChildMenu == null:
		newCurrentMenuElement -= 1
	if Input.is_action_just_pressed("move_down") and currentChildMenu == null:
		newCurrentMenuElement += 1
	if Input.is_action_just_pressed("action") and currentChildMenu == null:
		handleAction()
	
	if newCurrentMenuElement < 0:
		newCurrentMenuElement = menu_labels.size() - 1
	elif newCurrentMenuElement >= menu_labels.size():
		newCurrentMenuElement = 0
		
	if newCurrentMenuElement != currentMenuElement:
		currentMenuElement = newCurrentMenuElement
		updateMenu()

func updateMenu():
	var red = Color(1.0, 0.0, 0.0, 1.0)
	var black = Color(0.0, 0.0, 0.0, 1.0)
	for i in menu_labels.size():
		menu_labels[i].set(
			"theme_override_colors/font_color", 
			red if currentMenuElement == i else black
		)
		
func handleAction():
	match menu_labels[currentMenuElement]:
		new_game_label:
			get_tree().change_scene_to_packed(start_level)
		continue_label:
			get_tree().change_scene_to_packed(start_level)
		settings_label:
			currentChildMenu = settings_menu.instantiate()
			canvas_layer.add_child(currentChildMenu)
			main_menu_container.visible = false
		high_scores_label:
			currentChildMenu = high_score_menu.instantiate()
			canvas_layer.add_child(currentChildMenu)
			main_menu_container.visible = false
		authors_label:
			currentChildMenu = authors_menu.instantiate()
			canvas_layer.add_child(currentChildMenu)
			main_menu_container.visible = false
		exit_label:
			get_tree().quit()
