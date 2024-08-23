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
	# TODO
