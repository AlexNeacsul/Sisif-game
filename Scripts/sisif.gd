extends CharacterBody2D

signal health_changed(new_health)
@export var max_health: int = 100
var current_health: int = 100
var is_invincible: bool = false

@onready var boulder: CharacterBody2D = $"../boulder"
@onready var animated_sprite: AnimatedSprite2D = $SisifSprite

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var PUSH_STRENGTH: float = 70.0
var carrying_boulder = false

func _ready() -> void:
	current_health = max_health
	add_to_group("Player")

func get_carrying_boulder() -> bool:
	return carrying_boulder

func _input(event):
	if event.is_action_pressed("carry"):
		if !carrying_boulder:
			boulder.set_lift(true)
			carrying_boulder = true
		else:
			boulder.set_lift(false)
			carrying_boulder = false

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = get_last_slide_collision()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if is_on_floor():
		if direction == 0:
			if carrying_boulder:
				animated_sprite.play("idel_carrying")
			else:
				animated_sprite.play("Idle")
		else:
			if collision:
				var collider_node = collision.get_collider()
				if collider_node is RigidBody2D:
					animated_sprite.play("Pushing")
					var collision_normal: Vector2 = collision.get_normal()
					collider_node.apply_central_force(-collision_normal * PUSH_STRENGTH)
				else:
					animated_sprite.play("Run")
	else:
		animated_sprite.play("Jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func take_damage(amount: int):
	if is_invincible:
		return
	
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	health_changed.emit(current_health)
	
	if current_health <= 0:
		die()
	else:
		become_invincible()
		
func become_invincible():
	is_invincible = true
	
	animated_sprite.modulate.a = 0.5
	await get_tree().create_timer(1).timeout
	animated_sprite.modulate.a = 1.0
	is_invincible = false
	
func die():
	print("sisif e mort!")
	get_tree().reload_current_scene()
