extends Area2D

@export var talk_data: TalkData

@onready var talker_label = $TalkerLabel

var dialog: PackedScene = preload("res://content/dialogs/talker_dialog.tscn") as PackedScene

func _ready():
	talker_label.visible = Engine.is_editor_hint()

func _on_body_entered(body):
	if body.name == "Player":
		talker_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		talker_label.visible = false

func _process(_delta):
	if Engine.is_editor_hint() or GameManager.is_game_paused or talk_data == null:
		return
	if Input.is_action_just_pressed("action") and talker_label.visible:
		var dialog = dialog.instantiate() as TalkerDialog
		dialog.talk_data = talk_data
		DialogManager.show_dialog(dialog)
