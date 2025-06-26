extends Projectile
class_name Rocket

const ACCELERATION : float = 150.0

var desired_velocity : Vector3

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

var rotation_quat : Quaternion

func _ready() -> void:
    set_physics_process(false)
    type = BulletPool.BulletType.ROCKET
    rotation_quat = $Body3.basis.get_rotation_quaternion()


func _physics_process(delta: float) -> void:
    velocity = velocity.move_toward(desired_velocity, ACCELERATION * delta)
    position += velocity * delta

    rotation_quat *= Quaternion(Vector3.UP, TAU * 3 * delta)

    if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -40:
        return_to_pool()

    $Body3.rotation = $Body3.basis.get_rotation_quaternion().slerp(rotation_quat, 1.0).get_euler()

func set_damage():
    hurtbox.damage = base_damage * power_level




func start():
    set_physics_process(true)
    desired_velocity = -global_basis.z * speed

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)