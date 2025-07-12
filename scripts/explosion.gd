extends GPUParticles3D

func _ready() -> void:
    emitting = true
    set_instance_shader_parameter("alpha_threshold", 0.0)
    var tw : Tween = create_tween()
    tw.tween_interval(0.25)
    tw.tween_property(self, "instance_shader_parameters/alpha_threshold", 1.0, 0.7)
    finished.connect(queue_free)