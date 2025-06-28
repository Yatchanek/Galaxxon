extends Projectile
class_name ExplosiveBullet

@onready var weapon : CircleCannonWeapon = $CircleCannonWeapon

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

var elapsed_time : float = 0.0

func _ready() -> void:
    type = BulletPool.BulletType.EXPLOSIVE_BULLET
    set_physics_process(false)

func _physics_process(delta: float) -> void:
    position += velocity * delta

    if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -45:
        return_to_pool()

    elapsed_time += delta
    if elapsed_time >= 2.0:
        explode()


func set_damage():
    hurtbox.damage = base_damage * power_level
    body.set_instance_shader_parameter("body_color", body_colors[power_level - 1])


func explode():
    velocity = Vector3.ZERO
    set_physics_process(false)
    hurtbox.disable()
    weapon.shoot()
    weapon.can_shoot = true
    elapsed_time = 0.0
    await get_tree().create_timer(0.1).timeout
    return_to_pool()

func start():
    velocity = -global_basis.z * speed
    set_physics_process(true)

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)