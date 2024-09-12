extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite

@export var life = 60

func _physics_process(delta):
	if GameManager.is_game_paused:
		animated_sprite.stop()
		return
	
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

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(data: SavedData):
	global_position = data.position
	if data is SavedEnemyData:
		life = data.health
	
func on_save_game(saved_data: Array[SavedData]):
	var data = SavedEnemyData.new()
	data.scene_path = scene_file_path
	data.position = global_position
	data.health = life
	saved_data.append(data)
