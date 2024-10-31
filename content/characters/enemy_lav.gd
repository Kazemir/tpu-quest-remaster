extends CharacterBody2D

@onready var death_sound = $DeathSound

@export var life = 10

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

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

func deal_damage(val: int, from: Node2D):
	print("LAV, damage taken: ", val)
	life -= val
	if life <= 0:
		death_sound.play()
		await death_sound.finished
		queue_free() # TODO wait
	
