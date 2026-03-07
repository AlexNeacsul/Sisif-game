extends CharacterBody2D

@onready var sisif: CharacterBody2D = $"../Sisif"

var lifted = false
var lift_offset = Vector2(0, -61) # Poziția deasupra lui Sisif

func set_lift(lift_param: bool):
	lifted = lift_param
	lift()

func lift():
	if lifted:
		print("LIFTED")
	else:
		print("ARUNCAT")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if lifted:
		if sisif.get_carrying_boulder():
			print("hhh")
		global_position = sisif.global_position + lift_offset
	else:
		# Aplică gravitația doar când nu e ridicat
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
