extends Node3D
class_name Bullet

@onready var hurtbox : HurtBox = $Hurtbox
@onready var body : MeshInstance3D = $Body

@export var base_damage : int = 1
var velocity : Vector3
var speed : float = 75

var power_level : int = 1

var body_colors : PackedColorArray = [Color(0.0, 3.0, 0.0, 1.0), Color(3.0, 3.0, 0.0, 1.0), Color(3.0, 0.0, 0.0, 1.0)]

func _ready() -> void:
    set_physics_process(false)


func _physics_process(delta: float) -> void:
    position += velocity * delta

    if position.x < -30 or position.x > 30 or position.z > 2 or position.z < -45:
        return_to_pool()


func set_damage():
    hurtbox.damage = base_damage * power_level
    body.set_instance_shader_parameter("body_color", body_colors[power_level - 1])

func adjust_collision(is_player_bullet : bool):
    if is_player_bullet:
        hurtbox.collision_layer = 16
    else:
        hurtbox.collision_layer = 32

func return_to_pool():
    BulletPool.return_to_pool(self)

func start():
    velocity = -global_basis.z * speed
    set_physics_process(true)

func stop():
    velocity = Vector3.ZERO
    set_physics_process(false)