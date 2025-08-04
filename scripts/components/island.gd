extends Node3D
class_name Island

@export var meshes : Array[ArrayMesh] = []

@onready var body : MeshInstance3D = $Body

func _ready() -> void:
    body.mesh = meshes[Globals.RNG.randi_range(0, meshes.size() - 1)]
    rotation.y = Globals.RNG.randf_range(0, TAU)

func _process(delta: float) -> void:
    position.z += Globals.scroll_speed * delta
    if position.z >= 40:
        queue_free()