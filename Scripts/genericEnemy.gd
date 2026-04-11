extends CharacterBody2D

@export_group("Basic Settings")
@export var speed: float = 50.0
@export var chase_speed: float = 75.0
@export var gravity: float = 980.0
@export var walk_time: float = 2.0
@export var idle_time: float = 1.5
@export_group("")

@export_group("Attacking Settings")
@export var damage: int = 10
@export var attack_damage: int = 20
@export var attack_cooldown: float = 1.0
@export_enum("Mele", "Range", "Mixed") var attacking_type: String
@export_group("")

@export_group("Ranged Settings")
@export var projectile_scene: PackedScene
@export var projectile_time:float = 0.8
@export_enum("Parabolic", "Straight") var projectile_trajectory: int
@export_group("")

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
		if attacking_type == "Range":
			play_animation_helper("shoot")
		else:
			play_animation_helper("attacking")

	elif not can_attack and player_in_attack_range:
		velocity.x = 0
		play_animation_helper("idle")		
		if target_player:
			var dir_to_player = sign(target_player.global_position.x - global_position.x)
			animatedSprite.flip_h = (dir_to_player > 0)
			
	elif is_chasing and target_player:
		var dir_to_player = sign(target_player.global_position.x - global_position.x)
		velocity.x = dir_to_player * chase_speed
		play_animation_helper("run")
		animatedSprite.flip_h = (dir_to_player > 0)
		
	else:
		current_time -= delta
		if current_time <= 0:
			change_state()
			
		if is_idling:
			velocity.x = 0
			play_animation_helper("idle")
		else:
			velocity.x = direction * speed
			play_animation_helper("run")
			animatedSprite.flip_h = (direction > 0)
				
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
		target_player = body
		start_attack()

func _on_attacking_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = false

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(damage)
		
func start_attack() -> void:
	if is_attacking or not player_in_attack_range or not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if player_in_attack_range and target_player:
		if attacking_type == "Range" and projectile_scene != null:
			shoot_projectile()
		else:
			target_player.take_damage(attack_damage)
	
	is_attacking = false
	start_cooldown()
	
func start_cooldown() -> void:
	if get_tree() == null: return
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
	if player_in_attack_range: start_attack()

func shoot_projectile() -> void:
	if target_player == null: return
		
	var projectile =  projectile_scene.instantiate()
	#projectile.ball_destroyed.connect(_on_projectile_disappeared)
	get_tree().current_scene.call_deferred("add_child", projectile)
	projectile.global_position = global_position + Vector2(0, -20)
	
	var displacement = target_player.global_position - projectile.global_position
	var time = projectile_time
	var vel_x = displacement.x / time
	var vel_y = (displacement.y - 0.5 * gravity * time * time) / time
	
	projectile.velocity = Vector2(vel_x, vel_y)
	projectile.damage = attack_damage

func _on_projectile_disappeared() -> void:
	start_cooldown()
