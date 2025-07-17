extends Node
class_name ObstacleSpawner

enum LayoutType {
    COLUMNS,
    RANDOM
}

@export var spawn_target : Node3D
@export var bunker_scene : PackedScene
@export var silo_scene : PackedScene
@export var stationary_plane_scene : PackedScene
@export var obstacle_scene : PackedScene

var x_slots : int = 6
var z_slots : int = 3

var y_pos : float = -2.0
var start_x : int = 0
var start_z : int = 5

var block_mat = preload("res://resources/materials/block.tres")

var current_z : int

var cell_size : Vector2 = Vector2.ONE * 10.0
var grid_size : Vector2i = Vector2i(6, 45)

var elevated_positions : Dictionary[Vector2i, float] = {}

func _ready() -> void:
    current_z = start_z

func create_layout():
    var noise : FastNoiseLite = FastNoiseLite.new()
    noise.seed = randi()

    for i in grid_size.x:
        for j in grid_size.y:
            if randf() > 0.03:
                continue
            var noise_value : float = (noise.get_noise_2d(i * 10, j * 10) + 1.0) * 0.5

            var block : MeshInstance3D = MeshInstance3D.new()
            block.mesh = BoxMesh.new()
            block.mesh.size = Vector3(cell_size.x, noise_value * 15.0, cell_size.y)

            block.position = Vector3(-25 + i * cell_size.x, y_pos + block.mesh.size.y * 0.5, -start_z * cell_size.y - j * cell_size.y)
            block.mesh.material = block_mat

            spawn_target.add_child.call_deferred(block)

            elevated_positions[Vector2i(i, start_z + j)] = block.mesh.size.y

    var finished : bool = false

    while !finished:
        finished = spawn_section()

func spawn_section() -> bool:
    if current_z >= grid_size.y - 8:
        return true
    if Globals.RNG.randf() < 0.2:
        return false

    else:
        var max_columns : int = Globals.RNG.randi_range(1, 2)
        var columns_in_use : Array[int] = []
        if Globals.RNG.randf() < 0.5:
            for i : int in max_columns:
                var candidate : int
                var valid : bool = false
                var attempts : int = 0
                while !valid:
                    candidate = Globals.RNG.randi_range(0, x_slots - 1)
                    if attempts >= 10:
                        break
                    valid = true
                    for used_column : int in columns_in_use:
                        if abs(candidate - used_column) <= 1:
                            valid = false
                            attempts += 1
                            break
                if valid:
                    for j : int  in range(0, 6, 2):
                        var bldg : Building 
                        if Globals.RNG.randf() < 0.5:
                            bldg = silo_scene.instantiate()
                        else:
                            bldg = stationary_plane_scene.instantiate()
                        bldg.position = Vector3(-25 + cell_size.x * candidate, y_pos, -current_z * cell_size.y - j * cell_size.y)
                        if elevated_positions.has(Vector2i(candidate, current_z + j)):
                            bldg.position.y += elevated_positions[Vector2i(candidate, current_z + j)]
                            print("On elevated")
                        spawn_target.add_child.call_deferred(bldg)
                    columns_in_use.append(candidate)
            current_z += 6

        else:
            var max_items : int = Globals.RNG.randi_range(3, 6)
            var used_positions : Array[Vector2i] = []

            for i : int in max_items:
                var candidate : Vector2i 

                var valid : bool = false
                var attempts : int = 0
                while !valid:
                    candidate = Vector2i(Globals.RNG.randi_range(0, grid_size.x), current_z + Globals.RNG.randi_range(0, 3) * 2)
                    if attempts >= 10:
                        break
                    valid = true
                    if used_positions.has(candidate):
                        valid = false  
                        attempts += 1
                if valid:
                    var bldg : Building
                    var roll : float = Globals.RNG.randf()
                    if roll < 0.1:
                        bldg = bunker_scene.instantiate()
                    elif roll < 0.75:
                        bldg = silo_scene.instantiate()
                    else:
                        bldg = stationary_plane_scene.instantiate()

                    bldg.position = Vector3(-25 + cell_size.x * candidate.x, y_pos, -cell_size.y * candidate.y)
                    if elevated_positions.has(Vector2i(candidate.x, candidate.y)):
                            bldg.position.y += elevated_positions[Vector2i(candidate.x, candidate.y)]
                            print("On elevated")

                    spawn_target.add_child.call_deferred(bldg)
                    used_positions.append(candidate)
            current_z += 6

    return false

