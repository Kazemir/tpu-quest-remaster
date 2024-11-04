extends CharacterBody2D

@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_damage_taken = false

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(data: SavedData):
	global_position = data.position

func on_save_game(saved_data: Array[SavedData]):
	var data = SavedEnemyData.new()
	data.scene_path = scene_file_path
	data.position = global_position
	data.health = 10
	saved_data.append(data)

func deal_damage(val: int, from: Node2D):
	if is_damage_taken:
		return

	is_damage_taken = true
	animation_player.play("die")
	death_sound.play()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		if death_sound.playing:
			await death_sound.finished
		queue_free()
