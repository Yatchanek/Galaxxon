extends Node3D
class_name Projectile

@onready var hurtbox : HurtBox = $Hurtbox
@onready var body : MeshInstance3D = $Body

@export var base_damage : int = 1

@export var speed : float = 75

var velocity : Vector3
var power_level : int = 1

var type : BulletPool.BulletType


func adjust_collision(is_player_bullet : bool):
    if is_player_bullet:
        hurtbox.collision_layer = 32
    else:
        hurtbox.collision_layer = 64

func return_to_pool():
    BulletPool.return_to_pool(self)