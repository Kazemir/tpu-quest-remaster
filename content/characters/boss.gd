extends CharacterBody2D

const SPEED: float = 75.0
const JUMP_VELOCITY: float = -400.0

@onready var attack_area: Area2D = $AttackArea

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blood_particles: CPUParticles2D = $BloodParticles

@onready var pain_sound: AudioStreamPlayer2D = $PainSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

@export var life = 300
var is_damage_taken = false
var pending_attack_target_body: Node2D = null

func _physics_process(delta):
	if GameManager.is_game_paused:
		animated_sprite.stop()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_damage_taken:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif is_on_wall() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func move(dir, speed):
	if is_damage_taken:
		return
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

func deal_damage(val: int, from: Node2D):
	if is_damage_taken:
		return

	is_damage_taken = true
	blood_particles.restart()
	animated_sprite.play("idle")

	var dir = global_position.direction_to(from.global_position)
	velocity.x = -dir.x * SPEED * 11
	velocity.y = JUMP_VELOCITY * 0.7

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
		GameManager.triggerGameWin()
		queue_free()
	elif anim_name == "pain":
		is_damage_taken = false
		handle_animation()
		if pending_attack_target_body != null:
			pending_attack_target_body.deal_damage(5, self)
