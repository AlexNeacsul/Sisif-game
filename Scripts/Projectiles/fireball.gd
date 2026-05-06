extends GenericProjectile

func calc_velocity(displacement: Vector2) -> Vector2:
	var vel_x = displacement.x / projectile_time
	var vel_y = displacement.y
	
	return Vector2(vel_x, vel_y)
