extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

signal ball_destroyed

var velocity: Vector2 = Vector2.ZERO
var is_destroyed: bool = false
var damage: float = 10
var projectile_gravity: float = 980.0

func _ready() -> void:
	if animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
		
	velocity.y += projectile_gravity * delta
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if is_destroyed:
		return
		
	if body.is_in_group("Player"):
		body.take_damage(damage)
		trigger_destruction()
	elif not body.is_in_group("Player") and not body.is_in_group("Enemy"):
		trigger_destruction()

func trigger_destruction() -> void:
	if is_destroyed: return
	is_destroyed = true
	
	if animated_sprite.sprite_frames.has_animation("splash"):
		animated_sprite.play("splash")
		await animated_sprite.animation_finished
	
	ball_destroyed.emit()
	queue_free()
