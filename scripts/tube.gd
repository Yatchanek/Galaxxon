extends MeshInstance3D

@onready var mat : StandardMaterial3D = mesh.surface_get_material(0)


func _process(delta: float) -> void:
    mat.uv1_offset.z -= 0.2 * delta