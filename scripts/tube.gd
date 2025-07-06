extends Node3D
class_name Segment

@onready var body : MeshInstance3D = $Body
@onready var obstacle_spawner : ObstacleSpawner = $ObstacleSpawner

@export var length : float = 450    

var thread : Thread

var next_spawn_at : float
var current_z = -15

func _ready() -> void:
    thread = Thread.new()
    body.scale.z = length
    body.mesh.surface_get_material(0).uv1_scale.z = length / body.scale.x
    set_physics_process(false)
    create_obstacles()

func create_obstacles():
    while current_z >= -435:
        current_z = obstacle_spawner.spawn_section(current_z)
        current_z -= 40

    

func _physics_process(delta: float) -> void:
    position.z += Globals.scroll_speed * 2.0 * delta

func _exit_tree() -> void:
    if thread.is_started():
        thread.wait_to_finish()