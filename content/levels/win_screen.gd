extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("launch")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # show input box
