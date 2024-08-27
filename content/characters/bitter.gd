extends CharacterBody2D

@export var life = 30

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
