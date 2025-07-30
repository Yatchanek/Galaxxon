extends Node3D

@export var max_z_pos : float

func _process(delta: float) -> void:
    position.z += Globals.scroll_speed * delta * 0.75
    if position.z > 115 :
        position.z -= 300
        for child : MeshInstance3D in $Front.get_children():
            child.rotation.y = randf_range(0, PI)
            child.position.x = -50.0 + randf_range(-2, 2)
