extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -700.0

@onready var sprite = $Sprite

@onready var sound_jump_start = $SoundJumpStart
@onready var sound_jump_stop = $SoundJumpStop

@onready var particles_jump_right = $ParticlesJumpRight
@onready var particles_jump_left = $ParticlesJumpLeft

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sound_jump_start.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI acti	ons with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

	if is_on_floor():
		if sprite.animation == "jump":
			sound_jump_stop.play()
			particles_jump_right.restart()
			particles_jump_left.restart()
		if direction == 0:
			sprite.play("idle")
		else:
			sprite.play("walk")
	else:
		sprite.play("jump")

	move_and_slide()
