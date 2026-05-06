extends Area2D
#Making this script the main script for all projectiles
class_name GenericProjectile

@onready var animatedSprite = $AnimatedSprite2D

@export var has_gravity:bool = true
@export var projectile_time: float = 0.8

var velocity: Vector2 = Vector2.ZERO
var projectile_gravity: float = 980.0
var is_destroyed: bool = false
var damage: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animatedSprite.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_destroyed: return
	
	if has_gravity:
		velocity.y += projectile_gravity * delta
		position += velocity * delta
	else:
		position += velocity * delta

func setup_trajectory(start_pos: Vector2, target_pos: Vector2, new_damage: int) ->void:
	global_position = start_pos
	damage = new_damage
		
	var displacement = target_pos - start_pos
		
	velocity = calc_velocity(displacement)
	
func calc_velocity(displacement: Vector2) -> Vector2:
	var vel_x = displacement.x / projectile_time
	var vel_y = displacement.y / projectile_time
	
	return Vector2(vel_x, vel_y)

func _on_body_entered(body: Node2D) -> void:
	if is_destroyed: return
	
	if body.is_in_group("Player"):
		body.take_damage(damage)
		trigger_destruction()
	elif not body.is_in_group("Player") and not body.is_in_group("Enemy"):
		trigger_destruction()
		
func trigger_destruction() -> void:
	if is_destroyed: return
	
	is_destroyed = true
	
	if animatedSprite.sprite_frames.has_animation("impact"):
		animatedSprite.play("impact")
		await animatedSprite.animation_finished
	
	queue_free()
