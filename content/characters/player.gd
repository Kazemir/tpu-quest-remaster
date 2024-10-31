class_name Player
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const SOUND_CHECK_H_PADDING = 15.0
const SOUND_CHECK_V_PADDING = 5.0

@export var ground_tiles: TileMapLayer = null
@export var draw_debug: bool = false

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_player = $AnimationPlayer

@onready var sound_jump_start = $SoundJumpStart
@onready var sound_jump_stop = $SoundJumpStop

@onready var particles_jump_right = $ParticlesJumpRight
@onready var particles_jump_left = $ParticlesJumpLeft
@onready var blood_particles = $BloodParticles

@onready var sound_walk = $SoundWalk
@onready var sound_sword_attack = $SoundSwordAttack
@onready var sound_pain = $SoundPain
@onready var attack_collision_shape = $AttackArea/CollisionShape

var is_floating = false
var is_damage_taken = false

var attack_target_body_list: Array[Node2D] = []

func _physics_process(delta):
	if GameManager.is_game_paused:
		sprite.stop()
		return
	if not is_on_floor() and not is_floating:
		velocity += get_gravity() * delta

	if not is_damage_taken and Input.is_action_just_pressed("developer_mode"):
		is_floating = not is_floating

	if not is_damage_taken and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sound_jump_start.play()

	var direction = Input.get_axis("move_left", "move_right")
	if direction and not is_damage_taken:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.x == 0:
			is_damage_taken = false
	
	if abs(velocity.x) == SPEED and is_on_floor():
		if not sound_walk.playing:
			update_walk_sound()
			sound_walk.play()
	
	var direction_floating = Input.get_axis("move_up", "move_down")
	if not is_damage_taken and is_floating:
		velocity.y = direction_floating * SPEED
	
	if direction > 0:
		sprite.flip_h = false
		attack_collision_shape.position.x = 18
	elif direction < 0:
		sprite.flip_h = true
		attack_collision_shape.position.x = -18
	
	if not is_damage_taken and Input.is_action_just_pressed("action") and GameManager.player_weapon != GameManager.WeaponType.None and sprite.animation != "attack":
		sprite.play("attack")
		sound_sword_attack.play()
		
		for body in attack_target_body_list:
			match GameManager.player_weapon:
				GameManager.WeaponType.Sword:
					body.deal_damage(10, self)
				GameManager.WeaponType.SwordLight:
					body.deal_damage(100, self)
	
	if sprite.animation != "attack" or not sprite.is_playing():
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
		
	if draw_debug:
		queue_redraw()
	
	move_and_slide()

func update_walk_sound():
	if ground_tiles == null:
		return
	
	var ground_pos = global_position
	ground_pos.y = ground_pos.y + SOUND_CHECK_V_PADDING
	
	if velocity.x > 0:
		ground_pos.x = ground_pos.x + SOUND_CHECK_H_PADDING
	else:
		ground_pos.x = ground_pos.x - SOUND_CHECK_H_PADDING
	
	var cell_tile = ground_tiles.local_to_map(ground_pos)
	var data = ground_tiles.get_cell_tile_data(cell_tile)
	if data:
		var walk_sound = data.get_custom_data("walk_sound")
		match walk_sound:
			"stone":
				sound_walk.stream = load("res://content/audio/stone.ogg")
			"gravel":
				sound_walk.stream = load("res://content/audio/gravel2.ogg")
			"grass":
				sound_walk.stream = load("res://content/audio/grass1.ogg")
			"wood":
				sound_walk.stream = load("res://content/audio/wood.ogg")
			_:
				sound_walk.stream = load("res://content/audio/gravel2.ogg")
	else:
		sound_walk.stream = load("res://content/audio/gravel2.ogg")


func _on_draw():
	if draw_debug:
		var ground_pos = Vector2(0, 0)
		ground_pos.y = ground_pos.y + SOUND_CHECK_V_PADDING
		
		if velocity.x > 0:
			ground_pos.x = ground_pos.x + SOUND_CHECK_H_PADDING
		else:
			ground_pos.x = ground_pos.x - SOUND_CHECK_H_PADDING
		
		draw_circle(ground_pos, 3.0, Color.AQUA)


func _on_attack_area_body_entered(body):
	if not attack_target_body_list.has(body):
		attack_target_body_list.append(body)


func _on_attack_area_body_exited(body):
	var index = attack_target_body_list.find(body)
	if index != -1:
		attack_target_body_list.remove_at(index)

func deal_damage(val: int, from: Node2D):
	print("Player, damage taken: ", val)
	if is_damage_taken:
		return
	GameManager.recieveDamage(val)
	if GameManager.player_health > 0:
		animation_player.play("pain")
		blood_particles.restart()
		sound_pain.play()
		
		var dir = global_position.direction_to(from.global_position)
		velocity.x = -dir.x * SPEED * 5
		velocity.y = JUMP_VELOCITY * 0.7
		
		is_damage_taken = true
