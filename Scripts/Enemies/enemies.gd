extends Node2D

@onready var pools:Dictionary = {
	"miniBoss": $MiniBoss_pool1,
	"genericEnemy": $Enemies_pool1
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pool in pools.values():
		pool.visible = false
		pool.process_mode = Node.PROCESS_MODE_DISABLED
	spawn_enemies_by_zone()

func spawn_enemies_by_zone():
	var spawn_points = get_tree().get_nodes_in_group("spawnPoints")
	
	for point in spawn_points:
		if "pool_id" in point:
			spawn_enemies_at_markers(point, point.pool_id)
		else:
			spawn_enemies_at_markers(point, 1)

func spawn_enemies_at_markers(point_node, id):
	var source_pool = null
	
	match id:
		1:
			source_pool = pools[point_node.enemyType]
		_:
			source_pool = pools[point_node.enemyType]
	
	var templates = source_pool.get_children()
	
	if templates.size() == 0:
		print("Nu exista inamici")
		return
	else:
		var random_template = templates.pick_random()
		var new_enemy = random_template.duplicate()
		
		new_enemy.global_position = point_node.global_position
		new_enemy.visible = true
		new_enemy.process_mode = Node.PROCESS_MODE_INHERIT
		
		add_child(new_enemy)
		
		point_node.queue_free()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
