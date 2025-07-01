extends Projectile
class_name ExplosiveBullet

@onready var weapon : CircleCannonWeapon = $CircleCannonWeapon

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

var elapsed_time : float = 0.0

func _ready() -> void:
    set_physics_process(false)
    weapon.is_subweapon = from_sub_weapon

func _physics_process(delta: float) -> void:
    position += velocity * delta

    if Globals.game_mode == Globals.GameMode.GALAGA:
        if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -45:
            return_to_pool()
    else:
        if position.x < -25 or position.x > 25 or position.z < position.x - 53:
            return_to_pool()

    elapsed_time += delta
    if elapsed_time >= 2.0:
        explode()
        elapsed_time = 0.0


func set_damage():
    super()
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
    elapsed_time = 0.0
    set_physics_process(false)