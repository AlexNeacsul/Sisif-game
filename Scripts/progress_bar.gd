extends CanvasLayer

@onready var health_bar = $ProgressBar
@onready var player = %Sisif

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health

	player.health_changed.connect(update_health_bar)

func update_health_bar(new_health):
	health_bar.value = new_health
