extends CharacterBody2D

@export var speed: float = 10.0
@export var gravity: float = 980.0
@export var walk_time: float = 2.0
@export var idle_time: float = 1.5
@export var hp: int = 100

@onready var animatedSprite = $AnimatedSprite2D

var direction: int = 1
var is_idling: bool = true
var current_time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = [1, -1].pick_random()
	current_time = idle_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
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
