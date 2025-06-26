extends Enemy
class_name DiagonalEnemy

var desired_velocity : Vector3
var turned : bool = false

var elapsed_time : float = 0
var turn_threshold : int = -20

func _ready() -> void:
	super()
	desired_velocity = velocity

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if turned:
		velocity = lerp(velocity, desired_velocity, 0.05)
		body_pivot.rotation = body_pivot.basis.get_rotation_quaternion().slerp(rotation_quat, 0.05).get_euler()

	position += velocity * delta

	if !turned and elapsed_time > 2.0 and position.y > turn_threshold:
		turned = true
		if position.x >= 0:
			desired_velocity = velocity.rotated(Vector3.UP, -PI / 3)
			rotation_quat = Quaternion(Vector3.UP, -PI / 3) * Quaternion(Vector3.FORWARD, PI / 3.5)
		else:
			desired_velocity = velocity.rotated(Vector3.UP, PI / 4)
			rotation_quat = Quaternion(Vector3.UP, PI / 3)  * Quaternion(Vector3.FORWARD, -PI / 3.5)


	if position.y > 2 or position.x < -35 or position.x > 35:
		queue_free()


func die():
	EventBus.enemy_destroyed.emit(self)
	set_physics_process(false)
	hurtbox.disable()
	hitbox.disable()
	queue_free()