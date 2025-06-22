extends Area3D

@export var actor : Node3D

func _on_area_entered(area:Area3D) -> void:
	if area is HurtBox:
		actor.queue_free()
		area.destroy()
