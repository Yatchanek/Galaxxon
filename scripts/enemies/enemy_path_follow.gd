extends PathFollow3D
class_name EnemyPathFollow

var speed : float
var max_distance : float

var inverse : bool = false

var direction : int = 1

func _ready() -> void:
    if get_parent().inverse:
        inverse = true
        direction = -1
        progress_ratio = 1.0

func _physics_process(delta: float) -> void:
    progress_ratio += direction * 1.0 / speed * delta
    if (!inverse and progress_ratio > 0.999) or (inverse and progress_ratio < 0.005):
        queue_free()
