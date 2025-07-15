extends Area3D
class_name HurtBox

enum DamageType {
    SINGLE,
    CONTINUOUS
}

@export var damage : float = 1.0
@export var damage_type : DamageType = DamageType.SINGLE
@export var damage_interval : float = 0.1 
@export var actor : Node3D
@export var instadeath : bool = false

@onready var collision_shape : CollisionShape3D = $CollisionShape3D

var switched_off : bool = false


func _ready() -> void:
    if !actor:
        actor = get_parent()

func destroy():
    if actor is Projectile and !actor is SonicWave:
        actor.return_to_pool()

func set_size(size : Vector3):
    collision_shape.shape.size = size

func disable():
    $CollisionShape3D.set_deferred("disabled", true)


func enable():
    $CollisionShape3D.set_deferred("disabled", false)
