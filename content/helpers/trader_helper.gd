extends Area2D

@onready var trade_label = $TradeLabel

var dialog: PackedScene = preload("res://content/dialogs/trader_dialog.tscn") as PackedScene

func _ready():
	trade_label.visible = Engine.is_editor_hint()

func _on_body_entered(body):
	if body.name == "Player":
		trade_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		trade_label.visible = false

func _process(_delta):
	if Engine.is_editor_hint() or GameManager.is_game_paused:
		return
	if Input.is_action_just_pressed("action") and trade_label.visible:
		DialogManager.show_dialog(dialog.instantiate())
