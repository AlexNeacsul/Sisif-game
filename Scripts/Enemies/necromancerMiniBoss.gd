extends CharacterBody2D

@export_group("Basic Settings")
@export var speed:float = 50.0
@export var chase_speed:float = 75.0
@export var gravity:float = 980.0
@export var walk_time:float = 3.0
@export var idle_time:float = 7.5
@export var health:int = 300
@export var invincibility_time:float = 1.5
@export_group("")

@export_group("Attacking Settings")
@export var damage:int = 25
@export var attack_cooldown:float = 5.0
@export var minion_scene:PackedScene
@export var max_minions:int = 4
@export_group("")

@onready var animatedSprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var attackTimer:Timer = $AttackTimer

var is_idling:bool = true
var is_chasing:bool = false
var is_attacking:bool = false
var can_attack:bool = true
var player_in_attack_range:bool = false
var minions:int = 0
var direction:int = 1
var current_time:float = 0.0
var target_player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_time = idle_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor(): velocity.y += gravity * delta
	
	if is_attacking: 
		velocity.x = 0
		play_animation_helper("Attacking")
	else:
		current_time -= delta
		
		if current_time <= 0: change_state()
		
		if is_idling:
			velocity.x = 0
			play_animation_helper("Idle")
		else:
			velocity.x = -direction * speed
			play_animation_helper("Running")
			animatedSprite.flip_h = (direction > 0)
			
			if is_on_wall(): change_state()
	move_and_slide()

func play_animation_helper(animName) -> void:
	if animatedSprite.sprite_frames.has_animation(animName):
		animatedSprite.play(animName)
	else:
		pass
		
func change_state() -> void:
	if is_idling:
		is_idling = false
		current_time = walk_time
		direction = -direction
	else:
		is_idling = true
		current_time = idle_time


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): body.take_damage(damage)


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
	if body.is_in_group("Player"): player_in_attack_range = false
	
func _on_attack_timer_timeout() -> void:
	if player_in_attack_range and target_player and minions < max_minions:
		spawn_minion()
		
	is_attacking = false
	start_cooldown()

func start_attack() -> void:
	if is_attacking or not player_in_attack_range or not can_attack: return
	
	if minions >= max_minions: return
	
	is_attacking = true
	can_attack = false
	play_animation_helper("Attacking")
	attackTimer.start()
	
func spawn_minion() -> void:
	if minion_scene == null: return
	
	var minion = minion_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", minion)
	
	var spawn_dir = 1
	if target_player:
		spawn_dir = sign(target_player.global_position.x - global_position.x)
	elif animatedSprite.flip_h:
		spawn_dir = -1
		
	minion.global_position = global_position + Vector2(spawn_dir  * 60, - 10)
	
	minions += 1
	
	minion.tree_exited.connect(_on_minion_died)
	
func _on_minion_died() -> void:
	minions -= 1
	
	if player_in_attack_range and can_attack: start_attack()

func start_cooldown() -> void:
	if get_tree() == null: return
	
	await get_tree().create_timer(attack_cooldown).timeout
	
	can_attack = true
	
	if player_in_attack_range: start_attack()
