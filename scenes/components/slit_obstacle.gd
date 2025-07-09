@tool
extends Node3D
class_name SlitObstacle

@onready var upper_body : MeshInstance3D = $UpperBody
@onready var upper_hurtbox : HurtBox = $UpperBody/Hurtbox
@onready var bottom_body : MeshInstance3D = $BottomBody
@onready var bottom_hurtbox : HurtBox = $BottomBody/Hurtbox
@onready var upper_collision : CollisionShape3D = $Body/UpperCollision
@onready var bottom_collision : CollisionShape3D = $Body/BottomCollision


const mesh_scale : float = 15.0
var slit_height : float = 6.0
var slit_position : float
var total_height : float = (1.5 - sqrt(3) * 0.1) * mesh_scale
var top_pos : float = 1.5 * mesh_scale
var bottom_pos : float = sqrt(3) * 0.1 * mesh_scale

func _ready() -> void:
    set_process(false)
    slit_position = Globals.RNG.randf_range(slit_height * 0.5, total_height - slit_height * 0.5)
    if is_equal_approx(slit_position, slit_height * 0.5):
        upper_body.hide()
        upper_hurtbox.disable()
    elif is_equal_approx(slit_position, total_height - slit_height * 0.5):
        bottom_body.hide()
        bottom_hurtbox.disable()

    upper_body.mesh.size.y = slit_position - slit_height * 0.5
    upper_body.position.y = top_pos - upper_body.mesh.size.y * 0.5
    upper_collision.shape.size = upper_body.mesh.size
    upper_collision.position = upper_body.position

    bottom_body.mesh.size.y = total_height - slit_position - slit_height * 0.5
    bottom_body.position.y = bottom_pos + bottom_body.mesh.size.y * 0.5
    bottom_collision.shape.size = bottom_body.mesh.size
    bottom_collision.position = bottom_body.position

    if !Engine.is_editor_hint():
        upper_hurtbox.set_size(upper_body.mesh.size)
        bottom_hurtbox.set_size(bottom_body.mesh.size)
        set_process(true)


func _process(_delta: float) -> void:
    if global_position.z > 6.0:
        upper_body.mesh.material.albedo_color.a = 0.5
        set_process(false)