extends Area2D

@onready var talker_label = $TalkerLabel

func _ready():
	talker_label.visible = Engine.is_editor_hint()

func _on_body_entered(body):
	if body.name == "Player":
		talker_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		talker_label.visible = false

func _process(delta):
	if Engine.is_editor_hint():
		return
	#if Input.is_action_just_pressed("action") and talker_label.visible:
	#	game_hud.add_child(load("res://content/dialogs/talker_dialog.tscn").instance())
