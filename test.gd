@tool
extends Node3D

@onready var path : Path3D = $Path3D

var num_points : int
var elapsed_time : float = 0.0


var base_in_points : Array[Vector3] = []
var base_out_points : Array[Vector3] = []

func _ready() -> void:
    num_points = path.curve.point_count
