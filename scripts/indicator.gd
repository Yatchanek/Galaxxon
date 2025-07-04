extends MeshInstance3D

func _process(delta: float) -> void:
    global_position.y = EventBus.player.global_position.y


