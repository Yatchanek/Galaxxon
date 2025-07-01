extends MeshInstance3D
class_name Tube

func _ready() -> void:
    set_physics_process(false)

func _physics_process(delta: float) -> void:
    position.z += 20.0 * delta