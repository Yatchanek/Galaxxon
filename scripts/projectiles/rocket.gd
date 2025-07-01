extends Projectile
class_name Rocket

const ACCELERATION : float = 150.0

var desired_velocity : Vector3

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

var rotation_quat : Quaternion

var wings : MeshInstance3D

func _ready() -> void:
    set_physics_process(false)
    
    wings = $Body/Body3
    rotation_quat = wings.basis.get_rotation_quaternion()

func _physics_process(delta: float) -> void:
    velocity = velocity.move_toward(desired_velocity, ACCELERATION * delta)
    position += velocity * delta

    rotation_quat *= Quaternion(Vector3.UP, TAU * 3 * delta)

    if Globals.game_mode == Globals.GameMode.GALAGA:
        if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -45:
            return_to_pool()
    else:
        if position.x < -25 or position.x > 25 or position.z < position.x - 53:
            return_to_pool()

    wings.rotation = wings.basis.get_rotation_quaternion().slerp(rotation_quat, 1.0).get_euler()


func set_damage():
    super()
    wings.set_instance_shader_parameter("body_color", body_colors[(power_level - 1) % 3])


func start():
    set_physics_process(true)
    desired_velocity = -global_basis.z * speed

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)