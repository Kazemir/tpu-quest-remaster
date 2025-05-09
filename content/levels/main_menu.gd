extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var main_menu_container: Control = $CanvasLayer/MainMenuContainer

@onready var new_game_label: Label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer/NewGameLabel
@onready var continue_label: Label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer2/ContinueLabel
@onready var settings_label: Label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer3/SettingsLabel
@onready var high_scores_label: Label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer4/HighScoresLabel
@onready var authors_label: Label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer5/AuthorsLabel
@onready var exit_label: Label = $CanvasLayer/MainMenuContainer/GridContainer/CenterContainer6/ExitLabel

@onready var start_level: PackedScene = preload("res://content/levels/home_level.tscn") as PackedScene
@onready var authors_menu: PackedScene = preload("res://content/levels/authors_menu.tscn") as PackedScene
@onready var high_score_menu: PackedScene = preload("res://content/levels/high_score_menu.tscn") as PackedScene
@onready var settings_menu: PackedScene = preload("res://content/levels/settings_menu.tscn") as PackedScene

@onready var exit_confirm_dialog: PackedScene = preload("res://content/dialogs/exit_confirm_dialog.tscn") as PackedScene

var menu_labels: Array[Label]

var currentMenuElement: int = 0
var currentChildMenu: Node = null

func _ready():
	if OS.has_feature("web"):
		menu_labels = [new_game_label, continue_label, settings_label, high_scores_label, authors_label]
		exit_label.visible = false
	else:
		menu_labels = [new_game_label, continue_label, settings_label, high_scores_label, authors_label, exit_label]

	GameManager.go_to_main_menu()

	var bundle = NavigationManager.get_pending_bundle()
	var target = bundle.get("target")
	match target:
		"high_score_menu":
			currentMenuElement = menu_labels.find(high_scores_label)
			handleAction()

	updateMenu()

func _process(_delta):
	var newCurrentMenuElement = currentMenuElement
	if Input.is_action_just_pressed("escape"):
		if currentChildMenu != null:
			canvas_layer.remove_child(currentChildMenu)
			currentChildMenu = null
			main_menu_container.visible = true
		elif not OS.has_feature("web"):
			handleExit()
	if Input.is_action_just_pressed("move_up") and currentChildMenu == null:
		newCurrentMenuElement -= 1
	if Input.is_action_just_pressed("move_down") and currentChildMenu == null:
		newCurrentMenuElement += 1
	if Input.is_action_just_pressed("action"):
		if currentChildMenu == null:
			handleAction()
		elif currentChildMenu.name == "ExitConfirmDialog":
			get_tree().quit()

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
			GameManager.go_to_game()
			GameManager.resetPlayer()
			GameSaver.new_game()
			get_tree().change_scene_to_packed(start_level)
		continue_label:
			GameManager.go_to_game()
			if GameSaver.is_game_saved():
				GameSaver.load_game()
			else:
				get_tree().change_scene_to_packed(start_level)
		settings_label:
			switchToSubMenu(settings_menu)
		high_scores_label:
			switchToSubMenu(high_score_menu)
		authors_label:
			switchToSubMenu(authors_menu)
		exit_label:
			handleExit()

func handleExit():
	switchToSubMenu(exit_confirm_dialog)

func switchToSubMenu(scene: PackedScene):
	currentChildMenu = scene.instantiate()
	canvas_layer.add_child(currentChildMenu)
	main_menu_container.visible = false
