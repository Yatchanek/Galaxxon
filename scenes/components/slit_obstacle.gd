extends Node3D
class_name SlitObstacle

@onready var body : MeshInstance3D = $Body
@onready var hurtbox : HurtBox = $Body/Hurtbox

var height : float


func _ready() -> void:
    height = randf_range(8, 18)
    body.mesh.size.y = height
    body.position.y = 20 - height * 0.5
    hurtbox.set_size(Vector3(body.mesh.size.x, body.mesh.size.y, body.mesh.size.z))


func _process(_delta: float) -> void:
    if global_position.z > 6.0:
        body.mesh.material.albedo_color.a = 0.5
        set_process(false)