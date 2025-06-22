extends Node3D
class_name Bullet

@onready var hurtbox : HurtBox = $Hurtbox

var velocity : Vector3
var speed : float = 75



func _ready() -> void:
    set_physics_process(false)


func _physics_process(delta: float) -> void:
    position += velocity * delta

    if position.x < -40 or position.x > 40 or position.z > 2 or position.z < -40:
        return_to_pool()


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