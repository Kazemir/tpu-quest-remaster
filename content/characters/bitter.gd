extends CharacterBody2D

@onready var attack_area: Area2D = $AttackArea

@onready var animation_player = $AnimationPlayer
@onready var blood_particles = $BloodParticles

@onready var pain_sound = $PainSound
@onready var death_sound = $DeathSound

@export var life = 30

var is_damage_taken = false
var pending_attack_target_body: Node2D = null

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
	if is_damage_taken:
		return

	is_damage_taken = true
	blood_particles.restart()

	life -= val
	if life <= 0:
		attack_area.monitoring = false
		animation_player.play("die")
		death_sound.play()
	else:
		animation_player.play("pain")
		pain_sound.play()


func _on_attack_area_body_entered(body):
	if not is_damage_taken:
		body.deal_damage(5, self)
	else:
		pending_attack_target_body = body


func _on_attack_area_body_exited(body):
	if pending_attack_target_body == body:
		pending_attack_target_body = null


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		if death_sound.playing:
			await death_sound.finished
		queue_free()
	elif anim_name == "pain":
		is_damage_taken = false
		if pending_attack_target_body != null:
			pending_attack_target_body.deal_damage(5, self)
