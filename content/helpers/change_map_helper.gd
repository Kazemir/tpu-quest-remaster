extends Area2D

@onready var enter_label = $EnterLabel

@export var nextMap: PackedScene

func _ready():
	enter_label.visible = Engine.is_editor_hint()

func _on_body_entered(body):
	if body.name == "Player":
		enter_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		enter_label.visible = false

func _process(delta):
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed("action") and enter_label.visible:
		get_tree().change_scene_to_packed(nextMap)
