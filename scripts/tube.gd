extends Node3D
class_name Segment

# @onready var body : MeshInstance3D = $Body
@onready var obstacle_spawner : ObstacleSpawner = $ObstacleSpawner

@export var length : float = 450    


var thread : Thread

var next_spawn_at : float
var current_z = -15

func _ready() -> void:
    thread = Thread.new()
    # body.scale.z = length
    # body.mesh.surface_get_material(0).uv1_scale.z = length / body.scale.x
    thread.start(create_obstacles)
    await get_tree().create_timer(0.1).timeout
    show()
   # create_obstacles()

func create_obstacles():
    obstacle_spawner.create_layout()



func _physics_process(delta: float) -> void:
    if !Engine.is_editor_hint():
        position.z += Globals.scroll_speed * 2.5 * delta
        if position.z >= 490:
            queue_free()

func _exit_tree() -> void:
    if thread.is_started():
        thread.wait_to_finish()