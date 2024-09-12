extends StaticBody2D

@onready var sprite = $Sprite

var pointed_body: Node2D

func _on_talk_area_body_entered(body: Node2D):
	sprite.play("speak")

func _on_talk_area_body_exited(body: Node2D):
	sprite.play("point")

func _on_point_area_body_entered(body: Node2D):
	sprite.play("point")
	pointed_body = body

func _on_point_area_body_exited(body: Node2D):
	sprite.play("idle")
	pointed_body = null

func _process(_delta):
	if pointed_body == null:
		sprite.flip_h = false
	else:
		sprite.flip_h = pointed_body.global_position.x > global_position.x
