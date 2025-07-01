extends Projectile
class_name BasicBullet

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

func _ready() -> void:
    set_physics_process(false)


func _physics_process(delta: float) -> void:
    position += velocity * delta

    if Globals.game_mode == Globals.GameMode.GALAGA:
        if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -45:
            return_to_pool()
    else:
        if position.x < -25 or position.x > 25 or position.z < position.x - 53:
            return_to_pool()


func set_damage():
    super()
    body.set_instance_shader_parameter("body_color", body_colors[power_level - 1])



func start():
    velocity = -global_basis.z * speed
    set_physics_process(true)

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)