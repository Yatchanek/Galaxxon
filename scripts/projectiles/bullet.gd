extends Projectile
class_name BasicBullet

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

func _ready() -> void:
    set_physics_process(false)


func _physics_process(delta: float) -> void:
    position += velocity * delta


func set_damage():
    super()
    body.get_surface_override_material(0).albedo_color = body_colors[power_level - 1]



func start():
    velocity = -global_basis.z * speed
    set_physics_process(true)
    hitbox.enable()
    hurtbox.enable()

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)
    hitbox.disable()
    hurtbox.disable()