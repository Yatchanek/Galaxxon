extends Node3D
class_name Segment

@export var length : int = 450    
@export var bunker_scene : PackedScene
@export var silo_scene : PackedScene
@export var stationary_plane_scene : PackedScene
@export var obstacle_scene : PackedScene
@export var hole_obstacle_scene : PackedScene
@export var block_scene : PackedScene

signal obstacles_placed

enum ObstacleTypes {
    NORMAL_OBSTACLE,
    HIGH_OBSTACLE,
    WALL,
    NOTHING
}

var thread : Thread
var grid_size : Vector2i
var cell_size : Vector2i = Vector2(10, 10)

var obstacle_grid : PackedInt32Array = []

var y_pos : float = -2.0

var current_z : int

func initialize():
    current_z = 0
    grid_size = Vector2i(60 / cell_size.x, (length - 10 * cell_size.y) / cell_size.y)
    prints("Grid size:", grid_size)
    obstacle_grid.resize(grid_size.x * grid_size.y)
    obstacle_grid.fill(ObstacleTypes.NOTHING)
    thread = Thread.new()
    thread.start(create_obstacles)
    

func _ready() -> void:
    await get_tree().create_timer(0.1).timeout
    show()

func create_obstacles():
    var row : int = 0
    while row < grid_size.y:
        var roll : float = Globals.RNG.randf()
        if roll < 0.1:
            row += 2
            if Globals.RNG.randf() < 0.5:
                var obstacle : SlitObstacle = obstacle_scene.instantiate()
                obstacle.position = Vector3(-30, -5, -cell_size.y * (5 + row))
                add_child(obstacle)
            else:
                var obstacle : MovingHoleObstacle = hole_obstacle_scene.instantiate()
                obstacle.position = Vector3(-30, -5, -cell_size.y * (5 + row))
                add_child(obstacle)
            row += 3

        elif roll < 0.45:
            roll = Globals.RNG.randf()
            var items_in_row : int = 1
            if roll < 0.025:
                items_in_row = 3
            elif roll < 0.1:
                items_in_row = 2
            var slots : Array = range(0, grid_size.x)
            for i in items_in_row:
                roll = Globals.RNG.randf()
                var idx : int = Globals.RNG.randi_range(0, slots.size() - 1)
                var x_coord : int = slots[idx]
                if roll < 0.75:
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

                    bldg.position = Vector3(-30 + cell_size.x * (x_coord + 0.5), y_pos, -cell_size.y * (5 + row))
                    obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.NORMAL_OBSTACLE
                    roll = Globals.RNG.randf()
                    if roll < 0.15:
                        var height : float = spawn_block(x_coord, row)
                        bldg.position.y += height
                        obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.HIGH_OBSTACLE
                        prints("Building on block of height", height, ", y position", bldg.position.y)
                    add_child(bldg)
                else:
                    spawn_block(x_coord, row)
                    obstacle_grid[row * grid_size.x + x_coord] = ObstacleTypes.WALL
        row += 1            

    obstacles_placed.emit()


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
        position.z += Globals.scroll_speed * 3.0 * delta
        if position.z >= 490:
            queue_free()

func _exit_tree() -> void:
    if thread.is_started():
        thread.wait_to_finish()