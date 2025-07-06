extends Node
class_name ObstacleSpawner

enum LayoutType {
    COLUMNS,
    RANDOM
}

@export var spawn_target : Node3D
@export var bunker_scene : PackedScene
@export var silo_scene : PackedScene

var x_slots : int = 6
var z_slots : int = 3

var y_pos : float = sqrt(3) * 1.5
var start_x : float = 5.0

func spawn_section(start_z : float) -> float:
    var max_columns : int = randi_range(1, 3)
    var columns_in_use : Array[int] = []
    if randf() < 0.5:
        for i : int in max_columns:
            var candidate : int
            var valid : bool = false
            var attempts : int = 0
            while !valid:
                candidate = randi_range(0, x_slots - 1)
                if attempts >= 10:
                    break
                valid = true
                for used_column : int in columns_in_use:
                    if abs(candidate - used_column) <= 1:
                        valid = false
                        attempts += 1
                        break
            if valid:
                for j : int  in z_slots:
                    var silo : Silo = silo_scene.instantiate()
                    silo.position = Vector3(start_x + 10 * candidate, y_pos, start_z - 20 * j)
                    spawn_target.add_child.call_deferred(silo)
                columns_in_use.append(candidate)
        start_z -= z_slots * 20

    else:
        var max_items : int = randi_range(3, 6)
        var used_positions : Array[Vector2] = []

        for i : int in max_items:
            var candidate : Vector2 

            var valid : bool = false
            var attempts : int = 0
            while !valid:
                candidate = Vector2(randi_range(0, x_slots), randi_range(0, z_slots))
                if attempts >= 10:
                    break
                valid = true
                if used_positions.has(candidate):
                    valid = false  
                    attempts += 1
            if valid:
                var silo : Silo = silo_scene.instantiate()
                silo.position = Vector3(start_x + 10 * candidate.x, y_pos, start_z - 20 * candidate.y)
                spawn_target.add_child.call_deferred(silo)
                used_positions.append(candidate)
        start_z -= z_slots * 20

    return start_z

