extends Projectile
class_name BasicBullet

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

func _ready() -> void:
    set_physics_process(false)
    type = BulletPool.BulletType.BASIC_BULLET


func _physics_process(delta: float) -> void:
    position += velocity * delta

    if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -45:
        return_to_pool()


func set_damage():
    hurtbox.damage = base_damage * power_level
    body.set_instance_shader_parameter("body_color", body_colors[power_level - 1])



func return_to_pool():
    BulletPool.return_to_pool(self)

func start():
    velocity = -global_basis.z * speed
    set_physics_process(true)

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)