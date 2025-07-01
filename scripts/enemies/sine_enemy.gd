extends Enemy
class_name SineEnemy

@export var yawing : bool = false
@export var rolling : bool = false
@export var turning : bool = false

var angle : float = 0.0
var angle_2 : float = 0.0

func _ready() -> void:
	super()
	set_process(turning)

func _process(delta: float) -> void:
	angle += delta * 4.0


func _physics_process(delta: float) -> void:
	velocity = -global_basis.z.rotated(Vector3.UP, PI / 6 * sin(angle)) * speed
	position += velocity * delta
	
	if yawing:
		rotation_quat = Quaternion(Vector3.UP, PI / 6 * sin(angle))

	if rolling:
		if -global_basis.z.cross(velocity).y > 0:
			if yawing:
				rotation_quat *= Quaternion(Vector3.BACK, PI / 8 + PI / 12 * abs(velocity.z) / speed)
			else:
				rotation_quat = Quaternion(Vector3.BACK, PI / 8 + PI / 12 * abs(velocity.z) / speed)
		else:
			if yawing:
				rotation_quat *= Quaternion(Vector3.BACK, -PI / 8 - PI / 12 * abs(velocity.z) / speed)
			else:
				rotation_quat = Quaternion(Vector3.BACK, -PI / 8 - PI / 12 * abs(velocity.z) / speed)

	body_pivot.rotation = body_pivot.transform.basis.get_rotation_quaternion().slerp(rotation_quat, 0.05).get_euler()


	if position.x > 25 or position.x < -25 or position.z > 2:
		queue_free()

func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()