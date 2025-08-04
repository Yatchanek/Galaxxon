extends Node3D
class_name Segment

@export var length : int = 500
@export var bunker_scene : PackedScene
@export var silo_scene : PackedScene
@export var stationary_plane_scene : PackedScene
@export var obstacle_scene : PackedScene
@export var hole_obstacle_scene : PackedScene
@export var block_scene : PackedScene
@export var mountain_meshes : Array[ArrayMesh] = []

signal obstacles_placed

enum ObstacleTypes {
    NORMAL_OBSTACLE,
    HIGH_OBSTACLE,
    WALL,
    NOTHING
}

var thread : Thread
var grid_size : Vector2i
var cell_size : Vector2i = Vector2(10, 15)

var obstacle_grid : PackedInt32Array = []

var y_pos : float = 10.0

var signal_sent : bool = false
var exit_signal_sent : bool = false

var current_z : int

func initialize():
    current_z = 0
    grid_size = Vector2i(60 / cell_size.x, (length - 10 * cell_size.y) / cell_size.y)
    obstacle_grid.resize(grid_size.x * grid_size.y)
    obstacle_grid.fill(ObstacleTypes.NOTHING)
    thread = Thread.new()
    thread.start(create_obstacles)

func _ready() -> void:
    await get_tree().create_timer(0.1).timeout
    show()

func create_mountains():
    var current_z : float = 0.0
    while current_z >= -500:
        var mountain : MeshInstance3D = MeshInstance3D.new()
        mountain.scale *= 2.0
        mountain.mesh = mountain_meshes.pick_random()
        mountain.position.x = randf_range(-2, 2)
        mountain.position.z = current_z
        mountain.rotate_y(randf_range(0, TAU))
        $Land/Front.add_child(mountain)
        current_z -= 15

    current_z = 0.0
    while current_z >= -560:
        var mountain : MeshInstance3D = MeshInstance3D.new()
        mountain.scale *= 3.0
        mountain.mesh = mountain_meshes.pick_random()
        mountain.position.x = randf_range(-2, 2)
        mountain.position.z = current_z
        mountain.rotate_y(randf_range(0, TAU))
        $Land/Back.add_child(mountain)
        current_z -= 30
    obstacles_placed.emit()


func create_obstacles():
    var row : int = 0
    while row < grid_size.y:
        var roll : float = Globals.RNG.randf()
        if roll < 0.05:
            row += 2
            roll = Globals.RNG.randf()
            var obstacle : Node3D
            if roll < 0.9:
                obstacle = obstacle_scene.instantiate()
            else:
                obstacle = hole_obstacle_scene.instantiate()
  
            obstacle.position = Vector3(-30, 10, -65 -cell_size.y * (5 + row))
            add_child(obstacle)     
            row += 3
        elif roll < 0.6:
            var items_in_row : int = 1
            roll = Globals.RNG.randf()
            if roll < 0.025:
                items_in_row = 3
            elif roll < 0.1:
                items_in_row = 2
            var slots : Array = range(0, grid_size.x)
            for i in items_in_row:
                roll = Globals.RNG.randf()
                var idx : int = Globals.RNG.randi_range(0, slots.size() - 1)
                var x_coord : int = slots[idx]
                slots.remove_at(idx)
                var bldg : Building
                roll = Globals.RNG.randf()
                if roll < 0.15:
                    bldg = bunker_scene.instantiate()
                elif roll < 0.65:
                    bldg = silo_scene.instantiate()
                else:
                    bldg = stationary_plane_scene.instantiate()
                if row > 0:
                    while obstacle_grid[(row - 1) * grid_size.x + x_coord] == ObstacleTypes.HIGH_OBSTACLE or obstacle_grid[(row - 1) * grid_size.x + x_coord] == ObstacleTypes.WALL:
                        idx = Globals.RNG.randi_range(0, slots.size() - 1)
                        x_coord = slots[idx]
                        slots.remove_at(idx)

                bldg.position = Vector3(-30 + cell_size.x * (x_coord + 0.5), y_pos, -65 - cell_size.y * (5 + row))
                obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.NORMAL_OBSTACLE
                roll = Globals.RNG.randf()

                add_child(bldg)

            row += 1            
    create_mountains()


func spawn_block(x_coord : int, row : int) -> float:
    var block : Block = block_scene.instantiate()
    var height : float = Globals.RNG.randf_range(5, 15)
    
    block.initialize(height)
    block.position = Vector3(-30 + cell_size.x * (x_coord + 0.5), y_pos, -cell_size.y * (5 + row))
    #prints("Block height", height, "Block position", block.position)
    obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.WALL
    add_child(block)
    
    return height

func _physics_process(delta: float) -> void:
    if !Engine.is_editor_hint():
        position.z += Globals.scroll_speed * delta
        if position.z >= -20 and !signal_sent:
            print("Entered")
            EventBus.tube_entered.emit()
            signal_sent = true
        if position.z >= 575 and !exit_signal_sent:
            EventBus.tube_end_reached.emit()
            exit_signal_sent = true
        if position.z >= 650:
            queue_free()

func _exit_tree() -> void:
    if thread.is_started():
        thread.wait_to_finish()