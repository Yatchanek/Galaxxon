extends Node3D

@export var max_z_pos : float

func _process(delta: float) -> void:
    position.z += Globals.scroll_speed * delta * 0.75
    if position.z > 115 :
        position.z -= 300  

