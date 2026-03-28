extends CharacterBody2D

@export var speed: float = 50.0
@export var chase_speed: float = 75.0
@export var gravity: float = 980.0
@export var walk_time: float = 2.0
@export var idle_time: float = 1.5
@export var damage: int = 10
@export var attack_damage: int = 20
@export var attack_cooldown: float = 1.0

@onready var animatedSprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer

var direction: int = 1
var is_idling: bool = true
var current_time: float = 0.0
var is_chasing: bool = false
var is_attacking: bool = false
var can_attack: bool = true
var player_in_attack_range: bool = false
var target_player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = [1, -1].pick_random()
	current_time = idle_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_attacking:
		velocity.x = 0
		play_animation_helper("attacking")
	elif not can_attack and player_in_attack_range:
		velocity.x = 0
		play_animation_helper("idle")
		
		if target_player:
			var dir_to_player = sign(target_player.global_position.x - global_position.x)
			if dir_to_player < 0:
				animatedSprite.flip_h = false
			else:
				animatedSprite.flip_h = true
	elif is_chasing and target_player:
		var dir_to_player = sign(target_player.global_position.x - global_position.x)
		velocity.x = dir_to_player * chase_speed
		play_animation_helper("run")
		
		if dir_to_player < 0:
			animatedSprite.flip_h = false
		else:
			animatedSprite.flip_h = true
	else:
		current_time -= delta
		
		if current_time <= 0:
			change_state()
			
		if is_idling:
			velocity.x = 0
			play_animation_helper("idle")
		else:
			velocity.x += direction * speed * delta
			play_animation_helper("run")
			
			if direction < 0:
				animatedSprite.flip_h = false
			else:
				animatedSprite.flip_h = true
				
			if is_on_wall():
				change_state()
		
	move_and_slide()

func change_state() -> void:
	if is_idling:
		is_idling = false
		current_time = walk_time
		direction = -direction
	else:
		is_idling = true
		current_time = idle_time

func play_animation_helper(animName) -> void:
	if animatedSprite.sprite_frames.has_animation(animName):
		animatedSprite.play(animName)
	else:
		pass


func _on_chase_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = true
		target_player = body

func _on_chase_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = false
		target_player = null

func _on_attacking_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = true
		start_attack()

func _on_attacking_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = false

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(damage)
		
func start_attack() -> void:
	if is_attacking or not player_in_attack_range:
		return
	
	is_attacking = true
	can_attack = false
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if player_in_attack_range and target_player:
		target_player.take_damage(attack_damage)
	
	is_attacking = false
	
	if get_tree() == null:
		return
	await get_tree().create_timer(attack_cooldown).timeout
	
	if player_in_attack_range:
		start_attack()
