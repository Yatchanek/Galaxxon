extends Weapon
class_name LaserWeapon

@onready var hurtbox : HurtBox = $Hurtbox
@onready var laser : MeshInstance3D = $Laser
@onready var raycast : RayCast3D = $RayCast3D


@export var laser_colors : Array[Color] = []

var is_shooting : bool = false

var base_damage : float = 3

var previous_dist : float

var base_segment_length : float

var laser_radius : float = 0.5
var was_colliding : bool = true

func _ready() -> void:
    super()
    hurtbox.damage = power_level * base_damage
    if is_subweapon:
        laser.mesh.radius = 0.25
        hurtbox.damage *= 0.5
    max_power_level = 3
    laser.hide()
    hurtbox.disable()
    raycast.enabled = false
    base_segment_length = laser.mesh.section_length
    laser.set_instance_shader_parameter("laser_color", laser_colors[power_level - 1])

func upgrade():
    if power_level >= max_power_level:
        return
    power_level += 1
    laser.set_instance_shader_parameter("laser_color", laser_colors[power_level - 1])
    hurtbox.damage = power_level * base_damage
    if is_subweapon:
        hurtbox.damage *= 0.5
    hurtbox.set_size(Vector3(laser_radius, laser_radius, hurtbox.collision_shape.shape.size.z))

func _process(delta: float) -> void:
    if is_player_weapon:
        if Input.is_action_just_pressed("ui_accept"):
            shoot()
        if Input.is_action_just_released("ui_accept"):
            stop()

    if is_shooting:
        var dist : float
        if raycast.is_colliding():
            var hit_pos : Vector3 = raycast.get_collision_point()
            dist = global_position.z - hit_pos.z

        if !is_equal_approx(dist, previous_dist):
            previous_dist = dist
            laser.mesh.sections = clamp(dist / 10.0, 10, 20)
            laser.mesh.section_length = dist / laser.mesh.sections
            laser.position.z = - dist * 0.5
            hurtbox.set_size(Vector3(laser_radius, laser_radius, dist))
            hurtbox.position.z = -dist * 0.5




func stop():
    is_shooting = false
    laser.hide()
    hurtbox.disable()    
    raycast.enabled = false
    

func shoot():
    if disabled:
        return
    is_shooting = true
    laser.show()
    hurtbox.enable()    
    raycast.enabled = true
    
