extends Bullet
class_name ExplosiveBullet

@onready var weapon = $CircleCannonWeapon

var elapsed_time : float = 0.0

func _ready() -> void:
    set_physics_process(false)
    

func _physics_process(delta: float) -> void:
    super(delta)

    elapsed_time += delta
    if elapsed_time >= 2.0:
        explode()
        elapsed_time = 0.0


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
    hitbox.enable()
    hurtbox.enable()

func stop():
    super()
    elapsed_time = 0.0
