extends Node3D
class_name Segment

@onready var body : MeshInstance3D = $Body

@export var length : float = 600

func _ready() -> void:
    body.scale.z = length
    body.mesh.surface_get_material(0).uv1_scale.z = length / body.scale.x
    set_physics_process(false)

func _physics_process(delta: float) -> void:
    position.z += Globals.scroll_speed * 3.0 * delta