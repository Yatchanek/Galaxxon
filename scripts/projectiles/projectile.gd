extends Node3D
class_name Projectile

@onready var hurtbox : HurtBox = $Hurtbox
@onready var hitbox : HitBox = $Hitbox
@onready var body : MeshInstance3D = $Body

@export var base_damage : int = 1
@export var speed : float = 75
@export var from_sub_weapon : bool = false

var velocity : Vector3
var power_level : int = 1
var prev_power_level : int = 1

var type : BulletPool.BulletType


func adjust_collision(is_player_bullet : bool):
    if is_player_bullet:
        hurtbox.collision_layer = 32
    else:
        hurtbox.collision_layer = 64


func initialize(_type : BulletPool.BulletType, _speed : float, _power_level : int, is_player_bullet : bool, _from_sub_weapon : bool):
    type = _type
    speed = _speed
    
    from_sub_weapon = _from_sub_weapon
    if from_sub_weapon:
        for child in get_children():
            if child is MeshInstance3D:
                child.scale = Vector3.ONE * 0.5
    else:
        for child in get_children():
            if child is MeshInstance3D:
                child.scale = Vector3.ONE

    adjust_collision(is_player_bullet)
    if power_level != _power_level:
        prev_power_level = power_level
        power_level = _power_level
    set_damage()


func set_damage():
    hurtbox.damage = base_damage * power_level * 10
    if from_sub_weapon:
        hurtbox.damage *= 0.5

func return_to_pool():
    BulletPool.return_to_pool(self)