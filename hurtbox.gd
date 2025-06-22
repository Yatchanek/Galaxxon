extends Area3D
class_name HurtBox

@export var damage : int = 1

@export var actor : Node3D

func _ready() -> void:
    if !actor:
        actor = get_parent()

func destroy():
    if actor is Bullet:
        actor.return_to_pool()