extends Enemy
class_name PathEnemy

@export var flight_time : float 


func _process(delta: float) -> void:
	if -global_basis.z.cross(Vector3.RIGHT).y > 0:
		rotation_quat = Quaternion(Vector3.BACK, -PI / 8)
		rotation_quat *= Quaternion(Vector3.RIGHT, -PI / 8)
	else:
		rotation_quat = Quaternion(Vector3.BACK, PI / 8)
		rotation_quat *= Quaternion(Vector3.RIGHT, PI / 8)

	body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, delta).get_euler()



func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()