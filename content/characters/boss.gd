extends CharacterBody2D

const SPEED = 75.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite

@export var life = 300

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_wall() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func move(dir, speed):
	velocity.x = dir * speed
	handle_animation()
	update_flip(dir)

func update_flip(dir):
	animated_sprite.flip_h = abs(dir) != dir
	
func handle_animation():
	if velocity.x != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
		
func check_for_self(node):
	return node == self
