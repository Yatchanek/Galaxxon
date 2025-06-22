extends Node3D
class_name SineEnemy

@onready var body_pivot : Node3D = $BodyPivot

@export var turning : bool = true
@export var yawing : bool = true

var velocity : Vector3
var angle : float = 0.0
var angle_2 : float = 0.0
var speed : float = 15.0

var rotation_quat : Quaternion

func _ready() -> void:
	velocity = -basis.z * speed
	rotation_quat = body_pivot.transform.basis.get_rotation_quaternion()

	if global_basis.z.dot(Vector3.FORWARD) > 0.5:
		turning = false
		yawing = false

func _process(delta: float) -> void:
	angle += delta * 4.0


func _physics_process(delta: float) -> void:
	velocity = -global_basis.z.rotated(Vector3.UP, PI / 6 * sin(angle)) * speed
	position += velocity * delta
	
	if turning:
		rotation_quat = Quaternion(Vector3.UP, PI / 6 * sin(angle))

	if yawing:
		if velocity.z > 0:
			if turning:
				rotation_quat *= Quaternion(Vector3.BACK, PI / 6 + PI / 8 * abs(velocity.z) / speed)
			else:
				rotation_quat = Quaternion(Vector3.BACK, PI / 6 + PI / 8 * abs(velocity.z) / speed)
		else:
			if turning:
				rotation_quat *= Quaternion(Vector3.BACK, -PI / 6 - PI / 8 * abs(velocity.z) / speed)
			else:
				rotation_quat = Quaternion(Vector3.BACK, -PI / 6 - PI / 8 * abs(velocity.z) / speed)

	body_pivot.rotation = body_pivot.transform.basis.get_rotation_quaternion().slerp(rotation_quat, 0.05).get_euler()


	if (velocity.x > 0 and position.x > 40) or (velocity.x < 0 and position.x < -40) or (velocity.y > 0 and position.y < 2):
		queue_free()
