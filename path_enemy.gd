extends PathFollow3D
class_name PathEnemy

var speed : float
var max_distance : float

func _physics_process(delta: float) -> void:
    progress += speed * delta
    if progress > max_distance * 0.95:
        queue_free()