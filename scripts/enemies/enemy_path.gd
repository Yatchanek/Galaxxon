@tool
extends Path3D
class_name EnemyPath

@export var point_num : int = 3
@export var randomized : bool = false

@export var start : int = 40
@export var end : int = -40

var can_spawn : bool = true

var inverse : bool = false

func _ready() -> void:
    redraw()

func redraw():
    inverse = Globals.RNG.randf() < 0.5
    point_num = Globals.RNG.randi_range(3, 6)
    var width : float = start - end

    var min_x : float
    var max_x : float
    var min_z : float = 8
    var max_z : float = 12

    var interval : float = width / (point_num + 1)

    max_x = interval * 0.4
    min_x = max_x * 0.75

    if point_num > 1:
        var diff : int = point_num - 1
        min_z = min(min_z - diff, 5)
        max_z = max(max_z - diff, 10)

    curve = Curve3D.new()
    curve.add_point(Vector3(40, 0, 0))
    
    var default_point : Vector3 = Vector3(Globals.RNG.randf_range(min_x, max_x), 0, Globals.RNG.randf_range(-min_z, -max_z))
    for i : int in range(1, point_num + 1):
        curve.add_point(Vector3(40 - interval * i, 0, 0))
        var point_in : Vector3
        if i % 2 == 1:
            point_in = default_point
            curve.set_point_tilt(i, PI / 8)
        else:
            point_in = Vector3(default_point.x, default_point.y, -default_point.z)
            curve.set_point_tilt(i, -PI / 8)

        curve.set_point_in(i, point_in)
        curve.set_point_out(i, -point_in)     

        if randomized:
            point_in = Vector3(Globals.RNG.randf_range(min_x, max_x), 0, Globals.RNG.randf_range(-min_z, -max_z))

    curve.add_point(Vector3(-40, 0, 0))


func _on_enemy_exited():
    if get_child_count() == 0:
        can_spawn = true