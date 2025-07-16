extends Projectile
class_name SonicWave

var mat : ShaderMaterial

@export var colors : Array[Color] = []

func _ready() -> void:
    set_physics_process(false)
    mat = $Body.get_surface_override_material(0)

func _physics_process(delta: float) -> void:
    position += velocity * delta


func set_damage():
    super()
    mat.set_shader_parameter("albedo_color", colors[power_level - 1])


func start():
    velocity = -global_basis.z * speed
    mat.set_shader_parameter("direction", -global_basis.z)
    set_physics_process(true)
    hitbox.enable()
    hurtbox.enable()

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)
    hitbox.disable()
    hurtbox.disable()