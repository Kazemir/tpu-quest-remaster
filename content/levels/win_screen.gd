extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialog: PackedScene = preload("res://content/dialogs/input_dialog.tscn") as PackedScene
var main_menu: PackedScene = preload("res://content/levels/high_score_menu.tscn") as PackedScene

func _ready() -> void:
	animation_player.play("launch")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var dialog = dialog.instantiate() as InputDialog

	var score = GameManager.get_game_score()

	var dialog_data = InputDialogData.new()
	dialog_data.name = "game_winInput_caption"
	dialog_data.message = TranslationServer.translate("game_winInput_text") % score

	dialog.dialog_data = dialog_data
	DialogManager.show_dialog(dialog)

	var name = await dialog.entered
	if name == null:
		NavigationManager.MainMenu.go(get_tree())
	else:
		var bundle = {}
		bundle["target"] = "high_score_menu"
		NavigationManager.MainMenu.go(get_tree(), bundle)
