class_name Player
extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -700.0
const SOUND_CHECK_H_PADDING: float = 15.0
const SOUND_CHECK_V_PADDING: float = 5.0

@export var ground_tiles: TileMapLayer = null
@export var draw_debug: bool = false

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sound_jump_start: AudioStreamPlayer2D = $SoundJumpStart
@onready var sound_jump_stop: AudioStreamPlayer2D = $SoundJumpStop

@onready var particles_jump_right: CPUParticles2D = $ParticlesJumpRight
@onready var particles_jump_left: CPUParticles2D = $ParticlesJumpLeft
@onready var blood_particles: CPUParticles2D = $BloodParticles

@onready var sound_walk: AudioStreamPlayer2D = $SoundWalk
@onready var sound_sword_attack: AudioStreamPlayer2D = $SoundSwordAttack
@onready var sound_pain: AudioStreamPlayer2D = $SoundPain
@onready var attack_collision_shape: CollisionShape2D = $AttackArea/CollisionShape

@onready var god_mode_timer: Timer = $GodModeTimer

var is_floating: bool = false
var is_knockback: bool = false
var is_god_mode: bool = false

var attack_target_body_list: Array[Node2D] = []

func _physics_process(delta: float) -> void:
	if GameManager.is_game_paused:
		sprite.stop()
		return
	if not is_floating:
		velocity += get_gravity() * delta

	if not is_knockback and OS.has_feature("debug") and Input.is_action_just_pressed("developer_mode"):
		is_floating = not is_floating

	if is_knockback:
		pass
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sound_jump_start.play()

	var direction: float = Input.get_axis(&"move_left", &"move_right")
	if is_knockback:
		pass
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if abs(velocity.x) == SPEED and is_on_floor():
		if not sound_walk.playing:
			_update_walk_sound()
			sound_walk.play()

	var direction_floating: float = Input.get_axis(&"move_up", &"move_down")
	if not is_knockback and is_floating:
		velocity.y = direction_floating * SPEED

	if not is_knockback and Input.is_action_just_pressed("action"):
		_perform_attack()

	_update_sprite(direction)

	if draw_debug:
		queue_redraw()

	move_and_slide()

	if is_knockback and is_on_floor():
		is_knockback = false

func _update_walk_sound() -> void:
	if ground_tiles == null:
		return

	var ground_pos: Vector2 = global_position
	ground_pos.y = ground_pos.y + SOUND_CHECK_V_PADDING

	if velocity.x > 0:
		ground_pos.x = ground_pos.x + SOUND_CHECK_H_PADDING
	else:
		ground_pos.x = ground_pos.x - SOUND_CHECK_H_PADDING

	var cell_tile: Vector2i = ground_tiles.local_to_map(ground_pos)
	var data: TileData = ground_tiles.get_cell_tile_data(cell_tile)
	if data:
		var walk_sound: Variant = data.get_custom_data("walk_sound")
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


func _update_sprite(direction: float) -> void:
	if direction > 0:
		sprite.flip_h = false
		attack_collision_shape.position.x = 30
	elif direction < 0:
		sprite.flip_h = true
		attack_collision_shape.position.x = -30

	if sprite.animation != &"attack" or not sprite.is_playing():
		if is_on_floor():
			if sprite.animation == &"jump":
				sound_jump_stop.play()
				particles_jump_right.restart()
				particles_jump_left.restart()
			if direction == 0:
				sprite.play(&"idle")
			else:
				sprite.play(&"walk")
		else:
			sprite.play(&"jump")


func _perform_attack():
	if GameManager.player_weapon == GameManager.WeaponType.None or sprite.animation == "attack":
		return

	sprite.play(&"attack")
	sound_sword_attack.play()

	for body: Node2D in attack_target_body_list:
		match GameManager.player_weapon:
			GameManager.WeaponType.Sword:
				body.deal_damage(10, self)
			GameManager.WeaponType.SwordLight:
				body.deal_damage(100, self)


func _on_draw() -> void:
	if draw_debug:
		var ground_pos: Vector2 = Vector2(0, 0)
		ground_pos.y = ground_pos.y + SOUND_CHECK_V_PADDING

		if velocity.x > 0:
			ground_pos.x = ground_pos.x + SOUND_CHECK_H_PADDING
		else:
			ground_pos.x = ground_pos.x - SOUND_CHECK_H_PADDING

		draw_circle(ground_pos, 3.0, Color.AQUA)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not attack_target_body_list.has(body):
		attack_target_body_list.append(body)


func _on_attack_area_body_exited(body: Node2D) -> void:
	var index: int = attack_target_body_list.find(body)
	if index != -1:
		attack_target_body_list.remove_at(index)

const KNOCKBACK_HORIZONTAL_SPEED: float = 600.0 # Скорость отскока в сторону
const KNOCKBACK_VERTICAL_SPEED: float = -500.0 # Скорость прыжка вверх при отскоке

func deal_damage(val: int, from: Node2D) -> void:
	if is_god_mode or is_floating:
		return
	GameManager.recieveDamage(val)
	if GameManager.player_health > 0:
		animation_player.play(&"pain")
		blood_particles.restart()
		sound_pain.play()

		var knockback_direction: float = -sign(velocity.x)
		if knockback_direction == 0.0:
			knockback_direction = sign(global_position.x - from.global_position.x)
		if knockback_direction == 0.0:
			knockback_direction = 1.0

		velocity.x = knockback_direction * SPEED * 0.5
		velocity.y = JUMP_VELOCITY * 0.7

		is_knockback = true
		is_god_mode = true
		god_mode_timer.start()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"pain":
		sprite.modulate.a = 0.5


func _on_god_mode_timer_timeout() -> void:
	sprite.modulate.a = 1.0
	is_god_mode = false
