extends Node3D
class_name Weapon

@export var fire_rate : float = 0.1
@export var power_level : int = 1
@export var max_power_level : int = 9
@export var bullet_power : int
@export var spread_fire : bool = false
@export var is_player_weapon : bool = true
@export var is_subweapon : bool = false

var elapsed_time : float = 0.0
var can_shoot : bool = true

var disabled : bool = false

func _ready() -> void:
    if get_parent().name == "Subslot" or get_parent().name == "Subslot2":
        is_subweapon = true

func upgrade():
    if power_level >= max_power_level:
        return
    power_level += 1

func disable():
    disabled = true

func enable():
    disabled = false